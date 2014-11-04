//
//  XMPPLoginUser.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPLoginUser.h"
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

@implementation XMPPLoginUser

- (id)init
{
    return [self initWithLoginUserStorage:nil dispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    
    return [self initWithLoginUserStorage:nil dispatchQueue:queue];
}

- (id)initWithLoginUserStorage:(id <XMPPLoginUserStorage>)storage
{
    return [self initWithLoginUserStorage:storage dispatchQueue:NULL];
}

- (id)initWithLoginUserStorage:(id <XMPPLoginUserStorage>)storage dispatchQueue:(dispatch_queue_t)queue
{
    NSParameterAssert(storage != nil);
    
    if ((self = [super initWithDispatchQueue:queue])){
        if ([storage configureWithParent:self queue:moduleQueue]){
            xmppLoginUserStorage = storage;
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

- (id <XMPPLoginUserStorage>)xmppLoginUserStorage
{
    // Note: The xmppRosterStorage variable is read-only (set in the init method)
    
    return xmppLoginUserStorage;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - setter/getter
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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

- (void)saveLoginUserID:(NSString *)loginUserID
{
    [self saveLoginUserID:loginUserID bareJid:nil];
}

- (void)saveLoginUserID:(NSString *)loginUserID bareJid:(NSString *)bareJid
{
    [self setActiveUserID:loginUserID];
    
    dispatch_block_t block = ^{
        @autoreleasepool {
            
            NSString *loginID = [loginUserID copy];
            NSString *streamBareJidStr = [bareJid copy];
            [xmppLoginUserStorage saveLoginUserID:loginID bareJid:streamBareJidStr];
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)updatebareJidStr:(NSString *)bareJidStr withUserID:(NSString *)activeuserid
{
    dispatch_block_t block = ^{
        @autoreleasepool {
            
            NSString *loginID = [activeuserid copy];
            NSString *streamBareJidStr = [bareJidStr copy];
            [xmppLoginUserStorage updatebareJidStr:streamBareJidStr withUserID:loginID];
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)deleteLoginUserWithUserID:(NSString *)userID
{
    dispatch_block_t block = ^{
        @autoreleasepool {
            
            NSString *loginID = [userID copy];
            [xmppLoginUserStorage deleteLoginUserWithUserID:loginID];
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)deleteLoginUserWithUerBareJidStr:(NSString *)bareJidStr
{
    dispatch_block_t block = ^{
        
        @autoreleasepool {
            
            NSString *streamBareJidStr = [bareJidStr copy];
            [xmppLoginUserStorage deleteLoginUserWithUerBareJidStr:streamBareJidStr];
        }
        
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
    [self updatebareJidStr:[[sender myJID] bare] withUserID:activeUserID];
    if ([multicastDelegate respondsToSelector:@selector(xmppLoginUser:didLoginSucceedWith:)]) {
        [multicastDelegate xmppLoginUser:self didLoginSucceedWith:sender];
    }
}
//- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
//{
//    [self setActiveUserID:nil];
//}
//
//- (void)xmppStreamDidChangeMyJID:(XMPPStream *)xmppStream
//{
//
//}
//- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
//{
//
//}
//- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
//{
//    
//}

@end
