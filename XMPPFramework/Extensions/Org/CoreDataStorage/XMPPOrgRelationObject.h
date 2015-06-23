//
//  XMPPOrgRelationObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/29.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPManagedObject.h"

@class XMPPOrgCoreDataStorageObject;

@interface XMPPOrgRelationObject : XMPPManagedObject 

@property (nonatomic, retain) NSString * relationOrgId;
@property (nonatomic, retain) NSString * relationOrgName;
@property (nonatomic, retain) XMPPOrgCoreDataStorageObject *relationOrgShip;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc withOrgId:(NSString *)orgId;
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc withDic:(NSDictionary *)dic;
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc withOrgId:(NSString *)orgId orgName:(NSString *)orgName;
+ (id)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)moc withDic:(NSDictionary *)dic;

- (void)updateWithDic:(NSDictionary *)dic;

- (NSComparisonResult)compareByRelationId:(XMPPOrgRelationObject *)another;
- (NSComparisonResult)compareByRelationId:(XMPPOrgRelationObject *)another options:(NSStringCompareOptions)mask;

@end
