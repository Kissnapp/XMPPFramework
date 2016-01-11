//
//  XMPPUnReadMessageCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/21.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface XMPPMessageHistoryCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSDate * lastChatTime;
@property (nonatomic, retain) NSString * bareJidStr;
@property (nonatomic, retain) NSString * streamBareJidStr;
@property (nonatomic, retain) NSNumber * unReadCount;
@property (nonatomic, retain) NSNumber * hasBeenEnd;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                        bareJidStr:(NSString *)bareJidStr
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                        bareJidStr:(NSString *)bareJidStr
                            unRead:(BOOL)unRead
                              time:(NSDate *)time
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)deleteObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                bareJidStr:(NSString *)bareJidStr
                          streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)updateOrInsertObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                        bareJidStr:(NSString *)bareJidStr
                                            unRead:(BOOL)unRead
                                              time:(NSDate *)time
                                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)readObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                              bareJidStr:(NSString *)bareJidStr
                        streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)readOneObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                 bareJidStr:(NSString *)bareJidStr
                           streamBareJidStr:(NSString *)streamBareJidStr;

//The method is not implemented
/*
+ (BOOL)clearAllObjectsInInManagedObjectContext:(NSManagedObjectContext *)moc
                               streamBareJidStr:(NSString *)streamBareJidStr;
 */

@end
