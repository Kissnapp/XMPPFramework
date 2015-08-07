//
//  XMPPLoginUser.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPLoginHelper.h"
#import "XMPP.h"
#import "XMPPIDTracker.h"
#import "XMPPLogging.h"
#import "XMPPFramework.h"
#import "DDList.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
// Log flags: trace
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@implementation XMPPLoginHelper
@synthesize xmppLoginHelperStorage = _xmppLoginHelperStorage;

- (id)init
{
    return [self initWithLoginHelperStorage:nil dispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    
    return [self initWithLoginHelperStorage:nil dispatchQueue:queue];
}

- (id)initWithLoginHelperStorage:(id <XMPPLoginHelperStorage>)storage
{
    return [self initWithLoginHelperStorage:storage dispatchQueue:NULL];
}

- (id)initWithLoginHelperStorage:(id <XMPPLoginHelperStorage>)storage dispatchQueue:(dispatch_queue_t)queue
{
    NSParameterAssert(storage != nil);
    
    if ((self = [super initWithDispatchQueue:queue])){
        if ([storage configureWithParent:self queue:moduleQueue]){
            _xmppLoginHelperStorage = storage;
        }else{
            XMPPLogError(@"%@: %@ - Unable to configure storage!", THIS_FILE, THIS_METHOD);
        }
        
        //setting the dafault data
        //your code ...
    }
    return self;
}

- (BOOL)activate:(XMPPStream *)aXmppStream
{
    XMPPLogTrace();
    
    if ([super activate:aXmppStream])
    {
        XMPPLogVerbose(@"%@: Activated", THIS_FILE);
        
        // Reserved for future potential use
        
        return YES;
    }
    
    return NO;
}

- (void)deactivate
{
    XMPPLogTrace();
    
    // Reserved for future potential use
    
    [super deactivate];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Internal
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * This method may optionally be used by XMPPLoginUserStorage classes (declared in XMPPLoginUserPrivate.h).
 **/
- (GCDMulticastDelegate *)multicastDelegate
{
    return multicastDelegate;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Configuration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id <XMPPLoginHelperStorage>)xmppLoginHelperStorage
{
    // Note: The xmppRosterStorage variable is read-only (set in the init method)
    
    return _xmppLoginHelperStorage;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - setter/getter
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
- (void)setActiveUserID:(NSString *)activeuserid
{
    dispatch_block_t block = ^{
        activeUserID = [activeuserid copy];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (NSString *)activeUserID
{
    if (!activeUserID) {
        activeUserID = [self userIDWithBareJIDStr:[[xmppStream myJID] bare]];
    }
    
    return activeUserID;
}
 */
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)savePhoneNumber:(NSString *)phoneNumber
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage savePhoneNumber:phoneNumber];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)saveEmailAddress:(NSString *)emailAddress
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage saveEmailAddress:emailAddress];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)updatePhoneNumberCurrentLoginUser:(NSString *)phoneNumber
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage updatePhoneNumber:phoneNumber xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)updateEmailAddressCurrentLoginUser:(NSString *)emailAddress
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage updateEmailAddress:emailAddress xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)updateStreamBareJidStrWithPhoneNumber:(NSString *)phoneNumber
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage updateStreamBareJidStrWithPhoneNumber:phoneNumber emailAddress:nil xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)updateStreamBareJidStrWithEmailAddress:(NSString *)emailAddress
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage updateStreamBareJidStrWithPhoneNumber:nil emailAddress:emailAddress xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}


- (void)deleteUserWithPhoneNumber:(NSString *)phoneNumber
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage deleteLoginUserWithPhoneNumber:phoneNumber];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)deleteUserWithEmailAddress:(NSString *)emailAddress
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage deleteLoginUserWithEmailAddress:emailAddress];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)deleteUserWithStreamBareJidStr:(NSString *)streamBareJidStr
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage deleteLoginUserWithStreamBareJidStr:streamBareJidStr];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)deleteUserCurrentLoginUser
{
    [self deleteUserWithStreamBareJidStr:[[xmppStream myJID] bare]];
}



- (NSString *)streamBareJidStrWithPhoneNumber:(NSString *)phoneNumber
{
    __block NSString *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage streamBareJidStrWithPhoneNumber:phoneNumber];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}
- (NSString *)streamBareJidStrWithEmailAddress:(NSString *)emailAddress
{
    __block NSString *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage streamBareJidStrWithEmailAddress:emailAddress];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (NSString *)currentPhoneNumber
{
    __block NSString *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage phoneNumberWithStreamBareJidStr:[[xmppStream myJID] bare]];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (NSString *)currentEmaiAddress
{
    __block NSString *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage emailAddressWithStreamBareJidStr:[[xmppStream myJID] bare]];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}
- (NSString *)phoneNumberWithStreamBareJidStr:(NSString *)streamBareJidStr
{
    __block NSString *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage phoneNumberWithStreamBareJidStr:streamBareJidStr];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}
- (NSString *)emailAddressWithStreamBareJidStr:(NSString *)streamBareJidStr
{
    __block NSString *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage emailAddressWithStreamBareJidStr:streamBareJidStr];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (NSData *)clientDataCurrentLoginUser
{
    __block NSData *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage clientDataCurrentXMPPStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}
- (NSData *)clientDataForPhoneNumber:(NSString *)phoneNumber
{
    __block NSData *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage clientDataForPhoneNumber:phoneNumber];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}
