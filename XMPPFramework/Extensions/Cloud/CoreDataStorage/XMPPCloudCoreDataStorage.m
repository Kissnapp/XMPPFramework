//
//  XMPPCloudCoreDataStorage.m
//  XMPP_Project
//
//  Created by jeff on 15/9/22.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPCloudCoreDataStorage.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPCloud.h"

#define AssertPrivateQueue() \
NSAssert(dispatch_get_specific(storageQueueTag), @"Private method: MUST run on storageQueue");

@interface XMPPCloudCoreDataStorage () <XMPPCloudStorage>

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


- (void)insertCloudFolderDics:(NSArray *)folderDics cloudIDs:(NSArray *)cloudIDs projectID:(NSString *)projectID parent:(NSString *)parent xmppStream:(XMPPStream *)stream
{
    __block NSArray *allUsers = nil;
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        NSString *entityName = NSStringFromClass([XMPPCloudCoreDataStorageObject class]);
        
        if (!streamBareJidStr) return;
        if (!projectID) return;
        if (!parent) return;
        if (!moc) return;
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND project == %@ AND parent == %@ AND (cloudID IN %@)",streamBareJidStr, projectID, parent, cloudIDs];
        [fetchRequest setPredicate:predicate];
//        allUsers = [moc executeFetchRequest:fetchRequest error:nil];
        
        for ( NSDictionary *dic in folderDics ) {
            NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
            [dicM setObject:projectID forKey:@"project"];
            [dicM setObject:parent forKey:@"parent"];
            if ([parent isEqualToString:@"-1"]) {
                [dicM setObject:[NSNumber numberWithInteger:1] forKey:@"folderOrFileType"];
            } else if (0) {
                
            }
            [dicM setObject:streamBareJidStr forKey:@"streamBareJidStr"];
            [XMPPCloudCoreDataStorageObject insertInManagedObjectContext:moc withDic:dicM];
            [self save];
        }
    }];
}

- (id)cloudFolderWithParent:(NSString *)parent projectID:(NSString *)projectID xmppStream:(XMPPStream *)stream
{
    __block NSArray *allUsers = nil;
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPCloudCoreDataStorageObject class]);
        if (!projectID) return;
        if (!parent) return;
        if (!moc) return;
        if (!streamBareJidStr) return;
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND project == %@ AND parent == %@",streamBareJidStr, projectID, parent];
        [fetchRequest setPredicate:predicate];
        allUsers = [moc executeFetchRequest:fetchRequest error:nil];
    }];
    return allUsers;
}


@end
