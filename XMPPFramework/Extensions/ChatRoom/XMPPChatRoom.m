//
//  XMPPChatRoom.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/24.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPChatRoom.h"
#import "XMPPIDTracker.h"
#import "XMPPLogging.h"
#import "XMPPFramework.h"
#import "DDList.h"


#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
// Log flags: trace
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

enum XMPPChatRoomConfig
{
    kAutoFetchChatRoom = 1 << 0,                   // If set, we automatically fetch ChatRoom after authentication
    kAutoAcceptKnownPresenceSubscriptionRequests = 1 << 1, // See big description in header file... :D
    kRosterlessOperation = 1 << 2,
    kAutoClearAllChatRoomAndResources = 1 << 3,
};
enum XMPPChatRoomFlags
{
    kRequestedChatRoom = 1 << 0,  // If set, we have requested the ChatRoom
    kHasChatRoom       = 1 << 1,  // If set, we have received the ChatRoom
    kPopulatingChatRoom = 1 << 2,  // If set, we are populating the ChatRoom
};


@implementation XMPPChatRoom

- (id)init
{
    return [self initWithChatRoomStorage:nil dispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    return [self initWithChatRoomStorage:nil dispatchQueue:queue];
}

- (id)initWithChatRoomStorage:(id <XMPPChatRoomStorage>)storage
{
    return [self initWithChatRoomStorage:storage dispatchQueue:NULL];
}

- (id)initWithChatRoomStorage:(id <XMPPChatRoomStorage>)storage dispatchQueue:(dispatch_queue_t)queue
{
    NSParameterAssert(storage != nil);
    
    if ((self = [super initWithDispatchQueue:queue]))
    {
        if ([storage configureWithParent:self queue:moduleQueue])
        {
            xmppChatRoomStorage = storage;
        }
        else
        {
            XMPPLogError(@"%@: %@ - Unable to configure storage!", THIS_FILE, THIS_METHOD);
        }
        
        config = kAutoFetchChatRoom | kAutoAcceptKnownPresenceSubscriptionRequests | kAutoClearAllChatRoomAndResources;
        flags = 0;
        
        //earlyPresenceElements = [[NSMutableArray alloc] initWithCapacity:2];
        
        //mucModules = [[DDList alloc] init];
    }
    return self;
}

- (BOOL)activate:(XMPPStream *)aXmppStream
{
    XMPPLogTrace();
    
    if ([super activate:aXmppStream])
    {
        XMPPLogVerbose(@"%@: Activated", THIS_FILE);
        
        xmppIDTracker = [[XMPPIDTracker alloc] initWithStream:xmppStream dispatchQueue:moduleQueue];
        
//#ifdef _XMPP_VCARD_AVATAR_MODULE_H
//        {
//            // Automatically tie into the vCard system so we can store user photos.
//            
//            [xmppStream autoAddDelegate:self
//                          delegateQueue:moduleQueue
//                       toModulesOfClass:[XMPPvCardAvatarModule class]];
//        }
//#endif
//        
//#ifdef _XMPP_MUC_H
//        {
//            // Automatically tie into the MUC system so we can ignore non-roster presence stanzas.
//            
//            [xmppStream enumerateModulesWithBlock:^(XMPPModule *module, NSUInteger idx, BOOL *stop) {
//                
//                if ([module isKindOfClass:[XMPPMUC class]])
//                {
//                    [mucModules add:(__bridge void *)module];
//                }
//            }];
//        }
//#endif
//        
        return YES;
    }
    
    return NO;
}

- (void)deactivate
{
    XMPPLogTrace();
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        [xmppIDTracker removeAllIDs];
        xmppIDTracker = nil;
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
//#ifdef _XMPP_VCARD_AVATAR_MODULE_H
//    {
//        [xmppStream removeAutoDelegate:self delegateQueue:moduleQueue fromModulesOfClass:[XMPPvCardAvatarModule class]];
//    }
//#endif
    
    [super deactivate];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark- Internal
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * This method may optionally be used by XMPPRosterStorage classes (declared in XMPPRosterPrivate.h).
 **/
- (GCDMulticastDelegate *)multicastDelegate
{
    return multicastDelegate;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Configuration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id <XMPPChatRoomStorage>)xmppChatRoomStorage
{
    // Note: The xmppRosterStorage variable is read-only (set in the init method)
    
    return xmppChatRoomStorage;
}

- (BOOL)autoFetchRoster
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = (config & kAutoFetchChatRoom) ? YES : NO;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)setAutoFetchRoster:(BOOL)flag
{
    dispatch_block_t block = ^{
        
        if (flag)
            config |= kAutoFetchChatRoom;
        else
            config &= ~kAutoFetchChatRoom;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (BOOL)autoClearAllUsersAndResources
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = (config & kAutoClearAllChatRoomAndResources) ? YES : NO;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)setAutoClearAllUsersAndResources:(BOOL)flag
{
    dispatch_block_t block = ^{
        
        if (flag)
            config |= kAutoClearAllChatRoomAndResources;
        else
            config &= ~kAutoClearAllChatRoomAndResources;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (BOOL)hasRequestedChatRoomList
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = (flags & kRequestedChatRoom) ? YES : NO;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (BOOL)isPopulating{
    
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = (flags & kPopulatingChatRoom) ? YES : NO;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (BOOL)hasChatRoomList
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = (flags & kHasChatRoom) ? YES : NO;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (BOOL)_requestedChatRoom
{
    NSAssert(dispatch_get_specific(moduleQueueTag) , @"Invoked on incorrect queue");
    
    return (flags & kRequestedChatRoom) ? YES : NO;
}

- (void)_setRequestedChatRoom:(BOOL)flag
{
    NSAssert(dispatch_get_specific(moduleQueueTag) , @"Invoked on incorrect queue");
    
    if (flag)
        flags |= kRequestedChatRoom;
    else
        flags &= ~kRequestedChatRoom;
}

- (BOOL)_hasChatRoom
{
    NSAssert(dispatch_get_specific(moduleQueueTag) , @"Invoked on incorrect queue");
    
    return (flags & kHasChatRoom) ? YES : NO;
}

- (void)_setHasChatRoom:(BOOL)flag
{
    NSAssert(dispatch_get_specific(moduleQueueTag) , @"Invoked on incorrect queue");
    
    if (flag)
        flags |= kHasChatRoom;
    else
        flags &= ~kHasChatRoom;
}

- (BOOL)_populatingChatRoom
{
    NSAssert(dispatch_get_specific(moduleQueueTag) , @"Invoked on incorrect queue");
    
    return (flags & kPopulatingChatRoom) ? YES : NO;
}

- (void)_setPopulatingChatRoom:(BOOL)flag
{
    NSAssert(dispatch_get_specific(moduleQueueTag) , @"Invoked on incorrect queue");
    
    if (flag)
        flags |= kPopulatingChatRoom;
    else
        flags &= ~kPopulatingChatRoom;
}

- (void)fetchChatRoomList
{
    // This is a public method, so it may be invoked on any thread/queue.
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if ([self _requestedChatRoom])
        {
            // We've already requested the roster from the server.
            return;
        }
        
        // <iq type="get">
        //   <query xmlns="jabber:iq:roster"/>
        // </iq>
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:aft_groupchat"];
        [query addAttributeWithName:@"query_type" stringValue:@"aft_get_groups"];
        
        XMPPIQ *iq = [XMPPIQ iqWithType:@"get" elementID:[xmppStream generateUUID]];
        [iq addChild:query];
        
        [xmppIDTracker addElement:iq
                           target:self
                         selector:@selector(handleFetchChatRoomListQueryIQ:withInfo:)
                          timeout:60];
        
        [xmppStream sendElement:iq];
        
        [self _setRequestedChatRoom:YES];
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
/**
 *  transfrom the data to the xmppChatRoomStorage
 *
 *  @param json JSON data
 */
- (void)transFormDataWithJSONStr:(NSString *)json
{
    NSAssert(dispatch_get_specific(moduleQueueTag) , @"Invoked on incorrect queue");
    
    if (!json) {
        return;
    }
    
    //BOOL hasChatRoom = [self hasChatRoomList];
    NSArray *array = [json objectFromJSONString];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *dic = obj;
        
        [xmppChatRoomStorage handleChatRoomDictionary:dic xmppStream:xmppStream];
        //if (hasChatRoom) {
        //    [xmppChatRoomStorage handleChatRoomDictionary:dic xmppStream:xmppStream];
        //}
        
    }];
}

- (void)setNickNameFromStorageWithNickName:(NSString *)nickname withBareJidStr:(NSString *)bareJidStr
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    [xmppChatRoomStorage setNickNameFromStorageWithNickName:nickname withBareJidStr:bareJidStr xmppStream:xmppStream];
    
    [multicastDelegate xmppChatRoom:self didAlterNickName:nickname withBareJidStr:bareJidStr];
}

-(void)transChatRoomUserDataWithJSONStr:(NSString *)json
{
    NSAssert(dispatch_get_specific(moduleQueueTag) , @"Invoked on incorrect queue");
    
    if (!json) {
        return;
    }
    
    NSArray *array = [json objectFromJSONString];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *dic = obj;
        
        [xmppChatRoomStorage handleChatRoomUserDictionary:dic xmppStream:xmppStream];
        
    }];
 
}

- (BOOL)createChatRoomWithNickName:(NSString *)room_nickeName
{
    if (!room_nickeName) {
        return  NO;
    }
    
    dispatch_block_t block=^{
        
        @autoreleasepool{
            
            NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:aft_groupchat"];
            [query addAttributeWithName:@"query_type" stringValue:@"aft_create_group"];
            [query setStringValue:room_nickeName];
            
            XMPPIQ *iq = [XMPPIQ iqWithType:@"set" elementID:[xmppStream generateUUID]];
            [iq addChild:query];
            
            [xmppIDTracker addElement:iq
                               target:self
                             selector:@selector(handleCreateChatRoomIQ:withInfo:)
                              timeout:60];
            
            [xmppStream sendElement:iq];
        
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
    
    return YES;
}

- (BOOL)inviteUser:(NSArray *)userArray joinChatRoom:(NSString *)roomJIDstr
{
    if (!roomJIDstr || [userArray count] <= 0) {
        return  NO;
    }
    
    dispatch_block_t block=^{
        
        @autoreleasepool{
            
            NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:aft_groupchat"];
            [query addAttributeWithName:@"query_type" stringValue:@"aft_add_member"];
            [query addAttributeWithName:@"groupid" stringValue:roomJIDstr];
            
            NSString *jsonStr = [userArray JSONString];
            [query setStringValue:jsonStr];
        
            XMPPIQ *iq = [XMPPIQ iqWithType:@"set" elementID:[xmppStream generateUUID]];
            [iq addChild:query];
            
//            [xmppIDTracker addElement:iq
//                               target:self
//                             selector:@selector(handleCreateChatRoomListIQ:withInfo:)
//                              timeout:60];
            
            [xmppStream sendElement:iq];
            
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
    
    return YES;

}

- (BOOL)inviteUser:(NSArray *)userArray andCreateChatRoomWithNickName:(NSString *)room_nickName
{
    if (!room_nickName || [userArray count] <= 0) {
        return  NO;
    }
    
    dispatch_block_t block=^{
        
        @autoreleasepool{
            
            NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:aft_groupchat"];
            [query addAttributeWithName:@"query_type" stringValue:@"aft_group_member"];
            [query addAttributeWithName:@"nickname" stringValue:room_nickName];
            
            NSString *jsonStr = [userArray JSONString];
            [query setStringValue:jsonStr];
            
            XMPPIQ *iq = [XMPPIQ iqWithType:@"set" elementID:[xmppStream generateUUID]];
            [iq addChild:query];
            
            [xmppIDTracker addElement:iq
                               target:self
                             selector:@selector(handleCreateChatRoomAndInviteUserIQ:withInfo:)
                              timeout:60];
            
            [xmppStream sendElement:iq];
            
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
    
    return YES;
}

- (void)setNickName:(NSString *)nickName forBareJidStr:(NSString *)bareJidStr
{
    if (!nickName || !bareJidStr) return;
    
    dispatch_block_t block=^{
        
        @autoreleasepool{
            
//            NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:aft_groupchat"];
//            [query addAttributeWithName:@"query_type" stringValue:@"aft_group_member"];
//            [query addAttributeWithName:@"nickname" stringValue:room_nickName];
//            
//            NSString *jsonStr = [userArray JSONString];
//            [query setStringValue:jsonStr];
//            
//            XMPPIQ *iq = [XMPPIQ iqWithType:@"set" elementID:[xmppStream generateUUID]];
//            [iq addChild:query];
//            
//            [xmppIDTracker addElement:iq
//                               target:self
//                             selector:@selector(handleCreateChatRoomAndInviteUserIQ:withInfo:)
//                              timeout:60];
//            
//            [xmppStream sendElement:iq];
            
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPIDTracker
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)handleFetchChatRoomListQueryIQ:(XMPPIQ *)iq withInfo:(XMPPBasicTrackingInfo *)basicTrackingInfo{
    
//    <iq to="jid" id="2115763" type="result">
//    <query xmlns="jabber:iq:aft_groupchat" query_type="aft_get_groups">
//    [{"jid": "100001","nickname": "First"},{"jid": "100002","nickname": "Second"}]
//    </query>
//    </iq>
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        NSXMLElement *query = [iq elementForName:@"query" xmlns:@"jabber:iq:aft_groupchat"];
        NSString *jsonStr = [query stringValue];
        
        BOOL hasChatRoom = [self hasChatRoomList];
        
        if (!hasChatRoom){
            [xmppChatRoomStorage clearAllChatRoomsForXMPPStream:xmppStream];
            [self _setPopulatingChatRoom:YES];
            [multicastDelegate xmppChatRoomDidBeginPopulating:self];
            [xmppChatRoomStorage beginChatRoomPopulationForXMPPStream:xmppStream];
        }
        
        //TODO:Save all the chat room list here
        [self transFormDataWithJSONStr:jsonStr];
        
        if (!hasChatRoom){
            // We should have our ChatRoom now
            
            [self _setHasChatRoom:YES];
            [self _setPopulatingChatRoom:NO];
            [multicastDelegate xmppChatRoomDidEndPopulating:self];
            [xmppChatRoomStorage endChatRoomPopulationForXMPPStream:xmppStream];
            
            // Process any premature presence elements we received.
        }
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
    
}

- (void)handleCreateChatRoomIQ:(XMPPIQ *)iq withInfo:(XMPPBasicTrackingInfo *)basicTrackingInfo{
    /*
    <iq to='juliet@example.com/balcony' type='result' id='112233'>
    <query xmlns="jabber:iq:aft_groupchat" groupid="1000000000003"/>
    </iq>
     <iq to='juliet@example.com/balcony' type='result' id='112233'>
     <query xmlns="jabber:iq:aft_groupchat" groupid="1000000000003" ,name = "nickname" ,master="1234567@192.168.1.100" action="add"/>
     </iq>
     */
    dispatch_block_t block = ^{
        @autoreleasepool {
            //if there is a error attribute
            if ([[iq attributeStringValueForName:@"type"] isEqualToString:@"error"]) {
                [multicastDelegate xmppChatRoom:self didCreateChatRoomError:iq];
                return ;
            }
            
            //if this action have succeed
            if ([[iq type] isEqualToString:@"result"]) {
                //find the query elment
                NSXMLElement *query = [iq elementForName:@"query" xmlns:@"jabber:iq:aft_groupchat"];
            
                if (query) {
                    //init a XMPPChatRoomCoreDataStorageObject to restore the info
                    NSString *roomID = [query attributeStringValueForName:@"groupid"];
                    NSString *roomNickName = [query stringValue];
                    NSDictionary *tempDictionary = @{
                                                     @"jid":roomID,
                                                     @"nickname":roomNickName
                                                     };
                    NSArray *tempArray = @[tempDictionary];
                    
                    NSString *jsonStr = [tempArray JSONString];
                    
                    if (roomID) {
                        //TODO:Here need save the room info into the database
                        [self transFormDataWithJSONStr:jsonStr];
                        [multicastDelegate xmppChatRoom:self didCreateChatRoomID:roomID roomNickName:roomNickName];
                    }
                }
                
            }
            
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)handleCreateChatRoomAndInviteUserIQ:(XMPPIQ *)iq withInfo:(XMPPBasicTrackingInfo *)basicTrackingInfo{
    /*
     <iq from="cc4bc427-eeaa-41eb-84a7-f713c0205a9f@192.168.1.167/caoyue-PC" type="result" id="aad5a">
        <query xmlns="jabber:iq:aft_groupchat" groupid="10000001" query_type="aft_group_member">
            nickname
        </query>
     </iq>
     */
    dispatch_block_t block = ^{
        @autoreleasepool {
            //if there is a error attribute
            if ([[iq attributeStringValueForName:@"type"] isEqualToString:@"error"]) {
                [multicastDelegate xmppChatRoom:self didCreateChatRoomError:iq];
                return ;
            }
            
            //if this action have succeed
            if ([[iq type] isEqualToString:@"result"]) {
                //find the query elment
                NSXMLElement *query = [iq elementForName:@"query" xmlns:@"jabber:iq:aft_groupchat"];
                
                if (query) {
                    //init a XMPPChatRoomCoreDataStorageObject to restore the info
                    NSString *roomID = [query attributeStringValueForName:@"groupid"];
                    NSString *roomNickName = [query attributeStringValueForName:@"nickname"];
                    NSDictionary *tempDictionary = @{
                                                     @"jid":roomID,
                                                     @"nickname":roomNickName
                                                     };
                    NSArray *tempArray = @[tempDictionary];
                    
                    NSString *jsonStr = [tempArray JSONString];
                    
                    if (roomID) {
                        //TODO:Here need save the room info into the database
                        [self transFormDataWithJSONStr:jsonStr];
                        [multicastDelegate xmppChatRoom:self didCreateChatRoomID:roomID roomNickName:roomNickName];
                    }
                }
                
            }
            
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)handleAlterChatRoomNickNameIQ:(XMPPIQ *)iq withInfo:(XMPPBasicTrackingInfo *)basicTrackingInfo{
    /*
     <iq from="cc4bc427-eeaa-41eb-84a7-f713c0205a9f@192.168.1.167/caoyue-PC" type="result" id="aad5a">
     <query xmlns="jabber:iq:aft_groupchat" groupid="10000001" query_type="aft_group_member">
     nickname
     </query>
     </iq>
     */
    dispatch_block_t block = ^{
        @autoreleasepool {
            //if there is a error attribute
            if ([[iq attributeStringValueForName:@"type"] isEqualToString:@"error"]) {
                [multicastDelegate xmppChatRoom:self didCreateChatRoomError:iq];
                return ;
            }
            
            //if this action have succeed
            if ([[iq type] isEqualToString:@"result"]) {
                //find the query elment
                NSXMLElement *query = [iq elementForName:@"query" xmlns:@"jabber:iq:aft_groupchat"];
                
                if (query) {
                    //init a XMPPChatRoomCoreDataStorageObject to restore the info
                    NSString *roomID = [query attributeStringValueForName:@"groupid"];
                    NSString *roomNickName = [query attributeStringValueForName:@"nickname"];
                    NSDictionary *tempDictionary = @{
                                                     @"jid":roomID,
                                                     @"nickname":roomNickName
                                                     };
                    NSArray *tempArray = @[tempDictionary];
                    
                    NSString *jsonStr = [tempArray JSONString];
                    
                    if (roomID) {
                        //TODO:Here need save the room info into the database
                        [self transFormDataWithJSONStr:jsonStr];
                        [multicastDelegate xmppChatRoom:self didCreateChatRoomID:roomID roomNickName:roomNickName];
                    }
                }
                
            }
            
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark- XMPPStreamDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    // This method is invoked on the moduleQueue.
    
    XMPPLogTrace();
    
    if ([self autoFetchChatRoomList])
    {
        [self fetchChatRoomList];
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    // This method is invoked on the moduleQueue.
    
    XMPPLogTrace();
    
    // Note: Some jabber servers send an iq element with an xmlns.
    // Because of the bug in Apple's NSXML (documented in our elementForName method),
    // it is important we specify the xmlns for the query.
    
    NSXMLElement *query = [iq elementForName:@"query" xmlns:@"jabber:iq:aft_groupchat"];
    
    if (query){
        if([iq isSetIQ]){
            
            [multicastDelegate xmppChatRoom:self didReceiveChatRoomPush:iq];
            
        }else if([iq isResultIQ]){
            [xmppIDTracker invokeForElement:iq withObject:iq];
        }
        
        return YES;
    }
    
    return NO;
}


- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    // This method is invoked on the moduleQueue.
    
    XMPPLogTrace();
    
    if([self autoClearAllChatRoomsAndResources]){
        [xmppChatRoomStorage clearAllChatRoomsForXMPPStream:xmppStream];
    }
    
    [self _setRequestedChatRoom:NO];
    [self _setHasChatRoom:NO];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    // This method is invoked on the moduleQueue.
    /*
     <message from='aftgroup_groupid@only.test.com' " "id='jid' type='groupchat' xml:lang='en' push="true">
     <body>hell</body>
     </message>
     */
    
    XMPPLogTrace();
    
    // Is this a message we need to store (a chat message)?
    //
    // A message to all recipients MUST be of type groupchat.
    // A message to an individual recipient would have a <body/>.
    
    NSXMLElement *bodyElement = [message bodyElementFromChatRoomPushMessage];
    
    //This is a chart room push message
    if (bodyElement){
        //TODO:... Handle other types of messages.
        //FIXME:fix the code here ...
        //MARK:mark the code here ...
        //???:what's this?
        //!!!!:how to do this here?
        NSString *chatRoomID = [bodyElement attributeStringValueForName:@"groupid"];
        NSString *chatRoomNickName = [bodyElement attributeStringValueForName:@"nickname"];
        NSString *jsonStr = [bodyElement stringValue];
        
        if (chatRoomID && chatRoomNickName) {
            NSDictionary *dic = @{
                                  @"jid":chatRoomID,
                                  @"nickname":chatRoomNickName
                                  };
            [xmppChatRoomStorage InsertOrUpdateChatRoomWith:dic xmppStream:xmppStream];
        }
        
        if (jsonStr) {
            //FIXME:To restore or delete the user info from the coradata system
        }
        
        [multicastDelegate xmppChatRoom:self didReceiveSeiverPush:message];
    }
}

@end
