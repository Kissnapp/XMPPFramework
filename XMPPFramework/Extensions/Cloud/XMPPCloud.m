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

#pragma mark - 处理服务器返回的数据

#pragma mark - 1.处理获取文件夹内容
- (void)handleCloudListFolderDatasWithDicDatas:(NSDictionary *)dicDatas projectID:(NSString *)projectID
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    NSArray *serverDatas = [self _handleCloudListFolderDatasWithDicDatas:dicDatas projectID:projectID];
    
    [_xmppCloudStorage insertCloudDatas:serverDatas xmppStream:xmppStream];
}

- (NSArray *)_handleCloudListFolderDatasWithDicDatas:(NSDictionary *)dicDatas projectID:(NSString *)projectID
{
    /**
     {"parent":"-1", 
     "folder":[{"id":"10", "type":"2", "name":"", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", 		"owner":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "Time":"2015-10-15 17:57:03"},
     {"id":"9", "type":"0", "name":"资料归档", "creator":"admin", "owner":"admin", "Time":"2015-10-13 16:41:36"},
     {"id":"8", "type":"0", "name":"资料库", "creator":"admin", "owner":"admin", "Time":"2015-10-13 16:41:36"},
     {"id":"7", "type":"0", "name":"工作文件", "creator":"admin", "owner":"admin", "Time":"2015-10-13 16:41:36"}], 
     "file":[]}
     
     */
    NSString *myJidStr = [[xmppStream myJID] bare];
    NSString *parent = [dicDatas objectForKey:@"parent"];
    NSArray *folders = [dicDatas objectForKey:@"folder"];
    NSArray *files = [dicDatas objectForKey:@"file"];
    
    NSMutableArray *arrayM = [NSMutableArray array];
    for ( NSDictionary *dic in folders ) {
        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
        [dicM setObject:projectID forKey:@"project"];
        [dicM setObject:parent forKey:@"parent"];
        [dicM setObject:[NSNumber numberWithBool:YES] forKey:@"folderOrFileType"];
        NSString *creator = [dic objectForKey:@"creator"];
        if ( [creator isEqualToString:myJidStr] ) {
            [dicM setObject:[NSNumber numberWithInteger:1] forKey:@"folderIsMe"];
        } else {
            [dicM setObject:[NSNumber numberWithInteger:0] forKey:@"folderIsMe"];
        }
        [arrayM addObject:dicM];
    }
    
    /**
     // 公共文件夹/子文件夹
     <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="4FB8B9C3-BB8A-4527-AF80-BC3FF05CEDC1" type="result"><query xmlns="aft:library" subtype="list_folder" project="460">{"parent":"9", "folder":[{"id":"27", "type":"1", "name":"尼克", "creator":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38", "owner":"admin", "Time":"2015-10-22 15:36:29"},{"id":"24", "type":"1", "name":"星期", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "owner":"admin", "Time":"2015-10-21 11:19:35"},{"id":"22", "type":"1", "name":"心情", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "owner":"admin", "Time":"2015-10-21 10:58:42"}], "file":[]}</query></iq>
     // 私人文件夹
     <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="EF25643B-BD84-483C-BAF1-8476DA63E8D6" type="result"><query xmlns="aft:library" subtype="list_folder" project="460">{"parent":"10", "folder":[{"id":"21", "type":"3", "name":"星期天", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "owner":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "Time":"2015-10-16 13:28:21"},{"id":"11", "type":"5", "name":"通讯录", "creator":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "owner":"1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38", "Time":"2015-10-15 17:57:03"}], "file":[]}</query></iq>
     */
    for ( NSDictionary *dic in files ) {
        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
        [dicM setObject:projectID forKey:@"project"];
        [dicM setObject:parent forKey:@"parent"];
        [dicM setObject:[NSNumber numberWithBool:NO] forKey:@"folderOrFileType"];
        [arrayM addObject:dicM];
    }
    return [NSArray arrayWithArray:arrayM];
}

#pragma mark 2.处理创建文件夹数据
- (void)handleCloudAddFolderDatasWithDicDatas:(NSDictionary *)dicDatas projectID:(NSString *)projectID
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    NSArray *serverDatas = [self _handleCloudAddFolderDatasWithDicDatas:dicDatas projectID:projectID];
    
    [_xmppCloudStorage insertCloudDatas:serverDatas xmppStream:xmppStream];
}

