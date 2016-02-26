//
//  XMPPChatMesageCoreDataStorage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPMessageCoreDataStorage.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPMessageCoreDataStorageObject.h"
#import "XMPPMessageHistoryCoreDataStorageObject.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "NSNumber+XMPP.h"
#import "XMPPAllMessage.h"
#import "XMPPAllMessageQueryModule.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
                            do { \
                                    _Pragma("clang diagnostic push") \
                                    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
                                    Stuff; \
                                    _Pragma("clang diagnostic pop") \
                                } while (0)


#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_INFO; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

#define AssertPrivateQueue() \
NSAssert(dispatch_get_specific(storageQueueTag), @"Private method: MUST run on storageQueue");

@interface XMPPMessageCoreDataStorage () <XMPPAllMessageStorage, XMPPAllMessageQueryModuleStorage>
{

}
@end

@implementation XMPPMessageCoreDataStorage
static XMPPMessageCoreDataStorage *sharedInstance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[XMPPMessageCoreDataStorage alloc] initWithDatabaseFilename:nil storeOptions:nil];
    });
    
    return sharedInstance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)commonInit
{
    XMPPLogTrace();
    [super commonInit];
    
    // This method is invoked by all public init methods of the superclass
    autoRemovePreviousDatabaseFile = YES;
    autoRecreateDatabaseFile = YES;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Tool methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public API (XMPPAllMessageStorage Methods)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)configureWithParent:(XMPPAllMessage *)aParent queue:(dispatch_queue_t)queue
{
    return [super configureWithParent:aParent queue:queue];
}

- (void)archiveMessage:(XMPPExtendMessage *)message
                active:(BOOL)active
            xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *myBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        if ([XMPPMessageCoreDataStorageObject updateOrInsertObjectInManagedObjectContext:moc
                                                                                  active:active
                                                                       xmppExtendMessage:message
                                                                        streamBareJidStr:myBareJidStr]) {
            // do nothing
        }
    }];
}

//When read the message ,we should -1 for the unread message table
- (void)readMessageWithMessage:(XMPPMessageCoreDataStorageObject *)message xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        
        [message setBeenRead:@(YES)];
    
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        [XMPPMessageHistoryCoreDataStorageObject readOneObjectInManagedObjectContext:moc
                                                                          bareJidStr:message.bareJidStr
                                                                    streamBareJidStr:message.streamBareJidStr];
        
    }];
}

//we should -1 to the unread message table
- (void)readMessageWithMessageID:(NSString *)messageID xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        if (xmppStream){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"msgId == %@ && \
                                                                        streamBareJidStr == %@",
                                                                          messageID,
                                                                          streamBareJidStr];
            
            XMPPMessageCoreDataStorageObject *updateObject = [XMPPMessageCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                  predicate:predicate];
            if (!updateObject) return;
            
            [updateObject setBeenRead:@(YES)];
            [XMPPMessageHistoryCoreDataStorageObject readOneObjectInManagedObjectContext:moc
                                                                         bareJidStr:updateObject.bareJidStr
                                                                       streamBareJidStr:updateObject.streamBareJidStr];
        }
    }];
}

- (void)readAllUnreadMessageWithBareUserJid:(NSString *)bareUserJid xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        // Note: Deleting a user will delete all associated resources
        // because of the cascade rule in our core data model.
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([XMPPMessageCoreDataStorageObject class])
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate;
            //!!!!:Notice:This method should not read the voice message
            predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ && \
                                                            streamBareJidStr == %@ && \
                                                            outgoing == %@ && \
                                                            beenRead == %@ &&   \
                                                            msgType != %@",
                                                            bareUserJid,
                                                            streamBareJidStr,
                                                            @0,
                                                            @0,
                                                            @(XMPPExtendSubMessageAudioType)];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allMessages = [moc executeFetchRequest:fetchRequest error:nil];
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPMessageCoreDataStorageObject *message in allMessages){

            //update the hasBeenRead attribute
            message.beenRead = @(YES);
            
            if (++unsavedCount >= saveThreshold){
                [self save];
                unsavedCount = 0;
            }
        }
        
        //Update the unread message object
        [XMPPMessageHistoryCoreDataStorageObject readObjectInManagedObjectContext:moc
                                                                       bareJidStr:bareUserJid
                                                                 streamBareJidStr:streamBareJidStr];

    }];
}

