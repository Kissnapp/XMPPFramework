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



- (void)deleteCloudDatas:(NSArray *)serverDatas xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        if (!streamBareJidStr) return;
        if (!moc) return;
        if (!serverDatas.count) return;
        
        NSDictionary *serverDic = [serverDatas firstObject];
        NSString *cloudID = [serverDic objectForKey:@"id"];
        
        [XMPPCloudCoreDataStorageObject deleteInManagedObjectContext:moc cloudID:cloudID streamBareJidStr:streamBareJidStr];
    }];
}



- (void)insertCloudDatas:(NSArray *)serverDatas xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        NSString *entityName = NSStringFromClass([XMPPCloudCoreDataStorageObject class]);
        
        if (!streamBareJidStr) return;
        if (!moc) return;
        if (!serverDatas.count) return;
        
//        for ( NSDictionary *dic in serverDatas ) {
//            [XMPPCloudCoreDataStorageObject updateInManagedObjectContext:moc dic:dic streamBareJidStr:streamBareJidStr];
//        }
        
        NSDictionary *serverDic = [serverDatas firstObject];
        NSString *projectID = [serverDic objectForKey:@"project"];
        NSString *parent = [serverDic objectForKey:@"parent"];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];

        for ( NSDictionary *dic in serverDatas ) {
            NSString *cloudID = [dic objectForKey:@"id"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND project == %@ AND parent == %@ AND cloudID == %@", streamBareJidStr, projectID, parent, cloudID];
            [fetchRequest setPredicate:predicate];
            NSArray *array = [moc executeFetchRequest:fetchRequest error:nil];
            
            if ( !array.count ) {
                [XMPPCloudCoreDataStorageObject insertInManagedObjectContext:moc dic:dic streamBareJidStr:streamBareJidStr];
            }
        }
    }];
}

- (id)cloudFolderWithParent:(NSString *)parent projectID:(NSString *)projectID xmppStream:(XMPPStream *)stream
{
    __block NSArray *allUsers = nil;
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
//            NSString *entityName = NSStringFromClass([XMPPCloudCoreDataStorageObject class]);
//            NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
//            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"project == %@ AND parent == %@", projectID, parent];
//            NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"cloudID" ascending:NO];
//        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd, nil];
//            [fetchRequest setPredicate:predicate];
//            [fetchRequest setEntity:entity];
//            [fetchRequest setSortDescriptors:sortDescriptors];
//        allUsers = [moc executeFetchRequest:fetchRequest error:nil];
//        NSLog(@"allUser----- %@", allUsers);
        NSString *entityName = NSStringFromClass([XMPPCloudCoreDataStorageObject class]);
        if (!projectID) return;
        if (!parent) return;
        if (!moc) return;
        if (!streamBareJidStr) return;
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        int tempIndex = 9;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND project == %@ AND parent == %@ AND cloudID.intValue <= %d",streamBareJidStr, projectID, parent, tempIndex];
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"cloudID" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd, nil];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        allUsers = [moc executeFetchRequest:fetchRequest error:nil];
    }];
    return allUsers;
}

@end
