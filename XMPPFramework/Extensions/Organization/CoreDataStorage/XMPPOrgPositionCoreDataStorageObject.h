//
//  XMPPOrgPositionCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/26.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface XMPPOrgPositionCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * ptId;
@property (nonatomic, retain) NSString * ptName;
@property (nonatomic, retain) NSNumber * ptLeft;
@property (nonatomic, retain) NSNumber * ptRight;
@property (nonatomic, retain) NSString * dpId;
@property (nonatomic, retain) NSString * orgId;
@property (nonatomic, retain) NSString * dpName;
@property (nonatomic, retain) NSString * streamBareJidStr;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                          withPtId:(NSString *)ptId
                             orgId:(NSString *)orgId
                  streamBareJidStr:(NSString *)streamBareJidStr;
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           withDic:(NSDictionary *)dic
                  streamBareJidStr:(NSString *)streamBareJidStr;
+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                    streamBareJidStr:(NSString *)streamBareJidStr;
+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                            withPtId:(NSString *)ptId
                               orgId:(NSString *)orgId
                    streamBareJidStr:(NSString *)streamBareJidStr;
+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                             withDic:(NSDictionary *)dic
                    streamBareJidStr:(NSString *)streamBareJidStr;
- (void)updateWithDic:(NSDictionary *)dic;

@end
