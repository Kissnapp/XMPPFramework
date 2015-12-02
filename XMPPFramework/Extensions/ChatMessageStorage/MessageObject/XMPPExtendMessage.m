//
//  XMPPExtendMessage.m
//  XMPP_Project
//
//  Created by Peter Lee on 15/11/27.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPExtendMessage.h"
#import "XMPPLogging.h"
#import <objc/runtime.h>
#import "NSString+NSDate.h"
#import "NSDate+NSString.h"
#import "XMPPMessageCoreDataStorageObject.h"
#import "XMPPBaseMessageObject.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_ERROR;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_ERROR;
#endif

#define MESSAGE_SENDER_ELEMENT_NAME             @"sender"

#define MESSAGE_ID_ATTRIBUTE_NAME               @"id"
#define MESSAGE_TYPE_ATTRIBUTE_NAME             @"type"

#define MESSAGE_TIME_ATTRIBUTE_NAME             @"timestamp"
#define MESSAGE_IS_GROUP_CHAT_ATTRIBUTE_NAME    @"groupChat"
#define MESSAGE_OUTGOING_ATTRIBUTE_NAME         @"outgoing"

#define EXTEND_MESSAGE_TO_USER_ATTRIBUTE_NAME       @"to"
#define EXTEND_MESSAGE_FROM_USER_ATTRIBUTE_NAME     @"from"
#define EXTEND_MESSAGE_READ_STATUS_ATTRIBUTE_NAME   @"beenRead"
#define EXTEND_MESSAGE_SEND_STATE_ATTRIBUTE_NAME    @"sendState"

@interface XMPPExtendMessage ()
{
}
@end

@implementation XMPPExtendMessage

