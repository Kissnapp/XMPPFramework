//
//  XMPPLoginUserCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/12/5.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPLoginUserCoreDataStorageObject.h"


@implementation XMPPLoginUserCoreDataStorageObject

@dynamic loginIdType;
@dynamic loginId;
@dynamic streamBareJidStr;
@dynamic currentLoginUser;
@dynamic clientKeyData;
@dynamic serverKeyData;
@synthesize loginTime;
@synthesize autoLogin;


- (NSString *)loginId
{
    [self willAccessValueForKey:@"loginId"];
    NSString *value = [self primitiveValueForKey:@"loginId"];
    [self didAccessValueForKey:@"loginId"];
    return value;
}

- (void)setLoginId:(NSString *)value
{
    [self willChangeValueForKey:@"loginId"];
    [self setPrimitiveValue:value forKey:@"loginId"];
    [self didChangeValueForKey:@"loginId"];
}

- (NSNumber *)loginIdType
{
    [self willAccessValueForKey:@"loginIdType"];
    NSNumber *value = [self primitiveValueForKey:@"loginIdType"];
    [self didAccessValueForKey:@"loginIdType"];
    return value;
}

- (void)setLoginIdType:(NSNumber *)value
{
    [self willChangeValueForKey:@"loginIdType"];
    [self setPrimitiveValue:value forKey:@"loginIdType"];
    [self didChangeValueForKey:@"loginIdType"];
}

- (NSNumber *)autoLogin
{
    [self willAccessValueForKey:@"autoLogin"];
    NSNumber *value = [self primitiveValueForKey:@"autoLogin"];
    [self didAccessValueForKey:@"autoLogin"];
    return value;
}

- (void)setAutoLogin:(NSNumber *)value
{
    [self willChangeValueForKey:@"autoLogin"];
    [self setPrimitiveValue:value forKey:@"autoLogin"];
    [self didChangeValueForKey:@"autoLogin"];
}

- (NSNumber *)currentLoginUser
{
    [self willAccessValueForKey:@"currentLoginUser"];
    NSNumber *value = [self primitiveValueForKey:@"currentLoginUser"];
    [self didAccessValueForKey:@"currentLoginUser"];
    return value;
}

- (void)setCurrentLoginUser:(NSNumber *)value
{
    [self willChangeValueForKey:@"currentLoginUser"];
    [self setPrimitiveValue:value forKey:@"currentLoginUser"];
    [self didChangeValueForKey:@"currentLoginUser"];
}

- (NSDate *)loginTime
{
    [self willAccessValueForKey:@"loginTime"];
    NSDate *value = [self primitiveValueForKey:@"loginTime"];
    [self didAccessValueForKey:@"loginTime"];
    return value;
}

- (void)setLoginTime:(NSDate *)value
{
    [self willChangeValueForKey:@"loginTime"];
    [self setPrimitiveValue:value forKey:@"loginTime"];
    [self didChangeValueForKey:@"loginTime"];
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

- (NSData *)clientKeyData
{
    [self willAccessValueForKey:@"clientKeyData"];
    NSData *value = [self primitiveValueForKey:@"clientKeyData"];
    [self didAccessValueForKey:@"clientKeyData"];
    return value;
}

- (void)setClientKeyData:(NSData *)value
{
    [self willChangeValueForKey:@"clientKeyData"];
    [self setPrimitiveValue:value forKey:@"clientKeyData"];
    [self didChangeValueForKey:@"clientKeyData"];
}

- (NSData *)serverKeyData
{
    [self willAccessValueForKey:@"serverKeyData"];
    NSData *value = [self primitiveValueForKey:@"serverKeyData"];
    [self didAccessValueForKey:@"serverKeyData"];
    return value;
}

- (void)setServerKeyData:(NSData *)value
{
    [self willChangeValueForKey:@"serverKeyData"];
    [self setPrimitiveValue:value forKey:@"serverKeyData"];
    [self didChangeValueForKey:@"serverKeyData"];
}

#pragma mark - awake action

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setPrimitiveValue:[NSDate date] forKey:@"loginTime"];
}

#pragma mark - public methods

