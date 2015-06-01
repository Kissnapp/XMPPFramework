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
#pragma mark Public API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestOrganizationViewWithTemplateId:(NSString *)templateId completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            if (!templateId) {
                [self _callBackWithMessage:@"The template id you inputed is nil" completionBlock:completionBlock];
            }
            
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
-(void)requestAllTemplateWithBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
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
-(void)allPorjectListWithBlock:(CompletionBlock)completionBlock
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
             创建工程：
             <iq from="79509d447102413a89e9ada9fde3cf6b@192.168.1.162/Gajim" id="5244001" type="set">
             <project xmlns="aft:project"  type="create">
             {"name": "星河丹堤", "template":"41", "template":"1"}
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
- (void)getPossibleStaff:(NSString *)ID completionBlock:(CompletionBlock)completionBlock
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
                 [{"id":"xxx", "name":"xxx"}, {"id":"xxx", "name":"xxx"}]
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
                 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="result">
                 <project xmlns="aft:project" type="list_template">
                 {"template": [{"id":"xx", "name":"xxx"}, {"id":"xx", "name":"xxx"}]}
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
                 {"id":"project_id","name": "project1", "job":"xxx", "part":"xxx"}
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
                 {project_id_value:[{"job_id":"123", "job_name”:””, "part":"xxx"}, {"job_id":"356", "job_name":"xxx", "part":"xxx"} ]}
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
                 <project xmlns="aft:project"  type="list_children_jobs">
                 {project_id_value:[{"job_id":"123", "job_name”:””, "part":"xxx"}, {"job_id":"356", "job_name":"xxx", "part":"xxx"} ]}
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
                 <project xmlns="aft:project"  type="list_children_jobs">
                 {project_id_value:[{"job_id":"123", "job_name”:””, "part":"xxx"}, {"job_id":"356", "job_name":"xxx", "part":"xxx"} ]}
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

                 */
                
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

@end
