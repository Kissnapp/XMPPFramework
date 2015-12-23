//
//  XMPPSubscribeCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/12/23.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPSubscribeCoreDataStorageObject.h"
#import "NSString+NSDate.h"


@implementation XMPPSubscribeCoreDataStorageObject

@dynamic bareJidStr;
@dynamic streamBareJidStr;
@dynamic nickName;
@dynamic message;
@dynamic time;
@dynamic state;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)bareJidStr
{
    [self willAccessValueForKey:@"bareJidStr"];
    NSString *value = [self primitiveValueForKey:@"bareJidStr"];
    [self didAccessValueForKey:@"bareJidStr"];
    
    return value;
}

- (void)setBareJidStr:(NSString *)value
{
    [self willChangeValueForKey:@"bareJidStr"];
    [self setPrimitiveValue:value forKey:@"bareJidStr"];
    [self didChangeValueForKey:@"bareJidStr"];
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

- (NSDate *)time
{
    [self willAccessValueForKey:@"time"];
    NSDate *value = [self primitiveValueForKey:@"time"];
    [self didAccessValueForKey:@"time"];
    
    return value;
}

- (void)setTime:(NSDate *)value
{
    [self willChangeValueForKey:@"time"];
    [self setPrimitiveValue:value forKey:@"time"];
    [self didChangeValueForKey:@"time"];
}

- (NSString *)message
{
    [self willAccessValueForKey:@"message"];
    NSString *value = [self primitiveValueForKey:@"message"];
    [self didAccessValueForKey:@"message"];
    
    return value;
}

- (void)setMessage:(NSString *)value
{
    [self willChangeValueForKey:@"formOrgId"];
    [self setPrimitiveValue:value forKey:@"formOrgId"];
    [self didChangeValueForKey:@"formOrgId"];
}


- (NSNumber *)state
{
    [self willAccessValueForKey:@"state"];
    NSNumber *value = [self primitiveValueForKey:@"state"];
    [self didAccessValueForKey:@"state"];
    
    return value;
}

- (void)setState:(NSNumber *)value
{
    [self willChangeValueForKey:@"state"];
    [self setPrimitiveValue:value forKey:@"state"];
    [self didChangeValueForKey:@"state"];
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSManagedObject
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)awakeFromInsert
{
    // your code here ...
    [super awakeFromInsert];
    //[self setPrimitiveValue:[NSDate date] forKey:@"time"];
    //[self setPrimitiveValue:@(XMPPSubscribeStateReceive) forKey:@"state"];
}

- (void)awakeFromFetch
{
    // your code here ...
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Creation & Updates
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                        bareJidStr:(NSString *)bareJidStr
                  streamBareJidStr:(NSString *)streamBareJidStr
{
     if (moc == nil) return nil;
    if (bareJidStr == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    NSString *entityName = NSStringFromClass([self class]);
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ AND streamBareJidStr == %@", bareJidStr, streamBareJidStr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPSubscribeCoreDataStorageObject *)[results lastObject];
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                        bareJidStr:(NSString *)bareJidStr
                          nickName:(NSString *)nickName
                           message:(NSString *)message
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (moc == nil) return nil;
    if (bareJidStr == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    NSString *entityName = NSStringFromClass([self class]);
    
    XMPPSubscribeCoreDataStorageObject *newSubcribe = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                                      inManagedObjectContext:moc];
    
    newSubcribe.streamBareJidStr = streamBareJidStr;
    newSubcribe.bareJidStr = bareJidStr;
    newSubcribe.nickName = nickName;
    newSubcribe.message = message;
    newSubcribe.time = [NSDate date];
    newSubcribe.state = @(XMPPSubscribeStateReceive);
    
    return newSubcribe;
}

+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc
                          bareJidStr:(NSString *)bareJidStr
                            nickName:(NSString *)nickName
                             message:(NSString *)message
                               state:(XMPPSubscribeState)state
                         updateState:(BOOL)updateState
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    BOOL result = NO;

    if (moc == nil) return result;
    if (bareJidStr == nil) return result;
    if (streamBareJidStr == nil) return result;
    
    
    XMPPSubscribeCoreDataStorageObject *subcribe = [XMPPSubscribeCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                         bareJidStr:bareJidStr
                                                                                                   streamBareJidStr:streamBareJidStr];
    if (subcribe) {
        
        if (nickName.length > 0) subcribe.nickName = nickName;
        if (message.length > 0) subcribe.message = message;
        if (updateState) subcribe.state = @(state);
        
        result = YES;
    }
    
    return result;
}

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                          bareJidStr:(NSString *)bareJidStr
                    streamBareJidStr:(NSString *)streamBareJidStr
{
    
    BOOL result = NO;
    
    if (moc == nil) return result;
    if (bareJidStr == nil) return result;
    if (streamBareJidStr == nil) return result;
    
    XMPPSubscribeCoreDataStorageObject *subcribe = [XMPPSubscribeCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                         bareJidStr:bareJidStr
                                                                                                   streamBareJidStr:streamBareJidStr];
    
    if (subcribe) {
        
        [moc deleteObject:subcribe];
        
        result = YES;
    }
    
    return result;
}

@end
