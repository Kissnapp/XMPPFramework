//
//  XMPPChatMessage.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/29.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPModule.h"
#import "XMPPMessage.h"
#import "NSXMLElement+XMPP.h"
#import "XMPPMessageCoreDataStorage.h"
#import "XMPPMessageCoreDataStorageObject.h"
/**
 *  When we send a message,we should observer this notice for
 *  distinguishing the message has been send succeed or not
 */
#define SEND_MESSAGE_SUCCEED @"send_message_succeed"   /*When a message has been sent succeed,we will send a this notice to the notification center*/
#define SEND_MESSAGE_FAILED @"send_message_failed"    /*When a message has been sent failed,we will send a this notice to the notification center*/

typedef NS_ENUM(NSUInteger, XMPPMessageType){
    XMPPMessageDefaultType = 0,
    XMPPMessageUserRequestType,
    XMPPMessageSystemPushType
};

@protocol XMPPAllMessageStorage;
@protocol XMPPChatMessageDelegate;


@interface XMPPAllMessage : XMPPModule
{
@protected
    
    __strong id <XMPPAllMessageStorage> xmppMessageStorage;
    NSString *activeUser;
    
@private
    
    BOOL clientSideMessageArchivingOnly;
    BOOL receiveUserRequestMessage;
    BOOL receiveSystemPushMessage;
    NSXMLElement *preferences;
}
/**
 *  Init with the storage
 *
 *  @param storage The storage
 *
 *  @return The new created object
 */
- (id)initWithMessageStorage:(id <XMPPAllMessageStorage>)storage;
/**
 *  Init with the storage and the queue
 *
 *  @param storage The storage
 *  @param queue   The action queue
 *
 *  @return The Created object
 */
- (id)initWithMessageStorage:(id <XMPPAllMessageStorage>)storage dispatchQueue:(dispatch_queue_t)queue;
/**
 *  ADD the active chat user Who is chatting with
 *
 *  @param userBareJidStr The active user base jid string
 *  @param delegate       The delegate
 *  @param delegateQueue  The dekegate queue
 */
- (void)addActiveUser:(NSString *)userBareJidStr Delegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
/**
 *  remove the active user when we close the chat with the active user
 *
 *  @param delegate The delegate
 */
- (void)removeActiveUserAndDelegate:(id)delegate;
/**
 *  Save the message before sending
 *  Notice:When we send a message we should call this method first
 *
 *  @param message The message will been sent
 */
- (void)saveBeforeSendingWithMessage:(XMPPMessage *)message;
/**
 *  Clear the Given user's chat history
 *
 *  @param userJid user JID
 */
- (void)clearChatHistoryWithUserJid:(XMPPJID *)userJid;
/**
 *  read all the unread message,aftering this action,this user will has no unread message
 *
 *  @param userJid user bare jid string
 */
- (void)readAllUnreadMessageWithUserJid:(XMPPJID *)userJid;
/**
 *  read a message with its messageID
 *
 *  @param messageID The given messageID
 */
- (void)readMessageWithMessageID:(NSString *)messageID;
/**
 *  Delete a message object with given message id
 *
 *  @param messageID The given message ID
 */
- (void)deleteMessageWithMessageID:(NSString *)messageID;
/**
 *  Update The message 's sending status
 *
 *  @param messageID The given message id
 */
- (void)updateMessageSendStatusWithMessageID:(NSString *)messageID;
/**
 *  Set a message's hasBeenRead status into YES;
 *
 *  @param message The given message object
 */
- (void)readMessageWithMessage:(XMPPMessageCoreDataStorageObject *)message;
/**
 *  Delete a message with the message object
 *
 *  @param message The given message object
 */
- (void)deleteMessageWithMessage:(XMPPMessageCoreDataStorageObject *)message;
/**
 *  Update a message with given message object
 *
 *  @param message The given object
 */
- (void)updateMessageSendStatusWithMessage:(XMPPMessageCoreDataStorageObject *)message;
/**
 *  Get the last chat message with the given user bare jid string
 *
 *  @param bareJidStr the given user bare jid string
 *
 *  @return The message object
 */
- (XMPPMessageCoreDataStorageObject *)lastMessageWithBareJidStr:(NSString *)bareJidStr;
/**
 *  Fetch a lot of messages with given user bare jid string,the fetch size and the fetch offset
 *
 *  @param bareJidStr  The given user bare jid str
 *  @param fetchSize   The message count we will fetch
 *  @param fetchOffset The beginnig oppsion we want to fetch
 *  @param isPrivate   Whether Fetch the private message
 *
 *  @return A array which contains the fetch result
 */
- (NSArray *)fetchMessagesWithBareJidStr:(NSString *)bareJidStr fetchSize:(NSInteger)fetchSize fetchOffset:(NSInteger)fetchOffset;

@property (readonly, strong) id <XMPPAllMessageStorage> xmppMessageStorage;

@property (readwrite, assign) BOOL clientSideMessageArchivingOnly;
@property (readwrite, assign) BOOL receiveUserRequestMessage;
@property (readwrite, assign) BOOL receiveSystemPushMessage;

@property (nonatomic, strong) NSString *activeUser;

@property (readwrite, copy) NSXMLElement *preferences;

@end


//XMPPChatMessageStorage
@protocol XMPPAllMessageStorage <NSObject>

@required

- (BOOL)configureWithParent:(XMPPAllMessage *)aParent queue:(dispatch_queue_t)queue;
- (void)archiveMessage:(XMPPMessage *)message sendFromMe:(BOOL)sendFromMe activeUser:(NSString *)activeUser xmppStream:(XMPPStream *)stream;
- (void)readAllUnreadMessageWithBareUserJid:(NSString *)bareUserJid xmppStream:(XMPPStream *)xmppStream;
- (void)clearChatHistoryWithBareUserJid:(NSString *)bareUserJid xmppStream:(XMPPStream *)xmppStream;

@optional

- (void)readMessageWithMessageID:(NSString *)messageID xmppStream:(XMPPStream *)xmppStream;
- (void)readMessageWithMessage:(XMPPMessageCoreDataStorageObject *)message xmppStream:(XMPPStream *)xmppStream;

- (void)deleteMessageWithMessageID:(NSString *)messageID xmppStream:(XMPPStream *)xmppStream;
- (void)deleteMessageWithMessage:(XMPPMessageCoreDataStorageObject *)message xmppStream:(XMPPStream *)xmppStream;

- (void)updateMessageSendStatusWithMessageID:(NSString *)messageID success:(BOOL)success xmppStream:(XMPPStream *)xmppStream;
- (void)updateMessageSendStatusWithMessage:(XMPPMessageCoreDataStorageObject *)message success:(BOOL)success xmppStream:(XMPPStream *)xmppStream;
- (id)lastMessageWithBareJidStr:(NSString *)bareJidStr xmppStream:(XMPPStream *)xmppStream;
- (NSArray *)fetchMessagesWithBareJidStr:(NSString *)bareJidStr fetchSize:(NSInteger)fetchSize fetchOffset:(NSInteger)fetchOffset isPrivate:(BOOL)isPrivate xmppStream:(XMPPStream *)xmppStream;
@end


//XMPPChatMessageDelegate
@protocol XMPPAllMessageDelegate <NSObject>

@required

@optional
- (void)xmppAllMessage:(XMPPAllMessage *)xmppAllMessage receiveMessage:(XMPPMessage *)message;
- (void)xmppAllMessage:(XMPPAllMessage *)xmppAllMessage willSendMessage:(XMPPMessage *)message;

@end

