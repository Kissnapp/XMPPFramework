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
#define IS_GROUP_CHAT_ELEMENT_NAME          @"isGroupChat"

//#define ADDITION_ELEMENT_NAME               @"additionMessage"

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
    if (self.xmppAdditionalMessageObject)
        [dictionary setObject:[self.xmppAdditionalMessageObject toDictionary] forKey:@"additionMessage"];
    
    [dictionary setObject:[NSNumber numberWithBool:self.isPrivate] forKey:@"isPrivate"];
    [dictionary setObject:[NSNumber numberWithBool:self.isGroupChat] forKey:@"isGroupChat"];
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:self.messageType] forKey:@"messageType"];
    
    return dictionary;
}

-(void)fromDictionary:(NSMutableDictionary*)message
{
    self.messageID = [message objectForKey:@"messageID"];
    self.messageTime = [message objectForKey:@"sendTime"];
    
    self.xmppAdditionalMessageObject = [[XMPPAdditionalMessageObject alloc] initWithDictionary:[message objectForKey:@"additionMessage"] ];
    self.isPrivate = [(NSNumber *)[message objectForKey:@"isPrivate"] boolValue];
    self.isGroupChat = [(NSNumber *)[message objectForKey:@"isGroupChat"] boolValue];
    self.messageType = [(NSNumber *)[message objectForKey:@"messageType"] unsignedIntegerValue];
}

-(XMPPMessage *)toXMPPMessage
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    
    if (self.xmppAdditionalMessageObject) {
        [body addChild:[self.xmppAdditionalMessageObject toXMLElement]];
    }
    
    if (self.messageID) {
        NSXMLElement *messageID = [NSXMLElement elementWithName:MESSAGE_ID_ELEMENT_NAME stringValue:self.messageID];
        [body addChild:messageID];
    }
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:self.toUser] elementID:nil child:body];
    
    if (self.messageType > 0) {
        NSXMLElement *messageType = [NSXMLElement elementWithName:MESSAGE_TYPE_ELEMENT_NAME numberValue:[NSNumber numberWithUnsignedInteger:self.messageType]];
        [message addChild:messageType];
    }
    
    if (self.isPrivate) {
        NSXMLElement *isPrivate = [NSXMLElement elementWithName:IS_PRIVATE_ELEMENT_NAME numberValue:[NSNumber numberWithBool:self.isPrivate]];
        [message addChild:isPrivate];
    }
    
    if (self.isGroupChat) {
        NSXMLElement *isChatRoomMessage = [NSXMLElement elementWithName:IS_GROUP_CHAT_ELEMENT_NAME numberValue:[NSNumber numberWithBool:self.isGroupChat]];
        [body addChild:isChatRoomMessage];
    }
    
   
    return message;
}
//This method has no Parameter hasBeenRead,sendFromMe...
-(void)fromXMPPMessage:(XMPPMessage *)message
{
    NSXMLElement *body = [message elementForName:@"body"];
    if (!body) return;
    
    self.fromUser = [[message from] bare];
    self.toUser = [[message to] bare];
    self.messageTime = [self getLocalDateWithUTCString:[[message elementForName:@"timestamp"] stringValue]];
    self.messageType = [[message elementForName:@"messageType"] stringValueAsNSUInteger];
    self.isPrivate = [[message elementForName:@"isPrivate"] stringValueAsBool];
    self.isGroupChat = [[body elementForName:@"isGroupChat"] stringValueAsBool];
    
    self.messageID = [[body elementForName:@"messageID"] stringValue];
    
    NSXMLElement *additionMessageInfo = [body elementForName:ADDITION_ELEMENT_NAME xmlns:ADDITION_ELEMENT_XMLNS];
    if (additionMessageInfo) {
        self.xmppAdditionalMessageObject = [[XMPPAdditionalMessageObject alloc] init];
        [self.xmppAdditionalMessageObject fromXMLElement:additionMessageInfo];
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
    self.xmppAdditionalMessageObject = xmppMessageCoreDataStorageObject.messageBody;
    self.fromUser = self.sendFromMe ? xmppMessageCoreDataStorageObject.streamBareJidStr:xmppMessageCoreDataStorageObject.bareJidStr;
    self.toUser = self.sendFromMe ? xmppMessageCoreDataStorageObject.bareJidStr:xmppMessageCoreDataStorageObject.streamBareJidStr;
    self.isPrivate = xmppMessageCoreDataStorageObject.isPrivate > 0;
    self.isGroupChat = xmppMessageCoreDataStorageObject.isGroupChat > 0;
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
    [newObject setIsGroupChat:self.isGroupChat];
    [newObject setIsPrivate:self.isPrivate];
    [newObject setHasBeenRead:self.hasBeenRead];
    [newObject setSendFromMe:self.sendFromMe];
    [newObject setXmppAdditionalMessageObject:self.xmppAdditionalMessageObject];
    
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
    [aCoder encodeObject:self.xmppAdditionalMessageObject forKey:@"xmppAdditionalMessageObject"];

    [aCoder encodeObject:[NSNumber numberWithBool:self.sendFromMe] forKey:@"sendFromMe"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isPrivate] forKey:@"isPrivate"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.hasBeenRead] forKey:@"hasBeenRead"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isGroupChat] forKey:@"isGroupChat"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.messageType = [(NSNumber *)[aDecoder decodeObjectForKey:@"messageType"] unsignedIntegerValue];
        self.messageID = [aDecoder decodeObjectForKey:@"messageID"];
        self.messageTime = [aDecoder decodeObjectForKey:@"messageTime"];
        self.fromUser = [aDecoder decodeObjectForKey:@"fromUser"];
        self.toUser = [aDecoder decodeObjectForKey:@"toUser"];
        self.xmppAdditionalMessageObject = [aDecoder decodeObjectForKey:@"xmppAdditionalMessageObject"];
        self.sendFromMe = [(NSNumber *)[aDecoder decodeObjectForKey:@"sendFromMe"] boolValue];
        self.isPrivate = [(NSNumber *)[aDecoder decodeObjectForKey:@"isPrivate"] boolValue];
        self.isGroupChat = [(NSNumber *)[aDecoder decodeObjectForKey:@"isGroupChat"] boolValue];
        self.hasBeenRead = [(NSNumber *)[aDecoder decodeObjectForKey:@"hasBeenRead"] boolValue];
    }
    return  self;
}


@end
