//
//  XMPPOrganization.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/22.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPP.h"

typedef void(^CompletionBlock)(id data, NSError *error);

@protocol XMPPOrgDelegate;
@protocol XMPPOrgStorage;

@class XMPPOrgUserCoreDataStorageObject;

@interface XMPPOrg : XMPPModule
{
    __strong id <XMPPOrgStorage> _xmppOrgStorage;
}

@property (strong, readonly) id <XMPPOrgStorage> xmppOrgStorage;

@property (assign) BOOL autoFetchOrgList;
@property (assign) BOOL autoFetchOrgTemplateList;

- (id)initWithOrganizationStorage:(id <XMPPOrgStorage>)storage;
- (id)initWithOrganizationStorage:(id <XMPPOrgStorage>)storage dispatchQueue:(dispatch_queue_t)queue;

#pragma mark - 获取所有项目
- (void)requestServerAllOrgList;
- (void)requestDBAllOrgListWithBlock:(CompletionBlock)completionBlock;
- (void)clearAllOrgs;

#pragma mark - 获取所有模板
- (void)requestServerAllTemplates;
- (void)requestDBAllTemplatesWithBlock:(CompletionBlock)completionBlock;
- (void)clearAllTemplates;

#pragma mark - 获取一个组织的所有职位信息
- (void)requestServerAllPositionListWithOrgId:(NSString *)orgId;

- (void)requestDBAllPositionListWithOrgId:(NSString *)orgId
                          completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 获取一个组织的所有成员信息
- (void)requestServerAllUserListWithOrgId:(NSString *)orgId;
- (void)requestDBAllUserListWithOrgId:(NSString *)orgId completionBlock:(CompletionBlock)completionBlock;;

#pragma mark - 获取一个组织的所有关键组织的id
- (void)requestServerAllRelationListWithOrgId:(NSString *)orgId;
- (void)requestDBAllRelationListWithOrgId:(NSString *)orgId completionBlock:(CompletionBlock)completionBlock;;

#pragma mark - 验证组织name
- (void)checkOrgName:(NSString *)name
     completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 创建组织
- (void)createOrgWithName:(NSString *)name
               templateId:(NSString *)templateId
                selfJobId:(NSString *)jobId
          completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 结束组织
- (void)endOrgWithId:(NSString *)orgId
     completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 查询自己可以添加的职位（自己的子职位）列表
- (void)requestDBAllSubPositionsWithPtId:(NSString *)ptId
                                   orgId:(NSString *)orgId
                         completionBlock:(CompletionBlock)completionBlock;

- (void)requestServerAllSubPositionsWithOrgId:(NSString *)orgId
                              completionBlock:(CompletionBlock)completionBlock;


#pragma mark - 创建新的职位信息
/**
 *  创建新的职位信息
 *
 *  @param orgId           组织id
 *  @param parentPtId      职位所属上级职位的id
 *  @param ptName          职位名称
 *  @param dpName          职位所属部门名称
 *  @param completionBlock 返回结果block
 */
- (void)createPositionWithOrgId:(NSString *)orgId
                     parentPtId:(NSString *)parentPtId
                         ptName:(NSString *)ptName
                         dpName:(NSString *)dpName
                completionBlock:(CompletionBlock)completionBlock;

#pragma mark - 为某个组织加人
- (void)addUsers:(NSArray *)users joinOrg:(NSString *)orgId completionBlock:(CompletionBlock)completionBlock;
- (void)fillOrg:(NSString *)orgId callBackBlock:(CompletionBlock)completionBlock withUsers:(XMPPOrgUserCoreDataStorageObject *)user1, ... ;

#pragma mark - 从某个组织删人

#pragma mark - 订阅某个组织

#pragma mark - 取消订阅m

-(void)addCustomJob:(NSString*)ID
           parentId:(NSString*)parentId
               name:(NSString*)jobName
               part:(NSString*)part
    completionBlock:(CompletionBlock)completionBlock ;

