//
//  XMPPOrganizationCoreDataStorage.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/22.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPOrgCoreDataStorage.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "NSNumber+XMPP.h"
#import "XMPPOrg.h"
#import "XMPPOrgCoreDataStorageObject.h"
#import "XMPPOrgPositionCoreDataStorageObject.h"
#import "XMPPOrgUserCoreDataStorageObject.h"

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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - extension
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPOrgCoreDataStorage ()<XMPPOrgStorage>

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation XMPPOrgCoreDataStorage

static XMPPOrgCoreDataStorage *sharedInstance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[XMPPOrgCoreDataStorage alloc] initWithDatabaseFilename:nil storeOptions:nil];
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
#pragma mark - XMPPOrganizationStorage
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)configureWithParent:(XMPPAllMessage *)aParent queue:(dispatch_queue_t)queue
{
    return [super configureWithParent:aParent queue:queue];
}

- (void)clearAllOrgWithXMPPStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K != %@",@"streamBareJidStr",streamBareJidStr, @"orgState",@(XMPPOrgCoreDataStorageObjectStateTemplate)];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allOrgs = [moc executeFetchRequest:fetchRequest error:nil];
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgCoreDataStorageObject *org in allOrgs){
            
            [moc deleteObject:org];
            
            if (++unsavedCount >= saveThreshold){
                [self save];
                unsavedCount = 0;
            }
        }
    }];
}
- (void)clearAllTemplatesWithXMPPStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@",@"streamBareJidStr",streamBareJidStr, @"orgState",@(XMPPOrgCoreDataStorageObjectStateTemplate)];
            
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *allOrgs = [moc executeFetchRequest:fetchRequest error:nil];
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgCoreDataStorageObject *org in allOrgs){
            
            [moc deleteObject:org];
            
            if (++unsavedCount >= saveThreshold){
                [self save];
                unsavedCount = 0;
            }
        }
    }];
}

- (id)allOrgTemplatesWithXMPPStream:(XMPPStream *)stream
{
    __block NSArray *allTemplates = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (streamBareJidStr){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@",@"streamBareJidStr",
                         streamBareJidStr, @"orgState", @(XMPPOrgCoreDataStorageObjectStateTemplate)];
            
            [fetchRequest setPredicate:predicate];
            
            allTemplates = [moc executeFetchRequest:fetchRequest error:nil];
        }
    }];
    
    return allTemplates;
}

- (id)allOrgsWithXMPPStream:(XMPPStream *)stream
{
    __block NSArray *allOrgs = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (streamBareJidStr){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K != %@",@"streamBareJidStr",
                                      streamBareJidStr, @"orgState", @(XMPPOrgCoreDataStorageObjectStateTemplate)];
            
            [fetchRequest setPredicate:predicate];
            
            allOrgs = [moc executeFetchRequest:fetchRequest error:nil];
        }
    }];
    
    return allOrgs;
}

- (id)orgWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;
{
    __block id org = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:1];
        
        if (streamBareJidStr){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@",@"streamBareJidStr",
                                      streamBareJidStr, @"orgId", orgId];
            
            [fetchRequest setPredicate:predicate];
            
            org = [[moc executeFetchRequest:fetchRequest error:nil] lastObject];
        }
    }];
    
    return org;
}

- (void)clearPositionsWithOrgId:(NSString *)orgId  xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgPositionCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND orgId == %@",streamBareJidStr,orgId];
            [fetchRequest setPredicate:predicate];
            
        }
        
        NSArray *allUnusedPositions = [moc executeFetchRequest:fetchRequest error:nil];
        
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgPositionCoreDataStorageObject *position in allUnusedPositions) {
            
            [moc deleteObject:position];
            
            if (++unsavedCount >= saveThreshold){
                
                [self save];
                unsavedCount = 0;
            }
        }
        
    }];
}

