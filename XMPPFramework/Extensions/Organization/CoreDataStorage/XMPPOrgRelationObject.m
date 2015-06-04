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
@dynamic relationOrgShip;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PropertyTransforming method
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc withOrgId:(NSString *)orgId
{
    if (orgId == nil) return nil;
    if (moc == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"relationOrgId", orgId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPOrgRelationObject *)[results lastObject];
}

+ (id)fetchOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc withOrgId:(NSString *)orgId
{
    if (orgId == nil) return nil;
    if (moc == nil) return nil;
    
    XMPPOrgRelationObject *object = [XMPPOrgRelationObject objectInManagedObjectContext:moc
                                                                              withOrgId:orgId];
    
    if (!object) {
        
        object = [XMPPOrgRelationObject insertInManagedObjectContext:moc
                                                           withOrgId:orgId];
    }
    
    return object;
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc withOrgId:(NSString *)orgId
{
    if (orgId == nil) return nil;
    if (moc == nil) return nil;
    
    XMPPOrgRelationObject *object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                                  inManagedObjectContext:moc];
    object.relationOrgId = orgId;
    
    return object;
}

@end