//When there is only one message ,we should delete the unread message history
- (void)deleteMessageWithMessageID:(NSString *)messageID xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        if (xmppStream){
            
            XMPPMessageCoreDataStorageObject *updateObject = [XMPPMessageCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                      msgId:messageID
                                                                                                           streamBareJidStr:streamBareJidStr];
            if (!updateObject) return;
        
            //The all message count
            NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([XMPPMessageCoreDataStorageObject class])
                                                      inManagedObjectContext:moc];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ && \
                                                                        streamBareJidStr == %@",
                                                                        updateObject.bareJidStr,
                                                                        updateObject.streamBareJidStr];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:entity];
            [fetchRequest setFetchLimit:2];
            [fetchRequest setPredicate:predicate];
            [fetchRequest setFetchBatchSize:saveThreshold];
            
            NSArray *allMessages = [moc executeFetchRequest:fetchRequest error:nil];
            
            //When the all message count is only one,we should delete the chat history
            if ([allMessages count] < 2) {
                [XMPPMessageHistoryCoreDataStorageObject deleteObjectInManagedObjectContext:moc
                                                                                 bareJidStr:updateObject.bareJidStr
                                                                          streamBareJidStr:streamBareJidStr];
            }
            
            //Delete the message
            [moc deleteObject:updateObject];
        }

    }];
}

//When there is only one message ,we should delete the unread message history
- (void)deleteMessageWithMessage:(XMPPMessageCoreDataStorageObject *)message xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        //The all message count
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([XMPPMessageCoreDataStorageObject class])
                                                  inManagedObjectContext:moc];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr== %@ && \
                                                                    streamBareJidStr == %@",
                                                                      message.bareJidStr,
                                                                      message.streamBareJidStr];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchLimit:2];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        NSArray *allMessages = [moc executeFetchRequest:fetchRequest error:nil];
        
        //When the all message count is only one,we should delete the chat history
        if ([allMessages count] < 2) {
            [XMPPMessageHistoryCoreDataStorageObject deleteObjectInManagedObjectContext:moc
                                                                             bareJidStr:message.bareJidStr
                                                                      streamBareJidStr:streamBareJidStr];
        }
        
        //Delete the message
        [moc deleteObject:message];
    }];
}

- (void)clearChatHistoryWithBareUserJid:(NSString *)bareUserJid
                             xmppStream:(XMPPStream *)stream
                        completionBlock:(void (^_Nullable)(NSString *bareJidStr))completionBlock
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([XMPPMessageCoreDataStorageObject class])
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ && \
                                                            streamBareJidStr == %@",
                                                             bareUserJid,
                                                             streamBareJidStr];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allMessages = [moc executeFetchRequest:fetchRequest error:nil];
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPMessageCoreDataStorageObject *message in allMessages){
            [moc deleteObject:message];
            
            if (++unsavedCount >= saveThreshold){
                [self save];
                unsavedCount = 0;
            }
        }
        //Delete the unread message object
        [XMPPMessageHistoryCoreDataStorageObject deleteObjectInManagedObjectContext:moc
                                                                         bareJidStr:bareUserJid
                                                                   streamBareJidStr:streamBareJidStr];
        
        if (completionBlock != NULL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock([bareUserJid copy]);
            });
        }
    }];
}

