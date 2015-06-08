
//  XMPPOrganization.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/22.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPOrg.h"
#import "XMPP.h"
#import "XMPPIDTracker.h"
#import "XMPPLogging.h"
#import "XMPPFramework.h"
#import "DDList.h"
#import "NSDictionary+KeysTransfrom.h"

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

static const NSString *REQUEST_ALL_ORG_KEY = @"request_all_org_key";
static const NSString *REQUEST_ALL_TEMPLATE_KEY = @"request_all_template_key";
static const NSString *REQUEST_ORG_POSITION_LIST_KEY = @"request_org_position_list_key";
static const NSString *REQUEST_ORG_USER_LIST_KEY = @"request_org_user_list_key";
static const NSString *REQUEST_ORG_RELATION_LIST_KEY = @"request_org_relation_list_key";

@interface XMPPOrg ()

@property (strong, nonatomic) NSMutableDictionary *requestBlockDcitionary;
@property (assign, nonatomic) BOOL canSendRequest;

@end

@implementation XMPPOrg
@synthesize xmppOrganizationStorage = _xmppOrganizationStorage;
@synthesize requestBlockDcitionary;
@synthesize canSendRequest;
@synthesize autoFetchOrgList;
@synthesize autoFetchOrgTemplateList;

- (id)init
{
    return [self initWithDispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    
    return [self initWithOrganizationStorage:nil dispatchQueue:queue];
}

- (id)initWithOrganizationStorage:(id <XMPPOrgStorage>)storage
{
    return [self initWithOrganizationStorage:storage dispatchQueue:NULL];
}

- (id)initWithOrganizationStorage:(id <XMPPOrgStorage>)storage dispatchQueue:(dispatch_queue_t)queue
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
        autoFetchOrgList = NO;
        autoFetchOrgTemplateList = NO;
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

- (BOOL)autoFetchOrgList
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = autoFetchOrgList;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)setAutoFetchOrgList:(BOOL)flag
{
    dispatch_block_t block = ^{
        
        autoFetchOrgList = flag;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (BOOL)autoFetchOrgTemplateList
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = autoFetchOrgTemplateList;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)setAutoFetchOrgTemplateList:(BOOL)flag
{
    dispatch_block_t block = ^{
        
        autoFetchOrgTemplateList = flag;
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

- (id <XMPPOrgStorage>)xmppOrganizationStorage
{
    // Note: The xmppRosterStorage variable is read-only (set in the init method)
    
    return _xmppOrganizationStorage;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)_insertOrUpdateOrgWithDic:(NSArray *)orgDics
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    if ([orgDics count] < 1) return;
    
    __weak typeof(self) weakSelf = self;
    
    [orgDics enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [_xmppOrganizationStorage insertOrUpdateOrgInDBWith:[(NSDictionary *)obj destinationDictionaryWithNewKeysMapDic:@{
                                                                                                                          @"orgId":@"id",
                                                                                                                          @"orgName":@"name",
                                                                                                                          @"orgState":@"status",
                                                                                                                          @"orgStartTime":@"start_time",
                                                                                                                          @"orgEndTime":@"end_time",
                                                                                                                          @"orgAdminJidStr":@"admin",
                                                                                                                          @"orgDescription":@"description",
                                                                                                                          @"ptTag":@"job_tag",
                                                                                                                          @"userTag":@"member_tag",
                                                                                                                          @"orgRelationShipTag":@"link_tag",
                                                                                                                          }]
                                                 xmppStream:xmppStream
                                                  userBlock:^(NSString *orgId) {
                                                      
                                                      // 0.request all user info from server
                                                      
                                                      [weakSelf requestServerAllUserListWithOrgId:orgId];
                                                      
                                                  } positionBlock:^(NSString *orgId) {
                                                      
                                                      // 1.request all position info from server
                                                      
                                                      [weakSelf requestServerAllPositionListWithOrgId:orgId];
                                                      
                                                  } relationBlock:^(NSString *orgId) {
                                                      
                                                      // 2.request all relation org info from server
                                                      
                                                      [weakSelf requestServerAllRelationListWithOrgId:orgId];
                                                  }];
        
    }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 获取所有项目
// 数据库同服务器请求
- (void)requestServerAllOrgList
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            // 0. Create a key for storaging completion block
            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_ORG_KEY];
            
            // 1. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
             <project xmlns="aft:project" type="list_project">
             </project>
             </iq>
             */
            
            // 2. Create the request iq
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:@"aft:project"
                                                                         attribute:@{@"type":@"list_project"}
                                                                       stringValue:nil];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
        }else{
            // 0. tell the the user that can not send a request
            NSLog(@"%@",@"you can not send this iq before logining");
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

// 逻辑层向数据库请求
- (void)requestDBAllOrgListWithBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        NSArray *orgs = [_xmppOrganizationStorage allOrgsWithXMPPStream:xmppStream];
        
        ([orgs count] > 1) ? completionBlock(orgs, nil) : [self _requestServerAllOrgListWithBlock:completionBlock];
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)_requestServerAllOrgListWithBlock:(CompletionBlock)completionBlock
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
        
        // If the templateId is nil，we should notice the user the info
        // 0. Create a key for storaging completion block
        NSString *requestKey = [[self xmppStream] generateUUID];
        
        // 1. add the completionBlock to the dcitionary
        [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
        
        // 2. Listing the request iq XML
        /*
         <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
         <project xmlns="aft:project" type="list_project">
         </project>
         </iq>
         */
        
        // 3. Create the request iq
        ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                         xmlns:@"aft:project"
                                                                     attribute:@{@"type":@"list_project"}
                                                                   stringValue:nil];
        
        IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                         to:nil
                                                       type:@"get"
                                                         id:requestKey
                                               childElement:organizationElement];
        // 4. Send the request iq element to the server
        [[self xmppStream] sendElement:iqElement];
        
        // 5. add a timer to call back to user after a long time without server's reponse
        [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
        
    }else{
        // 0. tell the the user that can not send a request
        [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
    }
}
#pragma mark - 获取所有模板
- (void)requestServerAllTemplates
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 1. Create a key for storaging completion block
            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_TEMPLATE_KEY];
            
            // 2. Listing the request iq XML
            /*
             获取模块请求：
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
             <project xmlns="aft:project" type="list_template">
             </project>
             </iq>
             */
            
            // 3. Create the request iq
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"list_template"}
                                                                       stringValue:nil];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
        }else{
            // 0. tell the the user that can not send a request
            NSLog(@"you can not send this iq before logining");
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)_requestServerAllTemplatesWithBlock:(CompletionBlock)completionBlock
{
    
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    
    if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
        
        
        // 0. Create a key for storaging completion block
        NSString *requestKey = [[self xmppStream] generateUUID];
        
        // 1. add the completionBlock to the dcitionary
        [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
        
        // 2. Listing the request iq XML
        /*
         获取模块请求：
         <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
         <project xmlns="aft:project" type="list_template">
         </project>
         </iq>
         */
        
        // 3. Create the request iq
        
        ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                         xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                     attribute:@{@"type":@"list_template"}
                                                                   stringValue:nil];
        
        IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                         to:nil
                                                       type:@"get"
                                                         id:requestKey
                                               childElement:organizationElement];
        
        
        // 4. Send the request iq element to the server
        [[self xmppStream] sendElement:iqElement];
        
        // 5. add a timer to call back to user after a long time without server's reponse
        [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
        
    }else{
        // 0. tell the the user that can not send a request
        [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
    }
}

- (void)requestDBAllTemplatesWithBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        NSArray *templates = [_xmppOrganizationStorage allOrgTemplatesWithXMPPStream:xmppStream];
        
        ([templates count] > 1) ? completionBlock(templates, nil) : [self _requestServerAllTemplatesWithBlock:completionBlock];
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

#pragma mark - 获取一个组织的所有职位信息
- (void)requestServerAllPositionListWithOrgId:(NSString *)orgId
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 1. Create a key for storaging completion block
            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ORG_POSITION_LIST_KEY];
            
            // 2. Listing the request iq XML
            /*
             <iq from="2eef0b948af444ffb50223c485cae10b@192.168.1.162/Gajim" id="5244001" type="get">
             <project xmlns="aft.project" type="get_structure">
             {"project":"xxx"}
             </project>
             </iq>
             */
            
            // 3. Create the request iq
            
            NSDictionary *templateDic = [NSDictionary dictionaryWithObject:orgId
                                                                    forKey:@"project"];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"get_structure"}
                                                                       stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
        }else{
            // 0. tell the the user that can not send a request
            NSLog(@"you can not send this iq before logining");
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)_requestServerAllPositionListWithOrgId:(NSString *)orgId
                               completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            if (!orgId) {
                [self _callBackWithMessage:@"The template id you inputed is nil" completionBlock:completionBlock];
            }
            
            // fetch data from database
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="2eef0b948af444ffb50223c485cae10b@192.168.1.162/Gajim" id="5244001" type="get">
             <project xmlns="aft.project" type="get_structure">
             {"project":"xxx"}
             </project>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObject:orgId
                                                                    forKey:@"project"];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"get_structure"}
                                                                       stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
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