//fetch methods
+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                       phoneNumber:(NSString *)phonenumber
{
    if (moc == nil) return nil;
    if (phonenumber == nil) return nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"loginId == %@ AND loginIdType == %@",phonenumber,@(LoginHelperIdTypePhone)];
    
    return  [XMPPLoginUserCoreDataStorageObject fetchInInManagedObjectContext:moc
                                                                    predicate:predicate];
}

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                      emailAddress:(NSString *)emailaddress
{
    if (moc == nil) return nil;
    if (emailaddress == nil) return nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"loginId == %@ && loginIdType == %@",emailaddress,@(LoginHelperIdTypeEmail)];
    
    return  [XMPPLoginUserCoreDataStorageObject fetchInInManagedObjectContext:moc
                                                                    predicate:predicate];
}

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",@"streamBareJidStr",streamBareJidStr];
    
    return  [XMPPLoginUserCoreDataStorageObject fetchInInManagedObjectContext:moc
                                                                    predicate:predicate];
}

+ (id)fetchInInManagedObjectContext:(NSManagedObjectContext *)moc
                          predicate:(NSPredicate *)predicate
{
    if (moc == nil) return nil;
    if (predicate == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                              inManagedObjectContext:moc];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPLoginUserCoreDataStorageObject *)[results lastObject];
}

// insert methods
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           loginId:(NSString *)loginId
                       loginIdType:(LoginHelperIdType)loginIdType
                  currentLoginUser:(BOOL)currentLoginUser
                         autoLogin:(BOOL)autoLogin
                     clientKeyData:(NSData *)clientKeyData
                     serverKeyData:(NSData *)serverKeyData
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (!moc) return nil;
    
    XMPPLoginUserCoreDataStorageObject *newUser = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                                                inManagedObjectContext:moc];
    if (newUser) {
        [newUser updateWithLoginId:loginId
                       loginIdType:loginIdType
                  currentLoginUser:currentLoginUser
                         autoLogin:autoLogin
                     clientKeyData:clientKeyData
                     serverkeyData:serverKeyData
                  streamBareJidStr:streamBareJidStr];
        
        return newUser;
    }
    
    return nil;
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                       phoneNumber:(NSString *)phonenumber
                         autoLogin:(BOOL)autoLogin
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    return [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                    loginId:phonenumber
                                                                loginIdType:LoginHelperIdTypePhone
                                                           currentLoginUser:YES
                                                                  autoLogin:autoLogin
                                                              clientKeyData:nil
                                                              serverKeyData:nil
                                                           streamBareJidStr:streamBareJidStr];
}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                  emailAddress:(NSString *)emailaddress
                         autoLogin:(BOOL)autoLogin
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    return [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                    loginId:emailaddress
                                                                loginIdType:LoginHelperIdTypeEmail
                                                           currentLoginUser:YES
                                                                  autoLogin:autoLogin
                                                              clientKeyData:nil
                                                              serverKeyData:nil
                                                           streamBareJidStr:streamBareJidStr];
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                   phoneNumber:(NSString *)phonenumber
                         autoLogin:(BOOL)autoLogin
                     clientKeyData:(NSData *)clientKeyData
                     serverKeyData:(NSData *)serverKeyData
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    return [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                    loginId:phonenumber
                                                                loginIdType:LoginHelperIdTypePhone
                                                           currentLoginUser:YES
                                                                  autoLogin:autoLogin
                                                              clientKeyData:clientKeyData
                                                              serverKeyData:serverKeyData
                                                           streamBareJidStr:streamBareJidStr];
}



+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                      emailAddress:(NSString *)emailaddress
                         autoLogin:(BOOL)autoLogin
                     clientKeyData:(NSData *)clientKeyData
                     serverKeyData:(NSData *)serverKeyData
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    return [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                    loginId:emailaddress
                                                                loginIdType:LoginHelperIdTypeEmail
                                                           currentLoginUser:YES
                                                                  autoLogin:autoLogin
                                                              clientKeyData:clientKeyData
                                                              serverKeyData:serverKeyData
                                                           streamBareJidStr:streamBareJidStr];
}
//update or insert methods
+ (id)updateStreamBareJidStrOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                           phoneNumber:(NSString *)phonenumber
                                                 autoLogin:(BOOL)autoLogin
                                          streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return nil;
    if (phonenumber == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    XMPPLoginUserCoreDataStorageObject *updateUser = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                      phoneNumber:phonenumber];
    if (updateUser) {//if exist alter it
        [updateUser setStreamBareJidStr:streamBareJidStr];
        [updateUser setAutoLogin:@(autoLogin)];
        [updateUser setLoginTime:[NSDate date]];
    }else{// if not existed,create a new one
        updateUser = [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                      phoneNumber:phonenumber
                                                                            autoLogin:autoLogin
                                                                     streamBareJidStr:streamBareJidStr];
    }
    return updateUser;
}