- (void)clearAllChatHistoryAndMessageWithXMPPStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        NSEntityDescription *messageEntity = [NSEntityDescription entityForName:NSStringFromClass([XMPPMessageCoreDataStorageObject class])
                                                         inManagedObjectContext:moc];
        NSEntityDescription *historyEntity = [NSEntityDescription entityForName:NSStringFromClass([XMPPMessageHistoryCoreDataStorageObject class])
                                                         inManagedObjectContext:moc];
        
        NSFetchRequest *messageFetchRequest = [[NSFetchRequest alloc] init];
        NSFetchRequest *historyFetchRequest = [[NSFetchRequest alloc] init];
        
        [messageFetchRequest setEntity:messageEntity];
        [messageFetchRequest setFetchBatchSize:saveThreshold];
        
        [historyFetchRequest setEntity:historyEntity];
        [historyFetchRequest setFetchBatchSize:saveThreshold];
        
        if (xmppStream){
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@",streamBareJidStr];
            
            [messageFetchRequest setPredicate:predicate];
            [historyFetchRequest setPredicate:predicate];
        }
        
        NSArray *allMessages = [moc executeFetchRequest:messageFetchRequest error:nil];
        NSArray *allChatHistorys = [moc executeFetchRequest:historyFetchRequest error:nil];
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPMessageCoreDataStorageObject *message in allMessages){
            [moc deleteObject:message];
            
            if (++unsavedCount >= saveThreshold){
                [self save];
                unsavedCount = 0;
            }
        }
        
        for (XMPPMessageHistoryCoreDataStorageObject *history in allChatHistorys){
            [moc deleteObject:history];
            
            if (++unsavedCount >= saveThreshold){
                [self save];
                unsavedCount = 0;
            }
        }
    }];
}
- (void)updateMessageSendStatusWithMessageID:(NSString *)messageID
                                 sendSucceed:(XMPPMessageSendState)sendType
                                  xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        if (xmppStream){
            
            XMPPMessageCoreDataStorageObject *updateObject = [XMPPMessageCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                      msgId:messageID
                                                                                                           streamBareJidStr:streamBareJidStr];
            if (!updateObject) return;
            
            [updateObject setSendState:@(sendType)];
        }

    }];
}
- (void)updateMessageSendStatusWithMessage:(XMPPMessageCoreDataStorageObject *)message
                                   success:(BOOL)success
                                xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        [message setSendState:@(success)];
    }];
}

- (void)updateMessageWithNewFilePath:(NSString *)newFilePath
                           messageID:(NSString *)messageID
                          xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        if (xmppStream){
            
            XMPPMessageCoreDataStorageObject *updateObject = [XMPPMessageCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                      msgId:messageID
                                                                                                           streamBareJidStr:streamBareJidStr];
            if (!updateObject) return;
            
            id object = updateObject.subData;
            
            SEL selectorSetFilePath = NSSelectorFromString(@"setFilePath:");
            SEL selectorSetFileData = NSSelectorFromString(@"setFileData:");
            
            if ([object  respondsToSelector:selectorSetFilePath]) {
                
                SuppressPerformSelectorLeakWarning(
                    [object performSelector:selectorSetFilePath withObject:newFilePath];
                );
                
            }
            
            if ([object  respondsToSelector:selectorSetFileData]) {
                
                SuppressPerformSelectorLeakWarning(
                                                   [object performSelector:selectorSetFileData withObject:nil];
                );
            }

        }

    }];
}

- (id)lastMessageWithBareJidStr:(NSString *)bareJidStr xmppStream:(XMPPStream *)xmppStream
{
    if (!bareJidStr || !xmppStream) return nil;
    
    __block id result = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([XMPPMessageCoreDataStorageObject class])
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"msgTime" ascending:YES];
       
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (xmppStream){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ && \
                                                                        streamBareJidStr == %@",
                                                                        bareJidStr,
                                                                        streamBareJidStr];
        
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allMessages = [moc executeFetchRequest:fetchRequest error:nil];
        
        result = (XMPPMessageCoreDataStorageObject *)[allMessages lastObject];
    }];
    
    return result;
}

