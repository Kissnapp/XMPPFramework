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
@end
