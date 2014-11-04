//
//  XMPPChatMessage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/8.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPChatMessageObject.h"
#import "XMPPFramework.h"

#define MESSAGE_TYPE_ELEMENT_NAME           @"messageType"
#define MESSAGE_ID_ELEMENT_NAME             @"messageID"
#define IS_PRIVATE_ELEMENT_NAME             @"isPrivate"
#define IS_CHAT_ROOM_MESSAGE_ELEMENT_NAME   @"isChatRoomMessage"

#define ADDITION_ELEMENT_NAME               @"additionMessageInfo"

@implementation XMPPChatMessageObject

#pragma mark -
#pragma mark - Public Methods

- (instancetype)init
{
    return [[XMPPChatMessageObject alloc] initWithType:0];
}

- (instancetype)initWithType:(NSUInteger)messageType
{
    self = [super init];
    if (self) {
        [self createMessageID];
        [self setMessageType:messageType];
    }
    return self;
}

-(instancetype)initWithDictionary:(NSMutableDictionary *)dictionary
{
    self = [super init];
    if (self) {
        [self fromDictionary:dictionary];
    }
    return self;
}

-(instancetype)initWithXMPPMessage:(XMPPMessage *)message  sendFromMe:(BOOL)sendFromMe hasBeenRead:(BOOL)hasBeenRead
{
    self = [super init];
    if (self) {
        self.hasBeenRead = hasBeenRead;
        self.sendFromMe = sendFromMe;
        [self fromXMPPMessage:message];
    }
    return self;
}

-(instancetype)initWithDictionary:(NSMutableDictionary *)dictionary from:(NSString *)from to:(NSString *)to hasBeenRead:(BOOL)hasBeenRead
{
    self = [super init];
    if (self) {
        self.fromUser = from;
        self.toUser = to;
        self.hasBeenRead = hasBeenRead;
        [self fromDictionary:dictionary];
    }
    return self;
}


-(instancetype)initWithXMPPMessageCoreDataStorageObject:(XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObject
{
    self = [super init];
    if (self) {
        [self setUpWithXMPPMessageCoreDataStorageObject:xmppMessageCoreDataStorageObject];
    }
    return self;
}

-(void)createMessageID
{
    self.messageID = [self UUIDString];
    self.sendFromMe = YES;
}

/**
 *  Get the unique string in system
 *
 *  @return The unique string we want
 */
-(NSString *)UUIDString
{
    CFUUIDRef uuidRef =CFUUIDCreate(NULL);
    
    CFStringRef uuidStringRef =CFUUIDCreateString(NULL, uuidRef);
    
    CFRelease(uuidRef);
    
    return (__bridge NSString *)uuidStringRef;
}


-(NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.messageID)
        [dictionary setObject:self.messageID forKey:@"messageID"];
    if (self.messageTime)
        [dictionary setObject:self.messageTime forKey:@"messageTime"];
    if (self.xmppSimpleMessageObject)
        [dictionary setObject:[self.xmppSimpleMessageObject toDictionary] forKey:@"xmppSimpleMessageObject"];
    
    [dictionary setObject:[NSNumber numberWithBool:self.isPrivate] forKey:@"isPrivate"];
    [dictionary setObject:[NSNumber numberWithBool:self.isChatRoomMessage] forKey:@"isChatRoomMessage"];
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:self.messageType] forKey:@"messageType"];
    
//    if (self.fromUser)
//        [dictionary setObject:self.fromUser forKey:@"fromUser"];
//    if (self.toUser)
//        [dictionary setObject:self.toUser forKey:@"toUser"];
//    [dictionary setObject:[NSNumber numberWithBool:self.sendFromMe] forKey:@"sendFromMe"];
//    [dictionary setObject:[NSNumber numberWithBool:self.hasBeenRead] forKey:@"hasBeenRead"];
    
    return dictionary;
}