- (NSArray *)_handleCloudAddFolderDatasWithDicDatas:(NSDictionary *)dicDatas projectID:(NSString *)projectID
{
    /**
     [{"parent":"9", "folder":[{"id":"25", "type":"1", "name":"星期天", "creator":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38", "owner":"admin", "Time":"2015-10-22 14:42:46"}]}]
     */
    
    NSString *myJidStr = [[xmppStream myJID] bare];
    NSString *parent = [dicDatas objectForKey:@"parent"];
    NSArray *folders = [dicDatas objectForKey:@"folder"];
    
    NSMutableArray *arrayM = [NSMutableArray array];
    for ( NSDictionary *dic in folders ) {
        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
        [dicM setObject:projectID forKey:@"project"];
        [dicM setObject:parent forKey:@"parent"];
        [dicM setObject:[NSNumber numberWithBool:YES] forKey:@"folderOrFileType"];
        NSString *owner = [dic objectForKey:@"creator"];
        if ( [owner isEqualToString:myJidStr] ) {
            [dicM setObject:[NSNumber numberWithInteger:1] forKey:@"folderIsMe"];
        } else {
            [dicM setObject:[NSNumber numberWithInteger:0] forKey:@"folderIsMe"];
        }
        [arrayM addObject:dicM];
    }
    return [NSArray arrayWithArray:arrayM];
}


#pragma mark 4.删除文件夹/删除文件
- (void)handleCloudDeleteFolderDatasWithDicDatas:(NSDictionary *)dicDatas projectID:(NSString *)projectID
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    NSArray *serverDatas = [self _handleCloudDeleteFolderDatasWithDicDatas:dicDatas projectID:projectID];
    
    [_xmppCloudStorage deleteCloudDatas:serverDatas xmppStream:xmppStream];
}

- (NSArray *)_handleCloudDeleteFolderDatasWithDicDatas:(NSDictionary *)dicDatas projectID:(NSString *)projectID
{
    /**
     {"id":"26"}
     */
    
    NSMutableArray *arrayM = [NSMutableArray array];
    [arrayM addObject:dicDatas];
    return [NSArray arrayWithArray:arrayM];
}



#pragma mark 9.获取共享人员列表
- (void)handleCloudSharedListDatasWithArrDatas:(NSArray *)arrDatas projectID:(NSString *)projectID cloudID:(NSString *)cloudID
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    NSArray *serverDatas = [self _handleCloudSharedListDatasWithArrDatas:arrDatas projectID:projectID cloudID:cloudID];
    
    // no process
    serverDatas = nil;
//    [_xmppCloudStorage insertCloudDatas:serverDatas xmppStream:xmppStream];
}

- (NSArray *)_handleCloudSharedListDatasWithArrDatas:(NSArray *)arrDatas projectID:(NSString *)projectID cloudID:(NSString *)cloudID
{
    /**
     <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="request_all_cloud_key" type="result">
     <query xmlns="aft:library" subtype="list_share_users" project="460">
     ["1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38","1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38","88f7c8781ae748959eb3d3d8de592e7b@120.24.94.38"]
     </query>
     </iq>
     */
    NSMutableArray *arrayM = [NSMutableArray array];
    for ( NSString *jidStr in arrDatas ) {
        NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
        [dicM setObject:jidStr forKey:@"jid"];
        [dicM setObject:projectID forKey:@"project"];
        [dicM setObject:cloudID forKey:@"id"];
        [arrayM addObject:dicM];
    }
    return arrayM;
}


#pragma mark - 网盘网络接口

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

- (void)requestCloudListFolderWithFolder:(NSNumber *)folder projectID:(NSString *)projectID block:(CompletionBlock)completionBlock
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

- (void)requestCloudAddFolderWithParent:(NSString *)parent projectID:(NSString *)projectID name:(NSString *)name block:(CompletionBlock)completionBlock
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



#pragma mark - 3.添加文件
/**
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="add_file">
 {"parent":"", "name":"xxx", "uuid":"xxx", "size":"xxx"}  %% parent value empty mean self folder not exist.  jid same with mms's store jid.
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library" subtype="add_file">
 {"parent":"xxx", "files":[]}
 </query>
 </iq>
 
 note(2, 3):如果在私人文件夹内创建文件夹或添加文件，个人文件夹还未创立，parent设为""，
 服务器会根据""，如果没有创建去创建它，创建的id号在parent属性里，客户端根据此parent去更新一下本地,
 如果有，则不用创建个人文件夹。
 
 */
