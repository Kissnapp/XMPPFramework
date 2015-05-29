//
//  XMPPOrganization.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/22.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>

typedef void(^allProjectBlock)(id data, NSError *error);
typedef void(^CompletionBlock)(id data, NSError *error);

typedef void (^allTemplateBlock)(id data, NSError *error);
typedef void (^checkNameBlock)(id data, NSError *error);
typedef void (^createBlock)(id data, NSError *error);
typedef void (^endBlock)(id data, NSError *error);

typedef void (^possibileBlock)(id data, NSError *error);
typedef void (^customeBlock)(id data, NSError *error);

typedef void (^addMemberBlock)(id data, NSError *error);
typedef void (^deleteMemberBlock)(id data, NSError *error);
typedef void (^memberListAndLinkBlock)(id data, NSError *error);
typedef void (^memberListBlock)(id data, NSError *error);

typedef void (^linkProjectListBlock)(id data, NSError *error);
typedef void (^searchProjectBlock)(id data, NSError *error);

typedef void (^subscribeProjectBlock)(id data, NSError *error);
typedef void (^subscribedProjectBlock)(id data, NSError *error);
typedef void (^unsubscribedProjectBlock)(id data, NSError *error);

@protocol XMPPOrganizationDelegate;
@protocol XMPPOrganizationStorage;

@interface XMPPOrganization : XMPPModule
{
    __strong id <XMPPOrganizationStorage> _xmppOrganizationStorage;
}

@property (strong, readonly) id <XMPPOrganizationStorage> xmppOrganizationStorage;

- (id)initWithOrganizationStorage:(id <XMPPOrganizationStorage>)storage;
- (id)initWithOrganizationStorage:(id <XMPPOrganizationStorage>)storage dispatchQueue:(dispatch_queue_t)queue;

- (void)requestOrganizationViewWithTemplateId:(NSString *)templateId
                              completionBlock:(CompletionBlock)completionBlock;
- (void)allPorjectListWithBlock:(allProjectBlock)completionBlock;

- (void)requestAllTemplateWithBlock:(allTemplateBlock)block;

- (void)checkOrganizationName:(NSString *)name
              completionBlock:(checkNameBlock)completionBlock;

- (void)createOrganizationWithName:(NSString *)name
                        templateId:(NSString *)templateId
                             jobId:(NSString *)jobId
                   completionBlock:(createBlock)completionBlock;

- (void)endOrganizationWithId:(NSString *)Id
              completionBlock:(endBlock)completionBlock;

-(void)getPossibleStaff:(NSString*)ID
        completionBlock:(possibileBlock)completionBlock;

-(void)addCustomJob:(NSString*)ID
           parentId:(NSString*)parentId
               name:(NSString*)jobName
               part:(NSString*)part
    completionBlock:(customeBlock)completionBlock ;

-(void)addMemberToProject:(NSString*)ID
                    jodId:(NSString*)jobID
                     name:(NSString*)jobName
                      jid:(NSString*)jid
                     part:(NSString*)part
          completionBlock:(addMemberBlock)completionBlock;

-(void)deleteMemberFromPro:(NSString*)projectID
                       jid:(NSString*)jid
           completionBlock:(deleteMemberBlock)completionBlock;


-(void)memberListAndLinkPro:(NSString*)projectID
            completionBlock:(memberListAndLinkBlock)completionBlock;

-(void)allMemberList:(NSString*)projectID
     completionBlock:(memberListBlock)completionBlock;

-(void)allLinkProjectList:(NSString*)projectID
          completionBlock:(linkProjectListBlock)completionBlock;

-(void)searchProject:(NSString*)name
     completionBlock:(searchProjectBlock)completionBlock;

-(void)subcribeProject:(NSString*)myID
                target:(NSString*)targetID
       completionBlock:(subscribeProjectBlock)competionBlock;

-(void)agreeSubcribeProject:(NSString*)myID
                     target:(NSString*)targetID
            completionBlock:(subscribedProjectBlock)competionBlock;

-(void)dissagreeSubcribeProject:(NSString*)myID
                         target:(NSString*)targetID
                completionBlock:(unsubscribedProjectBlock)competionBlock;



@end


// XMPPOrganizationDelegate
@protocol XMPPOrganizationDelegate <NSObject>

@required

@optional

@end

// XMPPOrganizationStorage
@protocol XMPPOrganizationStorage <NSObject>

@required

- (BOOL)configureWithParent:(XMPPOrganization *)aParent queue:(dispatch_queue_t)queue;

@optional

@end
