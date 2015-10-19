//
//  XMPPCloud.m
//  XMPP_Project
//
//  Created by jeff on 15/9/22.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPCloud.h"
#import "XMPPLogging.h"
#import "XMPP.h"

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
static const double REQUEST_TIMEOUT_DELAY = 30.0f;
static const NSString *CLOUD_PUSH_MSG_XMLNS = @"aft:library";
static const NSString *CLOUD_REQUEST_ERROR_XMLNS = @"aft:errors";
static const NSString *CLOUD_ERROR_DOMAIN = @"com.afusion.cloud.error";
static const NSInteger CLOUD_ERROR_CODE = 9999;
static NSString *CLOUD_REQUEST_XMLNS = @"aft:library";
static NSString *const REQUEST_ALL_CLOUD_KEY = @"request_all_cloud_key";

@interface XMPPCloud ()

@end

@implementation XMPPCloud
@synthesize xmppCloudStorage = _xmppCloudStorage;

- (id)init
{
    return [self initWithDispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    
    return [self initWithCloudStorage:nil dispatchQueue:queue];
}

- (id)initWithCloudStorage:(id <XMPPCloudStorage>)storage
{
    return [self initWithCloudStorage:storage dispatchQueue:NULL];
}

- (id)initWithCloudStorage:(id <XMPPCloudStorage>)storage dispatchQueue:(dispatch_queue_t)queue
{
    NSParameterAssert(storage != nil);
    
    if ((self = [super initWithDispatchQueue:queue])){
        if ([storage configureWithParent:self queue:moduleQueue]){
            _xmppCloudStorage = storage;
        }else{
            XMPPLogError(@"%@: %@ - Unable to configure storage!", THIS_FILE, THIS_METHOD);
        }
        
        //setting the dafault data
        //your code ...
        
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

- (id <XMPPCloudStorage>)xmppOrgStorage
{
    // Note: The xmppRosterStorage variable is read-only (set in the init method)
    
    return _xmppCloudStorage;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_resetFoldersWithDics:(NSArray *)folderDics parent:(NSString *)parent projectID:(NSString *)projectID
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    if ([folderDics count] < 1) return;

}


- (NSArray *)_specifiedValuesWithKey:(NSString *)key fromDics:(NSArray *)dics
{
    if (!dispatch_get_specific(moduleQueueTag)) return nil;
    if ([dics count] < 1) return nil;
    
    __block NSMutableArray *array = [NSMutableArray array];
    
    [dics enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *dic = (NSDictionary *)obj;
        
        [array addObject:[dic objectForKey:key]];
        
    }];
    
    return array;
}



#pragma mark - 1.获取文件夹内容
/**
 <iq type="get" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="list_folder">
 {"folder":""}   %% folder_id = -1: list_root,  %% list root  folder value is empty.
 </query>
 </iq>
 
 结果：
 note: 客户端根据owner中的jid从本地数据库中，获取此人的职位并显示, 如果是admin不做此操作。
 
 list_root result:
 <iq type="result" id="1234" >
 <query xmlns="aft:library" subtype="list_folder">
 {"parent":"xxx", "folders":[], "files":[]}
 %%[{"folder":"1", "id":"1",  "type":"0" "name":"资料库",      "creator":"admin", "owner":"admin", "time":"2015-09-01"},
 %%{"folder":"1", "id":"2",  "type":"0" "name":"资料归档",  "creator":"admin", "owner":"admin", "time":"2015-09-01"},
 %%{"folder":"1", "id":"3",  "type":"0" "name":"工作文件",  "creator":"admin", "owner":"admin", "time":"2015-09-01"},
 %%{"folder":"1", "id":"4",  "type":"2" "name":"张三",          "creator":"jid",      "owner":"admin",  "time":"2015-09-01"}
 </query>
 </iq>
 
 note: 客户端检查一下type=2的项，有没有owner=self jid，如果没有，显示一个自己的文件夹。
 
 list other folder result:
 <iq type="result" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="list_folder">
 {"parent":"xxx", "folders":[], "files":[]}
 %%[{"folder":"1", "id":"4", "parent":"xx", "type":"1" "name":"效果图", "creator":"jid", "owner":"admin", "time":"2015-09-01"},
 %% {"folder":"0", "id":"5", "parent":"xx", "uuid":"xxx", "name":"通迅录.xls", "version":"3", "creator":"jid", "time":"2015-09-01"}]
 </query>
 </iq>
 
 */

- (void)requestCloudFolderContentsWithFolder:(NSNumber *)folder projectID:(NSString *)projectID block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {
            
            // we should make sure whether we can send a request to the server
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="get" id="1234" >
             <query xmlns="aft:library" project="xxx" subtype="list_folder">
             {"folder":""}   %% folder_id = -1: list_root,  %% list root  folder value is empty.
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", folder],@"folder", nil];
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":@"list_folder", @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:cloudElement];
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        } else {
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
    
}


#pragma mark 2.创建文件夹
/*
 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
 <project xmlns="aft:project" type="project_name_exist">
 {"name":"星河丹堤"}
 </project>
 </iq>
 
 <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
 <project xmlns="aft:project" type="project_name_exist">
 {"name":"桂芳园"}
 </project>
 </iq>
 
 */

/**
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="add_folder">
 {"parent":"", "name":"xxx"}  %% parent value empty mean self folder not exist.
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library" subtype="add_folder">
 {"parent":"xxx", "folders":[]}
 </query>
 </iq>
 
 */

- (void)requestCloudCreateFolderWithParent:(NSString *)parent projectID:(NSString *)projectID name:(NSString *)name block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            //        NSString *requestKey = [[self xmppStream] generateUUID];
            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="set" id="1234" >
             <query xmlns="aft:library" project="xxx" subtype="add_folder">
             {"parent":"", "name":"xxx"}  %% parent value empty mean self folder not exist.
             </query>
             </iq>
             */
            NSString *tempParent = parent;
            if (!tempParent) {
                // 数据库取
                //            tempParent = 数据库id;
            }
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", [NSString stringWithFormat:@"%@", tempParent ? tempParent: @""], @"parent", nil];
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":@"add_folder", @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:cloudElement];
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

#pragma mark - 4.删除文件夹/删除文件
/**
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="delete_folder"/"delete_file">
 {"id":"xxx"}
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library" subtype="delete_folder"/"delete_file">
 {"id":"xxx"}
 </query>
 </iq>
 
 note：如果把私人文件夹内的东西都删掉了，服务器会删掉私人文件夹，客户端需要更新私人文件夹id为"".
 
 */
- (void)requestCloudDeleteWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID folderOrFileType:(NSNumber *)folderOrFileType block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [[self xmppStream] generateUUID];
//            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="set" id="1234" >
             <query xmlns="aft:library" project="xxx" subtype="delete_folder"/"delete_file">
             {"id":"xxx"}
             </query>
             </iq>
             */
            NSString *subtype = folderOrFileType.boolValue ? @"delete_folder" : @"delete_file";
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:cloudID, @"id", nil];
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":subtype, @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:cloudElement];
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


#pragma mark - 5.重命名
/**
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="rename_folder"/"rename_file">
 {"id":"xxx", "name":"xxx"}
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="rename_folder"/"rename_file">
 {"id":"xxx", "name":"xxx"}
 </query>
 </iq>
 
 */
- (void)requestCloudRenameWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID name:(NSString *)name folderOrFileType:(NSNumber *)folderOrFileType block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            //        NSString *requestKey = [[self xmppStream] generateUUID];
            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="set" id="1234" >
             <query xmlns="aft:library"  project="xxx" subtype="rename_folder"/"rename_file">
             {"id":"xxx", "name":"xxx"}
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", cloudID, @"id", nil];
            
            NSString *subtype = folderOrFileType ? @"rename_folder" : @"rename_file";
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":subtype, @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:cloudElement];
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


#pragma mark - 6.共享
/**
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="share">
 {"id":"xxx", "users":["jid1", "jid2", "jid3", ...]} %% 如果没有users项，变成私密的。 如果users为[], 变成全共享的。
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="share">
 {"id":"xxx", "users":["jid1", "jid2", "jid3", ..]}
 </query>
 </iq>
 
 */
- (void)requestCloudShareWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID users:(NSArray *)users block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            //        NSString *requestKey = [[self xmppStream] generateUUID];
            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="set" id="1234" >
             <query xmlns="aft:library"  project="xxx" subtype="share">
             {"id":"xxx", "users":["jid1", "jid2", "jid3", ...]} %% 如果没有users项，变成私密的。 如果users为[], 变成全共享的。
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:cloudID, @"id", users, @"users", nil];
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":@"share", @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:cloudElement];
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


