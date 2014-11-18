//
//  XMPPChatMessage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/8.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPExtendMessageObject.h"
#import "XMPPFramework.h"
#import "XMPPLogging.h"
#import "XMPPDateTimeProfiles.h"
#import "NSData+XMPP.h"
#import <objc/runtime.h>

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_ERROR;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_ERROR;
#endif

#define XMPP_MESSAGE_EXTEND                     @"ExtendMessage"

#define MESSAGE_ELEMENT_NAME                    @"info"
#define MESSAGE_ELEMENT_XMLNS                   @"aft:message"
#define MESSAGE_SENDER_ELEMENT_NAME             @"sender"

#define MESSAGE_ID_ATTRIBUTE_NAME               @"id"
#define MESSAGE_TYPE_ATTRIBUTE_NAME             @"type"

#define MESSAGE_TIME_ATTRIBUTE_NAME             @"timestamp"
#define MESSAGE_IS_GROUP_CHAT_ATTRIBUTE_NAME    @"groupChat"

#define EXTEND_MESSAGE_TO_USER_ATTRIBUTE_NAME       @"toUser"
#define EXTEND_MESSAGE_FROM_USER_ATTRIBUTE_NAME     @"fromUser"
#define EXTEND_MESSAGE_READ_STATUS_ATTRIBUTE_NAME       @"hasBeenRead"
#define EXTEND_MESSAGE_SEND_STATUS_ATTRIBUTE_NAME       @"sendFromMe"

@implementation XMPPExtendMessageObject

#pragma mark - Public Methods


#pragma mark - class methods
+ (void)initialize {
    // We use the object_setClass method below to dynamically change the class from a standard NSXMLElement.
    // The size of the two classes is expected to be the same.
    //
    // If a developer adds instance methods to this class, bad things happen at runtime that are very hard to debug.
    // This check is here to aid future developers who may make this mistake.
    //
    // For Fearless And Experienced Objective-C Developers:
    // It may be possible to support adding instance variables to this class if you seriously need it.
    // To do so, try realloc'ing self after altering the class, and then initialize your variables.
    
    size_t superSize = class_getInstanceSize([NSXMLElement class]);
    size_t ourSize   = class_getInstanceSize([XMPPExtendMessageObject class]);
    
    if (superSize != ourSize)
    {
        XMPPLogError(@"Adding instance variables to XMPPExtendMessageObject is not currently supported!");
        
        [DDLog flushLog];
        exit(15);
    }
}

+ (XMPPExtendMessageObject *)xmppExtendMessageObject
{
    NSXMLElement *xmppExtendMessageElement = [NSXMLElement elementWithName:XMPP_MESSAGE_EXTEND];
    return [XMPPExtendMessageObject xmppExtendMessageObjectFromElement:xmppExtendMessageElement];
}

+ (XMPPExtendMessageObject *)xmppExtendMessageObjectFromElement:(NSXMLElement *)element
{
    object_setClass(element, [XMPPExtendMessageObject class]);
    return (XMPPExtendMessageObject *)element;
}

+ (XMPPExtendMessageObject *)xmppExtendMessageObjectFromXMPPMessage:(XMPPMessage *)message
{
    XMPPExtendMessageObject *xmppExtendMessageObject = [XMPPExtendMessageObject xmppExtendMessageObject];
    [xmppExtendMessageObject fromXMPPMessage:message];
    return xmppExtendMessageObject;
}

+ (XMPPExtendMessageObject *)xmppExtendMessageObjectCopyFromMessage:(XMPPMessage *)message
{
    return [self xmppExtendMessageObjectFromXMPPMessage:[message copy]];
}

