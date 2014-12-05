//
//  XMPPLoginUserCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/12/5.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPLoginUserCoreDataStorageObject.h"


@implementation XMPPLoginUserCoreDataStorageObject

@dynamic loginTime;
@dynamic phoneNumber;
@dynamic emailAddress;
@dynamic nickName;
@dynamic streamBareJidStr;
@dynamic longitude;
@dynamic latitude;
@dynamic password;


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


- (NSString *)phoneNumber
{
    [self willAccessValueForKey:@"phoneNumber"];
    NSString *value = [self primitiveValueForKey:@"phoneNumber"];
    [self didAccessValueForKey:@"phoneNumber"];
    return value;
}

- (void)setPhoneNumber:(NSString *)value
{
    [self willChangeValueForKey:@"phoneNumber"];
    [self setPrimitiveValue:value forKey:@"phoneNumber"];
    [self didChangeValueForKey:@"phoneNumber"];
}

- (NSString *)emailAddress
{
    [self willAccessValueForKey:@"emailAddress"];
    NSString *value = [self primitiveValueForKey:@"emailAddress"];
    [self didAccessValueForKey:@"emailAddress"];
    return value;
}

- (void)seEmailAddress:(NSString *)value
{
    [self willChangeValueForKey:@"emailAddress"];
    [self setPrimitiveValue:value forKey:@"emailAddress"];
    [self didChangeValueForKey:@"emailAddress"];
}

- (NSString *)nickName
{
    [self willAccessValueForKey:@"nickName"];
    NSString *value = [self primitiveValueForKey:@"nickName"];
    [self didAccessValueForKey:@"nickName"];
    return value;
}

- (void)setNickName:(NSString *)value
{
    [self willChangeValueForKey:@"nickName"];
    [self setPrimitiveValue:value forKey:@"nickName"];
    [self didChangeValueForKey:@"nickName"];
}

- (NSString *)password
{
    [self willAccessValueForKey:@"password"];
    NSString *value = [self primitiveValueForKey:@"password"];
    [self didAccessValueForKey:@"password"];
    return value;
}

- (void)setPassword:(NSString *)value
{
    [self willChangeValueForKey:@"password"];
    [self setPrimitiveValue:value forKey:@"password"];
    [self didChangeValueForKey:@"password"];
}

- (NSString *)latitude
{
    [self willAccessValueForKey:@"latitude"];
    NSString *value = [self primitiveValueForKey:@"latitude"];
    [self didAccessValueForKey:@"latitude"];
    return value;
}

- (void)setLatitude:(NSString *)value
{
    [self willChangeValueForKey:@"latitude"];
    [self setPrimitiveValue:value forKey:@"latitude"];
    [self didChangeValueForKey:@"latitude"];
}

- (NSString *)longitude
{
    [self willAccessValueForKey:@"longitude"];
    NSString *value = [self primitiveValueForKey:@"longitude"];
    [self didAccessValueForKey:@"longitude"];
    return value;
}

- (void)setLongitude:(NSString *)value
{
    [self willChangeValueForKey:@"longitude"];
    [self setPrimitiveValue:value forKey:@"longitude"];
    [self didChangeValueForKey:@"longitude"];
}
#pragma mark - awake action

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setPrimitiveValue:[NSDate date] forKey:@"loginTime"];
}

#pragma mark - public methods
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                   withPhoneNumber:(NSString *)phonenumber
                  withEmailAddress:(NSString *)emailaddress
                          nickName:(NSString *)nickname
                          password:(NSString *)password
                         longitude:(NSString *)longitude
                          latitude:(NSString *)latitude
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (!moc || !streamBareJidStr) return nil;
    
    XMPPLoginUserCoreDataStorageObject *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPLoginUserCoreDataStorageObject"
                                                                                inManagedObjectContext:moc];
    if (newUser) {
        [newUser updateWithPhoneNumber:phonenumber
                      withEmailAddress:emailaddress
                              nickName:nickname
                              password:password
                             longitude:longitude
                              latitude:latitude
                      streamBareJidStr:streamBareJidStr];
        
        return newUser;
    }
    
    return nil;
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                   withPhoneNumber:(NSString *)phonenumber
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    return [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                            withPhoneNumber:phonenumber
                                                           withEmailAddress:nil
                                                                   nickName:nil
                                                                   password:nil
                                                                  longitude:nil
                                                                   latitude:nil
                                                           streamBareJidStr:streamBareJidStr];
}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                  withEmailAddress:(NSString *)emailaddress
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    return [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                            withPhoneNumber:nil
                                                           withEmailAddress:emailaddress
                                                                   nickName:nil
                                                                   password:nil
                                                                  longitude:nil
                                                                   latitude:nil
                                                           streamBareJidStr:streamBareJidStr];
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                   withPhoneNumber:(NSString *)phonenumber
                          password:(NSString *)password
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    return [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                            withPhoneNumber:phonenumber
                                                           withEmailAddress:nil
                                                                   nickName:nil
                                                                   password:password
                                                                  longitude:nil
                                                                   latitude:nil
                                                           streamBareJidStr:streamBareJidStr];
}



