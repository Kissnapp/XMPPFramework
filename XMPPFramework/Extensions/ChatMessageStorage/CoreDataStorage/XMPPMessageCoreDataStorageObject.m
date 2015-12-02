//
//  XMPPMessageCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/10.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPMessageCoreDataStorageObject.h"
#import "XMPPExtendMessage.h"
#import "XMPPBaseMessageObject.h"

@implementation XMPPMessageCoreDataStorageObject

@dynamic msgId;
@dynamic sender;
@dynamic bareJidStr;
@dynamic streamBareJidStr;
@dynamic msgType;
@dynamic outgoing;
@dynamic beenRead;
@dynamic sendState;
@dynamic isGroup;
@dynamic msgTime;
@dynamic subData;


//This the getter and setters
#pragma mark - Getters/Setters methods

- (NSString *)msgId
{
    [self willAccessValueForKey:@"msgId"];
    NSString *value = [self primitiveValueForKey:@"msgId"];
    [self didAccessValueForKey:@"msgId"];
    return value;
}

- (void)setMsgId:(NSString *)value
{
    [self willChangeValueForKey:@"msgId"];
    [self setPrimitiveValue:value forKey:@"msgId"];
    [self didChangeValueForKey:@"msgId"];
}

- (NSString *)sender
{
    [self willAccessValueForKey:@"sender"];
    NSString *value = [self primitiveValueForKey:@"sender"];
    [self didAccessValueForKey:@"sender"];
    return value;
}

- (void)setSender:(NSString *)value
{
    [self willChangeValueForKey:@"sender"];
    [self setPrimitiveValue:value forKey:@"sender"];
    [self didChangeValueForKey:@"sender"];
}

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

- (NSNumber *)msgType
{
    [self willAccessValueForKey:@"msgType"];
    NSNumber *value = [self primitiveValueForKey:@"msgType"];
    [self didAccessValueForKey:@"msgType"];
    return value;
}

- (void)setMsgType:(NSNumber *)value
{
    [self willChangeValueForKey:@"msgType"];
    [self setPrimitiveValue:value forKey:@"msgType"];
    [self didChangeValueForKey:@"msgType"];
}

- (NSNumber *)outgoing
{
    [self willAccessValueForKey:@"outgoing"];
    NSNumber *value = [self primitiveValueForKey:@"outgoing"];
    [self didAccessValueForKey:@"outgoing"];
    return value;
}

- (void)setOutgoing:(NSNumber *)value
{
    [self willChangeValueForKey:@"outgoing"];
    [self setPrimitiveValue:value forKey:@"outgoing"];
    [self didChangeValueForKey:@"outgoing"];
}


- (NSNumber *)beenRead
{
    [self willAccessValueForKey:@"beenRead"];
    NSNumber *value = [self primitiveValueForKey:@"beenRead"];
    [self didAccessValueForKey:@"beenRead"];
    return value;
}

- (void)setBeenRead:(NSNumber *)value
{
    [self willChangeValueForKey:@"beenRead"];
    [self setPrimitiveValue:value forKey:@"beenRead"];
    [self didChangeValueForKey:@"beenRead"];
}

- (NSNumber *)sendState
{
    [self willAccessValueForKey:@"sendState"];
    NSNumber *value = [self primitiveValueForKey:@"sendState"];
    [self didAccessValueForKey:@"sendState"];
    return value;
}

- (void)setSendState:(NSNumber *)value
{
    [self willChangeValueForKey:@"sendState"];
    [self setPrimitiveValue:value forKey:@"sendState"];
    [self didChangeValueForKey:@"sendState"];
}

- (NSNumber *)isGroup
{
    [self willAccessValueForKey:@"isGroup"];
    NSNumber *value = [self primitiveValueForKey:@"isGroup"];
    [self didAccessValueForKey:@"isGroup"];
    return value;
}

- (void)setIsGroup:(NSNumber *)value
{
    [self willChangeValueForKey:@"isGroup"];
    [self setPrimitiveValue:value forKey:@"isGroup"];
    [self didChangeValueForKey:@"isGroup"];
}

- (NSDate *)msgTime
{
    [self willAccessValueForKey:@"msgTime"];
    NSDate *value = [self primitiveValueForKey:@"msgTime"];
    [self didAccessValueForKey:@"msgTime"];
    return value;
}

- (void)setMsgTime:(NSDate *)value
{
    [self willChangeValueForKey:@"msgTime"];
    [self setPrimitiveValue:value forKey:@"msgTime"];
    [self didChangeValueForKey:@"msgTime"];
}


