//
//  XMPPOrganization.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/22.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPOrganization.h"
#import "XMPP.h"
#import "XMPPIDTracker.h"
#import "XMPPLogging.h"
#import "XMPPFramework.h"
#import "DDList.h"

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

static const NSString *ORG_REQUEST_XMLNS = @"aft:project";
static const NSString *ORG_ERROR_DOMAIN = @"com.afusion.org.error";
static const NSInteger ORG_ERROR_CODE = 9999;

typedef void(^CompletionBlock)(id data, NSError *error);

@interface XMPPOrganization ()

@property (strong, nonatomic) NSMutableDictionary *requestBlockDcitionary;
@property (assign, nonatomic) BOOL canSendRequest;

@end

@implementation XMPPOrganization
@synthesize xmppOrganizationStorage = _xmppOrganizationStorage;
@synthesize requestBlockDcitionary;
@synthesize canSendRequest;

- (id)init
{
    return [self initWithDispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    
    return [self initWithOrganizationStorage:nil dispatchQueue:queue];
}

- (id)initWithOrganizationStorage:(id <XMPPOrganizationStorage>)storage
{
    return [self initWithOrganizationStorage:storage dispatchQueue:NULL];
}

- (id)initWithOrganizationStorage:(id <XMPPOrganizationStorage>)storage dispatchQueue:(dispatch_queue_t)queue
{
    NSParameterAssert(storage != nil);
    
    if ((self = [super initWithDispatchQueue:queue])){
        if ([storage configureWithParent:self queue:moduleQueue]){
            _xmppOrganizationStorage = storage;
        }else{
            XMPPLogError(@"%@: %@ - Unable to configure storage!", THIS_FILE, THIS_METHOD);
        }
        
        //setting the dafault data
        //your code ...
        canSendRequest = NO;
        requestBlockDcitionary = [NSMutableDictionary dictionary];
    }
    return self;
}

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

- (void)deactivate
{
    XMPPLogTrace();
    
    // Reserved for future potential use
    // Reserved for possible future use.
    dispatch_block_t block = ^{
        
        canSendRequest = NO;
        
        [requestBlockDcitionary removeAllObjects];
        requestBlockDcitionary = nil;
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
        
        [requestBlockDcitionary removeAllObjects];
        requestBlockDcitionary = nil;
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
#pragma mark Internal
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * This method may optionally be used by XMPPOrganization classes (declared in XMPPMoudle.h).
 **/
- (GCDMulticastDelegate *)multicastDelegate
{
    return multicastDelegate;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Configuration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id <XMPPOrganizationStorage>)xmppOrganizationStorage
{
    // Note: The xmppRosterStorage variable is read-only (set in the init method)
    
    return _xmppOrganizationStorage;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// call back with error info to who had used it
- (void)_removeCompletionBlockWithDictionary:(NSMutableDictionary *)dic requestKey:(NSString *)requestKey
{
    // We should find our request block after 60 seconds,if there is no reponse from the server,
    //  we should call back with a error to notice the user that the server has no response for this request
    NSTimeInterval delayInSeconds = 60.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, moduleQueue, ^(void){@autoreleasepool{
        
        if ([dic objectForKey:requestKey]) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"request from server with no response for a long time!" forKey:NSLocalizedDescriptionKey];
            NSError *_error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",ORG_ERROR_DOMAIN] code:ORG_ERROR_CODE userInfo:userInfo];
            
            CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestKey];
            if (completionBlock) {
                completionBlock(nil, _error);
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
//- (BOOL)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
//{
//    if ([[iq type] isEqualToString:@"get"]) {
//        
//        NSXMLElement *query = [iq elementForName:@"query" xmlns:[NSString stringWithFormat:@"%@",MMS_REQUEST_XMLNS]];
//        
//        if (query)
//        {
//            NSString *key = [iq elementID];
//            
//            if([[iq attributeStringValueForName:@"query_type"] isEqualToString:@"upload"])
//            {
//                [self requestUploadErrorWithCode:MMS_ERROR_CODE description:@"send iq error" key:key];
//            }
//            else if([[iq attributeStringValueForName:@"query_type"] isEqualToString:@"download"])
//            {
//                [self requestDownloadErrorWithCode:MMS_ERROR_CODE description:@"send iq error" key:key];
//            }
//            
//            return YES;
//        }
//    }
//    
//    return NO;
//}
//
//- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
//{
//    // This method is invoked on the moduleQueue.
//    
//    
//    // Note: Some jabber servers send an iq element with an xmlns.
//    // Because of the bug in Apple's NSXML (documented in our elementForName method),
//    // it is important we specify the xmlns for the query.
//    
//    if ([[iq type] isEqualToString:@"result"]) {
//        
//        NSXMLElement *query = [iq elementForName:@"query" xmlns:[NSString stringWithFormat:@"%@",MMS_REQUEST_XMLNS]];
//        
//        if (query)
//        {
//            NSString *key = [iq elementID];
//            
//            if([[query attributeStringValueForName:@"query_type"] isEqualToString:@"upload"])
//            {
//                /*
//                 <iq from='alice@localhost' to='alice@localhost' id='2115763' type='result'>
//                 <query xmlns='aft:mms' query_type='upload'>
//                 <token>3e4963702884b4ddf72a696c81ee49b</token>
//                 <file>1c7ca8f4-8e79-4e0a-8672-64b831da9a36</file>
//                 <expiration>1428994820549535</expiration>
//                 </query>
//                 </iq>
//                 */
//                NSString *token = [[query elementForName:@"token"] stringValue];
//                NSString *file = [[query elementForName:@"file"] stringValue];
//                NSString *expiration = [[query elementForName:@"expiration"] stringValue];
//                UploadBlock uploadBlock = (UploadBlock)[uploadCompletionBlockDcitionary objectForKey:key];
//                
//                if (uploadBlock) {
//                    uploadBlock(token, file, expiration, nil);
//                }
//                
//                [uploadCompletionBlockDcitionary removeObjectForKey:key];
//            }
//            else if([[query attributeStringValueForName:@"query_type"] isEqualToString:@"download"])
//            {
//                /*
//                 <iq type="result" id="2115763">
//                 <query xmlns="aft:mms" query_type="download" >https://xxx.aft.s3.amazonaws.com/8e13373a-46e8-40c4-8f18-dc2c9cf21223?AWSAccessKeyId=AKIAIQJNLH5YIBB3LV4Q&amp;Signature=yXTcTAfMstsIQzN5Opx5xGM9ur8%3D&amp;Expires=1426237616</query>
//                 </iq>
//                 */
//                NSDictionary *blockDic = [downloadCompletionBlockDcitionary objectForKey:key];
//                NSString *file = [[blockDic allKeys] firstObject];
//                
//                DownloadBlock downloadBlock = (DownloadBlock)[blockDic objectForKey:file];
//                
//                if (downloadBlock) {
//                    downloadBlock([query stringValue], nil);
//                }
//                
//                [downloadCompletionBlockDcitionary removeObjectForKey:key];
//            }
//            
//            
//            return YES;
//        }
//    }
//    
//    return NO;
//}
//
//- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
//{
//    // This method is invoked on the moduleQueue.
//    
//    [self setCanSendRequest:NO];
//    
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"You had disconnect with the server"                                                                      forKey:NSLocalizedDescriptionKey];
//    
//    NSError *_error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",MMS_ERROR_DOMAIN] code:MMS_ERROR_CODE userInfo:userInfo];
//    
//    [uploadCompletionBlockDcitionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        
//        UploadBlock uploadBlock = (UploadBlock)obj;
//        
//        if (uploadBlock) {
//            uploadBlock(nil, nil, nil, _error);
//        }
//        
//    }];
//    
//    [downloadCompletionBlockDcitionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        
//        NSDictionary *dic = (NSDictionary *)obj;
//        NSString *file = [[dic allKeys] firstObject];
//        DownloadBlock downloadBlock = (DownloadBlock)[dic objectForKey:file];
//        
//        if (downloadBlock) {
//            downloadBlock(nil, _error);
//        }
//        
//    }];
//    
//    [uploadCompletionBlockDcitionary removeAllObjects];
//    [downloadCompletionBlockDcitionary removeAllObjects];
//}

@end