- (void)requestDBAllPositionListWithOrgId:(NSString *)orgId
                          completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        NSArray *positions = [_xmppOrganizationStorage orgPositionListWithId:orgId xmppStream:xmppStream];
        
        ([positions count] > 1) ? completionBlock(positions, nil) : [self _requestServerAllPositionListWithOrgId:orgId
                                                                                                 completionBlock:completionBlock];
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

#pragma mark - 获取一个组织的所有成员信息
- (void)requestServerAllUserListWithOrgId:(NSString *)orgId;
{
    
}
- (void)requestDBAllUserListWithOrgId:(NSString *)orgId
{

}

#pragma mark - 获取一个组织的所有关键组织的id
- (void)requestServerAllRelationListWithOrgId:(NSString *)orgId
{

}
- (void)requestDBAllRelationListWithOrgId:(NSString *)orgId
{

}


- (void)requestOrganizationViewWithTemplateId:(NSString *)templateId completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            if (!templateId) {
                [self _callBackWithMessage:@"The template id you inputed is nil" completionBlock:completionBlock];
            }
            
            // fetch data from database
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="2eef0b948af444ffb50223c485cae10b@192.168.1.162/Gajim" id="5244001" type="get">
             <project xmlns="aft.project" type="get_structure">
             {"template":"xxx"}
             </project>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObject:templateId
                                                                    forKey:@"template"];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"get_structure"}
                                                                       stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
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
- (void)checkOrganizationName:(NSString *)name completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
        
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
             <project xmlns="aft:project" type="project_name_exist">
             {"name":"星河丹堤"}
             </project>
             </iq>

             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObject:name
                                                                    forKey:@"name"];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"project_name_exist"}
                                                                       stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
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

