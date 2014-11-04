//
//  XMPPLoginUserCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPLoginUserCoreDataStorageObject.h"


@implementation XMPPLoginUserCoreDataStorageObject

@dynamic loginID;
@dynamic streamBareJidStr;
@dynamic loginTime;

- (NSString *)loginID
{
    [self willAccessValueForKey:@"loginID"];
    NSString *value = [self primitiveValueForKey:@"loginID"];
    [self didAccessValueForKey:@"loginID"];
    return value;
}
            
- (void)setLoginID:(NSString *)value
{
    [self willChangeValueForKey:@"loginID"];
    [self setPrimitiveValue:value forKey:@"loginID"];
    [self didChangeValueForKey:@"loginID"];
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

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setPrimitiveValue:[NSDate date] forKey:@"loginTime"];
}

#pragma mark - public methods
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                       withLoginID:(NSString *)loginID
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (loginID == nil){
        NSLog(@"XMPPLoginUserCoreDataStorageObject: invalid loginID (nil)");
        return nil;
    }
    
    if (moc == nil) return nil;
    
    XMPPLoginUserCoreDataStorageObject *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPLoginUserCoreDataStorageObject"
                                            inManagedObjectContext:moc];
    
    newUser.loginID = loginID;
    newUser.streamBareJidStr = streamBareJidStr;
    
    return newUser;
}

+ (id)updateOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc
                               withLoginID:(NSString *)loginID
                          streamBareJidStr:(NSString *)streamBareJidStr
{
    if (loginID == nil) return nil;
    if (moc == nil) return nil;
    
    XMPPLoginUserCoreDataStorageObject *loginUser = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                         withLoginID:loginID];
    if (loginUser) {//if exist alter it
        loginUser.loginID = loginID;
        loginUser.streamBareJidStr = streamBareJidStr;
    }else{// if not existed,create a new one
        loginUser = [XMPPLoginUserCoreDataStorageObject insertInManagedObjectContext:moc
                                                                         withLoginID:loginID
                                                                    streamBareJidStr:streamBareJidStr];
    }
    return loginUser;
}

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                       withLoginID:(NSString *)loginID
{
    if (moc == nil) return nil;
    if (loginID == nil) return nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",@"loginID",loginID];
    
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

+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc
                       withLoginID:(NSString *)loginID
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return NO;
    if (loginID == nil) return NO;
    
    XMPPLoginUserCoreDataStorageObject *updateObject = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                            withLoginID:loginID];
    if (!updateObject) return NO;
    
    [updateObject setStreamBareJidStr:streamBareJidStr];
    
    return YES;
}

+ (BOOL)deleteFromManagedObjectContext:(NSManagedObjectContext *)moc
                           withLoginID:(NSString *)loginID
{
    if (moc == nil) return NO;
    if (loginID == nil) return NO;
    
    XMPPLoginUserCoreDataStorageObject *deleteObject = [XMPPLoginUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                            withLoginID:loginID];
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



@end
