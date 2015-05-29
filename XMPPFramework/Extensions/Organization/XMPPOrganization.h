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
