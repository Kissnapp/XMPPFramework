//
//  XMPPMmsRequest.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/4/9.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>

@protocol XMPPMmsRequestDelegate;

@interface XMPPMmsRequest : XMPPModule

- (void)requestUploadTokenWithCompletionBlock:(void (^)(NSString *token, NSError *error))completionBlock;
- (void)requestUploadTokenWithRequestKey:(NSString *)requestKey completionBlock:(void (^)(NSString *token, NSError *error))completionBlock;

- (void)requestDownloadURLWithToken:(NSString *)token completionBlock:(void (^)(NSString *token, NSError *error))completionBlock;
- (void)requestDownloadURLWithToken:(NSString *)token requestKey:(NSString *)requestKey completionBlock:(void (^)(NSString *URLString, NSError *error))completionBlock;

@end

@protocol XMPPMmsRequestDelegate <NSObject>

@optional

// upload request delegate notice
- (void)xmppMmsRequest:(XMPPMmsRequest *)xmppMmsRequest willRequestUploadTokenForRequestKey:(NSString *)requestKey;
- (void)xmppMmsRequest:(XMPPMmsRequest *)xmppMmsRequest didReceivedUploadToken:(NSString *)uploadToken forRequestKey:(NSString *)requestKey;
- (void)xmppMmsRequest:(XMPPMmsRequest *)xmppMmsRequest didReceivedError:(NSError *)error forUploadRequestKey:(NSString *)requestKey;

// download request delegate notice
- (void)xmppMmsRequest:(XMPPMmsRequest *)xmppMmsRequest willRequestDownloadURLForDownloadToken:(NSString *)downloadToken requestKey:(NSString *)requestKey;
- (void)xmppMmsRequest:(XMPPMmsRequest *)xmppMmsRequest didReceivedDownloadURL:(NSString *)URLString forDownloadToken:(NSString *)downloadToken requestKey:(NSString *)requestKey;
- (void)xmppMmsRequest:(XMPPMmsRequest *)xmppMmsRequest didReceivedError:(NSError *)error forDownloadToken:(NSString *)downloadToken requestKey:(NSString *)requestKey;

@end
