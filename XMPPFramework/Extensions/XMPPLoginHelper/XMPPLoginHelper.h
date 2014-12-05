//
//  XMPPLoginHelper.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPModule.h"

@protocol XMPPLoginHelperStorage;
@protocol XMPPLoginHelperDelegate;


@interface XMPPLoginHelper : XMPPModule
{
    __strong id <XMPPLoginHelperStorage> _xmppLoginHelperStorage;
}

- (id)initWithLoginHelperStorage:(id <XMPPLoginHelperStorage>)storage;
- (id)initWithLoginHelperStorage:(id <XMPPLoginHelperStorage>)storage dispatchQueue:(dispatch_queue_t)queue;

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

@property (strong, readonly) id <XMPPLoginHelperStorage> xmppLoginHelperStorage;

@end


@protocol XMPPLoginHelperStorage <NSObject>

@required

- (BOOL)configureWithParent:(XMPPLoginHelper *)aParent queue:(dispatch_queue_t)queue;

@optional

@end

@protocol XMPPLoginHelperDelegate <NSObject>

@required
@optional


@end