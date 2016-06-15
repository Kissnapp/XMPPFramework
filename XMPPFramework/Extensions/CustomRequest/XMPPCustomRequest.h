//
//  XMPPCustomRequest.h
//  XMPP_Project
//
//  Created by Peter Lee on 16/4/29.
//  Copyright © 2016年 Peter Lee. All rights reserved.
//

#import "XMPP.h"

@interface XMPPCustomRequest : XMPPModule

// 获取摄像机列表
- (void)requestCameraListWithProjectId:(NSString *)projectId
                       completionBlock:(CompletionBlock)completionBlock;

// 获取url验证token数据
- (void)requestBoAuthorizeWithProjectId:(NSString *)projectId
                        completionBlock:(CompletionBlock)completionBlock;

// 修改密码，注：该方法必须在登录之后使用
- (void)requestSettingPasswordWithOldPassword:(NSString *)oldPassword
                                  newPassword:(NSString *)newPassword
                              completionBlock:(CompletionBlock)completionBlock;

@end
