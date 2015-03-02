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

- (void)savePhoneNumber:(NSString *)phoneNumber;
- (void)saveEmailAddress:(NSString *)emailAddress;

- (void)updatePhoneNumber:(NSString *)phoneNumber;
- (void)updateEmailAddress:(NSString *)emailAddress;
- (void)updateStreamBareJidStrWithPhoneNumber:(NSString *)phoneNumber;
- (void)updateStreamBareJidStrWithEmailAddress:(NSString *)emailAddress;

- (void)deleteLoginUserWithPhoneNumber:(NSString *)phoneNumber;
- (void)deleteLoginUserWithEmailAddress:(NSString *)emailAddress;
- (void)deleteLoginUserWithStreamBareJidStr:(NSString *)streamBareJidStr;

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

- (void)savePhoneNumber:(NSString *)phoneNumber xmppStream:(XMPPStream *)stream;
- (void)saveEmailAddress:(NSString *)emailAddress xmppStream:(XMPPStream *)stream;

- (void)updatePhoneNumber:(NSString *)phoneNumber xmppStream:(XMPPStream *)stream;
- (void)updateEmailAddress:(NSString *)emailAddress xmppStream:(XMPPStream *)stream;
- (void)updateStreamBareJidStrWithPhoneNumber:(NSString *)phoneNumber emailAddress:(NSString *)emailAddress xmppStream:(XMPPStream *)stream;

- (void)deleteLoginUserWithPhoneNumber:(NSString *)phoneNumber;
- (void)deleteLoginUserWithEmailAddress:(NSString *)emailAddress;
- (void)deleteLoginUserWithStreamBareJidStr:(NSString *)streamBareJidStr;

- (NSString *)streamBareJidStrWithPhoneNumber:(NSString *)phoneNumber;
- (NSString *)streamBareJidStrWithEmailAddress:(NSString *)emailAddress;

- (NSString *)phoneNumberWithStreamBareJidStr:(NSString *)streamBareJidStr;
- (NSString *)emailAddressWithStreamBareJidStr:(NSString *)streamBareJidStr;

@end

@protocol XMPPLoginHelperDelegate <NSObject>

@required

@optional

@end