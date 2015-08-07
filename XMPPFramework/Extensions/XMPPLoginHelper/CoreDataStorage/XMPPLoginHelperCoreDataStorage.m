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

- (void)savePhoneNumber:(NSString *)phoneNumber
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                        phoneNumber:phoneNumber];
        if (user) {
            user.loginId = phoneNumber;
        }else{
            [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                 phoneNumber:phoneNumber
                                                                   autoLogin:YES
                                                            streamBareJidStr:nil];
        }
           
    }];
}

- (void)saveEmailAddress:(NSString *)emailAddress
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                       emailAddress:emailAddress];
        if (user) {
            user.loginId = emailAddress;
        }else{
            [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                emailAddress:emailAddress
                                                                   autoLogin:YES
                                                            streamBareJidStr:nil];
        }
        
    }];
}


- (void)updatePhoneNumber:(NSString *)phoneNumber xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        [XMPPLoginUserCoreDataStorageObject updatePhoneNumberInManagedObjectContext:moc
                                                                        phoneNumber:phoneNumber
                                                                   streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        
    }];
}
- (void)updateEmailAddress:(NSString *)emailAddress xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        [XMPPLoginUserCoreDataStorageObject updateEmailAddressInManagedObjectContext:moc
                                                                        emailAddress:emailAddress
                                                                    streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        
    }];
}
- (void)updateStreamBareJidStrWithPhoneNumber:(NSString *)phoneNumber emailAddress:(NSString *)emailAddress xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        XMPPLoginUserCoreDataStorageObject *object = nil;
        
        if (phoneNumber.length > 0) {
            object = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                          phoneNumber:phoneNumber];
        }else if(emailAddress.length > 0){
            object = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc emailAddress:emailAddress];
        }
        
        if (object != nil) {
            object.streamBareJidStr = [[self myJIDForXMPPStream:stream] bare];
        }
        
    }];
}

- (NSString *)streamBareJidStrWithPhoneNumber:(NSString *)phoneNumber
{
    __block NSString *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                        phoneNumber:phoneNumber];
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
                                                                                                       emailAddress:emailAddress];
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
            result = user.loginId;
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
            result = user.loginId;
        }
        
    }];
    
    return result;
}

- (NSData *)clientDataCurrentXMPPStream:(XMPPStream *)stream
{
    __block NSData *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                   streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        if (user) {
            result = user.clientKeyData;
        }
        
    }];
    
    return result;
}
- (NSData *)clientDataForPhoneNumber:(NSString *)phoneNumber
{
    __block NSData *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc phoneNumber:phoneNumber];
        if (user) {
            result = user.clientKeyData;
        }
        
    }];
    
    return result;
}
- (NSData *)clientDataForEmailAddress:(NSString *)emailAddress
{
    __block NSData *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc emailAddress:emailAddress];
        if (user) {
            result = user.clientKeyData;
        }
        
    }];
    
    return result;
}
- (NSData *)serverDataCurrentXMPPStream:(XMPPStream *)stream
{
    __block NSData *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                   streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        if (user) {
            result = user.serverKeyData;
        }
        
    }];
    
    return result;
}
- (NSData *)serverDataForPhoneNumber:(NSString *)phoneNumber
{
    __block NSData *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc phoneNumber:phoneNumber];
        if (user) {
            result = user.serverKeyData;
        }
        
    }];
    
    return result;
}
- (NSData *)serverDataForEmailAddress:(NSString *)emailAddress
{
    __block NSData *result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc emailAddress:emailAddress];
        if (user) {
            result = user.serverKeyData;
        }
        
    }];
    
    return result;
}

- (BOOL)autoLoginWithPhoneNumber:(NSString *)phoneNumber
{
    __block BOOL result = NO;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc phoneNumber:phoneNumber];
        if (user) {
            result = [user.autoLogin boolValue];
        }
        
    }];
    
    return result;
}
- (BOOL)autoLoginWithEmailAddress:(NSString *)emailAddress
{
    __block BOOL result = NO;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc emailAddress:emailAddress];
        if (user) {
            result = [user.autoLogin boolValue];
        }
        
    }];
    
    return result;
}

- (BOOL)autoLoginCurrentXMPPStream:(XMPPStream *)stream
{
    __block BOOL result = NO;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *user = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        if (user) {
            result = [user.autoLogin boolValue];
        }
        
    }];
    
    return result;
}

