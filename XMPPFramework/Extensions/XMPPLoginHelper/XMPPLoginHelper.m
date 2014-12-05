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
    
    return xmppLoginHelperStorage;
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
/*
- (NSString *)userIDWithBareJIDStr:(NSString *)bareJidStr
{
    __block NSString *result = nil;
    
    dispatch_block_t block = ^{
        result = [xmppLoginUserStorage userIDWithBareJIDStr:bareJidStr];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;

}
- (NSString *)bareJidStrWithUserID:(NSString *)userID
{
    __block NSString *result = nil;
    
    dispatch_block_t block = ^{
        result = [xmppLoginUserStorage bareJidStrWithUserID:userID];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}
*/
- (void)savePhoneNumber:(NSString *)phoneNumber streamBareJidStr:(NSString *)streamBareJidStr;
- (void)saveEmailAddress:(NSString *)emailAddress streamBareJidStr:(NSString *)streamBareJidStr;

- (void)updatePhoneNumber:(NSString *)phoneNumber withStreamBareJidStr:(NSString *)streamBareJidStr;
- (void)updateEmailAddress:(NSString *)emailAddress withStreamBareJidStr:(NSString *)streamBareJidStr;
- (void)updateStreamBareJidStr:(NSString *)streamBareJidStr withPhoneNumber:(NSString *)phoneNumber;
- (void)updateStreamBareJidStr:(NSString *)streamBareJidStr withEmailAddress:(NSString *)emailAddress;

- (NSString *)streamBareJidStrWithPhoneNumber:(NSString *)phoneNumber;
- (NSString *)streamBareJidStrWithEmailAddress:(NSString *)emailAddress;
- (NSString *)phoneNumberWithStreamBareJidStr:(NSString *)streamBareJidStr;
- (NSString *)emailAddressWithStreamBareJidStr:(NSString *)streamBareJidStr;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStreamDelegate methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    
}

- (void)xmppStreamDidChangeMyJID:(XMPPStream *)xmppStream
{

}


@end
