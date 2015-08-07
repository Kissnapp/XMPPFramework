//
//  XMPPLoginUserCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/12/5.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSUInteger, LoginHelperIdType) {
    LoginHelperIdTypePhone = 0,
    LoginHelperIdTypeEmail
};

@interface XMPPLoginUserCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSNumber * loginIdType;
@property (nonatomic, retain) NSString * loginId;
@property (nonatomic, retain) NSString * streamBareJidStr;
@property (nonatomic, retain) NSNumber * currentLoginUser;
@property (nonatomic, retain) NSNumber * autoLogin;
@property (nonatomic, retain) NSData * clientKeyData;
@property (nonatomic, retain) NSData * serverKeyData;
@property (nonatomic, retain) NSDate * loginTime;

//fetch
+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                       phoneNumber:(NSString *)phonenumber;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                      emailAddress:(NSString *)emailaddress;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)fetchInInManagedObjectContext:(NSManagedObjectContext *)moc
                          predicate:(NSPredicate *)predicate;

//add
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                       phoneNumber:(NSString *)phonenumber
                         autoLogin:(BOOL)autoLogin
                  streamBareJidStr:(NSString *)streamBareJidStr;
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                      emailAddress:(NSString *)emailaddress
                         autoLogin:(BOOL)autoLogin
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                       phoneNumber:(NSString *)phonenumber
                         autoLogin:(BOOL)autoLogin
                     clientKeyData:(NSData *)clientKeyData
                     serverKeyData:(NSData *)serverKeyData
                  streamBareJidStr:(NSString *)streamBareJidStr;
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                      emailAddress:(NSString *)emailaddress
                         autoLogin:(BOOL)autoLogin
                     clientKeyData:(NSData *)clientKeyData
                     serverKeyData:(NSData *)serverKeyData
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           loginId:(NSString *)loginId
                       loginIdType:(LoginHelperIdType)loginIdType
                  currentLoginUser:(BOOL)currentLoginUser
                         autoLogin:(BOOL)autoLogin
                     clientKeyData:(NSData *)clientKeyData
                     serverKeyData:(NSData *)serverKeyData
                  streamBareJidStr:(NSString *)streamBareJidStr;


+ (id)updateStreamBareJidStrOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                               phoneNumber:(NSString *)phonenumber
                                                 autoLogin:(BOOL)autoLogin
                                          streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)updateStreamBareJidStrOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                              emailAddress:(NSString *)emailaddress
                                                 autoLogin:(BOOL)autoLogin
                                          streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)updatePhoneNumberOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                          phoneNumber:(NSString *)phonenumber
                                            autoLogin:(BOOL)autoLogin
                                          streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)updateEmailAddressOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                          emailAddress:(NSString *)emailaddress
                                             autoLogin:(BOOL)autoLogin
                                          streamBareJidStr:(NSString *)streamBareJidStr;

//delete
+ (BOOL)deleteFromManagedObjectContext:(NSManagedObjectContext *)moc
                            phoneNumber:(NSString *)phonenumber;

+ (BOOL)deleteFromManagedObjectContext:(NSManagedObjectContext *)moc
                          emailAddress:(NSString *)emailaddress;

+ (BOOL)deleteFromManagedObjectContext:(NSManagedObjectContext *)moc
                      streamBareJidStr:(NSString *)streamBareJidStr;


//modify
+ (BOOL)updateStreamBareJidStrInManagedObjectContext:(NSManagedObjectContext *)moc
                                         phoneNumber:(NSString *)phonenumber
                                    streamBareJidStr:(NSString *)streamBareJidStr;
+ (BOOL)updateStreamBareJidStrInManagedObjectContext:(NSManagedObjectContext *)moc
                                        emailAddress:(NSString *)emailaddress
                                    streamBareJidStr:(NSString *)streamBareJidStr;
+ (BOOL)updatePhoneNumberInManagedObjectContext:(NSManagedObjectContext *)moc
                                    phoneNumber:(NSString *)phonenumber
                               streamBareJidStr:(NSString *)streamBareJidStr;
+ (BOOL)updateEmailAddressInManagedObjectContext:(NSManagedObjectContext *)moc
                                    emailAddress:(NSString *)emailaddress
                                streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)updateAllInManagedObjectContext:(NSManagedObjectContext *)moc
                                loginId:(NSString *)loginId
                            loginIdType:(LoginHelperIdType)loginIdType
                       currentLoginUser:(BOOL)currentLoginUser
                              autoLogin:(BOOL)autoLogin
                          clientKeyData:(NSData *)clientKeyData
                          serverKeyData:(NSData *)serverKeyData
                       streamBareJidStr:(NSString *)streamBareJidStr;

@end
