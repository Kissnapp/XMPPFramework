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

- (void)updatePhoneNumberCurrentLoginUser:(NSString *)phoneNumber;
- (void)updateEmailAddressCurrentLoginUser:(NSString *)emailAddress;
- (void)updateStreamBareJidStrWithPhoneNumber:(NSString *)phoneNumber;
- (void)updateStreamBareJidStrWithEmailAddress:(NSString *)emailAddress;

- (void)deleteUserWithPhoneNumber:(NSString *)phoneNumber;
- (void)deleteUserWithEmailAddress:(NSString *)emailAddress;
- (void)deleteUserWithStreamBareJidStr:(NSString *)streamBareJidStr;
- (void)deleteUserCurrentLoginUser;

- (NSString *)streamBareJidStrWithPhoneNumber:(NSString *)phoneNumber;
- (NSString *)streamBareJidStrWithEmailAddress:(NSString *)emailAddress;

- (NSString *)phoneNumberWithStreamBareJidStr:(NSString *)streamBareJidStr;
- (NSString *)emailAddressWithStreamBareJidStr:(NSString *)streamBareJidStr;

- (NSString *)currentPhoneNumber;
- (NSString *)currentEmaiAddress;

- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData forPhoneNumber:(NSString *)phoneNumber;
- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData forEmailAddress:(NSString *)emailAddress;
- (void)saveCurrentUserClientData:(NSData *)clientData serverData:(NSData *)serverData;

- (NSData *)clientDataCurrentLoginUser;
- (NSData *)clientDataForPhoneNumber:(NSString *)phoneNumber;
- (NSData *)clientDataForEmailAddress:(NSString *)emailAddress;

- (NSData *)serverDataCurrentLoginUser;
- (NSData *)serverDataForPhoneNumber:(NSString *)phoneNumber;
- (NSData *)serverDataForEmailAddress:(NSString *)emailAddress;

- (void)updateLoginTimeWithPhoneNumber:(NSString *)phoneNumber;
- (void)updateLoginTimeWithEmailAddress:(NSString *)emailAddress;
- (void)updateLoginTimeCurrentLoginUser;

- (BOOL)autoLoginWithPhoneNumber:(NSString *)phoneNumber;
- (BOOL)autoLoginWithEmailAddress:(NSString *)emailAddress;
- (BOOL)autoLoginCurrentUser;

- (void)updateAutoLogin:(BOOL)autoLogin forPhoneNumber:(NSString *)phoneNumber;
- (void)updateAutoLogin:(BOOL)autoLogin forEmailAddress:(NSString *)emailAddress;
- (void)updateAutoLoginCurrentLoginUser:(BOOL)autoLogin;

- (id)allLoginUserInDatabase;
- (id)currentLoginUser;


@property (strong, readonly) id <XMPPLoginHelperStorage> xmppLoginHelperStorage;

@end


@protocol XMPPLoginHelperStorage <NSObject>

@required

- (BOOL)configureWithParent:(XMPPLoginHelper *)aParent queue:(dispatch_queue_t)queue;

@optional

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




- (void)savePhoneNumber:(NSString *)phoneNumber;
- (void)saveEmailAddress:(NSString *)emailAddress;

- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData forPhoneNumber:(NSString *)phoneNumber;
- (void)saveClientData:(NSData *)clientData serverData:(NSData *)serverData forEmailAddress:(NSString *)emailAddress;
- (void)saveCurrentUserClientData:(NSData *)clientData serverData:(NSData *)serverData xmppStream:(XMPPStream *)stream;

- (NSData *)clientDataCurrentXMPPStream:(XMPPStream *)stream;
- (NSData *)clientDataForPhoneNumber:(NSString *)phoneNumber;
- (NSData *)clientDataForEmailAddress:(NSString *)emailAddress;

- (NSData *)serverDataCurrentXMPPStream:(XMPPStream *)stream;
- (NSData *)serverDataForPhoneNumber:(NSString *)phoneNumber;
- (NSData *)serverDataForEmailAddress:(NSString *)emailAddress;

- (void)updateLoginTimeWithPhoneNumber:(NSString *)phoneNumber;
- (void)updateLoginTimeWithEmailAddress:(NSString *)emailAddress;
- (void)updateLoginTimeCurrentXMPPStream:(XMPPStream *)stream;

- (BOOL)autoLoginWithPhoneNumber:(NSString *)phoneNumber;
- (BOOL)autoLoginWithEmailAddress:(NSString *)emailAddress;
- (BOOL)autoLoginCurrentXMPPStream:(XMPPStream *)stream;

- (void)updateAutoLogin:(BOOL)autoLogin forPhoneNumber:(NSString *)phoneNumber;
- (void)updateAutoLogin:(BOOL)autoLogin forEmailAddress:(NSString *)emailAddress;
- (void)updateAutoLoginCurrentLoginUser:(BOOL)autoLogin xmppStream:(XMPPStream *)stream;

- (id)allLoginUserInDatabase;
- (id)currentLoginUserWithXMPPStream:(XMPPStream *)stream;

@end

@protocol XMPPLoginHelperDelegate <NSObject>

@required

@optional

@end