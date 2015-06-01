//
//  XMPPOrgUserCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/26.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPOrgUserCoreDataStorageObject.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation XMPPOrgUserCoreDataStorageObject

@dynamic userId;
@dynamic userJidStr;
@dynamic orgId;
@dynamic ptId;
@dynamic streamBareJidStr;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - primitive Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)userId
{
    [self willAccessValueForKey:@"userId"];
    NSString *value = [self primitiveValueForKey:@"userId"];
    [self didAccessValueForKey:@"userId"];
    
    return value;
}

- (void)setUserId:(NSString *)value
{
    [self willChangeValueForKey:@"userId"];
    [self setPrimitiveValue:value forKey:@"userId"];
    [self didChangeValueForKey:@"userId"];
}

- (NSString *)userJidStr
{
    [self willAccessValueForKey:@"userJidStr"];
    NSString *value = [self primitiveValueForKey:@"userJidStr"];
    [self didAccessValueForKey:@"userJidStr"];
    
    return value;
}

- (void)setUserJidStr:(NSString *)value
{
    [self willChangeValueForKey:@"userJidStr"];
    [self setPrimitiveValue:value forKey:@"userJidStr"];
    [self didChangeValueForKey:@"userJidStr"];
}

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

- (NSString *)ptId
{
    [self willAccessValueForKey:@"ptId"];
    NSString *value = [self primitiveValueForKey:@"ptId"];
    [self didAccessValueForKey:@"ptId"];
    
    return value;
}

- (void)setPtId:(NSString *)value
{
    [self willChangeValueForKey:@"ptId"];
    [self setPrimitiveValue:value forKey:@"ptId"];
    [self didChangeValueForKey:@"ptId"];
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
/*
+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                            withUserId:(NSString *)userId
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (userId == nil) return nil;
    if (moc == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPOrgUserCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate;
    if (streamBareJidStr == nil)
        predicate = [NSPredicate predicateWithFormat:@"%K == %@",@"userId", userId];
    else
        predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@",
                     @"userId", userId, @"streamBareJidStr", streamBareJidStr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPOrgUserCoreDataStorageObject *)[results lastObject];
}
*/

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                        withUserId:(NSString *)userId
                             orgId:(NSString *)orgId
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (userId == nil) return nil;
    if (orgId == nil) return nil;
    if (moc == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPOrgUserCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate;
    if (streamBareJidStr == nil)
        predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@",@"userId", userId, @"orgId", orgId];
    else
        predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND && %K == %@ AND %K == %@",
                     @"userId", userId, @"orgId", orgId, @"streamBareJidStr", streamBareJidStr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPOrgUserCoreDataStorageObject *)[results lastObject];
}


+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           withDic:(NSDictionary *)dic
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    
    if (moc == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    
    XMPPOrgUserCoreDataStorageObject *newUser;
    newUser = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPOrgUserCoreDataStorageObject"
                                            inManagedObjectContext:moc];
    
    newUser.streamBareJidStr = streamBareJidStr;
    
    [newUser updateWithDic:dic];
    
    return newUser;
}

+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    BOOL result = NO;
    
    NSString *tempUserId = [dic objectForKey:@"userId"];
    NSString *tempOrgId = [dic objectForKey:@"orgId"];
    
    if (tempUserId == nil)  return result;
    if (tempOrgId == nil)  return result;
    if (moc == nil)  return result;
    
    XMPPOrgUserCoreDataStorageObject *newUser = [XMPPOrgUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                    withUserId:tempUserId
                                                                                                         orgId:tempOrgId
                                                                                              streamBareJidStr:streamBareJidStr];
    if (newUser != nil) {
        
        [newUser updateWithDic:dic];
        result = YES;
        
    }else{
        [XMPPOrgUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                               withDic:dic
                                                      streamBareJidStr:streamBareJidStr];
        result = YES;
    }
    
    
    return result;
}

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                          withUserId:(NSString *)userId
                               orgId:(NSString *)orgId
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    if (userId == nil) return NO;
    if (orgId == nil) return NO;
    if (moc == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    
    XMPPOrgUserCoreDataStorageObject *deleteObject = [XMPPOrgUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                         withUserId:userId
                                                                                                              orgId:orgId
                                                                                                   streamBareJidStr:streamBareJidStr];
    if (deleteObject){
        
        [moc deleteObject:deleteObject];
        return YES;
    }
    
    return NO;
}

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    if (dic == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    if (moc == nil) return NO;
    
    NSString *tempUserId = [dic objectForKey:@"userId"];
    NSString *tempOrgId = [dic objectForKey:@"orgId"];
    
    if (tempUserId == nil) return NO;
    if (tempOrgId == nil) return NO;
    
    XMPPOrgUserCoreDataStorageObject *deleteObject = [XMPPOrgUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                         withUserId:tempUserId
                                                                                                              orgId:tempOrgId
                                                                                                   streamBareJidStr:streamBareJidStr];
    if (deleteObject){
        
        [moc deleteObject:deleteObject];
        return YES;
    }
    
    return NO;
}

- (void)updateWithDic:(NSDictionary *)dic
{
    NSString *tempUserId = [dic objectForKey:@"userId"];
    NSString *tempUserJidStr = [dic objectForKey:@"userJidStr"];
    NSString *tempOrgId = [dic objectForKey:@"orgId"];
    NSString *tempPtId = [dic objectForKey:@"ptId"];
    NSString *tempStreamBareJidStr = [dic objectForKey:@"streamBareJidStr"];
    
    if (tempUserId) self.userId = tempUserId;
    if (tempUserJidStr) self.userJidStr = tempUserJidStr;
    if (tempOrgId) self.orgId = tempOrgId;
    if (tempPtId) self.ptId = tempPtId;
    if (tempStreamBareJidStr) self.streamBareJidStr = tempStreamBareJidStr;
}

@end