-(void)fromDictionary:(NSMutableDictionary*)message
{
    self.messageID = [message objectForKey:@"messageID"];
    self.messageTime = [message objectForKey:@"sendTime"];
    
    self.xmppSimpleMessageObject = [[XMPPSimpleMessageObject alloc] initWithDictionary:[message objectForKey:@"xmppSimpleMessageObject"] ];
    self.isPrivate = [(NSNumber *)[message objectForKey:@"isPrivate"] boolValue];
    self.isChatRoomMessage = [(NSNumber *)[message objectForKey:@"isChatRoomMessage"] boolValue];
    self.messageType = [(NSNumber *)[message objectForKey:@"messageType"] unsignedIntegerValue];
    
//    self.fromUser = [message objectForKey:@"fromUser"];
//    self.toUser = [message objectForKey:@"toUser"];
//    self.hasBeenRead = [(NSNumber *)[message objectForKey:@"hasBeenRead"] boolValue];
//    self.sendFromMe = [(NSNumber *)[message objectForKey:@"sendFromMe"] boolValue];

}

-(XMPPMessage *)toXMPPMessage
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    
    if (self.messageType > 0) {
        NSXMLElement *messageType = [NSXMLElement elementWithName:MESSAGE_TYPE_ELEMENT_NAME numberValue:[NSNumber numberWithUnsignedInteger:self.messageType]];
        [body addChild:messageType];
    }
    
    if (self.messageID) {
        NSXMLElement *messageID = [NSXMLElement elementWithName:MESSAGE_ID_ELEMENT_NAME stringValue:self.messageID];
        [body addChild:messageID];
    }
    if (self.isPrivate) {
        NSXMLElement *isPrivate = [NSXMLElement elementWithName:IS_PRIVATE_ELEMENT_NAME numberValue:[NSNumber numberWithBool:self.isPrivate]];
        [body addChild:isPrivate];
    }
    
    if (self.isChatRoomMessage) {
        NSXMLElement *isChatRoomMessage = [NSXMLElement elementWithName:IS_CHAT_ROOM_MESSAGE_ELEMENT_NAME numberValue:[NSNumber numberWithBool:self.isChatRoomMessage]];
        [body addChild:isChatRoomMessage];
    }
    
    if (self.xmppSimpleMessageObject) {
        [body addChild:[self.xmppSimpleMessageObject toXMLElement]];
    }
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:self.toUser] elementID:nil child:body];
    return message;
}
//This method has no Parameter hasBeenRead,sendFromMe...
-(void)fromXMPPMessage:(XMPPMessage *)message
{
    NSXMLElement *body = [message elementForName:@"body"];
    if (!body) return;
    
    self.fromUser = [[message from] bare];
    self.toUser = [[message to] bare];
    self.messageTime = [self getLocalDateWithUTCString:[[body elementForName:@"messageTime"] stringValue]];
    self.messageType = [[body elementForName:@"messageType"] stringValueAsNSUInteger];
    self.messageID = [[body elementForName:@"messageID"] stringValue];
    self.isPrivate = [[body elementForName:@"isPrivate"] stringValueAsBool];
    self.isChatRoomMessage = [[body elementForName:@"isChatRoomMessage"] stringValueAsBool];
    
    NSXMLElement *additionMessageInfo = [body elementForName:ADDITION_ELEMENT_NAME];
    if (additionMessageInfo) {
        self.xmppSimpleMessageObject = [[XMPPSimpleMessageObject alloc] init];
        [self.xmppSimpleMessageObject fromXMLElement:additionMessageInfo];
    }
}
/**
 *  Get The local date obejct from the UTC string
 *
 *  @param utc UTC date string
 *
 *  @return The local date obejct
 */
- (NSDate *)getLocalDateWithUTCString:(NSString *)utc
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate *ldate = [dateFormatter dateFromString:utc];
    return ldate;
}