- (void)requestCloudAddFileWithParent:(NSString *)parent projectID:(NSString *)projectID name:(NSString *)name size:(NSData *)size uuid:(NSString *)uuid block:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (!dispatch_get_specific(moduleQueueTag)) return;
        
        if ([self canSendRequest]) {
            
            // we should make sure whether we can send a request to the server
            // If the templateId is nil，we should notice the user the info
            
            // 0. Create a key for storaging completion block
//            NSString *requestKey = [[self xmppStream] generateUUID];
            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /**
             <iq type="set" id="1234" >
             <query xmlns="aft:library" project="xxx" subtype="add_file">
             {"parent":"", "name":"xxx", "uuid":"xxx", "size":"xxx"}  %% parent value empty mean self folder not exist.  jid same with mms's store jid.
             </query>
             </iq>
             */
            
            // 3. Create the request iq
            NSDictionary *templateDic = [NSDictionary dictionaryWithObjectsAndKeys:parent, @"parent", name, @"name", uuid, @"uuid", size, @"size", nil];
            
            ChildElement *cloudElement = [ChildElement childElementWithName:@"query"
                                                                      xmlns:@"aft:library"
                                                                  attribute:@{@"subtype":@"add_file", @"project":projectID}
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



#pragma mark 4.删除文件夹/删除文件
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


#pragma mark 5.重命名
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


#pragma mark 6.共享
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
             
             <iq id="request_all_cloud_key" type="set"><query xmlns="aft:library" subtype="share" project="460"/></iq>
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


#pragma mark 7.移动
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

#pragma mark 9.获取共享人员列表
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
            NSString *requestKey = [[self xmppStream] generateUUID];
//            NSString *requestKey = [NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY];
            
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


#pragma mark 12.获取日志 问题
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


#pragma mark 14.清空回收站
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
            
            
#pragma mark - 1.list_folder
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
                NSDictionary *dicData = (NSDictionary *)data;
                [self handleCloudListFolderDatasWithDicDatas:dicData projectID:projectID];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.向数据库获取数据
                    NSArray *folder = [_xmppCloudStorage cloudFolderWithParent:[dicData objectForKey:@"parent"] projectID:projectID xmppStream:xmppStream];
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:folder];
                }
                return YES;
            }
            
