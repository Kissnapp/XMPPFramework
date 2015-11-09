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
- (void)insertCloudDic:(NSDictionary *)serverDic xmppStream:(XMPPStream *)stream;
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

- (void)deleteClouDic:(NSDictionary *)serverDic xmppStream:(XMPPStream *)stream;
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

// 更新特殊的key
- (void)updateSpecialCloudDic:(NSDictionary *)serverDic xmppStream:(XMPPStream *)stream;
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
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND project == %@ AND parent == %@",streamBareJidStr, projectID, [NSNumber numberWithInteger:[parent integerValue]]];
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"cloudID" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd, nil];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        allUsers = [moc executeFetchRequest:fetchRequest error:nil];
    }];
    return allUsers;
}

#pragma mark - 2.创建文件夹
- (id)cloudAddFolderWithProjectID:(NSString *)projectID cloudID:(NSString *)cloudID xmppStream:(XMPPStream *)stream
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


#pragma mark - 4.删除文件夹/删除文件
- (id)cloudDeleteWithProjectID:(NSString *)projectID cloudID:(NSString *)cloudID xmppStream:(XMPPStream *)stream
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
