//
//  XMPPChatRoom.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/24.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"
#import "JSONKit.h"
#import "XMPPChatRoomCoreDataStorageObject.h"
#import "XMPPMessage+ChatRoomMessage.h"


#define _XMPP_CHAT_ROOM_H

@class XMPPIDTracker;
@protocol XMPPChatRoomStorage;
@protocol XMPPChatRoomDelegate;

@interface XMPPChatRoom : XMPPModule
{/*	Inherited from XMPPModule:
  
  XMPPStream *xmppStream;
  
  dispatch_queue_t moduleQueue;
  id multicastDelegate;
  */
    __strong id <XMPPChatRoomStorage> xmppChatRoomStorage;
    
    XMPPIDTracker *xmppIDTracker;
    
    Byte config;
    Byte flags;
}

- (id)initWithChatRoomStorage:(id <XMPPChatRoomStorage>)storage;
- (id)initWithChatRoomStorage:(id <XMPPChatRoomStorage>)storage dispatchQueue:(dispatch_queue_t)queue;

/* Inherited from XMPPModule:
 
 - (BOOL)activate:(XMPPStream *)xmppStream;
 - (void)deactivate;
 
 @property (readonly) XMPPStream *xmppStream;
 
 - (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
 - (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
 - (void)removeDelegate:(id)delegate;
 
 - (NSString *)moduleName;
 
 */

@property (strong, readonly) id <XMPPChatRoomStorage> xmppChatRoomStorage;

/**
 * Whether or not to automatically fetch the Chat room list from the server.
 *
 * The default value is YES.
 **/
@property (assign) BOOL autoFetchChatRoomList;

/**
 * Whether or not to automatically clear all ChatRooms and Resources when the stream disconnects.
 * If you are using XMPPChatRoomCoreDataStorage you may want to set autoRemovePreviousDatabaseFile to NO.
 *
 * All ChatRooms and Resources will be cleared when the roster is next populated regardless of this property.
 *
 * The default value is YES.
 **/
@property (assign) BOOL autoClearAllChatRoomsAndResources;

@property (assign, getter = hasRequestedChatRoomList, readonly) BOOL requestedChatRoomList;

@property (assign, getter = isPopulating, readonly) BOOL populating;


@property (assign, readonly) BOOL hasChatRoomList;

/**
 *  fetch all the chat room list
 */
- (void)fetchChatRoomList;
/**
 *  create room with a nick name
 *
 *  @param room_nickeName the nick name of the room which  will been created
 *
 *  @return YES:if succeed,
 *           NO:other cases
 */
- (BOOL)createChatRoomWithNickName:(NSString *)room_nickeName;
/**
 *  invite other users to join the chat room
 *
 *  @param userArray user information array，Contains user‘JID mainly
 *          The Array should been a list of jid string array,such as
 *              ["123","456","789",...]
 *  @param roomJID   the chat room jid
 *
 *  @return YES,if succeed
 *           NO,other cases
 */
- (BOOL)inviteUser:(NSArray *)userArray joinChatRoom:(NSString *)roomJIDStr;
/**
 *  Create a room and invite some user join it
 *
 *  @param userArray     user jid string array
 *  @param room_nickName the nickname of the room you want to create
 *
 *  @return YES,if action finished
 *          NO,Other cases
 */
- (BOOL)inviteUser:(NSArray *)userArray andCreateChatRoomWithNickName:(NSString *)room_nickName;
/**
 *  Set the nickname for name
 *
 *  @param nickName     chat room nickname
 *  @param bareJidStr   The chat room's bare jid string
 */
- (void)setNickName:(NSString *)nickName forBareJidStr:(NSString *)bareJidStr;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol XMPPChatRoomStorage <NSObject>

@required

- (BOOL)configureWithParent:(id)aParent queue:(dispatch_queue_t)queue;
- (void)beginChatRoomPopulationForXMPPStream:(XMPPStream *)stream;
- (void)endChatRoomPopulationForXMPPStream:(XMPPStream *)stream;

- (void)handleChatRoomDictionary:(NSDictionary *)dictionary xmppStream:(XMPPStream *)stream;
- (void)handlePresence:(XMPPPresence *)presence xmppStream:(XMPPStream *)stream;

- (BOOL)chatRoomExistsWithID:(NSString *)id xmppStream:(XMPPStream *)stream;

- (void)clearAllChatRoomsForXMPPStream:(XMPPStream *)stream;

- (NSArray *)idsForXMPPStream:(XMPPStream *)stream;

- (void)InsertOrUpdateChatRoomWith:(NSDictionary *)dic xmppStream:(XMPPStream *)stream;

- (void)setNickNameFromStorageWithNickName:(NSString *)nickname withBareJidStr:(NSString *)bareJidStr  xmppStream:(XMPPStream *)stream;

@optional


#if TARGET_OS_IPHONE
- (void)setPhoto:(UIImage *)photo forChatRoomWithID:(NSString *)id xmppStream:(XMPPStream *)stream;
#else
- (void)setPhoto:(NSImage *)photo forChatRoomWithID:(NSString *)id xmppStream:(XMPPStream *)stream;
#endif

- (void)handleChatRoomUserDictionary:(NSDictionary *)dictionary xmppStream:(XMPPStream *)stream;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol XMPPChatRoomDelegate <NSObject>

@required

@optional

- (void)xmppChatRoom:(XMPPChatRoom *)sender didCreateChatRoomID:(NSString *)roomID roomNickName:(NSString *)nickname;
- (void)xmppChatRoom:(XMPPChatRoom *)sender didCreateChatRoomError:(NSXMLElement *)errorElement;

/**
 * Sent when a Roster Push is received as specified in Section 2.1.6 of RFC 6121.
 **/
- (void)xmppChatRoom:(XMPPChatRoom *)sender didReceiveChatRoomPush:(XMPPIQ *)iq;

- (void)xmppChatRoom:(XMPPChatRoom *)sender didReceiveSeiverPush:(XMPPMessage *)message;

/**
 * Sent when the initial roster is received.
 **/
- (void)xmppChatRoomDidBeginPopulating:(XMPPChatRoom *)sender;

/**
 * Sent when the initial roster has been populated into storage.
 **/
- (void)xmppChatRoomDidEndPopulating:(XMPPChatRoom *)sender;

/**
 * Sent when the roster receives a roster item.
 *
 * Example:
 *
 * <item jid='romeo@example.net' name='Romeo' subscription='both'>
 *   <group>Friends</group>
 * </item>
 **/
- (void)xmppChatRoom:(XMPPChatRoom *)sender didReceiveChatRoomItem:(NSXMLElement *)item;
- (void)xmppChatRoom:(XMPPChatRoom *)sender didAlterNickName:(NSString *)newNickName withBareJidStr:(NSString *)bareJidStr;


@end

