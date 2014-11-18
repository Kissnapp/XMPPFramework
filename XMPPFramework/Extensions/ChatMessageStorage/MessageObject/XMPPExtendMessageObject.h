//
//  XMPPChatMessage.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/8.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXML.h"
#import "XMPPMessage.h"
#import "XMPPBaseMessageObject.h"
#import "XMPPAdditionalCoreDataMessageObject.h"
#import "XMPPMessageCoreDataStorageObject.h"

#import "XMPPAudioMessageObject.h"
#import "XMPPTextMessageObject.h"
/**
 *  The type of a message
 */
typedef NS_ENUM(NSUInteger, XMPPExtendMessageType){
    /**
     *  The default message is a text message
     */
    XMPPExtendMessageTextType = 0,
    /**
     *  a voice message
     */
    XMPPExtendMessageAudioType,
    /**
     *  a video file message
     */
    XMPPExtendMessageVideoType,
    /**
     *  a picture file message
     */
    XMPPExtendMessagePictureType,
    /**
     *  a Positio information message
     */
    XMPPExtendMessagePositionType,
    /**
     *  a control message to control the speak
     */
    XMPPExtendMessageControlType,
    /**
     *  a request message to request for media chat
     */
    XMPPExtendMessageMediaRequestType
};


@interface XMPPExtendMessageObject : XMPPBaseMessageObject

@property (assign, nonatomic) NSUInteger                        messageType;      //The message type
@property (strong, nonatomic) NSString                          *messageID;       //message ID,used to find the appointed message
@property (strong, nonatomic) NSString                          *fromUser;        //The user id of Who send the message
@property (strong, nonatomic) NSString                          *toUser;          //The user id of who the message will been send to
@property (strong, nonatomic) NSDate                            *messageTime;     //The message send time,this message is a local time
//@property (assign, nonatomic) BOOL                              isPrivate;      //The mark to  distinguish the message whether is a private message
@property (assign, nonatomic) BOOL                              hasBeenRead;      //The mark to  distinguish whether the message has been read
@property (assign, nonatomic) BOOL                              isGroupChat; //Mark value 4,Wether is a chat room chat
@property (assign, nonatomic) BOOL                              sendFromMe;       //Whether the message is send from myself
@property (strong, nonatomic) NSString                          *sender;          //The user in the chat room who sender this message

@property (strong, nonatomic) XMPPTextMessageObject             *text;            //The text object which has all the text info
@property (strong, nonatomic) XMPPAudioMessageObject            *audio;           //The audio object which has all the audio info


+ (XMPPExtendMessageObject *)xmppExtendMessageObject;

/**
 *  When we using this method the messageID has been setted and the sendFromMe has been setted to YES,
 *
 *  @return Message Object
 */
- (instancetype)init;
/**
 *  init a message obejct with the type you needed
 *
 *  @param messageType The type of the message
 *
 *  @return The message object
 */
- (instancetype)initWithType:(XMPPExtendMessageType)messageType;
/**
 *  Init method
 *  Please be careful here,because we will don't have the fromUser,toUser,sendFromMe,hasBeenRead
 *
 *  @param dictionary The information dictionary
 *
 *  @return The message object
 */
-(instancetype)initWithDictionary:(NSMutableDictionary *)dictionary;
/**
 *  This the main method we will use to create a XMPPChatMessageObject object ,Plesase this method mainly
 *
 *  @param xmppMessageCoreDataStorageObject The object fethched from the coredata
 *
 *  @return The Message Object
 */
-(instancetype)initWithXMPPMessageCoreDataStorageObject:(XMPPMessageCoreDataStorageObject *)xmppMessageCoreDataStorageObject;
/**
 *  Create a XMPPChatMessageObject object with the XMPPMessage object,
 *
 *  @param message     The XMPPMessage object
 *  @param sendFromMe  sendFromMe
 *  @param hasBeenRead hasBeenRead
 *
 *  @return The Message object
 */
-(instancetype)initWithXMPPMessage:(XMPPMessage *)message  sendFromMe:(BOOL)sendFromMe hasBeenRead:(BOOL)hasBeenRead;

/**
 *  Create the message id,we must do this before send this message
 */
-(void)createMessageID;
/**
 *  Transform the Message object into a Dictionary Object
 *
 *  @return A message dictionary
 */
-(NSMutableDictionary *)toDictionary;
/**
 *  Get the message object from the Dictionary which contains the whole info of the message
 *
 *  @param message The message object
 */
-(void)fromDictionary:(NSMutableDictionary*)message;
/**
 *  Get a XMPPMessage from the XMPPChatMessageObject
 *
 *  @return The XMPPMessage element we will get
 */
-(XMPPMessage *)toXMPPMessage;
/**
 *  Get the XMPPChatMessageObject from a xml element
 *
 *  @param xmlElement The xml element
 */
-(void)fromXMPPMessage:(XMPPMessage *)message;

@end