+ (id)updateStreamBareJidStrOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                          emailAddress:(NSString *)emailaddress
                                                 autoLogin:(BOOL)autoLogin
                                          streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return nil;
    if (emailaddress == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    XMPPLoginUserCoreDataStorageObject *updateUser = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                     emailAddress:emailaddress];
    if (updateUser) {//if exist alter it
        [updateUser setStreamBareJidStr:streamBareJidStr];
        [updateUser setAutoLogin:@(autoLogin)];
        [updateUser setLoginTime:[NSDate date]];
    }else{// if not existed,create a new one
        updateUser = [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                    emailAddress:emailaddress
                                                                            autoLogin:autoLogin
                                                                     streamBareJidStr:streamBareJidStr];
    }
    return updateUser;
}

+ (id)updatePhoneNumberOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                      phoneNumber:(NSString *)phonenumber
                                            autoLogin:(BOOL)autoLogin
                                     streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return nil;
    if (phonenumber == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    XMPPLoginUserCoreDataStorageObject *updateUser = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                     streamBareJidStr:streamBareJidStr];
    if (updateUser) {//if exist alter it
        [updateUser setLoginId:phonenumber];
        [updateUser setLoginIdType:@(LoginHelperIdTypePhone)];
        [updateUser setAutoLogin:@(autoLogin)];
        [updateUser setLoginTime:[NSDate date]];
    }else{// if not existed,create a new one
        updateUser = [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                      phoneNumber:phonenumber
                                                                            autoLogin:autoLogin
                                                                     streamBareJidStr:streamBareJidStr];
    }
    return updateUser;
}

+ (id)updateEmailAddressOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                          emailAddress:(NSString *)emailaddress
                                             autoLogin:(BOOL)autoLogin
                                      streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return nil;
    if (emailaddress == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    XMPPLoginUserCoreDataStorageObject *updateUser = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                     streamBareJidStr:streamBareJidStr];
    if (updateUser) {//if exist alter it
        [updateUser setLoginId:emailaddress];
        [updateUser setLoginIdType:@(LoginHelperIdTypeEmail)];
        [updateUser setAutoLogin:@(autoLogin)];
        [updateUser setLoginTime:[NSDate date]];
    }else{// if not existed,create a new one
        updateUser = [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                     emailAddress:emailaddress
                                                                            autoLogin:autoLogin
                                                                     streamBareJidStr:streamBareJidStr];
    }
    return updateUser;
}


//update mthods
+ (BOOL)updateAllInManagedObjectContext:(NSManagedObjectContext *)moc
                                loginId:(NSString *)loginId
                            loginIdType:(LoginHelperIdType)loginIdType
                       currentLoginUser:(BOOL)currentLoginUser
                              autoLogin:(BOOL)autoLogin
                          clientKeyData:(NSData *)clientKeyData
                          serverKeyData:(NSData *)serverKeyData
                       streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    
    XMPPLoginUserCoreDataStorageObject *updateObject = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                       streamBareJidStr:streamBareJidStr];
    if (!updateObject) return NO;
    
    [updateObject updateWithLoginId:loginId
                        loginIdType:loginIdType
                   currentLoginUser:currentLoginUser
                          autoLogin:autoLogin
                      clientKeyData:clientKeyData
                      serverkeyData:serverKeyData
                   streamBareJidStr:streamBareJidStr];
    
    return YES;
}