+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                  withEmailAddress:(NSString *)emailaddress
                          password:(NSString *)password
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    return [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                            withPhoneNumber:nil
                                                           withEmailAddress:emailaddress
                                                                   nickName:nil
                                                                   password:password
                                                                  longitude:nil
                                                                   latitude:nil
                                                           streamBareJidStr:streamBareJidStr];
}
//update or insert methods
+ (id)updateStreamBareJidStrOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                           withPhoneNumber:(NSString *)phonenumber
                                          streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return nil;
    if (phonenumber == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    XMPPLoginUserCoreDataStorageObject *updateUser = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                      withPhoneNumber:phonenumber];
    if (updateUser) {//if exist alter it
        [updateUser setStreamBareJidStr:streamBareJidStr];
        [updateUser setLoginTime:[NSDate date]];
    }else{// if not existed,create a new one
        updateUser = [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                      withPhoneNumber:phonenumber
                                                                     streamBareJidStr:streamBareJidStr];
    }
    return updateUser;
}

+ (id)updateStreamBareJidStrOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                          withEmailAddress:(NSString *)emailaddress
                                          streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return nil;
    if (emailaddress == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    XMPPLoginUserCoreDataStorageObject *updateUser = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                     withEmailAddress:emailaddress];
    if (updateUser) {//if exist alter it
        [updateUser setStreamBareJidStr:streamBareJidStr];
        [updateUser setLoginTime:[NSDate date]];
    }else{// if not existed,create a new one
        updateUser = [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                     withEmailAddress:emailaddress
                                                                     streamBareJidStr:streamBareJidStr];
    }
    return updateUser;
}

+ (id)updatePhoneNumberOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                      withPhoneNumber:(NSString *)phonenumber
                                     streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return nil;
    if (phonenumber == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    XMPPLoginUserCoreDataStorageObject *updateUser = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                     streamBareJidStr:streamBareJidStr];
    if (updateUser) {//if exist alter it
        [updateUser setPhoneNumber:phonenumber];
        [updateUser setLoginTime:[NSDate date]];
    }else{// if not existed,create a new one
        updateUser = [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                      withPhoneNumber:phonenumber
                                                                     streamBareJidStr:streamBareJidStr];
    }
    return updateUser;
}

+ (id)updateEmailAddressOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                                      withEmailAddress:(NSString *)emailaddress
                                      streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return nil;
    if (emailaddress == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    XMPPLoginUserCoreDataStorageObject *updateUser = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                     streamBareJidStr:streamBareJidStr];
    if (updateUser) {//if exist alter it
        [updateUser setEmailAddress:emailaddress];
        [updateUser setLoginTime:[NSDate date]];
    }else{// if not existed,create a new one
        updateUser = [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                     withEmailAddress:emailaddress
                                                                     streamBareJidStr:streamBareJidStr];
    }
    return updateUser;
}

//fetch methods
+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                   withPhoneNumber:(NSString *)phonenumber
{
    if (moc == nil) return nil;
    if (phonenumber == nil) return nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",@"phoneNumber",phonenumber];
    
    return  [XMPPLoginUserCoreDataStorageObject fetchInInManagedObjectContext:moc
                                                                WithPredicate:predicate];
}

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                  withEmailAddress:(NSString *)emailaddress
{
    if (moc == nil) return nil;
    if (emailaddress == nil) return nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",@"emailAddress",emailaddress];
    
    return  [XMPPLoginUserCoreDataStorageObject fetchInInManagedObjectContext:moc
                                                                WithPredicate:predicate];
}

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",@"streamBareJidStr",streamBareJidStr];
    
    return  [XMPPLoginUserCoreDataStorageObject fetchInInManagedObjectContext:moc
                                                                WithPredicate:predicate];
}

+ (id)fetchInInManagedObjectContext:(NSManagedObjectContext *)moc
                      WithPredicate:(NSPredicate *)predicate
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