- (NSData *)clientDataForEmailAddress:(NSString *)emailAddress
{
    __block NSData *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage clientDataForEmailAddress:emailAddress];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (NSData *)serverDataCurrentLoginUser
{
    __block NSData *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage serverDataCurrentXMPPStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}
- (NSData *)serverDataForPhoneNumber:(NSString *)phoneNumber
{
    __block NSData *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage serverDataForPhoneNumber:phoneNumber];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}
- (NSData *)serverDataForEmailAddress:(NSString *)emailAddress
{
    __block NSData *result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage serverDataForEmailAddress:emailAddress];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}
- (BOOL)autoLoginWithPhoneNumber:(NSString *)phoneNumber
{
    __block BOOL result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage autoLoginWithPhoneNumber:phoneNumber];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}
- (BOOL)autoLoginWithEmailAddress:(NSString *)emailAddress
{
    __block BOOL result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage autoLoginWithEmailAddress:emailAddress];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}
- (BOOL)autoLoginCurrentUser
{
    __block BOOL result = nil;
    
    dispatch_block_t block = ^{
        result = [_xmppLoginHelperStorage autoLoginCurrentXMPPStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (id)allLoginUserInDatabase
{
    __block id allLoginUsers = nil;
    
    dispatch_block_t block = ^{
        allLoginUsers = [_xmppLoginHelperStorage allLoginUserInDatabase];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return allLoginUsers;
}
- (id)currentLoginUser
{
    __block id currentLoginUser = nil;
    
    dispatch_block_t block = ^{
        currentLoginUser = [_xmppLoginHelperStorage currentLoginUserWithXMPPStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return currentLoginUser;
}

- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData forPhoneNumber:(NSString *)phoneNumber
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage saveClientData:clientData serverData:serverData forPhoneNumber:phoneNumber];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData forEmailAddress:(NSString *)emailAddress
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage saveClientData:clientData serverData:serverData forEmailAddress:emailAddress];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)saveCurrentUserClientData:(NSData *)clientData serverData:(NSData *)serverData
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage saveCurrentUserClientData:clientData serverData:serverData xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)updateLoginTimeWithPhoneNumber:(NSString *)phoneNumber
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage updateLoginTimeWithPhoneNumber:phoneNumber];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)updateLoginTimeWithEmailAddress:(NSString *)emailAddress
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage updateLoginTimeWithEmailAddress:emailAddress];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)updateLoginTimeCurrentLoginUser
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage updateLoginTimeCurrentXMPPStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)updateAutoLogin:(BOOL)autoLogin forPhoneNumber:(NSString *)phoneNumber
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage updateAutoLogin:autoLogin forPhoneNumber:phoneNumber];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)updateAutoLogin:(BOOL)autoLogin forEmailAddress:(NSString *)emailAddress
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage updateAutoLogin:autoLogin forEmailAddress:emailAddress];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)updateAutoLoginCurrentLoginUser:(BOOL)autoLogin
{
    dispatch_block_t block = ^{
        [_xmppLoginHelperStorage updateAutoLoginCurrentLoginUser:autoLogin xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStreamDelegate methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    XMPPLogTrace();
    switch (sender.authenticateType) {
        case XMPPLoginTypePhone:
            [self savePhoneNumber:[[XMPPJID jidWithString:sender.authenticateStr] user]];
            break;
        case XMPPLoginTypeEmail:
            [self saveEmailAddress:[[XMPPJID jidWithString:sender.authenticateStr] user]];
            break;
        default:
            break;
    }
}

- (void)xmppStreamDidChangeMyJID:(XMPPStream *)sender
{
    XMPPLogTrace();
    
    if (sender.hasMyJIDFromServer) {
        switch (sender.authenticateType) {
            case XMPPLoginTypePhone:
                [self updateStreamBareJidStrWithPhoneNumber:[[XMPPJID jidWithString:sender.authenticateStr] user]];
                break;
            case XMPPLoginTypeEmail:
                [self updateStreamBareJidStrWithEmailAddress:[[XMPPJID jidWithString:sender.authenticateStr] user]];
                break;
            default:
                break;
        }
    }
}

- (NSString *)streamBareJidStrWithAuthenticateStr:(NSString *)authenticateStr authenticateType:(XMPPLoginType)authenticateType
{
    NSString *result = nil;
    
    switch (authenticateType) {
        case XMPPLoginTypePhone:
            result = [self streamBareJidStrWithPhoneNumber:authenticateStr];
            break;
         case XMPPLoginTypeEmail:
            result = [self streamBareJidStrWithEmailAddress:authenticateStr];
            break;
        default:
            break;
    }
    
    return result;
}

- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData xmppStream:(XMPPStream *)sender
{
    switch (sender.authenticateType) {
        case XMPPLoginTypePhone:
            [self saveClientData:clientData serverData:serverData forPhoneNumber:[[XMPPJID jidWithString:sender.authenticateStr] user]];
            break;
        case XMPPLoginTypeEmail:
            [self  saveClientData:clientData serverData:serverData forEmailAddress:[[XMPPJID jidWithString:sender.authenticateStr] user]];
            break;
        default:
            [self saveCurrentUserClientData:clientData serverData:serverData];
            break;
    }
}

- (NSData *)clientKeyDataWithXMPPStream:(XMPPStream *)sender
{
    return nil;
}

- (NSData *)serverKeyDataWithXMPPStream:(XMPPStream *)sender
{
    return nil;
}

@end