+ (BOOL)updateStreamBareJidStrInManagedObjectContext:(NSManagedObjectContext *)moc
                                         phoneNumber:(NSString *)phonenumber
                                    streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    if (phonenumber == nil) return NO;
    
    XMPPLoginUserCoreDataStorageObject *updateObject = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                            phoneNumber:phonenumber];
    if (!updateObject) return NO;
    
    [updateObject setStreamBareJidStr:streamBareJidStr];
    [updateObject setLoginTime:[NSDate date]];
    
    return YES;

}
+ (BOOL)updateStreamBareJidStrInManagedObjectContext:(NSManagedObjectContext *)moc
                                        emailAddress:(NSString *)emailaddress
                                    streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    if (emailaddress == nil) return NO;
    
    XMPPLoginUserCoreDataStorageObject *updateObject = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                           emailAddress:emailaddress];
    if (!updateObject) return NO;
    
    [updateObject setStreamBareJidStr:streamBareJidStr];
    [updateObject setLoginTime:[NSDate date]];
    
    return YES;

}
+ (BOOL)updatePhoneNumberInManagedObjectContext:(NSManagedObjectContext *)moc
                                    phoneNumber:(NSString *)phonenumber
                               streamBareJidStr:(NSString *)streamBareJidStr
{
    XMPPLoginUserCoreDataStorageObject *loginUser = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                    streamBareJidStr:streamBareJidStr];
    if (loginUser == nil) return NO;
    
    loginUser.loginId = phonenumber;
    loginUser.loginIdType = @(LoginHelperIdTypePhone);
    return YES;
}

+ (BOOL)updateEmailAddressInManagedObjectContext:(NSManagedObjectContext *)moc
                                    emailAddress:(NSString *)emailaddress
                                streamBareJidStr:(NSString *)streamBareJidStr
{
    XMPPLoginUserCoreDataStorageObject *loginUser = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                    streamBareJidStr:streamBareJidStr];
    if (loginUser == nil) return NO;
    
    loginUser.loginId = emailaddress;
    loginUser.loginIdType = @(LoginHelperIdTypeEmail);
    return YES;
}


//delete methods
+ (BOOL)deleteFromManagedObjectContext:(NSManagedObjectContext *)moc
                           phoneNumber:(NSString *)phonenumber
{
    if (moc == nil) return NO;
    if (phonenumber == nil) return NO;
    
    XMPPLoginUserCoreDataStorageObject *deleteObject = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                        phoneNumber:phonenumber];
    if (deleteObject != nil){
        
        [moc deleteObject:deleteObject];
        return YES;
    }
    
    return NO;
}


+ (BOOL)deleteFromManagedObjectContext:(NSManagedObjectContext *)moc
                          emailAddress:(NSString *)emailaddress
{
    if (moc == nil) return NO;
    if (emailaddress == nil) return NO;
    
    XMPPLoginUserCoreDataStorageObject *deleteObject = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                           emailAddress:emailaddress];
    if (deleteObject != nil){
        
        [moc deleteObject:deleteObject];
        return YES;
    }
    
    return NO;
}


+ (BOOL)deleteFromManagedObjectContext:(NSManagedObjectContext *)moc
                      streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    
    XMPPLoginUserCoreDataStorageObject *deleteObject = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                       streamBareJidStr:streamBareJidStr];
    if (deleteObject != nil){
        
        [moc deleteObject:deleteObject];
        return YES;
    }
    
    return NO;
}


#pragma mark - object update method
- (void)updateWithLoginId:(NSString *)loginId
              loginIdType:(LoginHelperIdType)loginIdType
         currentLoginUser:(BOOL)currentLoginUser
                autoLogin:(BOOL)autoLogin
            clientKeyData:(NSData *)clientKeyData
            serverkeyData:(NSData *)serverkeyData
             streamBareJidStr:(NSString *)streamBareJidStr
{
    BOOL hasChanges = NO;
    if (loginId) {
        [self setLoginId:self.loginId];
        hasChanges = YES;
    }
    if (loginIdType) {
        [self setLoginIdType:@(loginIdType)];
        hasChanges = YES;
    }
    if (clientKeyData) {
        [self setClientKeyData:clientKeyData];
        hasChanges = YES;
    }
    if (serverkeyData) {
        [self setServerKeyData:serverkeyData];
        hasChanges = YES;
    }
    if (streamBareJidStr) {
        [self setStreamBareJidStr:streamBareJidStr];
        hasChanges = YES;
    }
    
    [self setCurrentLoginUser:@(currentLoginUser)];
    [self setAutoLogin:@(autoLogin)];
    
    if (hasChanges) [self setLoginTime:[NSDate date]];
}

@end