- (void)clearUsersWithOrgId:(NSString *)orgId  xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgUserCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND orgId == %@",streamBareJidStr,orgId];
            [fetchRequest setPredicate:predicate];
            
        }
        
        NSArray *allUnusedUsers = [moc executeFetchRequest:fetchRequest error:nil];
        
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgUserCoreDataStorageObject *user in allUnusedUsers) {
            
            [moc deleteObject:user];
            
            if (++unsavedCount >= saveThreshold){
                
                [self save];
                unsavedCount = 0;
            }
        }
        
    }];
}

- (void)deleteUserWithUserJidStr:(NSString *)userJidStr orgId:(NSString *)orgId  xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgUserCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND orgId == %@ AND userJidStr == %@",streamBareJidStr,orgId,userJidStr];
            [fetchRequest setPredicate:predicate];
            
        }
        
        NSArray *allUsers = [moc executeFetchRequest:fetchRequest error:nil];
        
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgUserCoreDataStorageObject *user in allUsers) {
            
            [moc deleteObject:user];
            
            if (++unsavedCount >= saveThreshold){
                
                [self save];
                unsavedCount = 0;
            }
        }
        
    }];
}

- (void)clearRelationsWithOrgId:(NSString *)orgId  xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:1];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND orgId == %@",streamBareJidStr,orgId];
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray *tempOrgs = [moc executeFetchRequest:fetchRequest error:nil];
        
        NSArray *allRelations = [[(XMPPOrgCoreDataStorageObject *)[tempOrgs lastObject] orgRelationShip] allObjects];
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgRelationObject *relation in allRelations) {
            
            [moc deleteObject:relation];
            
            if (++unsavedCount >= saveThreshold){
                
                [self save];
                unsavedCount = 0;
            }
        }
        
    }];
}


- (id)orgPositionsWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block NSArray *allPositions = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgPositionCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (streamBareJidStr){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@",@"streamBareJidStr",
                                      streamBareJidStr, @"orgId", orgId];
            
            [fetchRequest setPredicate:predicate];
            
            allPositions = [moc executeFetchRequest:fetchRequest error:nil];
        }
    }];
    
    return allPositions;
}

- (id)orgUsersWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block NSArray *allUsers = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgUserCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (streamBareJidStr){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@",@"streamBareJidStr",
                                      streamBareJidStr, @"orgId", orgId];
            
            [fetchRequest setPredicate:predicate];
            
            allUsers = [moc executeFetchRequest:fetchRequest error:nil];
        }
    }];
    
    return allUsers;
}

- (id)newUsersWithOrgId:(NSString *)orgId userIds:(NSArray *)userIds xmppStream:(XMPPStream *)stream
{
    __block NSArray *newUsers = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgUserCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (streamBareJidStr){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userJidStr in %@ AND streamBareJidStr == %@ && orgId == %@",userIds,
                                      streamBareJidStr, orgId];
            
            [fetchRequest setPredicate:predicate];
            
            newUsers = [moc executeFetchRequest:fetchRequest error:nil];
        }
    }];
    
    return newUsers;
}

- (void)clearUnusedOrgWithOrgIds:(NSArray *)orgIds isTemplate:(BOOL)isTemplate xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (streamBareJidStr){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:(isTemplate ? @"NOT(orgId in %@) AND streamBareJidStr == %@ AND orgState == %@":@"NOT(orgId in %@) AND streamBareJidStr == %@ AND orgState == %@"), orgIds,
                                      streamBareJidStr, @(XMPPOrgCoreDataStorageObjectStateTemplate)];
            
            [fetchRequest setPredicate:predicate];
            
            NSArray *deleteOrgs = [moc executeFetchRequest:fetchRequest error:nil];
            
            NSUInteger unsavedCount = [self numberOfUnsavedChanges];
            
            for (XMPPOrgCoreDataStorageObject *org in deleteOrgs){
                
                [moc deleteObject:org];
                
                if (++unsavedCount >= saveThreshold){
                    [self save];
                    unsavedCount = 0;
                }
            }
        }
        
    }];
    // delete unused users
    [self clearUnusedUserWithOrgIds:orgIds xmppStream:stream];
    
    // delete unused positions
    [self clearUnusedPositionWithOrgIds:orgIds xmppStream:stream];
}

