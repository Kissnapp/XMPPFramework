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

@interface XMPPOrg : XMPPModule
{
    __strong id <XMPPOrgStorage> _xmppOrganizationStorage;
}

@property (strong, readonly) id <XMPPOrgStorage> xmppOrganizationStorage;

@property (assign) BOOL autoFetchOrgList;
@property (assign) BOOL autoFetchOrgTemplateList;

- (id)initWithOrganizationStorage:(id <XMPPOrgStorage>)storage;
- (id)initWithOrganizationStorage:(id <XMPPOrgStorage>)storage dispatchQueue:(dispatch_queue_t)queue;

#pragma mark - 获取所有项目
- (void)requestServerAllOrgList;
- (void)requestDBAllOrgListWithBlock:(CompletionBlock)completionBlock;

#pragma mark - 获取所有模板
- (void)requestServerAllTemplates;
- (void)requestDBAllTemplatesWithBlock:(CompletionBlock)completionBlock;

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


- (void)requestServerOrgPositionListWithOrgId:(NSString *)orgId;


- (void)requestOrganizationViewWithTemplateId:(NSString *)templateId
                              completionBlock:(CompletionBlock)completionBlock;

- (void)allPorjectListWithBlock:(CompletionBlock)completionBlock;

- (void)requestAllTemplateWithBlock:(CompletionBlock)block;

- (void)checkOrganizationName:(NSString *)name
              completionBlock:(CompletionBlock)completionBlock;

- (void)createOrganizationWithName:(NSString *)name
                        templateId:(NSString *)templateId
                             jobId:(NSString *)jobId
                   completionBlock:(CompletionBlock)completionBlock;

- (void)endOrganizationWithId:(NSString *)Id
              completionBlock:(CompletionBlock)completionBlock;

-(void)getPossiblePosition:(NSString*)ID
        completionBlock:(CompletionBlock)completionBlock;

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

- (id)allOrgTemplatesWithXMPPStream:(XMPPStream *)stream;
- (id)allOrgsWithXMPPStream:(XMPPStream *)stream;
- (id)orgPositionListWithId:(NSString *)orgId xmppStream:(XMPPStream *)stream;

- (id)orgUserListWithId:(NSString *)orgId xmppStream:(XMPPStream *)stream;
- (id)orgRelationListWithId:(NSString *)orgId xmppStream:(XMPPStream *)stream;

- (void)insertOrUpdateOrgInDBWith:(NSDictionary *)dic
                       xmppStream:(XMPPStream *)stream
                        userBlock:(void (^)(NSString *orgId))userBlock
                    positionBlock:(void (^)(NSString *orgId))positionBlock
                    relationBlock:(void (^)(NSString *orgId))relationBlock;

@end
