//
//  XMPPChatRoomUserCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/11/4.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPChatRoomUserCoreDataStorageObject.h"


@implementation XMPPChatRoomUserCoreDataStorageObject

@dynamic bareJidStr;
@dynamic chatRoomBareJidStr;
@dynamic nickeName;
@dynamic streamBareJidStr;

#pragma mark -
#pragma mark - Setters/Getters Methods

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

- (NSString *)chatRoomBareJidStr
{
    [self willAccessValueForKey:@"chatRoomBareJidStr"];
    NSString *value = [self primitiveValueForKey:@"chatRoomBareJidStr"];
    [self didAccessValueForKey:@"chatRoomBareJidStr"];
    return value;
}

- (void)setChatRoomBareJidStr:(NSString *)value
{
    [self willChangeValueForKey:@"chatRoomBareJidStr"];
    [self setPrimitiveValue:value forKey:@"chatRoomBareJidStr"];
    [self didChangeValueForKey:@"chatRoomBareJidStr"];
}

- (NSString *)nickeName
{
    [self willAccessValueForKey:@"nickeName"];
    NSString *value = [self primitiveValueForKey:@"nickeName"];
    [self didAccessValueForKey:@"nickeName"];
    return value;
}

- (void)setNickeName:(NSString *)value
{
    [self willChangeValueForKey:@"nickeName"];
    [self setPrimitiveValue:value forKey:@"nickeName"];
    [self didChangeValueForKey:@"nickeName"];
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

#pragma mark -
#pragma mark - Public Methods
+ (id)fetchObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                         withBareJidStr:(NSString *)bareJidStr
                       streamBareJidStr:(NSString *)streamBareJidStr
{
    return [XMPPChatRoomUserCoreDataStorageObject objectInManagedObjectContext:moc
                                                                withBareJidStr:bareJidStr
                                                              streamBareJidStr:streamBareJidStr];
}

+ (XMPPChatRoomUserCoreDataStorageObject *)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                                                         withBareJidStr:(NSString *)bareJidStr
                                                       streamBareJidStr:(NSString *)streamBareJidStr
{
    if (bareJidStr == nil) return nil;
    if (moc == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPChatRoomUserCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate;
    if (streamBareJidStr == nil)
        predicate = [NSPredicate predicateWithFormat:@"jid == %@", bareJidStr];
    else
        predicate = [NSPredicate predicateWithFormat:@"jid == %@ AND streamBareJidStr == %@",
                     bareJidStr, streamBareJidStr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPChatRoomUserCoreDataStorageObject *)[results lastObject];
}


#pragma mark -
#pragma mark - Private Methods

@end
