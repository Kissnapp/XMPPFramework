//
//  XMPPOrgRelationObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/29.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class XMPPOrgCoreDataStorageObject;

@interface XMPPOrgRelationObject : NSManagedObject

@property (nonatomic, retain) NSString * relationOrgId;
@property (nonatomic, retain) XMPPOrgCoreDataStorageObject *relationOrgShip;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc withOrgId:(NSString *)orgId;
+ (id)fetchOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc withOrgId:(NSString *)orgId;
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc withOrgId:(NSString *)orgId;

@end
