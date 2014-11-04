//
//  XMPPChatRoomCoreDataStorage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/25.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPChatRoomCoreDataStorage.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "NSNumber+XMPP.h"

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

@implementation XMPPChatRoomCoreDataStorage
static XMPPChatRoomCoreDataStorage *sharedInstance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[XMPPChatRoomCoreDataStorage alloc] initWithDatabaseFilename:nil storeOptions:nil];
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
    
    chatRoomPopulationSet = [[NSMutableSet alloc] init];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (XMPPChatRoomCoreDataStorageObject *)chatRoomForID:(NSString *)id
                                           xmppStream:(XMPPStream *)stream
                                 managedObjectContext:(NSManagedObjectContext *)moc
{
    // This is a public method, so it may be invoked on any thread/queue.
    
    XMPPLogTrace();
    
    if (id == nil) return nil;
    if (moc == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPChatRoomCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate;
    if (stream == nil)
        predicate = [NSPredicate predicateWithFormat:@"jid == %@", id];
    else
        predicate = [NSPredicate predicateWithFormat:@"jid == %@ AND streamBareJidStr == %@",
                     id, [[self myJIDForXMPPStream:stream] bare]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPChatRoomCoreDataStorageObject *)[results lastObject];
}


#pragma mark -
#pragma mark - XMPPChatRoomStorage Methods

- (void)handleChatRoomUserDictionary:(NSDictionary *)dictionary xmppStream:(XMPPStream *)stream
{
    //MARK:here we will storage the chat room user in to the Core Data system
    //???:Your code here ...
}

- (void)InsertOrUpdateChatRoomWith:(NSDictionary *)dic xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
       
        if ([chatRoomPopulationSet containsObject:[NSNumber xmpp_numberWithPtr:(__bridge void *)stream]]){
            NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
            
            [XMPPChatRoomCoreDataStorageObject insertInManagedObjectContext:moc
                                                           withNSDictionary:dic
                                                           streamBareJidStr:streamBareJidStr];
        }else{
            NSString *jid = [dic objectForKey:@"jid"];
            
            XMPPChatRoomCoreDataStorageObject *chatRoom = [self chatRoomForID:jid
                                                                   xmppStream:stream
                                                         managedObjectContext:moc];
            
            if (chatRoom) {
                [chatRoom updateWithDictionary:dic];
            }else{
                NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
                
                [XMPPChatRoomCoreDataStorageObject insertInManagedObjectContext:moc
                                                               withNSDictionary:dic
                                                               streamBareJidStr:streamBareJidStr];
            }
        }
        
    }];
}

//
- (void)beginChatRoomPopulationForXMPPStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        
        [chatRoomPopulationSet addObject:[NSNumber xmpp_numberWithPtr:(__bridge void *)stream]];
        
        // Clear anything already in the roster core data store.
        //
        // Note: Deleting a user will delete all associated resources
        // because of the cascade rule in our core data model.
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPChatRoomCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@",
                         [[self myJIDForXMPPStream:stream] bare]];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allChatRooms = [moc executeFetchRequest:fetchRequest error:nil];
        
        for (XMPPChatRoomCoreDataStorageObject *room in allChatRooms)
        {
            [moc deleteObject:room];
        }
        
    }];
}

- (void)endChatRoomPopulationForXMPPStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        [chatRoomPopulationSet removeObject:[NSNumber xmpp_numberWithPtr:(__bridge void *)stream]];
    }];
}

- (void)handleChatRoomDictionary:(NSDictionary *)dictionary xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    //	NSLog(@"NSXMLElement:%@",itemSubElement.description);
    // Remember XML heirarchy memory management rules.
    // The passed parameter is a subnode of the IQ, and we need to pass it to an asynchronous operation.
    NSDictionary *dic = [dictionary copy];
    
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        if ([chatRoomPopulationSet containsObject:[NSNumber xmpp_numberWithPtr:(__bridge void *)stream]]){
            NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
            
            [XMPPChatRoomCoreDataStorageObject insertInManagedObjectContext:moc
                                                           withNSDictionary:dic
                                                           streamBareJidStr:streamBareJidStr];
        }else{
            NSString *jid = [dic objectForKey:@"jid"];
            
            XMPPChatRoomCoreDataStorageObject *chatRoom = [self chatRoomForID:jid
                                                                   xmppStream:stream
                                                         managedObjectContext:moc];
            
            if (chatRoom) {
                [chatRoom updateWithDictionary:dic];
            }else{
                NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
                
                [XMPPChatRoomCoreDataStorageObject insertInManagedObjectContext:moc
                                                               withNSDictionary:dic
                                                               streamBareJidStr:streamBareJidStr];
            }
        }
        
    }];

}

- (BOOL)chatRoomExistsWithID:(NSString *)id xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    __block BOOL result = NO;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPChatRoomCoreDataStorageObject *chatRoom = [self chatRoomForID:id
                                                               xmppStream:stream
                                                     managedObjectContext:moc];
        
        result = (chatRoom != nil);
    }];
    
    return result;
}

- (void)clearAllChatRoomsForXMPPStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        
        // Note: Deleting a user will delete all associated resources
        // because of the cascade rule in our core data model.
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPChatRoomCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@",
                         [[self myJIDForXMPPStream:stream] bare]];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allChatRooms = [moc executeFetchRequest:fetchRequest error:nil];
        
        __block NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        [allChatRooms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            [moc deleteObject:(XMPPChatRoomCoreDataStorageObject *)obj];
            if (++unsavedCount >= saveThreshold){
                [self save];
                unsavedCount = 0;
            }
            
        }];
    }];
}

- (NSArray *)idsForXMPPStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    __block NSMutableArray *results = [NSMutableArray array];
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPChatRoomCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@",
                         [[self myJIDForXMPPStream:stream] bare]];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allChatRooms = [moc executeFetchRequest:fetchRequest error:nil];
        
        [allChatRooms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            [results addObject:((XMPPChatRoomCoreDataStorageObject *)obj).jid];
            
        }];
    
    }];
    
    return results;
}

#if TARGET_OS_IPHONE
- (void)setPhoto:(UIImage *)photo forChatRoomWithID:(NSString *)id xmppStream:(XMPPStream *)stream
#else
- (void)setPhoto:(NSImage *)photo forChatRoomWithID:(NSString *)id xmppStream:(XMPPStream *)stream
#endif
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPChatRoomCoreDataStorageObject *chatRoom = [self chatRoomForID:id
                                                               xmppStream:stream
                                                     managedObjectContext:moc];
        
        if (chatRoom){
            chatRoom.photo = photo;
        }
    }];
}

- (void)setNickNameFromStorageWithNickName:(NSString *)nickname withBareJidStr:(NSString *)bareJidStr xmppStream:(XMPPStream *)stream
{
    if (!nickname || !bareJidStr) return;
    
    
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPChatRoomCoreDataStorageObject *chatRoom = [self chatRoomForID:bareJidStr
                                                               xmppStream:stream
                                                     managedObjectContext:moc];
        
        if (chatRoom){
            [chatRoom setNickName:nickname];
        }
    
    }];
}

@end
