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
@dynamic ptTag;
@dynamic userTag;
@dynamic relationShipTag;
@dynamic orgRelationShip;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - primitive Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)orgId
{
    [self willAccessValueForKey:@"orgId"];
    NSString *value = [self primitiveValueForKey:@"orgId"];
    [self didAccessValueForKey:@"orgId"];
    
    return value;
}

- (void)setOrgId:(NSString *)value
{
    [self willChangeValueForKey:@"orgId"];
    [self setPrimitiveValue:value forKey:@"orgId"];
    [self didChangeValueForKey:@"orgId"];
}
- (NSString *)orgName
{
    [self willAccessValueForKey:@"orgName"];
    NSString *value = [self primitiveValueForKey:@"orgName"];
    [self didAccessValueForKey:@"orgName"];
    
    return value;
}

- (void)setOrgName:(NSString *)value
{
    [self willChangeValueForKey:@"orgName"];
    [self setPrimitiveValue:value forKey:@"orgName"];
    [self didChangeValueForKey:@"orgName"];
}
- (NSNumber *)orgState
{
    [self willAccessValueForKey:@"orgState"];
    NSNumber *value = [self primitiveValueForKey:@"orgState"];
    [self didAccessValueForKey:@"streamBareJidStr"];
    
    return value;
}

- (void)setOrgState:(NSNumber *)value
{
    [self willChangeValueForKey:@"orgState"];
    [self setPrimitiveValue:value forKey:@"orgState"];
    [self didChangeValueForKey:@"orgState"];
}
- (NSDate *)orgStartTime
{
    [self willAccessValueForKey:@"orgStartTime"];
    NSDate *value = [self primitiveValueForKey:@"orgStartTime"];
    [self didAccessValueForKey:@"orgStartTime"];
    
    return value;
}

- (void)setOrgStartTime:(NSDate *)value
{
    [self willChangeValueForKey:@"orgStartTime"];
    [self setPrimitiveValue:value forKey:@"orgStartTime"];
    [self didChangeValueForKey:@"orgStartTime"];
}
- (NSDate *)orgEndTime
{
    [self willAccessValueForKey:@"orgEndTime"];
    NSDate *value = [self primitiveValueForKey:@"orgEndTime"];
    [self didAccessValueForKey:@"orgEndTime"];
    
    return value;
}

- (void)setOrgEndTime:(NSDate *)value
{
    [self willChangeValueForKey:@"streamBareJidStr"];
    [self setPrimitiveValue:value forKey:@"streamBareJidStr"];
    [self didChangeValueForKey:@"streamBareJidStr"];
}
- (NSString *)orgAdminJidStr
{
    [self willAccessValueForKey:@"orgAdminJidStr"];
    NSString *value = [self primitiveValueForKey:@"orgAdminJidStr"];
    [self didAccessValueForKey:@"orgAdminJidStr"];
    
    return value;
}

- (void)setOrgAdminJidStr:(NSString *)value
{
    [self willChangeValueForKey:@"orgAdminJidStr"];
    [self setPrimitiveValue:value forKey:@"orgAdminJidStr"];
    [self didChangeValueForKey:@"orgAdminJidStr"];
}
- (NSString *)orgDescription
{
    [self willAccessValueForKey:@"orgDescription"];
    NSString *value = [self primitiveValueForKey:@"orgDescription"];
    [self didAccessValueForKey:@"orgDescription"];
    
    return value;
}

- (void)setOrgDescription:(NSString *)value
{
    [self willChangeValueForKey:@"orgDescription"];
    [self setPrimitiveValue:value forKey:@"orgDescription"];
    [self didChangeValueForKey:@"orgDescription"];
}

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

- (NSString *)ptTag
{
    [self willAccessValueForKey:@"ptTag"];
    NSString *value = [self primitiveValueForKey:@"ptTag"];
    [self didAccessValueForKey:@"ptTag"];
    
    return value;
}

- (void)setPtTag:(NSString *)value
{
    [self willChangeValueForKey:@"ptTag"];
    [self setPrimitiveValue:value forKey:@"ptTag"];
    [self didChangeValueForKey:@"ptTag"];
}

- (NSString *)userTag
{
    [self willAccessValueForKey:@"userTag"];
    NSString *value = [self primitiveValueForKey:@"userTag"];
    [self didAccessValueForKey:@"userTag"];
    
    return value;
}

- (void)setUserTag:(NSString *)value
{
    [self willChangeValueForKey:@"userTag"];
    [self setPrimitiveValue:value forKey:@"userTag"];
    [self didChangeValueForKey:@"userTag"];
}

- (NSString *)relationShipTag
{
    [self willAccessValueForKey:@"relationShipTag"];
    NSString *value = [self primitiveValueForKey:@"relationShipTag"];
    [self didAccessValueForKey:@"relationShipTag"];
    
    return value;
}

- (void)setRelationShipTag:(NSString *)value
{
    [self willChangeValueForKey:@"relationShipTag"];
    [self setPrimitiveValue:value forKey:@"relationShipTag"];
    [self didChangeValueForKey:@"relationShipTag"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSManagedObject
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)awakeFromInsert
{
    // your code here ...
}

- (void)awakeFromFetch
{
    // your code here ...
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Creation & Updates
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateWithDic:(NSDictionary *)dic
{
    
}


@end
