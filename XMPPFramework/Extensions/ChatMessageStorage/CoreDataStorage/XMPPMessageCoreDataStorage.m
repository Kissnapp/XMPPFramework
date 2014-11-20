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
    
    //chatRoomPopulationSet = [[NSMutableSet alloc] init];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Tool methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *  Get the UTC string from the local date string
 *
 *  @param localDate The local date string
 *
 *  @return The UTC string we will get
 */
-(NSString *)getUTCStringWithLocalDateString:(NSString *)localDate
{
    //将本地日期字符串转为UTC日期字符串
    //本地日期格式:2013-08-03 12:53:51
    //可自行指定输入输出格式
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:localDate];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}
/**
 *  The local date string we get with the UTC date string
 *
 *  @param utcDate The UTC date string
 *
 *  @return The local date string we will get
 */
-(NSString *)getLocalDateStringWithUTCDateString:(NSString *)utcDate
{
    //将UTC日期字符串转为本地时间字符串
    //输入的UTC日期格式2013-08-03T04:53:51+0000
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}
/**
 *  Get the UTC date string from the local date object
 *
 *  @param localDate The local date object
 *
 *  @return The UTC date string we will get
 */
- (NSString *)getUTCStringWithLocalDate:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}
/**
 *  Get the local date object with the given UTC date string
 *
 *  @param utc The utc date string
 *
 *  @return The local date obejct we will get
 */
- (NSDate *)getLocalDateWithUTCString:(NSString *)utc
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate *ldate = [dateFormatter dateFromString:utc];
    return ldate;
}
/**
 *  Get the date obejct With the given date string
 *
 *  @param strdate The given date string
 *
 *  @return The Date object we will get
 */
- (NSDate *)stringToDate:(NSString *)strdate
{
    //NSString 2 NSDate
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *retdate = [dateFormatter dateFromString:strdate];
    return retdate;
}
/**
 *  Get the date string with the given date object
 *
 *  @param date The given object
 *
 *  @return The string we will get
 */
- (NSString *)dateToString:(NSDate *)date
{
    //NSDate 2 NSString
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

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

- (NSArray *)fetchMessagesWithBareJidStr:(NSString *)bareJidStr fetchSize:(NSInteger)fetchSize fetchOffset:(NSInteger)fetchOffset isPrivate:(BOOL)isPrivate xmppStream:(XMPPStream *)xmppStream
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
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@ && %K == %@",@"bareJidStr",bareJidStr,@"streamBareJidStr",
                                      streamBareJidStr,@"isPrivate",@(isPrivate > 0)];
            
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
