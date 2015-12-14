//
//  XMPPMmsRequest.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/4/9.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>

typedef NS_ENUM(NSUInteger, XMPPMmsRequestUploadType) {
    XMPPMmsRequestUploadTypePublic = 1,
    XMPPMmsRequestUploadTypePrivateMessage,
    XMPPMmsRequestUploadTypePrivateFileLibrary
};

@interface XMPPMmsRequest : XMPPModule

- (void)privateUploadWithCompletionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSString *uploadid, NSError *error))completionBlock;

// public upload new file
- (void)publicUploadWithCompletionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSString *uploadid, NSError *error))completionBlock ;


- (void)uploadWithType:(XMPPMmsRequestUploadType)type
       completionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSString *uploadid, NSError *error))completionBlock;

#pragma mark - multipart upload

// privare upload new file
- (void)multipartPrivateUploadWithCompletionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSString *uploadid, NSError *error))completionBlock;

// public upload new file
- (void)multipartPublicUploadWithCompletionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSString *uploadid, NSError *error))completionBlock;

- (void)multipartUploadInfoWithType:(XMPPMmsRequestUploadType)type
                           completionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSString *uploadid, NSError *error))completionBlock;


- (void)completeMultipartUploadWithFile:(NSString *)file uploadId:(NSString *)uploadId completionBlock:(CompletionBlock)completionBlock;

#pragma mark - upload exists file
- (void)requestExistsUploadInfoWithFile:(NSString *)file
                        completionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSError *error))completionBlock;
- (void)requestExistsUploadInfoWithFile:(NSString *)file
                             requestKey:(NSString *)requestKey
                        completionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSError *error))completionBlock;

#pragma mark - download
- (void)requestDownloadURLWithFile:(NSString *)file
                    completionBlock:(void (^)(NSString *URLString, NSError *error))completionBlock;
- (void)requestDownloadURLWithFile:(NSString *)file
                         requestKey:(NSString *)requestKey
                    completionBlock:(void (^)(NSString *URLString, NSError *error))completionBlock;
@end


@interface XMPPMmsRequest (Deprecated)
// privare upload new file
- (void)requestUploadInfoWithCompletionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSError *error))completionBlock NS_DEPRECATED_IOS(6_0, 7_0, "该方法已经废弃，请使用privateUploadWithCompletionBlock:");

// public upload new file
- (void)requestPublicUploadInfoWithCompletionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSError *error))completionBlock NS_DEPRECATED_IOS(6_0, 7_0, "该方法已经废弃，请使用publicUploadWithCompletionBlock:");


- (void)requestUploadInfoWithType:(XMPPMmsRequestUploadType)type
                  completionBlock:(void (^)(NSString *token, NSString *file, NSString *expiration, NSError *error))completionBlock NS_DEPRECATED_IOS(6_0, 7_0, "该方法已经废弃，请使用uploadWithType:completionBlock:");
@end