- (id)allLoginUserInDatabase
{
    __block NSArray *allLoginUsers = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([XMPPLoginUserCoreDataStorageObject class])
                                                  inManagedObjectContext:moc];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setIncludesPendingChanges:YES];
        [fetchRequest setFetchLimit:saveThreshold];
        
        allLoginUsers = [moc executeFetchRequest:fetchRequest error:nil];

    }];
    
    return allLoginUsers;
}
- (id)currentLoginUserWithXMPPStream:(XMPPStream *)stream
{
    __block id result = nil;
    
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([XMPPLoginUserCoreDataStorageObject class])
                                                  inManagedObjectContext:moc];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@",[[self myJIDForXMPPStream:stream] bare]];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setIncludesPendingChanges:YES];
        [fetchRequest setFetchLimit:1];
        
        result = [[moc executeFetchRequest:fetchRequest error:nil] lastObject];
        
    }];
    
    return result;
}


- (void)deleteLoginUserWithPhoneNumber:(NSString *)phoneNumber
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        [XMPPLoginUserCoreDataStorageObject deleteFromManagedObjectContext:moc phoneNumber:phoneNumber];
    }];
}
- (void)deleteLoginUserWithEmailAddress:(NSString *)emailAddress
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        [XMPPLoginUserCoreDataStorageObject deleteFromManagedObjectContext:moc emailAddress:emailAddress];
    }];
}
- (void)deleteLoginUserWithStreamBareJidStr:(NSString *)streamBareJidStr
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        [XMPPLoginUserCoreDataStorageObject deleteFromManagedObjectContext:moc streamBareJidStr:streamBareJidStr];
    }];
}

- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData forPhoneNumber:(NSString *)phoneNumber
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *object = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                          phoneNumber:phoneNumber];
        if (object != nil) {
            object.clientKeyData = clientData;
            object.serverKeyData = serverData;
        }else{
            [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                 phoneNumber:phoneNumber
                                                                   autoLogin:YES
                                                               clientKeyData:clientData serverKeyData:serverData
                                                            streamBareJidStr:nil];
        }
    }];
}
- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData forEmailAddress:(NSString *)emailAddress
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *object = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                         emailAddress:emailAddress];
        if (object != nil) {
            object.clientKeyData = clientData;
            object.serverKeyData = serverData;
        }else{
            [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                emailAddress:emailAddress
                                                                   autoLogin:YES
                                                               clientKeyData:clientData
                                                               serverKeyData:serverData
                                                            streamBareJidStr:nil];
        }
    }];
}
- (void)saveCurrentUserClientData:(NSData *)clientData serverData:(NSData *)serverData xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *object = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                     streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        if (object != nil) {
            object.clientKeyData = clientData;
            object.serverKeyData = serverData;
        }else{
            object = [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc phoneNumber:nil autoLogin:YES streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
            object.clientKeyData = clientData;
            object.serverKeyData = serverData;
        }
    }];
}

- (void)updateLoginTimeWithPhoneNumber:(NSString *)phoneNumber
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *object = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc phoneNumber:phoneNumber];
        if (object) {
            object.loginTime = [NSDate date];
        }
    }];
}
- (void)updateLoginTimeWithEmailAddress:(NSString *)emailAddress
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *object = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc emailAddress:emailAddress];
        if (object) {
            object.loginTime = [NSDate date];
        }
    }];
}
- (void)updateLoginTimeCurrentXMPPStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *object = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                     streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        if (object) {
            object.loginTime = [NSDate date];
        }
    }];
}
- (void)updateAutoLogin:(BOOL)autoLogin forPhoneNumber:(NSString *)phoneNumber
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *object = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc phoneNumber:phoneNumber];
        if (object) {
            object.autoLogin = @(autoLogin);
        }
    }];
}
- (void)updateAutoLogin:(BOOL)autoLogin forEmailAddress:(NSString *)emailAddress
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *object = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc emailAddress:emailAddress];
        if (object) {
            object.autoLogin = @(autoLogin);
        }
    }];
}
- (void)updateAutoLoginCurrentLoginUser:(BOOL)autoLogin xmppStream:(XMPPStream *)stream
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        XMPPLoginUserCoreDataStorageObject *object = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
        if (object) {
            object.autoLogin = @(autoLogin);
        }
    }];
}
@end
