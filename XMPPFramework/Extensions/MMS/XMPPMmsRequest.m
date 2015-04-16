//
//  XMPPMmsRequest.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/4/9.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPMmsRequest.h"
#import "XMPPStream.h"

static const NSString *MMS_REQUEST_XMLNS = @"aft:mms";
static const NSString *MMS_ERROR_DOMAIN = @"com.afusion.mms.error";
static const NSInteger MMS_ERROR_CODE = 9999;
//static const NSString *MMS_DOWNLOAD_TOKEN_KEY = @"download_key_string";

typedef void(^CompletionBlock)(NSString *string, NSError *error);

@interface XMPPMmsRequest ()

@property (strong, nonatomic) NSMutableDictionary *uploadCompletionBlockDcitionary;
@property (strong, nonatomic) NSMutableDictionary *downloadCompletionBlockDcitionary;
@property (assign, nonatomic) BOOL canSendRequest;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation XMPPMmsRequest
@synthesize uploadCompletionBlockDcitionary;
@synthesize downloadCompletionBlockDcitionary;
@synthesize canSendRequest;

- (id)init
{
    return [self initWithDispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    if ((self = [super initWithDispatchQueue:queue]))
    {
        uploadCompletionBlockDcitionary = [NSMutableDictionary dictionary];
        downloadCompletionBlockDcitionary = [NSMutableDictionary dictionary];
        canSendRequest = NO;
    }
    return self;
}

- (BOOL)activate:(XMPPStream *)aXmppStream
{
    if ([super activate:aXmppStream])
    {
        // Reserved for possible future use.
        
        return YES;
    }
    
    return NO;
}

- (void)deactivate
{
    // Reserved for possible future use.
    dispatch_block_t block = ^{
        
        canSendRequest = NO;
        
        [uploadCompletionBlockDcitionary removeAllObjects];
        [downloadCompletionBlockDcitionary removeAllObjects];
        uploadCompletionBlockDcitionary = nil;
        downloadCompletionBlockDcitionary = nil;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    [super deactivate];
}

- (void)dealloc
{
    dispatch_block_t block = ^{
        
        [uploadCompletionBlockDcitionary removeAllObjects];
        [downloadCompletionBlockDcitionary removeAllObjects];
        uploadCompletionBlockDcitionary = nil;
        downloadCompletionBlockDcitionary = nil;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Configuration and Flags
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)canSendRequest
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = canSendRequest;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)setCanSendRequest:(BOOL)CanSendRequest
{
    dispatch_block_t block = ^{
        
        canSendRequest = CanSendRequest;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestUploadTokenWithCompletionBlock:(void (^)(NSString *token, NSError *error))completionBlock
{
    dispatch_block_t block = ^{
        
        NSString *key = [[self xmppStream] generateUUID];
        
        [self requestUploadTokenWithRequestKey:key completionBlock:completionBlock];
        
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)requestUploadTokenWithRequestKey:(NSString *)requestKey completionBlock:(void (^)(NSString *token, NSError *error))completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {
            
            [multicastDelegate xmppMmsRequest:self willRequestUploadTokenForRequestKey:requestKey];
            
            [uploadCompletionBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            /*
             <iq type="get" id="2115763">
             <query xmlns="aft:mms" query_type="upload"></query>
             </iq>
             */
            
            NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:[NSString stringWithFormat:@"%@",MMS_REQUEST_XMLNS]];
            [queryElement addAttributeWithName:@"query_type" stringValue:@"upload"];
            
            XMPPIQ *iq = [XMPPIQ iqWithType:@"get" elementID:requestKey child:queryElement];
            
            [[self xmppStream] sendElement:iq];
            
            [self _removeCompletionBlockWithDictionary:uploadCompletionBlockDcitionary requestKey:requestKey];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}


- (void)requestDownloadURLWithToken:(NSString *)token completionBlock:(void (^)(NSString *URLString, NSError *error))completionBlock
{
    dispatch_block_t block = ^{
        
        NSString *key = [[self xmppStream] generateUUID];
        
        [self requestDownloadURLWithToken:token requestKey:key completionBlock:completionBlock];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)requestDownloadURLWithToken:(NSString *)token requestKey:(NSString *)requestKey completionBlock:(void (^)(NSString *URLString, NSError *error))completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {
            [multicastDelegate xmppMmsRequest:self willRequestDownloadURLForDownloadToken:token requestKey:requestKey];
            
            NSDictionary *blockDic = [NSDictionary dictionaryWithObject:completionBlock forKey:token];
            [downloadCompletionBlockDcitionary setObject:blockDic forKey:requestKey];
            
            /*
             <iq type="get" id="2115763">
             <query xmlns="aft:mms" query_type="upload"></query>
             </iq>
             */
            
            NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:[NSString stringWithFormat:@"%@",MMS_REQUEST_XMLNS]];
            [queryElement addAttributeWithName:@"query_type" stringValue:@"download"];
            
            XMPPIQ *iq = [XMPPIQ iqWithType:@"get" elementID:requestKey child:queryElement];
            
            [[self xmppStream] sendElement:iq];
            
            [self _removeCompletionBlockWithDictionary:downloadCompletionBlockDcitionary requestKey:requestKey];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_removeCompletionBlockWithDictionary:(NSMutableDictionary *)dic requestKey:(NSString *)requestKey
{
    NSTimeInterval delayInSeconds = 60.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, moduleQueue, ^(void){@autoreleasepool{
    
        if ([dic objectForKey:requestKey]) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"request from server with no response for a long time!" forKey:NSLocalizedDescriptionKey];
            NSError *_error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",MMS_ERROR_DOMAIN] code:MMS_ERROR_CODE userInfo:userInfo];
            
            if ([dic isEqual:uploadCompletionBlockDcitionary]) {
                
                CompletionBlock completionBlock = (CompletionBlock)[dic objectForKey:requestKey];
                
                if (completionBlock) {
                    completionBlock(nil, _error);
                }
                
                [multicastDelegate xmppMmsRequest:self didReceivedError:_error forUploadRequestKey:requestKey];
                
            }else if ([dic isEqual:downloadCompletionBlockDcitionary]){
                
                NSDictionary *blockDic = [downloadCompletionBlockDcitionary objectForKey:requestKey];
                NSString *token = [[blockDic allKeys] firstObject];
                
                CompletionBlock completionBlock = (CompletionBlock)[blockDic objectForKey:token];
                
                if (completionBlock) {
                    completionBlock(nil, _error);
                }
                
                [multicastDelegate xmppMmsRequest:self didReceivedError:_error forDownloadToken:token requestKey:requestKey];
            }
            
            [dic removeObjectForKey:requestKey];
        }
    
    }});
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    // This method is invoked on the moduleQueue.
    
    [self setCanSendRequest:YES];
}
- (BOOL)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    if ([[iq type] isEqualToString:@"get"]) {
        
        NSXMLElement *query = [iq elementForName:@"query" xmlns:[NSString stringWithFormat:@"%@",MMS_REQUEST_XMLNS]];
        
        if (query)
        {
            NSString *key = [iq elementID];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"send iq error" forKey:NSLocalizedDescriptionKey];
            
            NSError *_error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",MMS_ERROR_DOMAIN] code:MMS_ERROR_CODE userInfo:userInfo];
            
            if([[iq attributeStringValueForName:@"query_type"] isEqualToString:@"upload"])
            {
                CompletionBlock completionBlock = (CompletionBlock)[uploadCompletionBlockDcitionary objectForKey:key];
                
                if (completionBlock) {
                    completionBlock(nil, _error);
                }

                [multicastDelegate xmppMmsRequest:self didReceivedError:_error forUploadRequestKey:key];
                
                [uploadCompletionBlockDcitionary removeObjectForKey:key];
            }
            else if([[iq attributeStringValueForName:@"query_type"] isEqualToString:@"download"])
            {
                NSDictionary *blockDic = [downloadCompletionBlockDcitionary objectForKey:key];
                NSString *token = [[blockDic allKeys] firstObject];
                
                CompletionBlock completionBlock = (CompletionBlock)[blockDic objectForKey:token];
                
                if (completionBlock) {
                    completionBlock(nil, _error);
                }
            
                [multicastDelegate xmppMmsRequest:self didReceivedError:_error forDownloadToken:token requestKey:key];
                
                [downloadCompletionBlockDcitionary removeObjectForKey:key];
            }
            
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    // This method is invoked on the moduleQueue.
    
    
    // Note: Some jabber servers send an iq element with an xmlns.
    // Because of the bug in Apple's NSXML (documented in our elementForName method),
    // it is important we specify the xmlns for the query.
    
    if ([[iq type] isEqualToString:@"result"]) {
        
        NSXMLElement *query = [iq elementForName:@"query" xmlns:[NSString stringWithFormat:@"%@",MMS_REQUEST_XMLNS]];
        
        if (query)
        {
            NSString *key = [iq elementID];
            
            if([[query attributeStringValueForName:@"query_type"] isEqualToString:@"upload"])
            {
                CompletionBlock completionBlock = (CompletionBlock)[uploadCompletionBlockDcitionary objectForKey:key];
                
                if (completionBlock) {
                    completionBlock([query stringValue], nil);
                }
                
                [multicastDelegate xmppMmsRequest:self didReceivedUploadToken:[query stringValue] forRequestKey:key];
                
                [uploadCompletionBlockDcitionary removeObjectForKey:key];
            }
            else if([[query attributeStringValueForName:@"query_type"] isEqualToString:@"download"])
            {
                NSDictionary *blockDic = [downloadCompletionBlockDcitionary objectForKey:key];
                NSString *token = [[blockDic allKeys] firstObject];
                
                CompletionBlock completionBlock = (CompletionBlock)[blockDic objectForKey:token];
                
                if (completionBlock) {
                    completionBlock([query stringValue], nil);
                }
                
                [multicastDelegate xmppMmsRequest:self didReceivedDownloadURL:[query stringValue] forDownloadToken:token requestKey:key];
                
                [downloadCompletionBlockDcitionary removeObjectForKey:key];
            }

            
            return YES;
        }
    }
    
    return NO;
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    // This method is invoked on the moduleQueue.
    
    [self setCanSendRequest:NO];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"You had disconnect with the server"                                                                      forKey:NSLocalizedDescriptionKey];
    
    NSError *_error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",MMS_ERROR_DOMAIN] code:MMS_ERROR_CODE userInfo:userInfo];
    
    [uploadCompletionBlockDcitionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        CompletionBlock completionBlock = (CompletionBlock)obj;
        
        if (completionBlock) {
            completionBlock(nil, _error);
        }
        
        [multicastDelegate xmppMmsRequest:self didReceivedError:_error forUploadRequestKey:(NSString *)key];
        
    }];
    
    [downloadCompletionBlockDcitionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSDictionary *dic = (NSDictionary *)obj;
        NSString *token = [[dic allKeys] firstObject];
        CompletionBlock completionBlock = (CompletionBlock)[dic objectForKey:token];
        
        if (completionBlock) {
            completionBlock(nil, _error);
        }
        
        [multicastDelegate xmppMmsRequest:self didReceivedError:_error forDownloadToken:token requestKey:(NSString *)key];
    }];
    
    [uploadCompletionBlockDcitionary removeAllObjects];
    [downloadCompletionBlockDcitionary removeAllObjects];
}

@end
