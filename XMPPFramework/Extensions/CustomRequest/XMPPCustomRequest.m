//
//  CustomRequest.m
//  XMPP_Project
//
//  Created by Peter Lee on 16/4/29.
//  Copyright © 2016年 Peter Lee. All rights reserved.
//

#import "XMPPCustomRequest.h"
#import "XMPPIDTracker.h"
#import "XMPPLogging.h"
#import "XMPPFramework.h"

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

static NSString *const CUSTOM_REQUEST_ID_PREFIX = @"custom_request_";

@implementation XMPPCustomRequest

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

- (NSString *)requestKey
{
    return [CUSTOM_REQUEST_ID_PREFIX stringByAppendingString:[super requestKey]];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - custom request
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 获取摄像机列表
- (void)requestCameraListWithProjectId:(NSString *)projectId
                       completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (projectId.length < 1) {
            [self _callBackWithMessage:@"the project id cannot be nil" completionBlock:completionBlock];
        }
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq type="get" id="aad5ba">
                <query xmlns="aft:camera" query_type="list" project="1">
                </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *parameters = @{
                                         @"query_type":@"list",
                                         @"project":projectId
                                         };
            
            ChildElement *queryElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:camera"
                                                                  attribute:parameters
                                                                stringValue:nil];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:queryElement];
            
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)requestBoAuthorizeWithProjectId:(NSString *)projectId
                        completionBlock:(CompletionBlock)completionBlock
{

}

- (void)requestSettingPasswordWithOldPassword:(NSString *)oldPassword
                                  newPassword:(NSString *)newPassword
                              completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (oldPassword.length < 1 || newPassword.length < 1) {
            [self _callBackWithMessage:@"old password or new password ware needed" completionBlock:completionBlock];
        }
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq type='set' id='change1'>
                <query xmlns='aft:register'>
                    <old_password>R0m30</old_password>
                    <password>R0m30</password>
                </query>
             </iq>
             */
            
            // 3. Create the request iq
            
            ChildElement *queryElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:register"
                                                                  attribute:nil
                                                                stringValue:nil];
            // 旧密码节点<old_password>oldPassword</old_password>
            ChildElement *oldPwdElemnt = [ChildElement childElementWithName:@"old_password"
                                                                      xmlns:nil
                                                                  attribute:nil
                                                                stringValue:oldPassword];
            
            // 新密码节点 <password>newPassword</password>
            ChildElement *newPwdElemnt = [ChildElement childElementWithName:@"password"
                                                                      xmlns:nil
                                                                  attribute:nil
                                                                stringValue:newPassword];
            
            [queryElement addChild:oldPwdElemnt];
            [queryElement addChild:newPwdElemnt];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:queryElement];
            
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPStreamDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    // This method is invoked on the moduleQueue.
    
    [self setCanSendRequest:YES];
}


- (BOOL)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    return [self _executeRequestBlockWithElementName:@"query" xmlns:nil sendIQ:iq];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    // This method is invoked on the moduleQueue.
    
    [self setCanSendRequest:NO];
    
    __weak typeof(self) weakSelf = self;
    
    [requestBlockDcitionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        CompletionBlock completionBlock = (CompletionBlock)obj;
        
        if (completionBlock) {
            
            [weakSelf callBackWithMessage:@"You had disconnect with the server"  completionBlock:completionBlock];
            [requestBlockDcitionary removeObjectForKey:key];
        }
        
    }];
}
/*
 <iq xmlns="jabber:client" from="7e75cb7ccf6447c0b595cb2107c90b35@120.24.94.38" to="7e75cb7ccf6447c0b595cb2107c90b35@120.24.94.38/mobile" id="custom_request_B2B3D108-533B-46B7-8B86-3FA6EB03C6F1" type="result"><query xmlns="aft:register"><old_password>a111111</old_password><password>a222222</password></query></iq>
 */

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    // This method is invoked on the moduleQueue.
    
    // Note: Some jabber servers send an iq element with an xmlns.
    // Because of the bug in Apple's NSXML (documented in our elementForName method),
    // it is important we specify the xmlns for the query.
    
    if (([[iq type] isEqualToString:@"result"]
         || [[iq type] isEqualToString:@"error"])
        && [[iq elementID] hasPrefix:CUSTOM_REQUEST_ID_PREFIX]) {
        
        NSXMLElement *queryElement = [iq elementForName:@"query"];
        
        if (queryElement){
            
            NSString *requestkey = [iq elementID];
            
            if ([[iq type] isEqualToString:@"error"]) {
            
                NSXMLElement *errorElement = [iq elementForName:@"error"];
                
                NSXMLElement *errorTextElement = [errorElement elementForName:@"text" xmlns:@"urn:ietf:params:xml:ns:xmpp-stanzas"];
                
                if (errorTextElement) {
                    NSString *info = [errorTextElement stringValue];
                    NSString *errorCode = [errorElement attributeStringValueForName:@"code"];
                    if ([errorCode isEqualToString:@"401"] && [info isEqualToString:@"The old password is wrong"]) {
                        [self _executeRequestBlockWithRequestKey:requestkey errorMessage:@"11401"];
                    }else if ([errorCode isEqualToString:@"406"] && [info isEqualToString:@"The password is too weak"]){
                        [self _executeRequestBlockWithRequestKey:requestkey errorMessage:@"11402"];
                    }
                }else{
                    NSXMLElement *codeElement = [errorElement elementForName:@"code"];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                }
    
                return YES;
            }
            
            // 转换数据
            id  data = [[queryElement stringValue] objectFromJSONString];
            
            // 用block返回数据
            [self _executeRequestBlockWithRequestKey:requestkey valueObject:data];
        }
    }
    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    // This method is invoked on the moduleQueue.
    XMPPLogTrace();
}



@end