-(void)addMemberToProject:(NSString*)ID
                    jodId:(NSString*)jobID
                     name:(NSString*)jobName
                      jid:(NSString*)jid
                     part:(NSString*)part
          completionBlock:(CompletionBlock)completionBlock;

-(void)deleteMemberFromPro:(NSString*)projectID
                       jid:(NSString*)jid
           completionBlock:(CompletionBlock)completionBlock;


-(void)memberListAndLinkPro:(NSString*)projectID
            completionBlock:(CompletionBlock)completionBlock;

-(void)allMemberList:(NSString*)projectID
     completionBlock:(CompletionBlock)completionBlock;

-(void)allLinkProjectList:(NSString*)projectID
          completionBlock:(CompletionBlock)completionBlock;

-(void)searchProject:(NSString*)name
     completionBlock:(CompletionBlock)completionBlock;

-(void)subcribeProject:(NSString*)myID
                target:(NSString*)targetID
       completionBlock:(CompletionBlock)completionBlock;

-(void)agreeSubcribeProject:(NSString*)myID
                     target:(NSString*)targetID
            completionBlock:(CompletionBlock)completionBlock;

-(void)dissagreeSubcribeProject:(NSString*)myID
                         target:(NSString*)targetID
                completionBlock:(CompletionBlock)completionBlock;

-(void)cancelSubcribeProject:(NSString*)myID
                         target:(NSString*)targetID
                completionBlock:(CompletionBlock)completionBlock;

-(void)getTempHashWithcompletionBlock:(CompletionBlock)completionBlock ;

@end


// XMPPOrganizationDelegate
@protocol XMPPOrgDelegate <NSObject>

@required

@optional

@end

// XMPPOrganizationStorage
@protocol XMPPOrgStorage <NSObject>

@required

- (BOOL)configureWithParent:(XMPPOrg *)aParent queue:(dispatch_queue_t)queue;

@optional

- (void)clearUnusedOrgWithOrgIds:(NSArray *)orgIds isTemplate:(BOOL)isTemplate xmppStream:(XMPPStream *)stream;
- (void)clearAllOrgWithXMPPStream:(XMPPStream *)stream;
- (void)clearAllTemplatesWithXMPPStream:(XMPPStream *)stream;
- (id)allOrgTemplatesWithXMPPStream:(XMPPStream *)stream;
- (id)allOrgsWithXMPPStream:(XMPPStream *)stream;
- (id)orgWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;

- (id)orgPositionsWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;

- (id)orgUsersWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;

- (id)orgRelationsWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;

- (void)insertOrUpdateOrgInDBWith:(NSDictionary *)dic
                       xmppStream:(XMPPStream *)stream
                        userBlock:(void (^)(NSString *orgId))userBlock
                    positionBlock:(void (^)(NSString *orgId))positionBlock
                    relationBlock:(void (^)(NSString *orgId))relationBlock;

- (void)clearUsersWithOrgId:(NSString *)orgId  xmppStream:(XMPPStream *)stream;
- (void)insertOrUpdateUserInDBWithOrgId:(NSString *)orgId dic:(NSDictionary *)dic xmppStream:(XMPPStream *)stream;
 
- (void)clearPositionsWithOrgId:(NSString *)orgId  xmppStream:(XMPPStream *)stream;
- (void)insertOrUpdatePositionInDBWithOrgId:(NSString *)orgId dic:(NSDictionary *)dic xmppStream:(XMPPStream *)stream;

- (void)clearRelationsWithOrgId:(NSString *)orgId  xmppStream:(XMPPStream *)stream;
- (void)insertOrUpdateRelationInDBWithOrgId:(NSString *)orgId dic:(NSDictionary *)dic xmppStream:(XMPPStream *)stream;

- (id)endOrgWithOrgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;

- (id)subPositionsWithPtId:(NSString *)ptId orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;
- (id)positionWithPtId:(NSString *)ptId orgId:(NSString *)orgId xmppStream:(XMPPStream *)stream;

@end