- (void)clearUnusedPositionWithOrgIds:(NSArray *)orgIds xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgPositionCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND NOT(orgId in %@)",streamBareJidStr,orgIds];
            [fetchRequest setPredicate:predicate];
            
        }
        
        NSArray *allUnusedPositions = [moc executeFetchRequest:fetchRequest error:nil];
        
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgPositionCoreDataStorageObject *position in allUnusedPositions) {
            
            [moc deleteObject:position];
            
            if (++unsavedCount >= saveThreshold){
                
                [self save];
                unsavedCount = 0;
            }
        }

    }];
}

- (void)clearUnusedUserWithOrgIds:(NSArray *)orgIds xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    [self scheduleBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgUserCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND NOT(orgId in %@)",streamBareJidStr,orgIds];
            [fetchRequest setPredicate:predicate];
            
        }
        
        NSArray *allUnusedUsers = [moc executeFetchRequest:fetchRequest error:nil];
        
        
        NSUInteger unsavedCount = [self numberOfUnsavedChanges];
        
        for (XMPPOrgUserCoreDataStorageObject *user in allUnusedUsers) {
            
            [moc deleteObject:user];
            
            if (++unsavedCount >= saveThreshold){
                
                [self save];
                unsavedCount = 0;
            }
        }
        
    }];
}

- (void)insertOrUpdateOrgInDBWith:(NSDictionary *)dic
                       xmppStream:(XMPPStream *)stream 
                        userBlock:(void (^)(NSString *orgId))userBlock
                    positionBlock:(void (^)(NSString *orgId))positionBlock
                    relationBlock:(void (^)(NSString *orgId))relationBlock
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *orgId = [dic objectForKey:@"orgId"];
        
        // find the give object info is whether existed
        XMPPOrgCoreDataStorageObject *orgObject = [XMPPOrgCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                   withOrgId:orgId
                                                                                            streamBareJidStr:streamBareJidStr];
        
        if (orgObject == nil) {
            
            orgObject = [XMPPOrgCoreDataStorageObject insertInManagedObjectContext:moc
                                                                           withDic:dic
                                                                  streamBareJidStr:streamBareJidStr];
            
            if (userBlock) userBlock(orgId);
            if (positionBlock) positionBlock(orgId);
            if (relationBlock) relationBlock(orgId);
            
        }else{
            
            NSString *userTag = [dic objectForKey:@"userTag"];
            NSString *ptTag = [dic objectForKey:@"ptTag"];
            NSString *orgRelationShipTag = [dic objectForKey:@"orgRelationShipTag"];
            
            if (![orgObject.userTag isEqualToString:userTag])
                if (userBlock) userBlock(orgId);
            
            if (![orgObject.ptTag isEqualToString:ptTag])
                if (positionBlock) positionBlock(orgId);
            
            if (![orgObject.relationShipTag isEqualToString:orgRelationShipTag])
                if (relationBlock) relationBlock(orgId);
            
            [orgObject updateWithDic:dic];
            
        }
    
    }];

}

- (void)insertOrUpdatePositionInDBWithOrgId:(NSString *)orgId dic:(NSDictionary *)dic xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        
        NSString *ptId = [dic objectForKey:@"ptId"];
        
        // find the give object info is whether existed
        XMPPOrgPositionCoreDataStorageObject *position = [XMPPOrgPositionCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                   withPtId:ptId
                                                                                                                      orgId:orgId
                                                                                                           streamBareJidStr:streamBareJidStr];
        
        if (position == nil) {
            
            position = [XMPPOrgPositionCoreDataStorageObject insertInManagedObjectContext:moc
                                                                                  withDic:dic
                                                                         streamBareJidStr:streamBareJidStr];
            
        }else{
            
            [position updateWithDic:dic];
        }
        
        position.orgId = orgId;
        
    }];
}
- (void)insertOrUpdateUserInDBWithOrgId:(NSString *)orgId dic:(NSDictionary *)dic xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        // find the give object info is whether existed
        XMPPOrgUserCoreDataStorageObject *user = [XMPPOrgUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                                                        withDic:dic
                                                                                               streamBareJidStr:streamBareJidStr];
        
        [user updateWithDic:dic];
        
        user.orgId = orgId;
        
    }];
}