#pragma mark - tools methods
-(void)createMessageId
{
    self.msgId = [self UUIDString];
    self.msgOutgoing = YES;
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

#pragma mark - class methods
+ (XMPPExtendMessage *)xmppExtendMessage
{
    NSXMLElement *messageElement = [XMPPMessage messageWithType:@"chat"];
    return [XMPPExtendMessage xmppExtendMessageFromElement:messageElement];
}

+ (XMPPExtendMessage *)xmppExtendMessageFromElement:(NSXMLElement *)element
{
    object_setClass(element, [XMPPExtendMessage class]);
    return (XMPPExtendMessage *)element;
}

+ (XMPPExtendMessage *)xmppExtendMessageFromXMPPMessage:(XMPPMessage *)message
{
    XMPPExtendMessage *xmppExtendMessage = [XMPPExtendMessage xmppExtendMessage];
    
    [xmppExtendMessage fromXMPPMessage:message];
    
    return xmppExtendMessage;
}

+ (XMPPExtendMessage *)xmppExtendMessageCopyFromMessage:(XMPPMessage *)message
{
    return [self xmppExtendMessageFromXMPPMessage:[message copy]];
}

+ (XMPPExtendMessage *)xmppExtendMessageWithCoreDataStorageObject:(XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObject
{
    XMPPExtendMessage *object = [XMPPExtendMessage xmppExtendMessage];
    
    [object fromXMPPMessageCoreDataStorageObject:xmppMessageCoreDataStorageObject];
    
    return object;
}

#pragma mark - object init methods

- (instancetype)init
{
    return [[XMPPExtendMessage alloc] initWithType:XMPPExtendSubMessageTextType];
}
- (instancetype)initWithType:(XMPPExtendSubMessageType)messageType
{
    self = [XMPPExtendMessage xmppExtendMessage];
    
    if (self) {
        [self createMessageId];
        [self setMsgType:messageType];
    }
    
    return self;
}
- (instancetype)initWithXMPPMessage:(XMPPMessage *)message
{
    self = [XMPPExtendMessage xmppExtendMessage];
    
    if (self) {
        [self fromXMPPMessage:message];
    }
    
    return self;
}
- (instancetype)initWithDictionary:(NSMutableDictionary *)dictionary
{
    self = [XMPPExtendMessage xmppExtendMessage];
    
    if (self) {
        [self fromDictionary:dictionary];
    }
    
    return self;
}
- (instancetype)initWithCoreDataStorageObject:(XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObject
{
    self = [XMPPExtendMessage xmppExtendMessage];
    
    if (self) {
        [self fromXMPPMessageCoreDataStorageObject:xmppMessageCoreDataStorageObject];
    }
    
    return self;
}


- (instancetype)initWithFrom:(NSString *)from
                          to:(NSString *)to
                        type:(XMPPExtendSubMessageType)type
                        time:(NSDate *)time
                    outgoing:(BOOL)outgoing
                    beenRead:(BOOL)beenRead
                   sendState:(XMPPMessageSendState)sendState
                     isGroup:(BOOL)isGroup
                      sender:(NSString *)sender
                     subData:(id)subData
{
    self = [XMPPExtendMessage xmppExtendMessage];
    
    if (self) {
        [self createMessageId];
        self.msgFrom = from;
        self.msgTo = to;
        self.msgType = type;
        self.msgTime = time;
        self.msgOutgoing = outgoing;
        self.msgBeenRead = beenRead;
        self.msgSendState = sendState;
        self.msgIsGroup = isGroup;
        self.msgSender = sender;
        self.msgSubData = subData;
    }
    
    return self;
}

- (instancetype)outgoingMsgTo:(NSString *)to
                         type:(XMPPExtendSubMessageType)type
                      isGroup:(BOOL)isGroup
                       sender:(NSString *)sender
                      subData:(id)subData
{

    return [self initWithFrom:nil
                           to:to
                         type:type
                         time:[NSDate date]
                     outgoing:YES
                     beenRead:YES
                    sendState:XMPPMessageSending
                      isGroup:isGroup
                       sender:sender
                      subData:subData];
}

- (instancetype)ingoingMsgFrom:(NSString *)from
                          type:(XMPPExtendSubMessageType)type
                   hasBeenRead:(NSInteger)hasBeenRead
                       isGroup:(BOOL)isGroup
                        sender:(NSString *)sender
                          time:(NSDate *)time
                     subObject:(id)subObject
{
    return [self initWithFrom:from
                           to:nil
                         type:type
                         time:time
                     outgoing:NO
                     beenRead:hasBeenRead
                    sendState:XMPPMessageSendSucceed
                      isGroup:isGroup
                       sender:sender
                      subData:subObject];
}

- (NSMutableDictionary *)dictionaryWithActive:(BOOL)active
{
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[[self infoElementWithCreate:NO] attributesAsDictionary]];
    
    for (NSString *key in [[self attributesAsDictionary] allKeys]) {
        dictionary[key] = [self attributesAsDictionary][key];
    }
    
    dictionary[@"unReadMessageCount"] = self.msgOutgoing ? @(0):@(!active);
    
    return dictionary;
}

-(void)fromDictionary:(NSMutableDictionary*)message
{

}

- (void)fromXMPPMessage:(XMPPMessage *)message
{
    XMPPExtendMessage *copyExtendMessage = [XMPPExtendMessage xmppExtendMessageFromElement:message];
    
    self.msgType = copyExtendMessage.msgType;
    self.msgId = copyExtendMessage.msgId;
    self.msgFrom = copyExtendMessage.msgFrom;
    self.msgTo = copyExtendMessage.msgTo;
    self.msgSender = copyExtendMessage.msgSender;
    self.msgTime = copyExtendMessage.msgTime;
    
    self.msgBeenRead = copyExtendMessage.msgBeenRead;
    self.msgIsGroup = copyExtendMessage.msgIsGroup;
    self.msgOutgoing = copyExtendMessage.msgOutgoing;
    self.msgSendState = copyExtendMessage.msgSendState;
    
    self.msgSubData = copyExtendMessage.msgSubData;
}


- (void)fromXMPPMessageCoreDataStorageObject:(XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObject
{
    self.msgOutgoing = [xmppMessageCoreDataStorageObject.outgoing boolValue];
    self.msgId = xmppMessageCoreDataStorageObject.msgId;
    self.msgType = [xmppMessageCoreDataStorageObject.msgType integerValue];
    self.msgFrom = self.msgOutgoing ? xmppMessageCoreDataStorageObject.streamBareJidStr:xmppMessageCoreDataStorageObject.bareJidStr;
    self.msgTo = self.msgOutgoing ? xmppMessageCoreDataStorageObject.bareJidStr:xmppMessageCoreDataStorageObject.streamBareJidStr;
    self.msgTime = xmppMessageCoreDataStorageObject.msgTime;
    self.msgBeenRead = self.msgOutgoing ? YES:[xmppMessageCoreDataStorageObject.beenRead boolValue];
    self.msgSendState = self.msgOutgoing ? [xmppMessageCoreDataStorageObject.sendState integerValue] : XMPPMessageSendSucceed;
    self.msgIsGroup = [xmppMessageCoreDataStorageObject.isGroup boolValue];
    self.msgSender = xmppMessageCoreDataStorageObject.sender;
    self.msgSubData = xmppMessageCoreDataStorageObject.subData;
}

#pragma mark - create and get the info element 

- (NSXMLElement *)infoElementWithCreate:(BOOL)create
{
    NSXMLElement *infoElement = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
    
    if (create && !infoElement) {
        
        infoElement = [NSXMLElement elementWithName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS];
        [self addChild:infoElement];
    }
    
    return infoElement;
}


#pragma mark - Attributes mthods


//The info element
- (NSUInteger)msgType
{
    NSUInteger result = 0;
    
    NSXMLElement *infoElement = [self infoElementWithCreate:NO];
    
    if (infoElement != nil) {
        
        result = [infoElement attributeUnsignedIntegerValueForName:MESSAGE_TYPE_ATTRIBUTE_NAME];
        
    }
    
    return result;
}

- (void)setMsgType:(NSUInteger)msgType
{
    [[self infoElementWithCreate:YES] addAttributeWithName:MESSAGE_TYPE_ATTRIBUTE_NAME unsignedIntegerValue:msgType];
}


- (NSString *)msgId
{
    NSString *result = nil;
    
    NSXMLElement *infoElement = [self infoElementWithCreate:NO];
    
    if (infoElement != nil) {
        
        result = [infoElement attributeStringValueForName:MESSAGE_ID_ATTRIBUTE_NAME];
    }
    
    return result;
}

- (void)setMsgId:(NSString *)msgId
{
    if (msgId) {
        
        NSXMLElement *infoElement = [self infoElementWithCreate:YES];
        [infoElement addAttributeWithName:MESSAGE_ID_ATTRIBUTE_NAME stringValue:msgId];
        
    }
}

- (NSString *)msgFrom
{
    return [[self from] bare];
}

- (void)setMsgFrom:(NSString *)msgFrom
{
    if (msgFrom) {
        [self addAttributeWithName:EXTEND_MESSAGE_FROM_USER_ATTRIBUTE_NAME stringValue:msgFrom];
    }
}

- (NSString *)msgTo
{
    return [[self to] bare];
}

- (void)setMsgTo:(NSString *)msgTo
{
    if (msgTo) {
        [self addAttributeWithName:EXTEND_MESSAGE_TO_USER_ATTRIBUTE_NAME stringValue:msgTo];
    }
}


- (NSString *)msgSender
{
    NSString *result = nil;
    
    NSXMLElement *infoElement = [self infoElementWithCreate:NO];
    
    if (infoElement != nil) {
        
        result = [[infoElement elementForName:MESSAGE_SENDER_ELEMENT_NAME] stringValue];
    }
    
    return result;
}

- (void)setMsgSender:(NSString *)msgSender
{
    if (msgSender) {
        
        NSXMLElement *infoElement = [self infoElementWithCreate:YES];
        
        NSXMLElement *senderElement = [infoElement elementForName:MESSAGE_SENDER_ELEMENT_NAME];
        
        // 删除之前的senderElement
        if (senderElement) {
            [infoElement removeChildAtIndex:[[infoElement children] indexOfObject:senderElement]];
        }
        
        // 添加现在的senderElement
        senderElement = [NSXMLElement elementWithName:MESSAGE_SENDER_ELEMENT_NAME];
        [senderElement setStringValue:msgSender];
        
        [infoElement addChild:senderElement];
    }
}


- (NSDate *)msgTime
{
    NSDate *result = nil;
    
    NSXMLElement *infoElement = [self infoElementWithCreate:NO];
    
    if (infoElement != nil) {
        
        result = [[infoElement attributeStringValueForName:MESSAGE_TIME_ATTRIBUTE_NAME] UTCStringToLocalDate];//UTCStringToLocalDate
    }
    
    return result;
}

//The messageTime must been a local time
- (void)setMsgTime:(NSDate *)msgTime
{
    if (msgTime) {
        
        NSXMLElement *infoElement = [self infoElementWithCreate:YES];
        [infoElement addAttributeWithName:MESSAGE_TIME_ATTRIBUTE_NAME stringValue:[msgTime LocalDateToUTCString]];
    }
}

- (BOOL)msgBeenRead
{
    
    BOOL result = YES;
    
    NSXMLElement *infoElement = [self infoElementWithCreate:NO];
    
    if (infoElement != nil) {
        
        result = [infoElement attributeBoolValueForName:EXTEND_MESSAGE_READ_STATUS_ATTRIBUTE_NAME];
    }
    
    return result;
}

- (void)setMsgBeenRead:(BOOL)msgBeenRead
{
    NSXMLElement *infoElement = [self infoElementWithCreate:YES];
    [infoElement addAttributeWithName:EXTEND_MESSAGE_READ_STATUS_ATTRIBUTE_NAME boolValue:msgBeenRead];
}

- (BOOL)msgIsGroup
{
    BOOL result = NO;
    
    NSXMLElement *infoElement = [self infoElementWithCreate:NO];
    
    if (infoElement != nil) {
        result = [infoElement attributeBoolValueForName:MESSAGE_IS_GROUP_CHAT_ATTRIBUTE_NAME];
    }
    
    return result;
}

- (void)setMsgIsGroup:(BOOL)msgIsGroup
{
    NSXMLElement *infoElement = [self infoElementWithCreate:YES];
    [infoElement addAttributeWithName:MESSAGE_IS_GROUP_CHAT_ATTRIBUTE_NAME boolValue:msgIsGroup];
}


- (BOOL)msgOutgoing
{
    BOOL result = NO;
    
    NSXMLElement *infoElement = [self infoElementWithCreate:NO];
    
    if (infoElement != nil) {
        result = [infoElement attributeBoolValueForName:MESSAGE_OUTGOING_ATTRIBUTE_NAME];
    }
    
    return result;
}

- (void)setMsgOutgoing:(BOOL)msgOutgoing
{
    NSXMLElement *infoElement = [self infoElementWithCreate:YES];
    [infoElement addAttributeWithName:MESSAGE_OUTGOING_ATTRIBUTE_NAME boolValue:msgOutgoing];
}

- (XMPPMessageSendState)msgSendState
{
    NSInteger result = XMPPMessageSendSucceed;
    
    NSXMLElement *infoElement = [self infoElementWithCreate:NO];
    
    if (infoElement != nil) {
        result = [infoElement attributeBoolValueForName:EXTEND_MESSAGE_SEND_STATE_ATTRIBUTE_NAME];
    }
    
    return result;
}

- (void)setMsgSendState:(XMPPMessageSendState)msgSendState
{
    NSXMLElement *infoElement = [self infoElementWithCreate:YES];
    [infoElement addAttributeWithName:EXTEND_MESSAGE_SEND_STATE_ATTRIBUTE_NAME integerValue:msgSendState];
}

- (XMPPBaseMessageObject *)msgSubData
{
    XMPPBaseMessageObject *result = nil;
    
    NSXMLElement *infoElement = [self infoElementWithCreate:NO];
    
    if (infoElement != nil) {
        
        NSXMLElement *subDataElement = nil;
        
        for (NSXMLElement *element in [infoElement children]) {
            
            if (![[element name] isEqualToString:MESSAGE_SENDER_ELEMENT_NAME]) {
                
                subDataElement = element;
                
                break;
            }
        }
        
        result = [XMPPBaseMessageObject xmppBaseMessageObjectFromElement:subDataElement];
    }
    
    return [result copy];
}

- (void)setMsgSubData:(XMPPBaseMessageObject *)msgSubData
{
    NSXMLElement *infoElement = [self infoElementWithCreate:YES];
    
    // 删除旧的msgSubData节点
    [infoElement removeElementsForName:[msgSubData name]];
    
    if (msgSubData) {
        // 添加新的
        [infoElement addChild:[msgSubData copy]];
    }
}

#pragma mark - NSCoding methods
- (id)initWithCoder:(NSCoder *)coder
{
    NSString *xmlString;
    if([coder allowsKeyedCoding])
    {
        if([coder respondsToSelector:@selector(requiresSecureCoding)] &&
           [coder requiresSecureCoding])
        {
            xmlString = [coder decodeObjectOfClass:[NSString class] forKey:@"xmlString"];
        }
        else
        {
            xmlString = [coder decodeObjectForKey:@"xmlString"];
        }
    }
    else
    {
        xmlString = [coder decodeObject];
    }
    
    // The method [super initWithXMLString:error:] may return a different self.
    // In other words, it may [self release], and alloc/init/return a new self.
    //
    // So to maintain the proper class (XMPPIQ, XMPPMessage, XMPPPresence, etc)
    // we need to get a reference to the class before invoking super.
    
    Class selfClass = [self class];
    
    if ((self = [super initWithXMLString:xmlString error:nil]))
    {
        object_setClass(self, selfClass);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    NSString *xmlString = [self compactXMLString];
    
    if([coder allowsKeyedCoding])
    {
        [coder encodeObject:xmlString forKey:@"xmlString"];
    }
    else
    {
        [coder encodeObject:xmlString];
    }
}
+ (BOOL)supportsSecureCoding
{
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Copying
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)copyWithZone:(NSZone *)zone
{
    NSXMLElement *elementCopy = [XMPPExtendMessage xmppExtendMessageFromElement:[super copyWithZone:zone]];
    object_setClass(elementCopy, [self class]);
    
    return elementCopy;
}


@end