#pragma mark - 7.移动
/**
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="move_folder"/"move_file">
 {"id":"xxx", "dest_parent":"xxx"}
 </query>
 </iq>
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="move_file"/"move_folder">
 {"id":"xxx", "dest_parent":"xxx"}
 </query>
 </iq>
 
 */
- (void)requestCloudMoveWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID destinationParent:(NSString *)destinationParent folderOrFileType:(NSNumber *)folderOrFileType block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
//                    NSString *requestKey = [[self xmppStream] generateUUID];
            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="set" id="1234" >
             <query xmlns="aft:library"  project="xxx" subtype="move_folder"/"move_file">
             {"id":"xxx", "dest_parent":"xxx"}
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:destinationParent, @"dest_parent", cloudID, @"id", nil];
            
            NSString *subtype = folderOrFileType ? @"move_folder" : @"move_file";
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":subtype, @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:cloudElement];
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

#pragma mark - 9.获取共享人员列表
/**
 
 <iq type="get" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="list_share_users">
 {"id":"xxx"}
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library" project="xxx"  subtype="list_share_users">
 ["jid1", "jid2", ...]
 </query>
 </iq>
 
 */
- (void)requestCloudSharedListWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID block:(CompletionBlock)completionBlock;
{
    dispatch_block_t block = ^{@autoreleasepool{
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            //        NSString *requestKey = [[self xmppStream] generateUUID];
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="get" id="1234" >
             <query xmlns="aft:library"  project="xxx" subtype="list_share_users">
             {"id":"xxx"}
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:cloudID, @"id", nil];
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":@"list_share_users", @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:cloudElement];
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


#pragma mark - 12.获取日志 问题
/**
 <iq type="get" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="get_log">
 {"before"/"after":"1", "count:"xxx"} %% 如果为before且值为""，则表示获取最近的多少条。
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="get_log">    %%规定一下count最大为20条，这样可以在一个结果里全部返回，不用一条一条的返回。
 {"count":"xxx", "logs":[{"id":"xxx", "jid":"xxx", "operation":"xxx", "text":"xxx", "time":"xxx", "project":"xxx"}, ...] } %% logs 需要客户端自己根据id去升序排序。
 </query>
 </iq>
 */
- (void)requestCloudGetLogWithProjectID:(NSString *)projectID count:(NSString *)count before:(NSString *)before block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            //        NSString *requestKey = [[self xmppStream] generateUUID];
            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="get" id="1234" >
             <query xmlns="aft:library" project="xxx" subtype="get_log">
             {"before"/"after":"1", "count:"xxx"} %% 如果为before且值为""，则表示获取最近的多少条。
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:count, @"count", before, @"before", nil];
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":@"get_log", @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"get"
                                                             id:requestKey
                                                   childElement:cloudElement];
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


#pragma mark - 14.清空回收站
/**
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="clear_trash">
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="clear_trash">
 </query>
 </iq>
 
 */
- (void)requestCloudClearTrashWithProjectID:(NSString *)projectID block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
//            NSString *requestKey = [[self xmppStream] generateUUID];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="set" id="1234" >
             <query xmlns="aft:library" project="xxx" subtype="clear_trash">
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionary];
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":@"clear_trash", @"project":projectID}
                                                                stringValue:[templateDic JSONString]];
            
            IQElement *iqElement = [IQElement iqElementWithFrom:nil
                                                             to:nil
                                                           type:@"set"
                                                             id:requestKey
                                                   childElement:cloudElement];
            
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
    return [self _executeRequestBlockWithElementName:@"project" xmlns:CLOUD_REQUEST_XMLNS sendIQ:iq];
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
    if ( [[iq type] isEqualToString:@"result"] || [[iq type] isEqualToString:@"error"] ) {
        NSXMLElement *project = [iq elementForName:@"query" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_XMLNS]];
        
        if (project) {
            NSString *requestkey = [iq elementID];
            NSString *projectType = [project attributeStringValueForName:@"subtype"];
            NSString *projectID = [project attributeStringValueForName:@"project"];
            NSString *subtype = [NSString stringWithFormat:@"%@%@%@", @"rename_folder", @"\"/\"", @"rename_file"];
            
            if ([projectType isEqualToString:@"list_folder"]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    return YES;
                }
                
                /**
                 结果：
                 note: 客户端根据owner中的jid从本地数据库中，获取此人的职位并显示, 如果是admin不做此操作。
                 
                 list_root result:
                 <iq type="result" id="1234" >
                 <query xmlns="aft:library" subtype="list_folder">
                 {"parent":"xxx", "folders":[], "files":[]}
                 %%[{"folder":"1", "id":"1",  "type":"0" "name":"资料库",      "creator":"admin", "owner":"admin", "time":"2015-09-01"},
                 %%{"folder":"1", "id":"2",  "type":"0" "name":"资料归档",  "creator":"admin", "owner":"admin", "time":"2015-09-01"},
                 %%{"folder":"1", "id":"3",  "type":"0" "name":"工作文件",  "creator":"admin", "owner":"admin", "time":"2015-09-01"},
                 %%{"folder":"1", "id":"4",  "type":"2" "name":"张三",          "creator":"jid",      "owner":"admin",  "time":"2015-09-01"}
                 </query>
                 </iq>
                 
                 note: 客户端检查一下type=2的项，有没有owner=self jid，如果没有，显示一个自己的文件夹。
                 
                 list other folder result:
                 <iq type="result" id="1234" >
                 <query xmlns="aft:library" project="xxx" subtype="list_folder">
                 {"parent":"xxx", "folders":[], "files":[]}
                 %%[{"folder":"1", "id":"4", "parent":"xx", "type":"1" "name":"效果图", "creator":"jid", "owner":"admin", "time":"2015-09-01"},
                 %% {"folder":"0", "id":"5", "parent":"xx", "uuid":"xxx", "name":"通迅录.xls", "version":"3", "creator":"jid", "time":"2015-09-01"}]
                 </query>
                 </iq>
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSString *parent = [data objectForKey:@"parent"];
                NSArray *folders = [data objectForKey:@"folder"];
                [self _resetFoldersWithDics:folders parent:parent projectID:projectID];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.向数据库获取数据
                    NSArray *folder = [_xmppCloudStorage cloudFolderWithParent:parent projectID:projectID xmppStream:xmppStream];
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:folder];
                }
                return YES;
            }
            else if ([projectType isEqualToString:@"add_folder"]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /**
                 <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="request_all_cloud_key" type="result">
                 <query xmlns="aft:library" subtype="add_folder" project="460">
                 {"parent":"10", "folder":[{"id":"11", "type":"3", "name":"通讯录", 		"creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", 		"owner":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "Time":"2015-10-15 17:57:03"}]}
                 </query>
                 </iq>
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                
                [self _executeRequestBlockWithRequestKey:requestkey valueObject:data];
                
                return YES;
            }
            else if ([projectType isEqualToString:subtype]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /**
                 
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                
                [self _executeRequestBlockWithRequestKey:requestkey valueObject:data];
                
                return YES;
            }
            else if ([projectType isEqualToString:@"share"]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    return YES;
                }
                
                /**
                 <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="request_all_cloud_key" type="result"><query xmlns="aft:library" subtype="share" project="460">{"id":"11","users":["88f7c8781ae748959eb3d3d8de592e7b@120.24.94.38","1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38"]}</query></iq>
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSString *parent = [data objectForKey:@"parent"];
                NSArray *folders = [data objectForKey:@"folder"];
                [self _resetFoldersWithDics:folders parent:parent projectID:projectID];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.向数据库获取数据
                    NSArray *folder = [_xmppCloudStorage cloudFolderWithParent:parent projectID:projectID xmppStream:xmppStream];
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:folder];
                }
                return YES;
            }


            
            
        }
        
    }
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    
}

@end

