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
#import "XMPPUnReadMessageCoreDataStorageObject.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "NSNumber+XMPP.h"
#import "XMPPMessage+AdditionMessage.h"

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
#pragma mark Public API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#pragma mark -
#pragma mark - XMPPAllMessageStorage Methods
- (BOOL)configureWithParent:(XMPPAllMessage *)aParent queue:(dispatch_queue_t)queue
{
    return [super configureWithParent:aParent queue:queue];
}

- (void)archiveMessage:(XMPPMessage *)message sendFromMe:(BOOL)sendFromMe activeUser:(NSString *)activeUser xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *myBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        [XMPPMessageCoreDataStorageObject updateOrInsertObjectInManagedObjectContext:moc
                                                               withMessageDictionary:[message toDictionaryWithSendFromMe:sendFromMe activeUser:activeUser]
                                                                    streamBareJidStr:myBareJidStr];
        
    }];
}

- (void)readAllUnreadMessageWithBareUserJid:(NSString *)bareUserJid xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        // Note: Deleting a user will delete all associated resources
        // because of the cascade rule in our core data model.
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate;
            //!!!!:Notice:This method should not read the voice message
            predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@ && %K == %@ && %K != %@",@"bareJidStr",bareUserJid,@"streamBareJidStr",
                         streamBareJidStr,@"hasBeenRead",@0,@"messageType",@1];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allMessages = [moc executeFetchRequest:fetchRequest error:nil];
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPMessageCoreDataStorageObject *message in allMessages){
            //[moc deleteObject:message];
            //update the hasBeenRead attribute
            message.hasBeenRead = [NSNumber numberWithBool:YES];
            
            if (++unsavedCount >= saveThreshold){
                [self save];
                unsavedCount = 0;
            }
        }
        //Update the unread message object
        [XMPPUnReadMessageCoreDataStorageObject readObjectInManagedObjectContext:moc withUserJIDstr:bareUserJid streamBareJidStr:streamBareJidStr];

    }];
}

- (void)clearChatHistoryWithBareUserJid:(NSString *)bareUserJid xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@",@"bareJidStr",bareUserJid,@"streamBareJidStr",
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
        [XMPPUnReadMessageCoreDataStorageObject deleteObjectInManagedObjectContext:moc withUserJIDstr:bareUserJid streamBareJidStr:streamBareJidStr];
    }];
}

- (void)readMessageWithMessageID:(NSString *)messageID xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        if (xmppStream){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@",@"messageID",messageID,@"streamBareJidStr",
                         streamBareJidStr];
            
            XMPPMessageCoreDataStorageObject *updateObject = [XMPPMessageCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                              withPredicate:predicate];
            if (!updateObject) return;
            [updateObject setHasBeenRead:[NSNumber numberWithBool:YES]];
        }
    }];
}

- (void)deleteMessageWithMessageID:(NSString *)messageID xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        if (xmppStream){
            
            XMPPMessageCoreDataStorageObject *updateObject = [XMPPMessageCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                              withMessageID:messageID
                                                                                                           streamBareJidStr:streamBareJidStr];
            if (!updateObject) return;
            [moc deleteObject:updateObject];
        }

    }];
}
- (void)updateMessageSendStatusWithMessageID:(NSString *)messageID sendSucceed:(XMPPMessageSendStatusType)sendType xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        if (xmppStream){
            
            XMPPMessageCoreDataStorageObject *updateObject = [XMPPMessageCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                              withMessageID:messageID
                                                                                                           streamBareJidStr:streamBareJidStr];
            if (!updateObject) return;
            [updateObject setHasBeenRead:[NSNumber numberWithInteger:sendType]];
        }

    }];
}
- (void)readMessageWithMessage:(XMPPMessageCoreDataStorageObject *)message xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        [message setHasBeenRead:[NSNumber numberWithBool:YES]];
    }];
}
- (void)deleteMessageWithMessage:(XMPPMessageCoreDataStorageObject *)message xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        [moc deleteObject:message];
    }];
}
- (void)updateMessageSendStatusWithMessage:(XMPPMessageCoreDataStorageObject *)message success:(BOOL)success xmppStream:(XMPPStream *)xmppStream
{
    [self scheduleBlock:^{
        [message setHasBeenRead:[NSNumber numberWithBool:success]];
    }];
}

- (id)lastMessageWithBareJidStr:(NSString *)bareJidStr xmppStream:(XMPPStream *)xmppStream
{
    if (!bareJidStr || !xmppStream) return nil;
    
    __block id result = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"messageTime" ascending:YES];
       
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (xmppStream){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@",@"bareJidStr",bareJidStr,@"streamBareJidStr",
                         streamBareJidStr];
        
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allMessages = [moc executeFetchRequest:fetchRequest error:nil];
        
        result = (XMPPMessageCoreDataStorageObject *)[allMessages lastObject];
    }];
    
    return result;
}

- (NSArray *)fetchMessagesWithBareJidStr:(NSString *)bareJidStr fetchSize:(NSInteger)fetchSize fetchOffset:(NSInteger)fetchOffset xmppStream:(XMPPStream *)xmppStream
{
    if (bareJidStr == nil || xmppStream == nil) return nil;
    
    __block NSArray *results = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"messageTime" ascending:YES];
        
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchLimit:fetchSize];
        [fetchRequest setFetchOffset:fetchOffset];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (xmppStream){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@",@"bareJidStr",bareJidStr,@"streamBareJidStr",
                                      streamBareJidStr];
            
            [fetchRequest setPredicate:predicate];
        }
        
        results = [moc executeFetchRequest:fetchRequest error:nil];
    }];
    
    return results;
}

////查询
//- (NSMutableArray*)selectData:(int)pageSize andOffset:(int)currentPage
//{
//    NSManagedObjectContext *moc = [self managedObjectContext];
//    
//    // 限定查询结果的数量
//    //setFetchLimit
//    // 查询的偏移量
//    //setFetchOffset
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    
//    [fetchRequest setFetchLimit:pageSize];
//    [fetchRequest setFetchOffset:currentPage];
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageCoreDataStorageObject" inManagedObjectContext:moc];
//    [fetchRequest setEntity:entity];
//    NSError *error;
//    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
//    NSMutableArray *resultArray = [NSMutableArray array];
//    
//    for (News *info in fetchedObjects) {
//        NSLog(@"id:%@", info.newsid);
//        NSLog(@"title:%@", info.title);
//        [resultArray addObject:info];
//    }
//    return resultArray;
//}
@end