#pragma mark -
#pragma mark - Private Methods
-(void)setUpWithXMPPMessageCoreDataStorageObject:(XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObject
{
    self.messageID = xmppMessageCoreDataStorageObject.messageID;
    self.messageTime = xmppMessageCoreDataStorageObject.messageTime;
    self.sendFromMe = [xmppMessageCoreDataStorageObject.sendFromMe boolValue];
    self.xmppSimpleMessageObject = xmppMessageCoreDataStorageObject.messageBody;
    self.fromUser = self.sendFromMe ? xmppMessageCoreDataStorageObject.streamBareJidStr:xmppMessageCoreDataStorageObject.bareJidStr;
    self.toUser = self.sendFromMe ? xmppMessageCoreDataStorageObject.bareJidStr:xmppMessageCoreDataStorageObject.streamBareJidStr;
    self.isPrivate = xmppMessageCoreDataStorageObject.isPrivate > 0;
    self.isChatRoomMessage = xmppMessageCoreDataStorageObject.isChatRoomMessage > 0;
    self.hasBeenRead = [xmppMessageCoreDataStorageObject.hasBeenRead boolValue];
    self.messageType = [xmppMessageCoreDataStorageObject.messageType unsignedIntegerValue];
}

#pragma mark -
#pragma mark NSCopying Methods
- (id)copyWithZone:(NSZone *)zone
{
    XMPPChatMessageObject *newObject = [[[self class] allocWithZone:zone] init];
    
    [newObject setMessageID:self.messageID];
    [newObject setMessageType:self.messageType];
    [newObject setFromUser:self.fromUser];
    [newObject setToUser:self.toUser];
    [newObject setMessageTime:self.messageTime];
    [newObject setIsChatRoomMessage:self.isChatRoomMessage];
    [newObject setIsPrivate:self.isPrivate];
    [newObject setHasBeenRead:self.hasBeenRead];
    [newObject setSendFromMe:self.sendFromMe];
    [newObject setXmppSimpleMessageObject:self.xmppSimpleMessageObject];
    
    return newObject;
}
#pragma mark -
#pragma mark NSCoding Methods
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.messageType] forKey:@"messageType"];
    [aCoder encodeObject:self.messageID forKey:@"messageID"];
    [aCoder encodeObject:self.fromUser forKey:@"fromUser"];
    [aCoder encodeObject:self.toUser forKey:@"toUser"];
    [aCoder encodeObject:self.messageTime forKey:@"messageTime"];
    [aCoder encodeObject:self.xmppSimpleMessageObject forKey:@"xmppSimpleMessageObject"];

    [aCoder encodeObject:[NSNumber numberWithBool:self.sendFromMe] forKey:@"sendFromMe"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isPrivate] forKey:@"isPrivate"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.hasBeenRead] forKey:@"hasBeenRead"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isChatRoomMessage] forKey:@"isChatRoomMessage"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.messageType = [(NSNumber *)[aDecoder decodeObjectForKey:@"messageType"] unsignedIntegerValue];
        self.messageID = [aDecoder decodeObjectForKey:@"messageID"];
        self.messageTime = [aDecoder decodeObjectForKey:@"messageTime"];
        self.fromUser = [aDecoder decodeObjectForKey:@"fromUser"];
        self.toUser = [aDecoder decodeObjectForKey:@"toUser"];
        self.xmppSimpleMessageObject = [aDecoder decodeObjectForKey:@"xmppSimpleMessageObject"];
        self.sendFromMe = [(NSNumber *)[aDecoder decodeObjectForKey:@"sendFromMe"] boolValue];
        self.isPrivate = [(NSNumber *)[aDecoder decodeObjectForKey:@"isPrivate"] boolValue];
        self.isChatRoomMessage = [(NSNumber *)[aDecoder decodeObjectForKey:@"isChatRoomMessage"] boolValue];
        self.hasBeenRead = [(NSNumber *)[aDecoder decodeObjectForKey:@"hasBeenRead"] boolValue];
    }
    return  self;
}


@end
