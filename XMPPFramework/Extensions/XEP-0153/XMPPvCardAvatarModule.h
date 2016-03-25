//
//  XMPPvCardAvatarModule.h
//  XEP-0153 vCard-Based Avatars
//
//  Created by Eric Chamberlain on 3/9/11.
//  Copyright 2011 RF.com. All rights reserved.

/*
 *  NOTE: Currently this implementation only supports downloading and caching avatars.
 */


#import <Foundation/Foundation.h>

#if !TARGET_OS_IPHONE
  #import <Cocoa/Cocoa.h>
#endif

#import "XMPP.h"
#import "XMPPvCardTempModule.h"

#define _XMPP_VCARD_AVATAR_MODULE_H

@protocol XMPPvCardAvatarStorage;


@interface XMPPvCardAvatarModule : XMPPModule <XMPPvCardTempModuleDelegate>
{
	__strong XMPPvCardTempModule *_xmppvCardTempModule;
	__strong id <XMPPvCardAvatarStorage> _moduleStorage;
	
	BOOL _autoClearMyvcard;
}

@property(nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;


/*
 * XEP-0153 Section 4.2 rule 1
 *
 * A client MUST NOT advertise an avatar image without first downloading the current vCard.
 * Once it has done this, it MAY advertise an image.
 *
 * Default YES
 */
@property(nonatomic, assign) BOOL autoClearMyvcard;


- (id)initWithvCardTempModule:(XMPPvCardTempModule *)xmppvCardTempModule;
- (id)initWithvCardTempModule:(XMPPvCardTempModule *)xmppvCardTempModule  dispatchQueue:(dispatch_queue_t)queue;



- (NSData *)photoDataForJID:(XMPPJID *)jid;
- (NSString *)phoneNumberForJID:(XMPPJID *)jid;
- (NSString *)emailAddressForJID:(XMPPJID *)jid;
- (NSString *)nickNameForJID:(XMPPJID *)jid;
- (NSString *)photoURLForBareJidStr:(NSString *)bareJidStr;
- (NSString *)qqIdForBareJidStr:(NSString *)bareJidStr;
- (NSString *)wechatIdForBareJidStr:(NSString *)bareJidStr;
- (NSString *)bareJidStrWithPhone:(NSString *)phone;


- (void)fetchPhotoDataWithBareJidStr:(NSString *)bareJidStr
                     completionBlock:(CompletionBlock)completionBlock;
- (void)fetchPhoneNumberWithBareJidStr:(NSString *)bareJidStr
                       completionBlock:(CompletionBlock)completionBlock;
- (void)fetchEmailAddressWithBareJidStr:(NSString *)bareJidStr
                              completionBlock:(CompletionBlock)completionBlock;
- (void)fetchNickNameWithBareJidStr:(NSString *)bareJidStr
                    completionBlock:(CompletionBlock)completionBlock;
- (void)fetchPhotoURLWithBareJidStr:(NSString *)bareJidStr
                    completionBlock:(CompletionBlock)completionBlock;
- (void)fetchQqIdWithBareJidStr:(NSString *)bareJidStr
                completionBlock:(CompletionBlock)completionBlock;
- (void)fetchWechatIdWithBareJidStr:(NSString *)bareJidStr
                    completionBlock:(CompletionBlock)completionBlock;

- (void)vCardWithBareJidStr:(NSString *)bareJidStr
            completionBlock:(CompletionBlock)completionBlock;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol XMPPvCardAvatarDelegate <NSObject>

#if TARGET_OS_IPHONE
- (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule 
              didReceivePhoto:(UIImage *)photo
                       forJID:(XMPPJID *)jid;
#else
- (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule 
              didReceivePhoto:(NSImage *)photo
                       forJID:(XMPPJID *)jid;
#endif

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol XMPPvCardAvatarStorage <NSObject>

- (NSData *)photoDataForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream;
- (NSString *)photoURLForJID:(XMPPJID *)jid  xmppStream:(XMPPStream *)stream;
- (NSString *)photoHashForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream;

- (NSString *)phoneNumberForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream;
- (NSString *)emailAddressForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream;
- (NSString *)nickNameForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream;
- (NSString *)qqidForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream;
- (NSString *)wechatIdForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream;
- (NSString *)bareJidStrForPhone:(NSString *)phone xmppStream:(XMPPStream *)stream;


/**
 * Clears the vCardTemp from the store.
 * This is used so we can clear any cached vCardTemp's for the JID.
**/
- (void)clearvCardTempForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream;

@end

@interface XMPPvCardAvatarModule (Deprecated)

- (void)requestvCardWithBareJidStr:(NSString *)bareJidStr
                   completionBlock:(CompletionBlock)completionBlock NS_DEPRECATED_IOS(6_0, 7_0, "该方法已经废弃请使用vCardWithBareJidStr:completionBlock:");
@end

