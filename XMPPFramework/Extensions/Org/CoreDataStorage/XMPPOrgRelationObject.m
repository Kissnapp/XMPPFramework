//
//  XMPPOrgRelationObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/29.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPOrgRelationObject.h"

@implementation XMPPOrgRelationObject

@dynamic orgId;
@dynamic relationOrgId;
@dynamic relationOrgName;
@dynamic streamBareJidStr;

- (NSMutableDictionary *)propertyTransformDictionary
{
    return [super propertyTransformDictionary];
}

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
- (NSString *)relationOrgId
{
    [self willAccessValueForKey:@"relationOrgId"];
    NSString *value = [self primitiveValueForKey:@"relationOrgId"];
    [self didAccessValueForKey:@"relationOrgId"];
    
    return value;
}

- (void)setRelationOrgId:(NSString *)value
{
    [self willChangeValueForKey:@"relationOrgId"];
    [self setPrimitiveValue:value forKey:@"relationOrgId"];
    [self didChangeValueForKey:@"relationOrgId"];
}

- (NSString *)relationOrgName
{
    [self willAccessValueForKey:@"relationOrgName"];
    NSString *value = [self primitiveValueForKey:@"relationOrgName"];
    [self didAccessValueForKey:@"relationOrgName"];
    
    return value;
}

- (void)setRelationOrgName:(NSString *)value
{
    [self willChangeValueForKey:@"relationOrgName"];
    [self setPrimitiveValue:value forKey:@"relationOrgName"];
    [self didChangeValueForKey:@"relationOrgName"];
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

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                     withSelfOrgId:(NSString *)selfOrgId
                     relationOrgId:(NSString *)relationOrgId
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (selfOrgId == nil) return nil;
    if (relationOrgId == nil) return nil;
    if (moc == nil) return nil;
    
    NSString *entityName = NSStringFromClass([XMPPOrgRelationObject class]);
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orgId == %@ AND relationOrgId == %@ AND streamBareJidStr == %@",selfOrgId, relationOrgId, streamBareJidStr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPOrgRelationObject *)[results lastObject];
}

+ (id)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)moc
                                 selfOrgId:(NSString *)selfOrgId
                                   withDic:(NSDictionary *)dic
                          streamBareJidStr:(NSString *)streamBareJidStr
{
    if (selfOrgId == nil) return nil;
    if (dic == nil) return nil;
    if (moc == nil) return nil;
    
    NSString *tempSelfOrgId = selfOrgId ? :[dic objectForKey:@"orgId"];
    NSString *relationOrgId = [dic objectForKey:@"relationOrgId"];
    
    if (selfOrgId == nil) return nil;
    if (relationOrgId == nil) return nil;
    
    XMPPOrgRelationObject *object = [XMPPOrgRelationObject objectInManagedObjectContext:moc
                                                                          withSelfOrgId:tempSelfOrgId
                                                                          relationOrgId:relationOrgId
                                                                       streamBareJidStr:streamBareJidStr];
    
    if (object == nil) {
        
        object = [XMPPOrgRelationObject insertInManagedObjectContext:moc
                                                           selfOrgId:tempSelfOrgId
                                                             withDic:dic
                                                    streamBareJidStr:streamBareJidStr];
    }else{
        
        [object updateWithDic:dic];
    }
    
    return object;
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                         selfOrgId:(NSString *)selfOrgId
                           withDic:(NSDictionary *)dic
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (selfOrgId == nil) return nil;
    if (dic == nil) return nil;
    if (moc == nil) return nil;
    
    NSString *entityName = NSStringFromClass([XMPPOrgRelationObject class]);
    
    XMPPOrgRelationObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                  inManagedObjectContext:moc];
    
    object.orgId = selfOrgId;
    object.streamBareJidStr = streamBareJidStr;
    
    [object updateWithDic:dic];
    
    return object;
}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                     withSelfOrgId:(NSString *)selfOrgId
                     relationOrgId:(NSString *)relationOrgId
                   relationOrgName:(NSString *)relationOrgName
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (selfOrgId == nil) return nil;
    if (relationOrgId == nil) return nil;
    if (moc == nil) return nil;
    
    NSString *entityName = NSStringFromClass([XMPPOrgRelationObject class]);
    
    XMPPOrgRelationObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                  inManagedObjectContext:moc];
    
    object.orgId = selfOrgId;
    object.relationOrgId = relationOrgId;
    object.relationOrgName = relationOrgName;
    object.streamBareJidStr = streamBareJidStr;
    
    return object;
}

- (void)updateWithDic:(NSDictionary *)dic
{
    NSString *tempOrgId = [dic objectForKey:@"orgId"];
    NSString *tempRelationOrgId = [dic objectForKey:@"relationOrgId"];
    NSString *tempRelationOrgName = [dic objectForKey:@"relationOrgName"];
    NSString *tempStreamBareJidStr = [dic objectForKey:@"streamBareJidStr"];
    
    if (tempOrgId) self.orgId = tempOrgId;
    if (tempRelationOrgId) self.relationOrgId = tempRelationOrgId;
    if (tempRelationOrgName) self.relationOrgName = tempRelationOrgName;
    if (tempStreamBareJidStr) self.streamBareJidStr = tempStreamBareJidStr;
}

- (NSComparisonResult)compareByRelationId:(XMPPOrgRelationObject *)another
{
    return [self compareByRelationId:another options:0];
}

- (NSComparisonResult)compareByRelationId:(XMPPOrgRelationObject *)another options:(NSStringCompareOptions)mask
{
    NSString *selfRelationId = [self relationOrgId];
    NSString *otherRelationId = [another relationOrgId];
    
    return [selfRelationId compare:otherRelationId options:mask];
}

@end
