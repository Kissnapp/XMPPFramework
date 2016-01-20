//
//  XMPPExtendMessage.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/11/27.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPMessage.h"

#define MESSAGE_ELEMENT_NAME                    @"info"
#define MESSAGE_ELEMENT_XMLNS                   @"aft:message"

/**
 *  The type of a message
 */
typedef NS_ENUM(NSUInteger, XMPPExtendSubMessageType){
    /**
     *  The default message is a text message
     */
    XMPPExtendSubMessageTextType = 0,
    /**
     *  a voice message
     */
    XMPPExtendSubMessageAudioType,
    /**
     *  a video file message
     */
    XMPPExtendSubMessageVideoType,
    /**
     *  a picture file message
     */
    XMPPExtendSubMessagePictureType,
    /**
     *  a Positio information message
     */
    XMPPExtendSubMessagePositionType,
    /**
     *  a control message to control the speak
     */
    XMPPExtendSubMessageControlType,
    /**
     *  a request message to request for media chat
     */
    XMPPExtendSubMessageMediaRequestType
};

typedef NS_ENUM(NSInteger, XMPPMessageSendState)
{
    XMPPMessageSendFailed = -1,
    XMPPMessageSending = 0,
    XMPPMessageSendSucceed = 1
};

@class XMPPBaseMessageObject;
@class XMPPMessageCoreDataStorageObject;

@interface XMPPExtendMessage : XMPPMessage


@property (assign, nonatomic) NSUInteger                        msgType;      //The message type
@property (strong, nonatomic) NSString                          *msgId;       //message ID,used to find the appointed message
@property (strong, nonatomic) NSString                          *msgFrom;     //The user id of Who send the message
@property (strong, nonatomic) NSString                          *msgTo;       //The user id of who the message will been send to
@property (strong, nonatomic) NSString                          *msgSender;   //The user in the chat room who sender this message
@property (strong, nonatomic) NSDate                            *msgTime;     //The message send time,this message is a local time

@property (assign, nonatomic) BOOL                              msgBeenRead;      //The mark to  distinguish whether the message has been read
@property (assign, nonatomic) BOOL                              msgIsGroup;      //Mark value 4,Wether is a chat room chat
@property (assign, nonatomic) BOOL                              msgOutgoing;       //Whether the message is send from myself
@property (assign, nonatomic) XMPPMessageSendState              msgSendState;        // Whether the message has been send

@property (strong, nonatomic) id                                msgSubData;


+ (XMPPExtendMessage *)xmppExtendMessage;
+ (XMPPExtendMessage *)xmppExtendMessageFromElement:(NSXMLElement *)element;
+ (XMPPExtendMessage *)xmppExtendMessageFromXMPPMessage:(XMPPMessage *)message;
+ (XMPPExtendMessage *)xmppExtendMessageCopyFromMessage:(XMPPMessage *)message;
+ (XMPPExtendMessage *)xmppExtendMessageWithCoreDataStorageObject:(XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObject;

- (instancetype)init;
- (instancetype)initWithType:(XMPPExtendSubMessageType)messageType;
- (instancetype)initWithXMPPMessage:(XMPPMessage *)message;
- (instancetype)initWithDictionary:(NSMutableDictionary *)dictionary;
- (instancetype)initWithCoreDataStorageObject:(XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObject;


- (instancetype)initWithFrom:(NSString *)from
                          to:(NSString *)to
                        type:(XMPPExtendSubMessageType)type
                        time:(NSDate *)time
                    outgoing:(BOOL)outgoing
                    beenRead:(BOOL)beenRead
                   sendState:(XMPPMessageSendState)sendState
                     isGroup:(BOOL)isGroup
                      sender:(NSString *)sender
                     subData:(id)subData;

- (instancetype)outgoingMsgTo:(NSString *)to
                         type:(XMPPExtendSubMessageType)type
                      isGroup:(BOOL)isGroup
                       sender:(NSString *)sender
                      subData:(id)subData;

- (instancetype)ingoingMsgFrom:(NSString *)from
                          type:(XMPPExtendSubMessageType)type
                   hasBeenRead:(NSInteger)hasBeenRead
                       isGroup:(BOOL)isGroup
                        sender:(NSString *)sender
                          time:(NSDate *)time
                     subObject:(id)subObject;

/**
 *  Create the message id,we must do this before send this message
 */
- (void)createMessageId;

/**
 *  Get the XMPPChatMessageObject from a xml element
 *
 *  @param xmlElement The xml element
 */
- (void)fromXMPPMessage:(XMPPMessage *)message;

//-(void)fromDictionary:(NSMutableDictionary*)message;

- (void)fromXMPPMessageCoreDataStorageObject:(XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObject;


- (NSMutableDictionary *)dictionaryWithActive:(BOOL)active;

@end