//update mthods
+ (BOOL)updateAllInManagedObjectContext:(NSManagedObjectContext *)moc
                      withPhoneNumber:(NSString *)phonenumber
                     withEmailAddress:(NSString *)emailaddress
                             nickName:(NSString *)nickname
                             password:(NSString *)password
                            longitude:(NSString *)longitude
                             latitude:(NSString *)latitude
                     streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    
    XMPPLoginUserCoreDataStorageObject *updateObject = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                       streamBareJidStr:streamBareJidStr];
    if (!updateObject) return NO;
    
    [updateObject updateWithPhoneNumber:phonenumber
                       withEmailAddress:emailaddress
                               nickName:nickname
                               password:password
                              longitude:longitude
                               latitude:latitude
                       streamBareJidStr:streamBareJidStr];
    [updateObject setLoginTime:[NSDate date]];
    
    return YES;
}

+ (BOOL)updateStreamBareJidStrInManagedObjectContext:(NSManagedObjectContext *)moc
                                     withPhoneNumber:(NSString *)phonenumber
                                    streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    if (phonenumber == nil) return NO;
    
    XMPPLoginUserCoreDataStorageObject *updateObject = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                        withPhoneNumber:phonenumber];
    if (!updateObject) return NO;
    
    [updateObject setStreamBareJidStr:streamBareJidStr];
    [updateObject setLoginTime:[NSDate date]];
    
    return YES;

}
+ (BOOL)updateStreamBareJidStrInManagedObjectContext:(NSManagedObjectContext *)moc
                                    withEmailAddress:(NSString *)emailaddress
                                    streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    if (emailaddress == nil) return NO;
    
    XMPPLoginUserCoreDataStorageObject *updateObject = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                       withEmailAddress:emailaddress];
    if (!updateObject) return NO;
    
    [updateObject setStreamBareJidStr:streamBareJidStr];
    [updateObject setLoginTime:[NSDate date]];
    
    return YES;

}
+ (BOOL)updatePhoneNumberInManagedObjectContext:(NSManagedObjectContext *)moc
                                withPhoneNumber:(NSString *)phonenumber
                               streamBareJidStr:(NSString *)streamBareJidStr
{
    return [XMPPLoginUserCoreDataStorageObject updateAllInManagedObjectContext:moc
                                                               withPhoneNumber:phonenumber
                                                              withEmailAddress:nil
                                                                      nickName:nil
                                                                      password:nil
                                                                     longitude:nil
                                                                      latitude:nil
                                                              streamBareJidStr:streamBareJidStr];
}
+ (BOOL)updateEmailAddressInManagedObjectContext:(NSManagedObjectContext *)moc
                                withEmailAddress:(NSString *)emailaddress
                                streamBareJidStr:(NSString *)streamBareJidStr
{
    return [XMPPLoginUserCoreDataStorageObject updateAllInManagedObjectContext:moc
                                                               withPhoneNumber:nil
                                                              withEmailAddress:emailaddress
                                                                      nickName:nil
                                                                      password:nil
                                                                     longitude:nil
                                                                      latitude:nil
                                                              streamBareJidStr:streamBareJidStr];
}


//delete methods
+ (BOOL)deleteFromManagedObjectContext:(NSManagedObjectContext *)moc
                       withPhoneNumber:(NSString *)phonenumber
{
    if (moc == nil) return NO;
    if (phonenumber == nil) return NO;
    
    XMPPLoginUserCoreDataStorageObject *deleteObject = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                        withPhoneNumber:phonenumber];
    if (deleteObject != nil){
        
        [moc deleteObject:deleteObject];
        return YES;
    }
    
    return NO;
}


+ (BOOL)deleteFromManagedObjectContext:(NSManagedObjectContext *)moc
                      withEmailAddress:(NSString *)emailaddress
{
    if (moc == nil) return NO;
    if (emailaddress == nil) return NO;
    
    XMPPLoginUserCoreDataStorageObject *deleteObject = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                       withEmailAddress:emailaddress];
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
- (void)updateWithPhoneNumber:(NSString *)phonenumber
             withEmailAddress:(NSString *)emailaddress
                     nickName:(NSString *)nickname
                     password:(NSString *)password
                    longitude:(NSString *)longitude
                     latitude:(NSString *)latitude
             streamBareJidStr:(NSString *)streamBareJidStr
{
    if (phonenumber) [self setPhoneNumber:phonenumber];
    if (emailaddress) [self setEmailAddress:emailaddress];
    if (nickname) [self setNickName:nickname];
    if (password) [self setPassword:password];
    if (longitude) [self setLongitude:longitude];
    if (latitude) [self setLatitude:latitude];
    if (streamBareJidStr) [self setStreamBareJidStr:streamBareJidStr];
}

@end
