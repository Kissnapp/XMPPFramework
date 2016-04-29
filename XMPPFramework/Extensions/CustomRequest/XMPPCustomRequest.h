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

@end
