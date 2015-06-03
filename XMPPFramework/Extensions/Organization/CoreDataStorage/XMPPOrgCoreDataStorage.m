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
#import "XMPPOrganization.h"
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

@interface XMPPOrgCoreDataStorage ()<XMPPOrganizationStorage>

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
- (NSArray*)allPorjectListWithbareJid:(NSString*)bareJidStr stream:(XMPPStream*)xmppStream
{
    
   __block NSArray *allProject = nil;
  [self executeBlock:^{
     
      
      NSManagedObjectContext *moc = [self managedObjectContext];
      NSString *streamBareJidStr = [[self myJIDForXMPPStream:xmppStream] bare];
      
      NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPOrgCoreDataStorageObject"
                                                inManagedObjectContext:moc];
      
      NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
      [fetchRequest setEntity:entity];
      [fetchRequest setFetchBatchSize:saveThreshold];
      
      if (xmppStream){
          NSPredicate *predicate;
          //!!!!:Notice:This method should not read the voice message
          predicate = [NSPredicate predicateWithFormat:@"%K == %@",@"streamBareJidStr",
                       streamBareJidStr];
          
          [fetchRequest setPredicate:predicate];
      }
      
      allProject = [moc executeFetchRequest:fetchRequest error:nil];
      
     
  }];
    
    return allProject;

}
- (NSArray *)userListForOrgWithBareJidStr:(NSString *)orgId xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    __block NSArray *results = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPOrgUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:saveThreshold];
        
        if (stream){
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"orgId == %@ && streamBareJidStr == %@",orgId,
                         [[self myJIDForXMPPStream:stream] bare]];
            
            [fetchRequest setPredicate:predicate];
        }
        
        results = [moc executeFetchRequest:fetchRequest error:nil];
        
    }];
    
    return results;
    
}
- (id)userInfoFromChatRoom:(NSString *)bareChatRoomJidStr withBareJidStr:(NSString *)bareJidStr xmppStream:(XMPPStream *)stream
{
    __block XMPPOrgPositionCoreDataStorageObject *result = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        result = [XMPPChatRoomUserCoreDataStorageObject fetchObjectInManagedObjectContext:moc
                                                                           withBareJidStr:bareJidStr
                                                                              chatRoomJid:bareChatRoomJidStr
                                                                         streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        
    }];
    
    return result;
}
-(id)orgPositionForOrg:(NSString*)streamBareJidStr withPtID:(NSString*)ptID orgID:(NSString*)orgID xmppStream:(XMPPStream *)stream
{
    __block XMPPOrgPositionCoreDataStorageObject *result = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        result = [XMPPOrgPositionCoreDataStorageObject objectInManagedObjectContext:moc withPtId:ptID orgId:orgID streamBareJidStr: streamBareJidStr];
        
        
    }];
    
    return result;
}

- (BOOL)isAdminForOrgnizationJidStr:(NSString *)bareOrgJidStr xmppStream:(XMPPStream *)stream
{
    XMPPLogTrace();
    
    __block BOOL result = NO;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPOrgCoreDataStorageObject *org = [self orgForID:bareOrgJidStr
                                                               xmppStream:stream
                                                     managedObjectContext:moc];
        //if the chat room obejct is exsited
        //We compare self jid is whether equal to the master bare jid string
        if (org) {
            result = ([org.orgAdminJidStr isEqualToString:[[stream myJID] bare]]);
        }
    }];
    
    return result;
}

- (XMPPOrgCoreDataStorageObject *)orgForID:(NSString *)id  xmppStream:(XMPPStream *)stream
                                managedObjectContext:(NSManagedObjectContext *)moc
{
    // This is a public method, so it may be invoked on any thread/queue.
    
    XMPPLogTrace();
    
    if (id == nil) return nil;
    if (moc == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPOrgCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate;
    if (stream == nil)
        predicate = [NSPredicate predicateWithFormat:@"orgAdminJidStr == %@", id];
    else
        predicate = [NSPredicate predicateWithFormat:@"orgAdminJidStr == %@ AND streamBareJidStr == %@",
                     id, [[self myJIDForXMPPStream:stream] bare]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPOrgCoreDataStorageObject *)[results lastObject];
}


@end
