//
//  XMPPLoginUserCoreDataStorage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPLoginUserCoreDataStorage.h"
#import "XMPP.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPLogging.h"
#import "XMPPLoginUserCoreDataStorageObject.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation XMPPLoginUserCoreDataStorage

static XMPPLoginUserCoreDataStorage *sharedInstance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[XMPPLoginUserCoreDataStorage alloc] initWithDatabaseFilename:nil storeOptions:nil];
    });
    
    return sharedInstance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)configureWithParent:(XMPPLoginUser *)aParent queue:(dispatch_queue_t)queue
{
    return [super configureWithParent:aParent queue:queue];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Overrides
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)commonInit
{
    [super commonInit];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPLoginUserStorage methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)userIDWithBareJIDStr:(NSString *)bareJidStr
{
    __block NSString *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *loginUser = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                        streamBareJidStr:bareJidStr];
        result = [loginUser.streamBareJidStr copy];
    }];
    
    return result;
}
- (NSString *)bareJidStrWithUserID:(NSString *)userID
{
    __block NSString *result = nil;
    
    [self executeBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *loginUser = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                             withLoginID:userID];
        result = [loginUser.streamBareJidStr copy];
    }];
    
    return result;
}

- (void)saveLoginUserID:(NSString *)loginUserID bareJid:(NSString *)bareJid
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        [XMPPLoginUserCoreDataStorageObject updateOrInsertInManagedObjectContext:moc
                                                                     withLoginID:loginUserID
                                                                streamBareJidStr:bareJid];
        
    }];
}

- (void)updatebareJidStr:(NSString *)bareJidStr withUserID:(NSString *)activeUserID
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        [XMPPLoginUserCoreDataStorageObject updateInManagedObjectContext:moc
                                                             withLoginID:activeUserID
                                                        streamBareJidStr:bareJidStr];
        
    }];
}

- (void)deleteLoginUserWithUserID:(NSString *)userID
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        [XMPPLoginUserCoreDataStorageObject deleteFromManagedObjectContext:moc
                                                               withLoginID:userID];
        
    }];
}
- (void)deleteLoginUserWithUerBareJidStr:(NSString *)bareJidStr
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        [XMPPLoginUserCoreDataStorageObject deleteFromManagedObjectContext:moc
                                                          streamBareJidStr:bareJidStr];
        
    }];
}
@end
