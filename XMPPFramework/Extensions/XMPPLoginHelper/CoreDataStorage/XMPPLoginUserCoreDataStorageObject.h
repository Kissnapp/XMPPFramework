//
//  XMPPLoginUserCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/12/5.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface XMPPLoginUserCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSDate * loginTime;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * streamBareJidStr;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * password;

//add
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                   withPhoneNumber:(NSString *)phonenumber
                  streamBareJidStr:(NSString *)streamBareJidStr;
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                  withEmailAddress:(NSString *)emailaddress
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                   withPhoneNumber:(NSString *)phonenumber
                          password:(NSString *)password
                  streamBareJidStr:(NSString *)streamBareJidStr;
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                  withEmailAddress:(NSString *)emailaddress
                          password:(NSString *)password
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                   withPhoneNumber:(NSString *)phonenumber
                  withEmailAddress:(NSString *)emailaddress
                          nickName:(NSString *)nickname
                          password:(NSString *)password
                         longitude:(NSString *)longitude
                          latitude:(NSString *)latitude
                  streamBareJidStr:(NSString *)streamBareJidStr;


+ (id)updateStreamBareJidStrOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                           withPhoneNumber:(NSString *)phonenumber
                                          streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)updateStreamBareJidStrOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                          withEmailAddress:(NSString *)emailaddress
                                          streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)updatePhoneNumberOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                           withPhoneNumber:(NSString *)phonenumber
                                          streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)updateEmailAddressOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                          withEmailAddress:(NSString *)emailaddress
                                          streamBareJidStr:(NSString *)streamBareJidStr;

//delete
+ (BOOL)deleteFromManagedObjectContext:(NSManagedObjectContext *)moc
                       withPhoneNumber:(NSString *)phonenumber;

+ (BOOL)deleteFromManagedObjectContext:(NSManagedObjectContext *)moc
                      withEmailAddress:(NSString *)emailaddress;

+ (BOOL)deleteFromManagedObjectContext:(NSManagedObjectContext *)moc
                      streamBareJidStr:(NSString *)streamBareJidStr;

//modify
+ (BOOL)updateStreamBareJidStrInManagedObjectContext:(NSManagedObjectContext *)moc
                                     withPhoneNumber:(NSString *)phonenumber
                                    streamBareJidStr:(NSString *)streamBareJidStr;
+ (BOOL)updateStreamBareJidStrInManagedObjectContext:(NSManagedObjectContext *)moc
                                    withEmailAddress:(NSString *)emailaddress
                                    streamBareJidStr:(NSString *)streamBareJidStr;
+ (BOOL)updatePhoneNumberInManagedObjectContext:(NSManagedObjectContext *)moc
                                withPhoneNumber:(NSString *)phonenumber
                               streamBareJidStr:(NSString *)streamBareJidStr;
+ (BOOL)updateEmailAddressInManagedObjectContext:(NSManagedObjectContext *)moc
                                withEmailAddress:(NSString *)emailaddress
                                streamBareJidStr:(NSString *)streamBareJidStr;
+ (BOOL)updateAllInManagedObjectContext:(NSManagedObjectContext *)moc
                      withPhoneNumber:(NSString *)phonenumber
                     withEmailAddress:(NSString *)emailaddress
                             nickName:(NSString *)nickname
                             password:(NSString *)password
                            longitude:(NSString *)longitude
                             latitude:(NSString *)latitude
                     streamBareJidStr:(NSString *)streamBareJidStr;



//fetch
+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                   withPhoneNumber:(NSString *)phonenumber;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                  withEmailAddress:(NSString *)emailaddress;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)fetchInInManagedObjectContext:(NSManagedObjectContext *)moc
                      WithPredicate:(NSPredicate *)predicate;

@end
