//
//  XMPPLoginUserCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface XMPPLoginUserCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString  * loginID;
@property (nonatomic, retain) NSString  * streamBareJidStr;
@property (nonatomic, retain) NSDate    * loginTime;

//add
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                       withLoginID:(NSString *)loginID
                  streamBareJidStr:(NSString *)streamBareJidStr;
+ (id)updateOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                               withLoginID:(NSString *)loginID
                          streamBareJidStr:(NSString *)streamBareJidStr;
//delete
+ (BOOL)deleteFromManagedObjectContext:(NSManagedObjectContext *)moc
                           withLoginID:(NSString *)loginID;
+ (BOOL)deleteFromManagedObjectContext:(NSManagedObjectContext *)moc
                      streamBareJidStr:(NSString *)streamBareJidStr;
//modify
+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc
                       withLoginID:(NSString *)loginID
                  streamBareJidStr:(NSString *)streamBareJidStr;

//fetch
+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                       withLoginID:(NSString *)loginID;
+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                  streamBareJidStr:(NSString *)streamBareJidStr;
+ (id)fetchInInManagedObjectContext:(NSManagedObjectContext *)moc
                      WithPredicate:(NSPredicate *)predicate;

@end
