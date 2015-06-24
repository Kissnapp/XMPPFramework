//
//  XMPPOrgRelationObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/29.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPOrgRelationObject.h"
#import "XMPPOrgCoreDataStorageObject.h"

@implementation XMPPOrgRelationObject

@dynamic relationOrgId;
@dynamic relationOrgName;
@dynamic streamBareJidStr;
@dynamic relationOrgShip;


- (NSMutableDictionary *)propertyTransformDictionary
{
    return [super propertyTransformDictionary];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
                         withOrgId:(NSString *)orgId
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (orgId == nil) return nil;
    if (moc == nil) return nil;
    
    NSString *entityName = NSStringFromClass([XMPPOrgRelationObject class]);
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"relationOrgId == %@ AND streamBareJidStr == %@", orgId, streamBareJidStr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPOrgRelationObject *)[results lastObject];
}

+ (id)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)moc
                                   withDic:(NSDictionary *)dic
                          streamBareJidStr:(NSString *)streamBareJidStr
{
    if (dic == nil) return nil;
    if (moc == nil) return nil;
    
    NSString *orgId = [dic objectForKey:@"relationOrgId"];
    
    if (orgId == nil) return nil;
    
    XMPPOrgRelationObject *object = [XMPPOrgRelationObject objectInManagedObjectContext:moc
                                                                              withOrgId:orgId
                                                                       streamBareJidStr:streamBareJidStr];
    
    if (object == nil) {
        
        object = [XMPPOrgRelationObject insertOrUpdateInManagedObjectContext:moc
                                                                     withDic:dic
                                                            streamBareJidStr:streamBareJidStr];
    }else{
        
        [object updateWithDic:dic];
    }
    
    return object;
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           withDic:(NSDictionary *)dic
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (dic == nil) return nil;
    if (moc == nil) return nil;
    
    NSString *entityName = NSStringFromClass([XMPPOrgRelationObject class]);
    
    XMPPOrgRelationObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                  inManagedObjectContext:moc];
    object.streamBareJidStr = streamBareJidStr;
    [object updateWithDic:dic];
    
    return object;
}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                         withOrgId:(NSString *)orgId
                           orgName:(NSString *)orgName
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (orgId == nil) return nil;
    if (moc == nil) return nil;
    
    NSString *entityName = NSStringFromClass([XMPPOrgRelationObject class]);
    
    XMPPOrgRelationObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                  inManagedObjectContext:moc];
    object.relationOrgId = orgId;
    object.relationOrgName = orgName;
    object.streamBareJidStr = streamBareJidStr;
    
    return object;
}

- (void)updateWithDic:(NSDictionary *)dic
{
    NSString *tempOrgId = [dic objectForKey:@"relationOrgId"];
    NSString *tempOrgName = [dic objectForKey:@"relationOrgName"];
    NSString *tempStreamBareJidStr = [dic objectForKey:@"streamBareJidStr"];
    
    if (tempOrgId) self.relationOrgId = tempOrgId;
    if (tempOrgName) self.relationOrgName = tempOrgName;
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
