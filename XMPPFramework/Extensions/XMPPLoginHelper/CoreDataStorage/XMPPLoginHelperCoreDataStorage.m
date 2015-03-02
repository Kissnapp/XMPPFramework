//
//  XMPPLoginUserCoreDataStorage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPLoginHelperCoreDataStorage.h"
#import "XMPP.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPLogging.h"
#import "XMPPLoginUserCoreDataStorageObject.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/*
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif
*/

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation XMPPLoginHelperCoreDataStorage

static XMPPLoginHelperCoreDataStorage *sharedInstance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[XMPPLoginHelperCoreDataStorage alloc] initWithDatabaseFilename:nil storeOptions:nil];
    });
    
    return sharedInstance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)configureWithParent:(XMPPLoginHelper *)aParent queue:(dispatch_queue_t)queue
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
- (void)savePhoneNumber:(NSString *)phoneNumber xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        [XMPPLoginUserCoreDataStorageObject updatePhoneNumberOrInsertInManagedObjectContext:moc
                                                                            withPhoneNumber:phoneNumber
                                                                           streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        
    }];
}

- (void)saveEmailAddress:(NSString *)emailAddress xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        [XMPPLoginUserCoreDataStorageObject updateEmailAddressOrInsertInManagedObjectContext:moc
                                                                            withEmailAddress:emailAddress
                                                                            streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        
    }];
}

- (void)updatePhoneNumber:(NSString *)phoneNumber xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        [XMPPLoginUserCoreDataStorageObject updatePhoneNumberInManagedObjectContext:moc
                                                                    withPhoneNumber:phoneNumber
                                                                   streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        
    }];
}
- (void)updateEmailAddress:(NSString *)emailAddress xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        [XMPPLoginUserCoreDataStorageObject updateEmailAddressInManagedObjectContext:moc
                                                                    withEmailAddress:emailAddress
                                                                    streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        
    }];
}
- (void)updateStreamBareJidStrWithPhoneNumber:(NSString *)phoneNumber emailAddress:(NSString *)emailAddress xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        [XMPPLoginUserCoreDataStorageObject updateAllInManagedObjectContext:moc
                                                            withPhoneNumber:phoneNumber
                                                           withEmailAddress:emailAddress
                                                                   nickName:nil
                                                                   password:nil
                                                                  longitude:nil
                                                                   latitude:nil
                                                           streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        
    }];
}

- (NSString *)streamBareJidStrWithPhoneNumber:(NSString *)phoneNumber
{
    __block NSString *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                    withPhoneNumber:phoneNumber];
        if (user) {
            
            result = user.streamBareJidStr;
        }
        
    }];
    
    return result;
}
- (NSString *)streamBareJidStrWithEmailAddress:(NSString *)emailAddress
{
    __block NSString *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                   withEmailAddress:emailAddress];
        if (user) {
            result = user.streamBareJidStr;
        }
        
    }];
    
    return result;
}

- (NSString *)phoneNumberWithStreamBareJidStr:(NSString *)streamBareJidStr
{
    __block NSString *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                   streamBareJidStr:streamBareJidStr];
        if (user) {
            result = user.phoneNumber;
        }
        
    }];
    
    return result;
}
- (NSString *)emailAddressWithStreamBareJidStr:(NSString *)streamBareJidStr
{
    __block NSString *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                   streamBareJidStr:streamBareJidStr];
        if (user) {
            result = user.emailAddress;
        }
        
    }];
    
    return result;
}

- (void)deleteLoginUserWithPhoneNumber:(NSString *)phoneNumber
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        [XMPPLoginUserCoreDataStorageObject deleteFromManagedObjectContext:moc withPhoneNumber:phoneNumber];
    }];
}
- (void)deleteLoginUserWithEmailAddress:(NSString *)emailAddress
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        [XMPPLoginUserCoreDataStorageObject deleteFromManagedObjectContext:moc withEmailAddress:emailAddress];
    }];
}
- (void)deleteLoginUserWithStreamBareJidStr:(NSString *)streamBareJidStr
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        [XMPPLoginUserCoreDataStorageObject deleteFromManagedObjectContext:moc streamBareJidStr:streamBareJidStr];
    }];
}
@end