#pragma mark - 2.add_folder
            else if ([projectType isEqualToString:@"add_folder"]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /**
                 <iq xmlns="jabber:client" from="33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38" to="33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38/mobile" id="request_all_cloud_key" type="result">
                 <query xmlns="aft:library" subtype="add_folder" project="460">
                 [{"parent":"9", "folder":[{"id":"25", "type":"1", "name":"星期天", "creator":"33d3119b90ce42e4824e4328bdae8d0e@120.24.94.38", "owner":"admin", "Time":"2015-10-22 14:42:46"}]}]
                 </query>
                 </iq>
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSArray *dic = (NSArray *)data;
                NSDictionary *dicData = [dic firstObject];
                [self handleCloudAddFolderDatasWithDicDatas:dicData projectID:projectID];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.向数据库获取数据
                    NSArray *folder = [_xmppCloudStorage cloudFolderWithParent:[dicData objectForKey:@"parent"] projectID:projectID xmppStream:xmppStream];
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:folder];
                }
                return YES;
            }
            
#pragma mark - 4.1.delete_folder -- no handle
            else if ([projectType isEqualToString:@"delete_folder"]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    
                    return YES;
                }
                
                /**
                 <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="86E1C98A-04DD-40F4-8E7E-E7E7C6A4DBFF" type="result">
                 <query xmlns="aft:library" subtype="delete_folder" project="460">
                 {"id":"18"}
                 </query>
                 </iq>
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSDictionary *dicData = (NSDictionary *)data;
                [self handleCloudDeleteFolderDatasWithDicDatas:dicData projectID:projectID];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.向数据库获取数据
                    NSArray *folder = [_xmppCloudStorage cloudFolderWithParent:[dicData objectForKey:@"parent"] projectID:projectID xmppStream:xmppStream];
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:folder];
                }
                return YES;
            }
            
#pragma mark - 4.2.delete_file -- no handle
            else if ([projectType isEqualToString:nil]) {
                
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
            
#pragma mark - 5.1.rename_folder -- no handle
            if ([projectType isEqualToString:@"rename_folder"]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    return YES;
                }
                
                /**
                 
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSDictionary *dicData = (NSDictionary *)data;
//                [self handleCloudListFolderDatasWithDicDatas:dicData projectID:projectID];
//                
//                // 1.判断是否向逻辑层返回block
//                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
//                    // 2.向数据库获取数据
//                    NSArray *folder = [_xmppCloudStorage cloudFolderWithParent:[dicData objectForKey:@"parent"] projectID:projectID xmppStream:xmppStream];
//                    // 3.用block返回数据
//                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:folder];
//                }
                return YES;
            }

#pragma mark - 5.2.rename_file -- no handle
            if ([projectType isEqualToString:@"rename_file"]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    return YES;
                }
                
                /**
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSDictionary *dicData = (NSDictionary *)data;
                [self handleCloudListFolderDatasWithDicDatas:dicData projectID:projectID];
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.向数据库获取数据
                    NSArray *folder = [_xmppCloudStorage cloudFolderWithParent:[dicData objectForKey:@"parent"] projectID:projectID xmppStream:xmppStream];
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:folder];
                }
                return YES;
            }
            
#pragma mark - 6.share -- no process
            else if ([projectType isEqualToString:@"share"]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    return YES;
                }
                
                /**
                 
                 <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="request_all_cloud_key" type="result"><query xmlns="aft:library" subtype="share" project="460">{"id":"28","users":[]}</query></iq>
                 <Oct 24 2015 14:26:35>
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
//                NSDictionary *dicData = (NSDictionary *)data;
//                [self handleCloudListFolderDatasWithDicDatas:dicData projectID:projectID];
//                
//                // 1.判断是否向逻辑层返回block
//                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
//                    // 2.向数据库获取数据
//                    NSArray *folder = [_xmppCloudStorage cloudFolderWithParent:[dicData objectForKey:@"parent"] projectID:projectID xmppStream:xmppStream];
//                    // 3.用block返回数据
//                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:folder];
//                }
                return YES;
            }
            
#pragma mark - 9.list_share_users
            else if ([projectType isEqualToString:@"list_share_users"]) {
                
                if ([[iq type] isEqualToString:@"error"]) {
                    NSXMLElement *errorElement = [iq elementForName:@"error"];
                    NSXMLElement *codeElement = [errorElement elementForName:@"code" xmlns:[NSString stringWithFormat:@"%@",CLOUD_REQUEST_ERROR_XMLNS]];
                    [self _executeRequestBlockWithRequestKey:requestkey errorMessage:[codeElement stringValue]];
                    return YES;
                }
                
                /**
                 88f7c8781ae748959eb3d3d8de592e7b
                 1758b0fbfecb47398d4d2710269aa9e5
                 
                 1758b0fbfecb47398d4d2710269aa9e5
                 1758b0fbfecb47398d4d2710269aa9e5
                 88f7c8781ae748959eb3d3d8de592e7b
                 
                 <iq xmlns="jabber:client" from="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38" to="1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38/mobile" id="request_all_cloud_key" type="result">
                    <query xmlns="aft:library" subtype="list_share_users" project="460">
                    ["1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38","1758b0fbfecb47398d4d2710269aa9e5@120.24.94.38","88f7c8781ae748959eb3d3d8de592e7b@120.24.94.38"]
                    </query>
                 </iq>
                 
                 */
                
                id data = [[project stringValue] objectFromJSONString];
                NSArray *arrData = (NSArray *)data;
                
                // 1.判断是否向逻辑层返回block
                if (![requestkey isEqualToString:[NSString stringWithFormat:@"%@",REQUEST_ALL_CLOUD_KEY]]) {
                    // 2.向数据库获取数据
//                    NSArray *folder = [_xmppCloudStorage cloudFolderWithParent:[dicData objectForKey:@"parent"] projectID:projectID xmppStream:xmppStream];
                    // 3.用block返回数据
                    [self _executeRequestBlockWithRequestKey:requestkey valueObject:arrData];
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