- (XMPPBaseMessageObject *)subData
{
    [self willAccessValueForKey:@"subData"];
    XMPPBaseMessageObject *value = [self primitiveValueForKey:@"subData"];
    [self didAccessValueForKey:@"subData"];
    return value;
}

- (void)setSubData:(XMPPBaseMessageObject *)value
{
    [self willChangeValueForKey:@"subData"];
    [self setPrimitiveValue:value forKey:@"subData"];
    [self didChangeValueForKey:@"subData"];
}


- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
}
#pragma mark -
#pragma mark - Public Methods

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc predicate:(NSPredicate *)predicate
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
    
    return (XMPPMessageCoreDataStorageObject *)[results lastObject];
}

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                             msgId:(NSString *)msgId
                  streamBareJidStr:(NSString *)streamBareJidStr

{
    if (msgId == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    if (moc == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"msgId == %@ AND streamBareJidStr == %@",
                              msgId, streamBareJidStr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (XMPPMessageCoreDataStorageObject *)[results lastObject];
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                            active:(BOOL)active
                 xmppExtendMessage:(XMPPExtendMessage *)xmppExtendMessage
                  streamBareJidStr:(NSString *)streamBareJidStr
{
    NSString *msgId = [xmppExtendMessage msgId];
    
    if (msgId == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    if (moc == nil) return nil;
    
    XMPPMessageCoreDataStorageObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                                                inManagedObjectContext:moc];
    
    [newObject updateFromXMPPExtendMessage:xmppExtendMessage streamBareJidStr:streamBareJidStr];
    
    //Add the unread message count or insert a new unread message info
    [XMPPUnReadMessageCoreDataStorageObject updateOrInsertObjectInManagedObjectContext:moc
                                                                        withUserJIDstr:xmppExtendMessage.msgOutgoing ? xmppExtendMessage.msgTo:xmppExtendMessage.msgFrom
                                                                    unReadMessageCount:(active ? 0:1)
                                                                          lastChatTime:xmppExtendMessage.msgTime
                                                                      streamBareJidStr:streamBareJidStr];
    
    return newObject;
}

- (void)updateFromXMPPExtendMessage:(XMPPExtendMessage *)xmppExtendMessage streamBareJidStr:(NSString *)streamBareJidStr
{
    self.msgId = xmppExtendMessage.msgId;
    self.sender = xmppExtendMessage.msgSender;
    self.outgoing = @(xmppExtendMessage.msgOutgoing);
    self.bareJidStr = xmppExtendMessage.msgOutgoing ? xmppExtendMessage.msgTo:xmppExtendMessage.msgFrom;
    self.msgType = @(xmppExtendMessage.msgType);
    self.beenRead = xmppExtendMessage.msgOutgoing ? @(YES):@(xmppExtendMessage.msgBeenRead);
    self.sendState = xmppExtendMessage.msgOutgoing ? @(xmppExtendMessage.msgSendState):@(XMPPMessageSendSucceed);
    self.isGroup = @(xmppExtendMessage.msgIsGroup);
    self.msgTime = xmppExtendMessage.msgTime;
    self.subData = xmppExtendMessage.msgSubData;
    self.streamBareJidStr = streamBareJidStr;
}

+ (BOOL)updateOrInsertObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                            active:(BOOL)active
                                 xmppExtendMessage:(XMPPExtendMessage *)xmppExtendMessage
                                  streamBareJidStr:(NSString *)streamBareJidStr
{
    NSString *msgId = xmppExtendMessage.msgId;
    
    if (msgId == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    if (moc == nil) return NO;
    
    XMPPMessageCoreDataStorageObject *updateObject = [XMPPMessageCoreDataStorageObject objectInManagedObjectContext:moc
                                                                                                              msgId:msgId
                                                                                                   streamBareJidStr:streamBareJidStr];
    //if the object we find alreadly in the coredata system ,we should update it
    if (updateObject){
        
        [updateObject updateFromXMPPExtendMessage:xmppExtendMessage streamBareJidStr:streamBareJidStr];
        
        return YES;
        
    }else{//if not find the object in the CoreData system ,we should insert the new object to it
        //FIXME:There is a bug meybe here
        updateObject = [XMPPMessageCoreDataStorageObject insertInManagedObjectContext:moc
                                                                               active:active
                                                                    xmppExtendMessage:xmppExtendMessage
                                                                     streamBareJidStr:streamBareJidStr];
        
        if(updateObject != nil) return YES;
    }
    
    return NO;

}

@end