+ (XMPPExtendMessageObject *)xmppExtendMessageObjectWithXMPPMessageCoreDataStorageObject:(XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObject
{
    XMPPExtendMessageObject *object = [XMPPExtendMessageObject xmppExtendMessageObject];
    
    
    return object;
}

- (void)fromXMPPMessageCoreDataStorageObject:(XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObject
{
    [self setFromUser:(xmppMessageCoreDataStorageObject.sendFromMe > 0 ? xmppMessageCoreDataStorageObject.streamBareJidStr: xmppMessageCoreDataStorageObject.bareJidStr)];
    [self setToUser:(xmppMessageCoreDataStorageObject.sendFromMe > 0 ? xmppMessageCoreDataStorageObject.bareJidStr: xmppMessageCoreDataStorageObject.streamBareJidStr)];
    [self setHasBeenRead:(xmppMessageCoreDataStorageObject.hasBeenRead > 0)];
    [self setSendFromMe:(xmppMessageCoreDataStorageObject.sendFromMe > 0)];
    [self setMessageType:[xmppMessageCoreDataStorageObject.messageType unsignedIntegerValue]];
    [self setMessageID:xmppMessageCoreDataStorageObject.messageID];
    [self setIsGroupChat:(xmppMessageCoreDataStorageObject.isGroupChat > 0)];
    [self setMessageTime:<#(NSDate *)#>];
}

#pragma mark - object class method
- (instancetype)init
{
    return [[XMPPExtendMessageObject alloc] initWithType:XMPPExtendMessageTextType];
}

- (instancetype)initWithType:(XMPPExtendMessageType)messageType
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

#pragma mark - Setters and getters

- (NSString *)toUser
{
    return [self attributeStringValueForName:EXTEND_MESSAGE_TO_USER_ATTRIBUTE_NAME];
}

- (void)setToUser:(NSString *)toUser
{
    if (toUser) {
        [self addAttributeWithName:EXTEND_MESSAGE_TO_USER_ATTRIBUTE_NAME stringValue:toUser];
    }
}

- (NSString *)fromUser
{
    return [self attributeStringValueForName:EXTEND_MESSAGE_FROM_USER_ATTRIBUTE_NAME];
}

- (void)setFromUser:(NSString *)fromUser
{
    if (fromUser) {
        [self addAttributeWithName:EXTEND_MESSAGE_FROM_USER_ATTRIBUTE_NAME stringValue:fromUser];
    }
}

- (BOOL)hasBeenRead
{
    return [self attributeBoolValueForName:EXTEND_MESSAGE_READ_STATUS_ATTRIBUTE_NAME];
}

- (void)setHasBeenRead:(BOOL)hasBeenRead
{
    [self addAttributeWithName:EXTEND_MESSAGE_READ_STATUS_ATTRIBUTE_NAME boolValue:hasBeenRead];
}

- (BOOL)sendFromMe
{
    return [self attributeBoolValueForName:EXTEND_MESSAGE_SEND_STATUS_ATTRIBUTE_NAME];
}

- (void)setSendFromMe:(BOOL)sendFromMe
{
    [self addAttributeWithName:EXTEND_MESSAGE_SEND_STATUS_ATTRIBUTE_NAME boolValue:sendFromMe];
}

//The info element
- (NSUInteger)messageType
{
    NSUInteger result = 0;
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    if (infoElement != nil) {
        
        result = [infoElement attributeUnsignedIntegerValueForName:MESSAGE_TYPE_ATTRIBUTE_NAME];
        
    }
    
    return result;
}

- (void)setMessageType:(NSUInteger)messageType
{
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    //If the info element is already existed,wo should add the value to it
    if (infoElement) {
        [infoElement addAttributeWithName:MESSAGE_TYPE_ATTRIBUTE_NAME unsignedIntegerValue:messageType];
        return;
    }
    //Otherwise,we should create a new info element
    infoElement = [NSXMLElement elementWithName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    [infoElement addAttributeWithName:MESSAGE_TYPE_ATTRIBUTE_NAME unsignedIntegerValue:messageType];
    [self addChild:infoElement];
}

- (NSString *)messageID
{
    NSString *result = nil;
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    if (infoElement != nil) {
        
        result = [infoElement attributeStringValueForName:MESSAGE_ID_ATTRIBUTE_NAME];
    }
    
    return result;
}

- (void)setMessageID:(NSString *)messageID
{
    if (messageID) {
        NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        //If the info element is already existed,wo should add the value to it
        if (infoElement) {
            [infoElement addAttributeWithName:MESSAGE_ID_ATTRIBUTE_NAME stringValue:messageID];
            return;
        }
        //Otherwise,we should create a new info element
        infoElement = [NSXMLElement elementWithName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        [infoElement addAttributeWithName:MESSAGE_ID_ATTRIBUTE_NAME stringValue:messageID];
        [self addChild:infoElement];
    }
}

/*
-(NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.messageID)
        [dictionary setObject:self.messageID forKey:@"messageID"];
    if (self.messageTime)
        [dictionary setObject:self.messageTime forKey:@"messageTime"];
    if (self.xmppAdditionalMessageObject)
        [dictionary setObject:[self.xmppAdditionalMessageObject toDictionary] forKey:@"additionMessage"];
    
    [dictionary setObject:[NSNumber numberWithBool:self.isGroupChat] forKey:@"isGroupChat"];
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:self.messageType] forKey:@"messageType"];
    
    return dictionary;
}

-(void)fromDictionary:(NSMutableDictionary*)message
{
    self.messageID = [message objectForKey:@"messageID"];
    self.messageTime = [message objectForKey:@"sendTime"];
    
    self.xmppAdditionalMessageObject = [[XMPPAdditionalMessageObject alloc] initWithDictionary:[message objectForKey:@"additionMessage"] ];
    
    self.isGroupChat = [(NSNumber *)[message objectForKey:@"isGroupChat"] boolValue];
    self.messageType = [(NSNumber *)[message objectForKey:@"messageType"] unsignedIntegerValue];
}
*/
-(XMPPMessage *)toXMPPMessage
{
    NSXMLElement *info = [NSXMLElement elementWithName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    
    //Add the attributes
    if (self.messageID) {
        [info addAttributeWithName:MESSAGE_ID_ATTRIBUTE_NAME stringValue:self.messageID];
    }
    
    if (self.messageType) {
        [info addAttributeWithName:MESSAGE_TYPE_ATTRIBUTE_NAME unsignedIntegerValue:self.messageType];
    }
    
    
    [info addAttributeWithName:MESSAGE_IS_GROUP_CHAT_ATTRIBUTE_NAME boolValue:self.isGroupChat];
    
    //add the sub xml elment
    if (self.isGroupChat) {
        NSXMLElement *sender = [NSXMLElement elementWithName:MESSAGE_SENDER_ELEMENT_NAME stringValue:[[XMPPJID jidWithString:self.toUser] bare]];
        [info addChild:sender];
    }
    
    if (self.xmppAdditionalMessageObject) {
        [info addChild:[self.xmppAdditionalMessageObject toXMLElement]];
    }
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:self.toUser] elementID:nil child:info];
    
    return message;
}
//This method has no Parameter hasBeenRead,sendFromMe...
- (void)fromXMPPMessage:(XMPPMessage *)message
{
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    //If this element is existed,we should remove it brefore
    if (infoElement) {
        [self removeChildAtIndex:[[self children] indexOfObject:infoElement]];
    }
    infoElement = [message elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    [self addChild:infoElement];
    [self setFromUser:message.from.bare];
    [self setToUser:message.to.bare];
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
    self.isGroupChat = xmppMessageCoreDataStorageObject.isGroupChat > 0;
    self.hasBeenRead = [xmppMessageCoreDataStorageObject.hasBeenRead boolValue];
    self.messageType = [xmppMessageCoreDataStorageObject.messageType unsignedIntegerValue];
}
/*
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
        self.isGroupChat = [(NSNumber *)[aDecoder decodeObjectForKey:@"isGroupChat"] boolValue];
        self.hasBeenRead = [(NSNumber *)[aDecoder decodeObjectForKey:@"hasBeenRead"] boolValue];
    }
    return  self;
}

*/
@end