- (void)insertOrUpdateRelationInDBWithOrgId:(NSString *)orgId dic:(NSDictionary *)dic xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        // find the give object info is whether existed
        
        XMPPOrgCoreDataStorageObject *org = [ XMPPOrgCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                              withOrgId:orgId
                                                                                       streamBareJidStr:streamBareJidStr];
        
        if (org) {
            
            XMPPOrgRelationObject *relation = [XMPPOrgRelationObject insertInManagedObjectContext:moc withDic:dic];
            
            [org addOrgRelationShipObject:relation];
        }
        
    }];
}

- (id)orgRelationsWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block NSArray *allRelations = nil;
    
    [self executeBlock:^{
        
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:1];
        
        if (streamBareJidStr){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@",@"streamBareJidStr",
                                      streamBareJidStr, @"orgId", orgId];
            
            [fetchRequest setPredicate:predicate];
            
            NSArray *tempOrgs = [moc executeFetchRequest:fetchRequest error:nil];
            
            allRelations = [[(XMPPOrgCoreDataStorageObject *)[tempOrgs lastObject] orgRelationShip] allObjects];
        }
    }];
    
    return allRelations;
}

- (id)endOrgWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block id org = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        // find the give object info is whether existed
        
        XMPPOrgCoreDataStorageObject *_org = [ XMPPOrgCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                              withOrgId:orgId
                                                                                       streamBareJidStr:streamBareJidStr];
        
        if (_org) {
            
            _org.orgState = @(XMPPOrgCoreDataStorageObjectStateEnd);
            org = _org;
        }
        
    }];
    
    return org;
}

- (id)subPositionsWithPtId:(NSString *)ptId orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block NSArray *subPositions = nil;
    
    [self executeBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        NSString *entityName = NSStringFromClass([XMPPOrgPositionCoreDataStorageObject class]);
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        XMPPOrgPositionCoreDataStorageObject *superPosition = [XMPPOrgPositionCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                        withPtId:ptId
                                                                                                                           orgId:orgId
                                                                                                                streamBareJidStr:streamBareJidStr];
        NSNumber *superLeft = superPosition.ptLeft;
        NSNumber *superRight = superPosition.ptRight;
        
        if (stream){
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND orgId == %@ AND ptLeft > %@ AND ptRight < %@",streamBareJidStr,orgId,superLeft,superRight];
            [fetchRequest setPredicate:predicate];
            
        }
        
        subPositions = [moc executeFetchRequest:fetchRequest error:nil];
        
    }];

    return subPositions;
}

- (id)positionWithPtId:(NSString *)ptId orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block XMPPOrgPositionCoreDataStorageObject *position = nil;
    
    [self executeBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        position = [XMPPOrgPositionCoreDataStorageObject objectInManagedObjectContext:moc
                                                                             withPtId:ptId
                                                                                orgId:orgId
                                                                     streamBareJidStr:streamBareJidStr];
        
    }];
    
    return position;
}

- (BOOL)isAdminWithUser:(NSString *)userBareJidStr orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    __block BOOL isAndmin = NO;
    
    [self executeBlock:^{
        //Your code ...
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSString *streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        
        XMPPOrgCoreDataStorageObject *org = [XMPPOrgCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                             withOrgId:orgId
                                                                                      streamBareJidStr:streamBareJidStr];
        
        if (org && [org.orgAdminJidStr isEqualToString:userBareJidStr]) {
            isAndmin = YES;
        }
    }];
    
    return isAndmin;
}

@end
