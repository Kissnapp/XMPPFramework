//
//  XMPPOrgCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/29.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPOrgCoreDataStorageObject.h"
#import "XMPPOrgRelationObject.h"


@implementation XMPPOrgCoreDataStorageObject

@dynamic orgId;
@dynamic orgName;
@dynamic orgState;
@dynamic orgStartTime;
@dynamic orgEndTime;
@dynamic orgAdminJidStr;
@dynamic orgDescription;
@dynamic streamBareJidStr;
@dynamic orgRelationShip;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - primitive Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)streamBareJidStr
{
    [self willAccessValueForKey:@"streamBareJidStr"];
    NSString *value = [self primitiveValueForKey:@"streamBareJidStr"];
    [self didAccessValueForKey:@"streamBareJidStr"];
    
    return value;
}

- (void)setStreamBareJidStr:(NSString *)value
{
    [self willChangeValueForKey:@"streamBareJidStr"];
    [self setPrimitiveValue:value forKey:@"streamBareJidStr"];
    [self didChangeValueForKey:@"streamBareJidStr"];
}

@end
