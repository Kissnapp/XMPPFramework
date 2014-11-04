//
//  XMPPLoginUser.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPModule.h"

@protocol XMPPLoginUserStorage;
@protocol XMPPLoginUserDelegate;


@interface XMPPLoginUser : XMPPModule
{
    __strong id <XMPPLoginUserStorage> xmppLoginUserStorage;
    
    NSString *activeUserID;

}

- (id)initWithLoginUserStorage:(id <XMPPLoginUserStorage>)storage;
- (id)initWithLoginUserStorage:(id <XMPPLoginUserStorage>)storage dispatchQueue:(dispatch_queue_t)queue;

- (NSString *)bareJidStrWithUserID:(NSString *)userID;
- (NSString *)userIDWithBareJIDStr:(NSString *)bareJidStr;

- (void)saveLoginUserID:(NSString *)loginUserID;
- (void)saveLoginUserID:(NSString *)loginUserID bareJid:(NSString *)bareJid;

- (void)updatebareJidStr:(NSString *)bareJidStr withUserID:(NSString *)activeUserID ;

- (void)deleteLoginUserWithUserID:(NSString *)userID;
- (void)deleteLoginUserWithUerBareJidStr:(NSString *)bareJidStr;


@property (strong, readonly) id <XMPPLoginUserStorage> xmppLoginUserStorage;
@property (strong, nonatomic) NSString *activeUserID;

@end


@protocol XMPPLoginUserStorage <NSObject>

@required

- (BOOL)configureWithParent:(XMPPLoginUser *)aParent queue:(dispatch_queue_t)queue;

@optional
- (NSString *)userIDWithBareJIDStr:(NSString *)bareJidStr;
- (NSString *)bareJidStrWithUserID:(NSString *)userID;
- (void)saveLoginUserID:(NSString *)loginUserID bareJid:(NSString *)bareJid;
- (void)updatebareJidStr:(NSString *)bareJidStr withUserID:(NSString *)activeUserID;
- (void)deleteLoginUserWithUserID:(NSString *)userID;
- (void)deleteLoginUserWithUerBareJidStr:(NSString *)bareJidStr;
@end

@protocol XMPPLoginUserDelegate <NSObject>

@required
@optional

- (void)xmppLoginUser:(XMPPLoginUser *)xmppLoginUser didLoginSucceedWith:(XMPPStream *)xmppStream;

@end