-(void)createOrganizationWithName:(NSString *)name templateId:(NSString *)templateId jobId:(NSString *)jobId completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="79509d447102413a89e9ada9fde3cf6b@192.168.1.162/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="create">
             {"name": "星河丹堤", "template":"41", "job":"1"}
             </project>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",templateId,@"template",jobId,@"job", nil];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"get_structure"}
                                                                       stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
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
-(void)endOrganizationWithId:(NSString *)Id completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="set">
             <project xmlns="aft.project"  type="finish">
             {"project": "40"}
             </project>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObject:Id
                                                                    forKey:@"project"];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"finish"}
                                                                       stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
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
- (void)getPossiblePosition:(NSString *)ID completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="79509d447102413a89e9ada9fde3cf6b@192.168.1.162/Gajim" id="5244001" type="get">
             <project xmlns="aft:project"  type="list_children_jobs">
             {"project":"62"}
             </project>
             </iq>

             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObject:ID
                                                                    forKey:@"project"];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"list_children_jobs"}
                                                                       stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
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
-(void)addCustomJob:(NSString *)ID parentId:(NSString *)parentId name:(NSString *)jobName part:(NSString *)part completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="79509d447102413a89e9ada9fde3cf6b@192.168.1.162/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="add_job">
             { "project":"62", "parent_job_id":"277", "job_name":"安装主任2", "part":"领导班子"}
             </project>
             </iq>
             
             */
            
            // 3. Create the request iq
            
            NSDictionary * tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     ID, @"project",parentId,@"parent_job_id",jobName,@"job_name",part,@"part", nil];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"add_job"}
                                                                       stringValue:[tmpDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
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
-(void)addMemberToProject:(NSString *)ID jodId:(NSString *)jobID name:(NSString *)jobName jid:(NSString *)jid part:(NSString *)part completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="79509d447102413a89e9ada9fde3cf6b@192.168.1.162/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="add_member">
             {"62": [{"job_id":"279", "job_name":"生产经理", "jid":"125d9af626064ba2bbdd1fe215b8926c", "part":"领导班子"}, {"job_id":"281", "job_name":"技术部长", "jid":"530fc2b5165148ea8ba98abda1b6176b",   "part":"技术部"} ] }
             </project>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary * tempDic = [NSDictionary dictionaryWithObjectsAndKeys:jobID,
                                       @"job_id",jobName,@"job_name",jid,@"jid",part,@"part", nil];
            NSArray * arr = [NSArray arrayWithObject:tempDic];
            NSDictionary* temp = [NSDictionary dictionaryWithObject:arr forKey:ID];

            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"add_member"}
                                                                       stringValue:[temp JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
            
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
-(void)deleteMemberFromPro:(NSString *)projectID jid:(NSString *)jid completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="2eef0b948af444ffb50223c485cae10b@192.168.1.162/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="delete_member">
             {"project":"40", "jid":"hello6@123"}
             </project>
             </iq>

             */
            
            // 3. Create the request iq
            NSDictionary * tempDic = [NSDictionary dictionaryWithObjectsAndKeys:projectID,
                                      @"project",jid,@"jid", nil];
         
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"delete_member"}
                                                                       stringValue:[tempDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
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
- (void)memberListAndLinkPro:(NSString *)projectID completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
             <project xmlns="aft:project"  type="list_member_and_link">
             {"project":"60"}
             </project>
             </iq>
             
             */
            
            // 3. Create the request iq
            NSDictionary * tempDic = [NSDictionary dictionaryWithObjectsAndKeys:projectID,
                                      @"project", nil];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"list_member_and_link"}
                                                                       stringValue:[tempDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
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
-(void)allMemberList:(NSString *)projectID completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
             <project xmlns="aft:project"  type="list_member">
             {"project":"60", "project_target":"61"}
             </project>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary * tempDic = [NSDictionary dictionaryWithObjectsAndKeys:projectID,
                                      @"project", nil];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"list_member"}
                                                                       stringValue:[tempDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
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
-(void)allLinkProjectList:(NSString *)projectID completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
             <project xmlns="aft:project"  type="list_link_project">
             {"project":"60"}
             </project>
             </iq>

             */
            
            // 3. Create the request iq
            NSDictionary * tempDic = [NSDictionary dictionaryWithObjectsAndKeys:projectID,
                                      @"project", nil];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"list_link_project"}
                                                                       stringValue:[tempDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
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
-(void)searchProject:(NSString *)name completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
             <project xmlns="aft:project"  type="search_project">
             {"name":"芳"}
             </project>
             </iq>
             */
            // 3. Create the request iq
            NSDictionary * tempDic = [NSDictionary dictionaryWithObjectsAndKeys:name,
                                      @"name", nil];
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"search_project"}
                                                                       stringValue:[tempDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
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
-(void)subcribeProject:(NSString *)myID target:(NSString *)targetID completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="subscribe">
             {"id_self":"60","id_target":"61"}
             </project>
             </iq>

             */
            // 3. Create the request iq
            NSDictionary * tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:myID,@"id_self",targetID,@"id_target", nil];

            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"subscribe"}
                                                                       stringValue:[tmpDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
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
-(void)agreeSubcribeProject:(NSString *)myID target:(NSString *)targetID completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="d931cb6e4e4d46449d6a132a8bf6c31e@192.168.1.158/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="subscribed">
             {"id_self":"49", "id_target":"48"}
             </project>
             </iq>

             
             */
            // 3. Create the request iq
            NSDictionary * tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:myID,@"id_self",targetID,@"id_target", nil];
            
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"subscribed"}
                                                                       stringValue:[tmpDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
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
-(void)dissagreeSubcribeProject:(NSString *)myID target:(NSString *)targetID completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="d931cb6e4e4d46449d6a132a8bf6c31e@192.168.1.158/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="unsubscribed">
             {"id_self":"49", "id_target":"48"}
             </project>
             </iq>
             */
            // 3. Create the request iq
            NSDictionary * tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:myID,@"id_self",targetID,@"id_target", nil];
            
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"subscribe"}
                                                                       stringValue:[tmpDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
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
-(void)cancelSubcribeProject:(NSString *)myID target:(NSString *)targetID completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="d931cb6e4e4d46449d6a132a8bf6c31e@192.168.1.158/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="unsubscribe">
             {"id_self":"49","id_target":"48"}
             </project>
             </iq>

             */
            // 3. Create the request iq
            NSDictionary * tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:myID,@"id_self",targetID,@"id_target", nil];
            
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"unsubscribe"}
                                                                       stringValue:[tmpDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
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
-(void)getTempHashWithcompletionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
             <project xmlns="aft:project" type="get_template_hash">
             </project>
             </iq>
             */
            // 3. Create the request iq
            
            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
                                                                         attribute:@{@"type":@"get_template_hash"}
                                                                       stringValue:nil];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:organizationElement];
            
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
#pragma mark Private methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)callBackWithMessage:(NSString *)message completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",ORG_ERROR_DOMAIN] code:ORG_ERROR_CODE userInfo:userInfo];
        completionBlock(nil, error);
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)_callBackWithMessage:(NSString *)message completionBlock:(CompletionBlock)completionBlock
{
    // if not this queue we should return
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",ORG_ERROR_DOMAIN] code:ORG_ERROR_CODE userInfo:userInfo];
    completionBlock(nil, error);
}

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
                [dic removeObjectForKey:requestKey];
                
            }
        }
        
    }});
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStreamDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    // This method is invoked on the moduleQueue.
    
    [self setCanSendRequest:YES];
    
    // fetch all the org list
    if (autoFetchOrgList) [self requestServerAllOrgList];
    if (autoFetchOrgTemplateList) [self requestServerAllTemplates];
}


