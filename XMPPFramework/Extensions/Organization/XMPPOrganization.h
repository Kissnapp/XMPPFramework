//
//  XMPPOrganization.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/22.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>


typedef void(^CompletionBlock)(id data, NSError *error);

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

-(void)getPossibleStaff:(NSString*)ID
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
- (NSArray*)allPorjectListWithbareJid:(NSString*)streamBareJidStr stream:(XMPPStream*)xmppStream;
@optional

@end
