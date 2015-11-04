//
//  XMPPCloud.h
//  XMPP_Project
//
//  Created by jeff on 15/9/22.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>

typedef void(^CompletionBlock)(id data, NSError *error);

@protocol XMPPCloudStorage;

@interface XMPPCloud : XMPPModule
{
    __strong id <XMPPCloudStorage> _xmppCloudStorage;
}

@property (strong, readonly) id <XMPPCloudStorage> xmppCloudStorage;

- (id)initWithCloudStorage:(id <XMPPCloudStorage>)storage;
- (id)initWithCloudStorage:(id <XMPPCloudStorage>)storage dispatchQueue:(dispatch_queue_t)queue;

#pragma mark - 1.获取文件夹内容
- (void)requestCloudListFolderWithFolder:(NSNumber *)folder projectID:(NSString *)projectID block:(CompletionBlock)completionBlock;

#pragma mark - 2.创建文件夹
- (void)requestCloudAddFolderWithParent:(NSString *)parent projectID:(NSString *)projectID name:(NSString *)name block:(CompletionBlock)completionBlock;

#pragma mark - 3.添加文件
- (void)requestCloudAddFileWithParent:(NSString *)parent projectID:(NSString *)projectID name:(NSString *)name size:(NSData *)size uuid:(NSString *)uuid block:(CompletionBlock)completionBlock;


#pragma mark - 4.删除文件夹/删除文件
- (void)requestCloudDeleteWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID folderOrFileType:(NSNumber *)folderOrFileType block:(CompletionBlock)completionBlock;


#pragma mark - 5.重命名
- (void)requestCloudRenameWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID name:(NSString *)name folderOrFileType:(NSNumber *)folderOrFileType block:(CompletionBlock)completionBlock;


#pragma mark - 6.共享
- (void)requestCloudShareWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID users:(NSArray *)users block:(CompletionBlock)completionBlock;


#pragma mark - 7.移动 **
- (void)requestCloudMoveWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID destinationParent:(NSString *)destinationParent folderOrFileType:(NSNumber *)folderOrFileType block:(CompletionBlock)completionBlock;


#pragma mark - 8.上传版本 问题
- (void)requestCloudUploadVersionWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID users:(NSArray *)users block:(CompletionBlock)completionBlock;

#pragma mark - 9.获取共享人员列表 问题
- (void)requestCloudSharedListWithCloudID:(NSString *)cloudID projectID:(NSString *)projectID block:(CompletionBlock)completionBlock;

#pragma mark - 10.获取文件版本
/**
 
 <iq type="get" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="list_version">
 {"id":"xxx"}
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="list_version">
 %% id是file version id, file是文件id. 如果id为-1则是最近的版本。
 {"id":"xxx", "file":[{"id":"-1", "file","xxx", "uuid":"xxx", "size":"xxx", "creator":"xxx", "time":"xxx"}, ...]}
 </query>
 </iq>
 
 */



#pragma mark - 11.网盘文件下载:TOFIX
/**
 
 <iq type="get" id="1234" >
 <query xmlns="aft:library"  project="xxx"  subtype="download">
 {"id":"xxx",  "uuid":"xxx"} %% id: file id
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="list_version">
 {"id":"xxx", "uuid":"xxx", "url":"xxx"}
 </query>
 </iq>
 
 */



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
- (void)requestCloudGetLogWithProjectID:(NSString *)projectID count:(NSString *)count before:(NSString *)before block:(CompletionBlock)completionBlock;


#pragma mark - 13.获取我的回收站
/**
 
 <iq type="get" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="get_trash">
 {"before"/"after":1, "count":"xxx"} %% 如果为before且值为""，则表示获取最近的多少条。
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library"  project="xxx" subtype="get_trash">    %%规定一下count最大为20条，这样可以在一个结果里全部返回，不用一条一条的返回。
 {"count":"xxx", "files":[] } %% logs 需要客户端自己根据id去升序排序。
 </query>
 </iq>
 
 注意：如果file的location里有"@"请替换为自己的姓名。
 
 */



#pragma mark - 14.清空回收站
- (void)requestCloudClearTrashWithProjectID:(NSString *)projectID block:(CompletionBlock)completionBlock;


#pragma mark - 15.恢复
/**
 
 <iq type="set" id="1234" >
 <query xmlns="aft:library" project="49" subtype="recover_file">
 {"id":"9", "name":"全体通过录2", "dest_parent":"2"}  % name may be a new name as dest folder has duplication name.
 </query>
 </iq>
 
 <iq type="result" id="1234" >
 <query xmlns="aft:library" project="xxx" subtype="recover_file">
 {"id":"xxx", "dest_parent":"xxx"}
 </query>
 </iq>
 
 */



@end


@protocol XMPPCloudStorage <NSObject>

@required

- (BOOL)configureWithParent:(XMPPCloud *)aParent queue:(dispatch_queue_t)queue;

@optional

- (id)cloudFolderWithParent:(NSString *)parent projectID:(NSString *)projectID xmppStream:(XMPPStream *)stream;
- (void)insertCloudDatas:(NSArray *)serverDatas xmppStream:(XMPPStream *)stream;
- (void)deleteCloudDatas:(NSArray *)serverDatas xmppStream:(XMPPStream *)stream;
@end
