//
//  XMPPMessageHistoryCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/21.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPMessageHistoryCoreDataStorageObject.h"


@implementation XMPPMessageHistoryCoreDataStorageObject

@dynamic bareJidStr;
@dynamic streamBareJidStr;
@dynamic unReadCount;
@dynamic hasBeenEnd;
@dynamic lastChatTime;
@dynamic topTime;

#pragma mark - Getter/Setters Methods

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

- (NSNumber *)unReadCount
{
    [self willAccessValueForKey:@"unReadCount"];
    NSNumber *value = [self primitiveValueForKey:@"unReadCount"];
    [self didAccessValueForKey:@"unReadCount"];
    return value;
}

- (void)setUnReadCount:(NSNumber *)value
{
    [self willChangeValueForKey:@"unReadCount"];
    [self setPrimitiveValue:value forKey:@"unReadCount"];
    [self didChangeValueForKey:@"unReadCount"];
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

- (NSDate *)lastChatTime
{
    [self willAccessValueForKey:@"lastChatTime"];
    NSDate *value = [self primitiveValueForKey:@"lastChatTime"];
    [self didAccessValueForKey:@"lastChatTime"];
    return value;
}

- (void)setLastChatTime:(NSDate *)value
{
    [self willChangeValueForKey:@"lastChatTime"];
    [self setPrimitiveValue:value forKey:@"lastChatTime"];
    [self didChangeValueForKey:@"lastChatTime"];
}

- (NSDate *)topTime
{
    [self willAccessValueForKey:@"topTime"];
    NSDate *value = [self primitiveValueForKey:@"topTime"];
    [self didAccessValueForKey:@"topTime"];
    return value;
}

- (void)setTopTime:(NSDate *)value
{
    [self willChangeValueForKey:@"topTime"];
    [self setPrimitiveValue:value forKey:@"topTime"];
    [self didChangeValueForKey:@"topTime"];
}

- (NSNumber *)hasBeenEnd
{
    [self willAccessValueForKey:@"hasBeenEnd"];
    NSNumber *value = [self primitiveValueForKey:@"hasBeenEnd"];
    [self didAccessValueForKey:@"hasBeenEnd"];
    return value;
}

- (void)setHasBeenEnd:(NSNumber *)value
{
    [self willChangeValueForKey:@"hasBeenEnd"];
    [self setPrimitiveValue:value forKey:@"hasBeenEnd"];
    [self didChangeValueForKey:@"hasBeenEnd"];
}

- (void)awakeFromInsert
{
    self.hasBeenEnd = [NSNumber numberWithBool:NO];
}

#pragma mark - Public  Methods

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                        bareJidStr:(NSString *)bareJidStr
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (bareJidStr.length < 1) return nil;
    if (streamBareJidStr.length < 1) return nil;
    if (moc == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ AND streamBareJidStr == %@",
                              bareJidStr, streamBareJidStr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPMessageHistoryCoreDataStorageObject *)[results lastObject];
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                        bareJidStr:(NSString *)bareJidStr
                            unRead:(BOOL)unRead
                              time:(NSDate *)time
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    if (!moc) return nil;
    if (bareJidStr.length < 1) return nil;
    if (streamBareJidStr.length < 1) return nil;
    
    XMPPMessageHistoryCoreDataStorageObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                                                       inManagedObjectContext:moc];
    newObject.bareJidStr = bareJidStr;
    newObject.streamBareJidStr = streamBareJidStr;
    newObject.unReadCount = @(unRead);
    newObject.lastChatTime = time;
    
    return newObject;
}

+ (BOOL)deleteObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                bareJidStr:(NSString *)bareJidStr
                          streamBareJidStr:(NSString *)streamBareJidStr
{
    if (bareJidStr.length < 1) return NO;
    if (streamBareJidStr.length < 1) return NO;
    if (moc == nil) return NO;
    
    XMPPMessageHistoryCoreDataStorageObject *deleteObject = [XMPPMessageHistoryCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                       bareJidStr:bareJidStr
                                                                                                                 streamBareJidStr:streamBareJidStr];
    
    if (!deleteObject) return NO;
    
    [moc deleteObject:deleteObject];
    
    return YES;
}




+ (BOOL)updateOrInsertObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                        bareJidStr:(NSString *)bareJidStr
                                            unRead:(BOOL)unRead
                                              time:(NSDate *)time
                                  streamBareJidStr:(NSString *)streamBareJidStr
{
    
    if (bareJidStr.length < 1) return NO;
    if (streamBareJidStr.length < 1) return NO;
    if (moc == nil) return NO;
    
    XMPPMessageHistoryCoreDataStorageObject *updateObject = [XMPPMessageHistoryCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                       bareJidStr:bareJidStr
                                                                                                                 streamBareJidStr:streamBareJidStr];
    //if the object we find alreadly in the coredata system ,we should update it
    if (updateObject){
        
        updateObject.bareJidStr = bareJidStr;
        if (unRead) updateObject.unReadCount = @([updateObject.unReadCount unsignedIntegerValue] + 1);
        updateObject.streamBareJidStr = streamBareJidStr;
        if (time) {
            updateObject.lastChatTime = time;
        }
        
        return YES;
        
    }else{//if not find the object in the CoreData system ,we should insert the new object to it
        //FIXME:There is a bug meybe here
        updateObject = [XMPPMessageHistoryCoreDataStorageObject insertInManagedObjectContext:moc
                                                                                  bareJidStr:bareJidStr
                                                                                      unRead:unRead
                                                                                        time:time
                                                                            streamBareJidStr:streamBareJidStr];
        return YES;
    }
    
    return NO;
}

+ (BOOL)readObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                              bareJidStr:(NSString *)bareJidStr
                        streamBareJidStr:(NSString *)streamBareJidStr
{
    if (bareJidStr.length < 1) return NO;
    if (streamBareJidStr.length < 1) return NO;
    if (moc == nil) return NO;
    
    XMPPMessageHistoryCoreDataStorageObject *readObject = [XMPPMessageHistoryCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                     bareJidStr:bareJidStr
                                                                                                               streamBareJidStr:streamBareJidStr];
    //if the object we find alreadly in the coredata system ,we should update it
    if (!readObject) return NO;
    
    readObject.unReadCount = @(0);
    
    return YES;
}

+ (BOOL)readOneObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                 bareJidStr:(NSString *)bareJidStr
                           streamBareJidStr:(NSString *)streamBareJidStr
{
    if (bareJidStr.length < 1) return NO;
    if (streamBareJidStr.length < 1) return NO;
    if (moc == nil) return NO;
    
    XMPPMessageHistoryCoreDataStorageObject *readObject = [XMPPMessageHistoryCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                                     bareJidStr:bareJidStr
                                                                                                               streamBareJidStr:streamBareJidStr];
    //if the object we find alreadly in the coredata system ,we should update it
    if (!readObject) return NO;
    
    NSUInteger oldUnreadCount = [readObject.unReadCount unsignedIntegerValue];
    
    if (oldUnreadCount > 0) --oldUnreadCount;
    
    readObject.unReadCount = @(oldUnreadCount);
    
    return YES;
}

@end