- (BOOL)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    if ([[iq type] isEqualToString:@"get"]) {
        
        NSXMLElement *project = [iq elementForName:@"project" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]];
        
        if (project)
        {
            NSString *requestkey = [iq elementID];
            
            CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
            
            if (completionBlock) {
                
                [self callBackWithMessage:@"send iq error" completionBlock:completionBlock];
                [requestBlockDcitionary removeObjectForKey:requestkey];
                
                return YES;
            }

        }
    }
    
    return NO;
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


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    // This method is invoked on the moduleQueue.
    
    
    // Note: Some jabber servers send an iq element with an xmlns.
    // Because of the bug in Apple's NSXML (documented in our elementForName method),
    // it is important we specify the xmlns for the query.
    
    if ([[iq type] isEqualToString:@"result"] || [[iq type] isEqualToString:@"error"]) {
        
        NSXMLElement *project = [iq elementForName:@"project" xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]];
        
        if (project){
            
            NSString *requestkey = [iq elementID];
            NSString *projectType = [project attributeStringValueForName:@"type"];
            
            if([projectType isEqualToString:@"get_structure"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    /*
                     <iq from="2eef0b948af444ffb50223c485cae10b@192.168.1.162/IOS" id="5244001" type="error">
                        <project xmlns="aft.project" type="get_structure"></project>
                        <error code="10003"></error>
                     </iq>
                     */

                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 <iq from="2eef0b948af444ffb50223c485cae10b@192.168.1.162/IOS" id="5244001" type="result">
                    <project xmlns="aft.project" type="get_structure">
                        [{"id":"xxx", "name":"项目经理", "left":"1", "right":"20", "part":"xxx"}, {...}]
                    </project>
                 </iq>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
    
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
            }else if([projectType isEqualToString:@"list_project"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 正确的结果：
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project" type="list_project">
                 [{"id":"xxx", "name":"xxx", "job_tag":"xxx", "member_tag":"xxx", "link_tag":"xxx"}, ...]   %% modify.
                 </project>
                 </iq>
                 */
                
                // 0.跟新数据库
                NSArray *orgDics = [[project stringValue] objectFromJSONString];
                
                [self _insertOrUpdateOrgWithDic:orgDics];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_TEMPLATE_KEY]]) {
                    
                    // 2.向数据库获取数据
                    NSArray *templates = [_xmppOrganizationStorage allOrgsWithXMPPStream:xmppStream];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        completionBlock(templates, nil);
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                }

                return YES;

                
            }else if([projectType isEqualToString:@"list_template"]){
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 正确的结果：("id"-->工程的ID, name-->工程的名称)
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project" type="list_template">
                 {"template": [{"id":"xx", "name":"xxx", "job_tag":"xxx", "member_tag":"xxx"}, ...]} %% modify  如果模板变了，要手动更改job_tag和member_tag.
                 </project>
                 </iq>
                 */
                
                // 0.跟新数据库
                NSArray *orgDics = [[project stringValue] objectFromJSONString];
        
                [self _insertOrUpdateOrgWithDic:orgDics];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_TEMPLATE_KEY]]) {
                    
                    // 2.向数据库获取数据
                    NSArray *templates = [_xmppOrganizationStorage allOrgTemplatesWithXMPPStream:xmppStream];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        completionBlock(templates, nil);
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                }
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"project_name_exist"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    
       
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
                 <project xmlns="aft:project" type="project_name_exist">
                 {"name":"桂芳园"}
                 </project>
                 </iq>

                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
                    
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"create"]){
                if ([[iq type] isEqualToString:@"error"]) {
                
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="create">
                 {"id":"project_id","name": "project1", "job":"xxx", "part":"xxx", "job_tag":"xxx", "member_tag":"xxx", "link_tag":"xxx",  "start_time":"xxx"}  %% modify
                 </project>
                 </iq>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
                    
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"finish"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft.project"  type="finish">
                 {"project": "40"}
                 </project>
                 </iq>
                 
                 push to all member:(don't push message to all link project member, because there are only chat).
                 <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
                 <sys xmlns="aft.sys.project" projectid="1" type="finished">
                 {"end_time":"xxx"} %% modify
                 </sys>
                 </message>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
                    
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"list_children_jobs"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    

                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="list_children_jobs">
                 {project_id_value:[{"job_id":"123", "job_name":"", "part":"xxx"}, {"job_id":"356", "job_name":"xxx", "part":"xxx"} ]}
                 </project>
                 </iq>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
                    
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
            }else if([projectType isEqualToString:@"add_job"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="add_job">
                 { "project":"60", "parent_job_id":"277", "job_name":"安装主任2", "part":"领导班子"}
                 </project>
                 </iq>
                 
                 %% modify update project job_timestamp.
                 
                 push msg:（客户端接收到这个消息后，需要重新去服务器拉组织架构，并重新获取project的job_tag)
                 <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
                 <sys xmlns="aft.sys.project" projectid="60" type="add_job">
                 {"job_tag":"xxx"} %% add modify
                 </sys>
                 </message>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
                    
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"add_member"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="add_member">
                 {"62": [{"job_id":"279", "job_name":"生产经理", "jid":"125d9af626064ba2bbdd1fe215b8926c@192.168.1.162", "part":"领导班子"}, {"job_id":"281", "job_name":"技术部长", "jid":"530fc2b5165148ea8ba98abda1b6176b@192.168.1.162",   "part":"技术部"} ] }
                 </project>
                 </iq>
                 
                 %% modify update project member_timestamp.
                 
                 push msg(推送给项目里所有的人及关联的项目里所有的人)
                 <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
                 <sys xmlns="aft.sys.project" projectid="1" type="add_member">
                 [ {"member_tag":"xxx"}, {"job_id":"279", "job_name":"生产经理", "jid":"125d9af626064ba2bbdd1fe215b8926c@192.168.1.162", "part":"领导班子"}, {"job_id":"281", "job_name":"技术部长", "jid":"530fc2b5165148ea8ba98abda1b6176b@192.168.1.162",   "part":"技术部"} ] %% modify
                 </sys>
                 </message>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
                    
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"delete_member"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 <iq from="2eef0b948af444ffb50223c485cae10b@192.168.1.162/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="delete_member">
                 {"project":"40", "jid":"hello6@123"}
                 </project>
                 </iq>
                 
                 %% modify update project member_timestamp.
                 
                 push msg:
                 <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
                 <sys xmlns="aft.sys.project" projectid="1" type="delete_member">
                 [{"member_tag":"xxx"}, {"jid":"xxx", "jid":"xxx", ...}] %% modify
                 </sys>
                 </message>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
                    
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"list_member_and_link"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    
             
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 结果：第一个[]是所有关联的组织ID和名称。
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="list_member_and_link">
                 {"project_id_value":[ [{"id":"xxx", "name":"xxx"}, {}], [{"jid":"xxx", "job_id":"xxx", "job_name":"xxx", "part":"1"}, {} ] ]}
                 </project>
                 </iq>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"list_member"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    
             
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="list_member">
                 {"project_id_value":[{"jid":"xxx", "job_id":"xxx", "job_name":"xxx", "part":"1"}, {} ]}
                 </projec
                 </iq>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"list_link_project"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    

                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="list_link_projeck">
                 {"self_project_id":[ [{"id":"xxx", "name":"xxx"}, {}] }
                 </project>
                 </iq>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
                
            }else if([projectType isEqualToString:@"search_project"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 模糊搜索
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="search_project">
                 [{"id":"xxx", "name":"xxx"},{"id":"xxx", "name":"xxx"},{}]
                 </project>
                 </iq>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
            }else if([projectType isEqualToString:@"subscribe"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    

                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="subscribe">
                 {"id_self":"50",“id_target":"51"}
                 </project>
                 </iq>
                 
                 push to id_target admin.
                 <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
                 <sys xmlns="aft.sys.project" projectid="1" type="subscribe">
                 {"id":"xxx", "name":"xxx"}
                 </sys>
                 </message>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
            }else if([projectType isEqualToString:@"subscribed"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 <iq from="d931cb6e4e4d46449d6a132a8bf6c31eb@192.168.1.158/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="subscribed">
                 {"id_self":"xxx",“id_target":"xxx"}
                 </project>
                 </iq>
                 
                 push to all member in each project.
                 <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
                 <sys xmlns="aft.sys.project" projectid="1" type="subscribed">
                 {"id":"xxx", "name":"xxx", "memeber_tag":"xxx"}  %% 分别发给两个组织，分别发对方组织的信息。   %% modify
                 </sys>
                 </message>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
            }else if([projectType isEqualToString:@"unsubscribed"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    
              
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 <iq from="2eef0b948af444ffb50223c485cae10b@192.168.1.162/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="unsubscribed">
                 {"id_self":"xxx", "id_target":"xxx"}
                 </project>
                 </iq>
                 
                 push message to id_target admin
                 <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
                 <sys xmlns="aft.sys.project" projectid="1" type="unsubscribed">
                 {"id":"xxx", "name":"xxx"}
                 </sys>
                 </message>
                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
            }else if([projectType isEqualToString:@"unsubscribe"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    
                  
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                /*
                 <iq from="73b3739b1949486da7ad87698189cb65@192.168.1.158/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project"  type="unsubscribe">
                 {"id_self":"xx",“id_target":"xxx"}
                 </project>
                 </iq>
                 
                 push to every in all each project member;
                 <message from="1@localhost" type="chat" xml:lang="en" to="13412345678@localhost">
                 <sys xmlns="aft.sys.project" projectid="1" type="subscribe">
                 {"id":"xxx", "name":"xxx", "link_tag":"xxx"}
                 </sys>
                 </message>

                 */
                
                id  data = [[project stringValue] objectFromJSONString];
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
            }else if([projectType isEqualToString:@"get_template_hash"]){
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    
                    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                    
                    if (completionBlock) {
                        
                        [self callBackWithMessage:[errorElement attributeStringValueForName:@"code"] completionBlock:completionBlock];
                        [requestBlockDcitionary removeObjectForKey:requestkey];
                    }
                    
                    return YES;
                }
                
                
                id  data = [[project stringValue] objectFromJSONString];
                CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
                
                if (completionBlock) {
                    completionBlock(data, nil);
                    [requestBlockDcitionary removeObjectForKey:requestkey];
                }
                
                return YES;
                
            }
            









            


            



            


        }
    }
    
    return NO;
}
@end