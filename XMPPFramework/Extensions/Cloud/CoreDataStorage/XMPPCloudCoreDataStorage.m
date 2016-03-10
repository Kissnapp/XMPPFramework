//
//  XMPPCloudCoreDataStorage.m
//  XMPP_Project
//
//  Created by jeff on 15/10/20.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPCloudCoreDataStorage.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPCloud.h"
#import "XMPPLogging.h"



#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_INFO; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif


#define AssertPrivateQueue() \
NSAssert(dispatch_get_specific(storageQueueTag), @"Private method: MUST run on storageQueue");


@interface XMPPCloudCoreDataStorage () <XMPPCloudStorage>
@property (nonatomic, assign) int index;
@end

@implementation XMPPCloudCoreDataStorage


static XMPPCloudCoreDataStorage *sharedInstance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[XMPPCloudCoreDataStorage alloc] initWithDatabaseFilename:nil storeOptions:nil];
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

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
    if (parentQueue)
        dispatch_release(parentQueue);
#endif
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPCloudStorage
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)configureWithParent:(XMPPCloud *)aParent queue:(dispatch_queue_t)queue
{
    return [super configureWithParent:aParent queue:queue];
}

#pragma mark - hand datas to database
- (void)insertCloudDic:(NSDictionary *)serverDic xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        if (!streamBareJidStr) return;
        if (!moc) return;
        if (!serverDic) return;
        
        [XMPPCloudCoreDataStorageObject updateInManagedObjectContext:moc dic:serverDic streamBareJidStr:streamBareJidStr];
    }];
}

- (void)deleteCloudDic:(NSDictionary *)serverDic xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        if (!streamBareJidStr) return;
        if (!moc) return;
        if (!serverDic) return;
        
        NSString *cloudID = [serverDic objectForKey:@"id"];
        if (!cloudID) return;
        
        [XMPPCloudCoreDataStorageObject deleteInManagedObjectContext:moc cloudID:cloudID streamBareJidStr:streamBareJidStr];
    }];
}
- (void)deleteCloudID:(NSString *)cloudID xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        if (!streamBareJidStr) return;
        if (!moc) return;
        if (!cloudID.length) return;
        
        [XMPPCloudCoreDataStorageObject deleteInManagedObjectContext:moc cloudID:cloudID streamBareJidStr:streamBareJidStr];
    }];
}


- (void)deleteProjectWithCloudDic:(NSDictionary *)serverDic xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        if (!streamBareJidStr) return;
        if (!moc) return;
        if (!serverDic) return;
        
        NSString *project = [serverDic objectForKey:@"project"];
        NSNumber *hasBeenDelete = [serverDic objectForKey:@"hasBeenDelete"];
        if (hasBeenDelete.integerValue) {
            [XMPPCloudCoreDataStorageObject deleteInManagedObjectContext:moc hasBeenDelete:hasBeenDelete project:project streamBareJidStr:streamBareJidStr];
        }
    }];
}

// 更新特殊的key
- (void)updateSpecialCloudDic:(NSDictionary *)serverDic xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        if (!streamBareJidStr) return;
        if (!moc) return;
        if (!serverDic) return;
        
        [XMPPCloudCoreDataStorageObject updateSpecialInManagedObjectContext:moc dic:serverDic streamBareJidStr:streamBareJidStr];
    }];
}


#pragma mark - getDatas
#pragma mark - 1.获取文件的信息
- (id)cloudGetFolderWithParent:(NSString *)parent projectID:(NSString *)projectID xmppStream:(XMPPStream *)stream
{
    __block NSArray *allUsers = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        NSString *entityName = NSStringFromClass([XMPPCloudCoreDataStorageObject class]);
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
        
        if (!projectID) return;
        if (!parent) return;
        if (!moc) return;
        if (!streamBareJidStr) return;
        
        NSNumber *parentNum = [NSNumber numberWithInteger:[parent integerValue]];
        NSNumber *hasBeenDelete = [NSNumber numberWithBool:NO];
        NSSortDescriptor *sdFirst = [[NSSortDescriptor alloc] initWithKey:@"folderType" ascending:YES];
        NSSortDescriptor *sdSecond = [[NSSortDescriptor alloc] initWithKey:@"createTime" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sdFirst, sdSecond, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND project == %@ AND parent == %@ AND hasBeenDelete == %@",streamBareJidStr, projectID, parentNum, hasBeenDelete];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        allUsers = [moc executeFetchRequest:fetchRequest error:nil];
    }];
    return allUsers;
}


#pragma mark - 2.cloudID查找数据 (删除,重命名...)
- (id)cloudIDInfoWithProjectID:(NSString *)projectID cloudID:(NSString *)cloudID xmppStream:(XMPPStream *)stream;
{
    __block NSArray *allUsers = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        NSString *entityName = NSStringFromClass([XMPPCloudCoreDataStorageObject class]);
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
        
        if (!projectID) return;
        if (!cloudID) return;
        if (!moc) return;
        if (!streamBareJidStr) return;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND project == %@ AND cloudID == %@",streamBareJidStr, projectID, cloudID];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        [fetchRequest setPredicate:predicate];
        
        allUsers = [moc executeFetchRequest:fetchRequest error:nil];
    }];
    return allUsers;
}

@end
