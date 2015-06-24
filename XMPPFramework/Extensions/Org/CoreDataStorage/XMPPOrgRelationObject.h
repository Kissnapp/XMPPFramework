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
@property (nonatomic, retain) NSString * streamBareJidStr;
@property (nonatomic, retain) XMPPOrgCoreDataStorageObject *relationOrgShip;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                         withOrgId:(NSString *)orgId
                  streamBareJidStr:(NSString *)streamBareJidStr;
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           withDic:(NSDictionary *)dic
                  streamBareJidStr:(NSString *)streamBareJidStr;
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                         withOrgId:(NSString *)orgId
                           orgName:(NSString *)orgName
                  streamBareJidStr:(NSString *)streamBareJidStr;
+ (id)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)moc
                                   withDic:(NSDictionary *)dic
                          streamBareJidStr:(NSString *)streamBareJidStr;

- (void)updateWithDic:(NSDictionary *)dic;

- (NSComparisonResult)compareByRelationId:(XMPPOrgRelationObject *)another;
- (NSComparisonResult)compareByRelationId:(XMPPOrgRelationObject *)another options:(NSStringCompareOptions)mask;

@end