- (NSArray *)fetchMessagesWithBareJidStr:(NSString *)bareJidStr
                               fetchSize:(NSInteger)fetchSize
                             fetchOffset:(NSInteger)fetchOffset
                              xmppStream:(XMPPStream *)xmppStream
{
    if (bareJidStr == nil || xmppStream == nil) return nil;
    
    __block NSArray *results = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([XMPPMessageCoreDataStorageObject class])
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"msgTime" ascending:NO];
        
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchLimit:fetchSize];
        [fetchRequest setFetchOffset:fetchOffset];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (xmppStream){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ && \
                                                                        streamBareJidStr == %@",
                                                                        bareJidStr,
                                                                        streamBareJidStr];
            
            [fetchRequest setPredicate:predicate];
        }
        
        results = [moc executeFetchRequest:fetchRequest error:nil];
    }];
    
    return results;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPAllMessageQueryModuleStorage
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)messageSendStateWithID:(NSString *)messageID xmppStream:(XMPPStream *)stream
{
    __block NSInteger result = 0;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([XMPPMessageCoreDataStorageObject class])
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchLimit:1];
        
        if (stream)
        {
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"msgId == %@ && \
                                                            streamBareJidStr == %@",
                                                            messageID,
                                                            [[self myJIDForXMPPStream:stream] bare]];
            
            [fetchRequest setPredicate:predicate];
        }
        
        XMPPMessageCoreDataStorageObject *message = [[moc executeFetchRequest:fetchRequest error:nil] lastObject];
        
        if (message) result = [message.sendState integerValue];
    }];
    
    return result;
}
- (id)messageWithID:(NSString *)messageID xmppStream:(XMPPStream *)stream
{
    __block XMPPMessageCoreDataStorageObject *result = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([XMPPMessageCoreDataStorageObject class])
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchLimit:1];
        
        if (stream)
        {
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"msgId== %@ && \
                                                            streamBareJidStr == %@",
                                                            messageID,
                                                            [[self myJIDForXMPPStream:stream] bare]];
            
            [fetchRequest setPredicate:predicate];
        }
        
        XMPPMessageCoreDataStorageObject *message = [[moc executeFetchRequest:fetchRequest error:nil] lastObject];
        
        if (message) result = message;
    }];
    
    return result;
}

- (void)setAllSendingStateMessagesToFailureStateWithXMPPStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([XMPPMessageCoreDataStorageObject class])
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ && \
                                                                        outgoing == %@ && \
                                                                        sendState == %@",
                                                                        streamBareJidStr,
                                                                        @(YES),
                                                                        @(0)];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allSendingStateMessages = [moc executeFetchRequest:fetchRequest error:nil];
        
        [allSendingStateMessages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            XMPPMessageCoreDataStorageObject *message = obj;
            
            message.sendState = @(XMPPMessageSendFailed);
        }];
    }];

}
- (id)allSendingStateMessagesWithXMPPStream:(XMPPStream *)stream
{
    __block NSArray *allSendingStateMessages = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([XMPPMessageCoreDataStorageObject class])
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"msgTime" ascending:YES];
        
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ && \
                                                                        outgoing == %@ && \
                                                                        sendState == %@",
                                                                        streamBareJidStr,
                                                                        @(YES),
                                                                        @(0)];
            
            [fetchRequest setPredicate:predicate];
        }
        
        allSendingStateMessages = [moc executeFetchRequest:fetchRequest error:nil];
    }];
    
    return allSendingStateMessages;
}

- (void)stopUpdatingMessageHistoryWithBareJidStr:(NSString *)bareJidStr xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        XMPPMessageHistoryCoreDataStorageObject *messageHistory = [XMPPMessageHistoryCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                             bareJidStr:bareJidStr
                                                                                                                       streamBareJidStr:streamBareJidStr];
        if (messageHistory) messageHistory.hasBeenEnd = @(YES);
    }];

}

@end
