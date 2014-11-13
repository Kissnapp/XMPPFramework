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

#define GROUP_INFO_PUSH @"groupinfo"
#define GROUP_MEMBER_PUSH @"groupmember"
#define GROUP_PUSH_XMLNS @"aft:groupchat"

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

enum XMPPChatRoomUserListFlags
{
    requestedChatRoomUserList = 1 << 0,  // If set, we have requested the ChatRoom user list
    hasChatRoomList       = 1 << 1,  // If set, we have received the ChatRoom user list
    populatingChatRoomUserList = 1 << 2,  // If set, we are populating the ChatRoom user list
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

#pragma mark - Private Methods

- (void)downloadChatRoomInfoWith:(NSString *)bareChatRoomJidStr
{
    NSAssert(dispatch_get_specific(moduleQueueTag) , @"Invoked on incorrect queue");
    
    if (!bareChatRoomJidStr) return;
    
    //we send the request xml as below:
    /*
     <iq type="get" id="aad5ba">
        <query xmlns="aft:groupchat" query_type="get_groupinfo" groupid="1"></query>
     </iq>
     */
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"aft:groupchat"];
    [query addAttributeWithName:@"query_type" stringValue:@"get_groupinfo"];
    [query addAttributeWithName:@"groupid" stringValue:bareChatRoomJidStr];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" elementID:[xmppStream generateUUID]];
    [iq addChild:query];
    
    [xmppIDTracker addElement:iq
                       target:self
                     selector:@selector(handleSingleChatRoomInfoIQ:withInfo:)
                      timeout:60];
    
    [xmppStream sendElement:iq];
    
    [self _setRequestedChatRoom:YES];

}

- (void)downloadUserListFromServerWithBareChatRoomJidStr:(NSString *)bareChatRoomJidStr
{
    // This is a private method, so it may be invoked on any thread/queue.
     NSAssert(dispatch_get_specific(moduleQueueTag) , @"Invoked on incorrect queue");
    
    if (!bareChatRoomJidStr) return;
    
    //we send the request xml as below:
    /*
     <iq from="1341234578@localhost/caoyue-PC" id="aad5a" type="get">
     <query xmlns="aft:groupchat" query_type="get_members" groupid="1"/>
     </iq>
     */
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"aft:groupchat"];
    [query addAttributeWithName:@"query_type" stringValue:@"get_members"];
    [query addAttributeWithName:@"groupid" stringValue:bareChatRoomJidStr];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" elementID:[xmppStream generateUUID]];
    [iq addChild:query];
    
    [xmppIDTracker addElement:iq
                       target:self
                     selector:@selector(handleFetchChatRoomUserListQueryIQ:withInfo:)
                      timeout:60];
    
    [xmppStream sendElement:iq];
    
    [self _setRequestedChatRoom:YES];

}


#pragma mark - Public methods
- (void)fetchChatRoomInfoFromServerWithBareChatRoomJidStr:(NSString *)bareChatRoomJidStr
{
    if ( !bareChatRoomJidStr ) return;
    
    dispatch_block_t block = ^{
        
        
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (XMPPChatRoomCoreDataStorageObject *)chatRoomWithBareJidStr:(NSString *)bareJidStr
{
    __block XMPPChatRoomCoreDataStorageObject *result = nil;
    
    dispatch_block_t block = ^{
        
        result = [xmppChatRoomStorage chatRoomWithBareJidStr:bareJidStr xmppStream:xmppStream];
        
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
    
}
- (XMPPChatRoomUserCoreDataStorageObject *)userInfoFromChatRoom:(NSString *)bareChatRoomJidStr withBareJidStr:(NSString *)bareJidStr
{
    __block XMPPChatRoomUserCoreDataStorageObject *result = nil;
    
    dispatch_block_t block = ^{
        
        result = [xmppChatRoomStorage userInfoFromChatRoom:bareChatRoomJidStr withBareJidStr:bareJidStr xmppStream:xmppStream];
        
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}
- (NSArray *)fetchChatRoomListFromLocal
{
    __block NSArray *results = nil;
    
    dispatch_block_t block = ^{
        
        results = [xmppChatRoomStorage chatRoomListWithXMPPStream:xmppStream];
        
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return results;
}
- (void)setSelfNickNameForBareChatRoomJidStr:(NSString *)bareChatRoomJidStr withNickName:(NSString *)newNickName
{
    dispatch_block_t block = ^{
        //The resquest xml as below
        /*
         <iq from="13412345678@localhost/caoyue-PC" type="set" id="aad5a">
         <query xmlns="aft:groupchat" query_type="set_nickname" groupid="1" nickname=”testnick”></query>
         </iq>
         */
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"aft:groupchat"];
        [query addAttributeWithName:@"query_type" stringValue:@"set_nickname"];
        [query addAttributeWithName:@"groupid" stringValue:bareChatRoomJidStr];
        [query addAttributeWithName:@"groupname" stringValue:newNickName];
        
        XMPPIQ *iq = [XMPPIQ iqWithType:@"set" elementID:[xmppStream generateUUID]];
        [iq addChild:query];
        
        [xmppIDTracker addElement:iq
                           target:self
                         selector:@selector(handleAlterSelfNickNameIQ:withInfo:)
                          timeout:60];
        
        [xmppStream sendElement:iq];
        
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (BOOL)isUserWithBareJidStr:(NSString *)bareJidStr aMemberOfChatRoom:(NSString *)bareChatRoomJidStr
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = [xmppChatRoomStorage isUserWithBareJidStr:bareJidStr aMemberOfChatRoom:bareChatRoomJidStr xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}
- (BOOL)isSelfAMemberOfChatRoomWithBareJidStr:(NSString *)chatRoomBareJidStr
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = [xmppChatRoomStorage isMemberOfChatRoomWithBareJidStr:chatRoomBareJidStr xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)exitFromChatRoomWithBareJidStr:(NSString *)chatRoomBareJidStr
{
    if (![self isSelfAMemberOfChatRoomWithBareJidStr:chatRoomBareJidStr]) {
        return;
    }
    
    dispatch_block_t block = ^{
        //exit from a chat room
        //The delete resquest xml as below
        /*
         <iq from="13412345678@localhost/caoyue-PC" type="set" id="aad5a">
            <query xmlns="aft:groupchat" query_type="remove_members" groupid="1">
                [“13412345678@localhost”]
            </query>
         </iq>
         */
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"aft:groupchat"];
        [query addAttributeWithName:@"query_type" stringValue:@"remove_members"];
        [query addAttributeWithName:@"groupid" stringValue:chatRoomBareJidStr];
        
        NSString *bareJidStr = [[xmppStream myJID] bare];
        NSArray *array = [NSArray arrayWithObjects:bareJidStr, nil];
        NSString *jsonStr = [array JSONString];
        
        [query setStringValue:jsonStr];
        
        XMPPIQ *iq = [XMPPIQ iqWithType:@"set" elementID:[xmppStream generateUUID]];
        [iq addChild:query];
        
        [xmppIDTracker addElement:iq
                           target:self
                         selector:@selector(handleExitChatRoomIQ:withInfo:)
                          timeout:60];
        
        [xmppStream sendElement:iq];
        
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);

}

- (BOOL)isMasterForBareChatRoomJidStr:(NSString *)bareChatRoomJidStr
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = [xmppChatRoomStorage isMasterForBareChatRoomJidStr:bareChatRoomJidStr xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;

}

- (void)deleteChatRoomWithBareChatRoomJidStr:(NSString *)bareChatRoomJidStr
{
    if (![self isMasterForBareChatRoomJidStr:bareChatRoomJidStr]) {
        return;
    }
    
    dispatch_block_t block = ^{
        //Delete the chat room
        //TODO:1.send a delete request xml to the server 2.wait for the server's respsone 3.accord to the server's respone we do delete action in the coredata
        //The delete resquest xml as below
        /*
         <iq from="1341234578@localhost" type="result" to="1341234578@localhost/caoyue-PC" id="aad5a">
            <query xmlns="aft:groupchat" query_type="dismiss_group" groupid=”1”>
            </query>
         </iq>
         */
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"aft:groupchat"];
        [query addAttributeWithName:@"query_type" stringValue:@"dismiss_group"];
        [query addAttributeWithName:@"groupid" stringValue:bareChatRoomJidStr];
        
        XMPPIQ *iq = [XMPPIQ iqWithType:@"set" elementID:[xmppStream generateUUID]];
        [iq addChild:query];
        
        [xmppIDTracker addElement:iq
                           target:self
                         selector:@selector(handleDeleteChatRoomIQ:withInfo:)
                          timeout:60];
        
        [xmppStream sendElement:iq];

        [multicastDelegate xmppChatRoom:self willDeleteChatRoomWithBareJidStr:bareChatRoomJidStr];
        
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)fetchChatRoomListFromServer
{
    // This is a public method, so it may be invoked on any thread/queue.
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if ([self _requestedChatRoom])
        {
            // We've already requested the roster from the server.
            return;
        }
        
        /*//we send the request xml as below:
         <iq from="1341234578@localhost/caoyue-PC" id="aad5a" type="get">
         <query xmlns="aft:groupchat" query_type="get_groups"/>
         </iq>
         */
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"aft:groupchat"];
        [query addAttributeWithName:@"query_type" stringValue:@"get_groups"];
        
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

- (void)fetchChatRoomFromServerWithBareChatRoomJidStr:(NSString *)bareChatRoomJidStr
{
    dispatch_block_t block = ^{ @autoreleasepool {
        
        [self downloadChatRoomInfoWith:bareChatRoomJidStr];
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);

}

- (void)transFormDataAndFetchUseListWithArray:(NSArray *)array
{
    NSAssert(dispatch_get_specific(moduleQueueTag) , @"Invoked on incorrect queue");
    
    if (!array) return;
    
    //BOOL hasChatRoom = [self hasChatRoomList];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *dic = obj;
        
        [xmppChatRoomStorage handleChatRoomDictionary:dic xmppStream:xmppStream];
        
        //If the autoFetchChatRoomUserList == YES,we should fetch the user list
        if ([self autoFetchChatRoomUserList]) {
            [self fetchUserListFromServerWithBareChatRoomJidStr:[[dic objectForKey:@"groupid"] copy]];
        }
        
    }];

}
/**
 *  transfrom the array to the xmppChatRoomStorage
 *
 *  @param array The info array
 */
- (void)transFormDataWithArray:(NSArray *)array
{
    NSAssert(dispatch_get_specific(moduleQueueTag) , @"Invoked on incorrect queue");
    
    if (!array) return;
    
    //BOOL hasChatRoom = [self hasChatRoomList];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *dic = obj;
        
        [xmppChatRoomStorage handleChatRoomDictionary:dic xmppStream:xmppStream];
        
    }];
}

- (void)setNickNameFromStorageWithNickName:(NSString *)nickname withBareJidStr:(NSString *)bareJidStr
{
    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    [xmppChatRoomStorage setNickNameFromStorageWithNickName:nickname withBareJidStr:bareJidStr xmppStream:xmppStream];
    
    [multicastDelegate xmppChatRoom:self didAlterNickName:nickname withBareJidStr:bareJidStr];
}

- (void)transFromDeleteChatRoomUserDataWithArray:(NSArray *)array
{
    NSAssert(dispatch_get_specific(moduleQueueTag) , @"Invoked on incorrect queue");
    if (!array) return;
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *dic = obj;
        
        [xmppChatRoomStorage deleteUserWithBareJidStr:[dic objectForKey:@"bareJidStr"]
                   fromChatRoomWithBareChatRoomJidStr:[dic objectForKey:@"RoomBareJidStr"]
                                           xmppStream:xmppStream];
    }];
}

- (void)transChatRoomUserDataWithArray:(NSArray *)array
{
    NSAssert(dispatch_get_specific(moduleQueueTag) , @"Invoked on incorrect queue");
    
    if (!array) return;
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *dic = obj;
        
        [xmppChatRoomStorage handleChatRoomUserDictionary:dic xmppStream:xmppStream];
        
    }];
 
}

- (void)transChatRoomUserDataWithJsonStr:(NSString *)jsonStr
{
    NSAssert(dispatch_get_specific(moduleQueueTag) , @"Invoked on incorrect queue");
    
    if (!jsonStr) return;
    
    NSArray *tempArray = [jsonStr objectFromJSONString];
    
    if (![tempArray count] <= 0) return;
    
    [tempArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
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
            /*
             <iq from="13412345678@localhost/caoyue-PC" type="set" id="aad5a">
             <query xmlns="aft:groupchat" query_type="create_group" groupname="FirstGroup"></query>
             </iq>
             */
            NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"aft:groupchat"];
            [query addAttributeWithName:@"query_type" stringValue:@"create_group"];
            [query addAttributeWithName:@"groupname" stringValue:room_nickeName ];
            
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
    /*
     <iq from="13412345678@localhost/caoyue-PC" id="aad5a" type="set">
        <query xmlns="aft:groupchat" groupid="3" query_type="add_member">
            ["13411111111@localhost","13422222222@localhost"]
        </query>
     </iq>
     */
    if (!roomJIDstr || [userArray count] <= 0) {
        return  NO;
    }
    
    dispatch_block_t block=^{
        
        @autoreleasepool{
            
            NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"aft:groupchat"];
            [query addAttributeWithName:@"query_type" stringValue:@"add_member"];
            [query addAttributeWithName:@"groupid" stringValue:roomJIDstr];
            
            NSString *jsonStr = [userArray JSONString];
            [query setStringValue:jsonStr];
        
            XMPPIQ *iq = [XMPPIQ iqWithType:@"set" elementID:[xmppStream generateUUID]];
            [iq addChild:query];
            
            [xmppIDTracker addElement:iq
                               target:self
                             selector:@selector(handleInviteFriendIQ:withInfo:)
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

- (void)joinChatRoomWithBareJidStr:(NSString *)bareJidStr
{
    NSArray *bareJidStrArray = [NSArray arrayWithObjects:[[xmppStream myJID] bare], nil];
    
    if ([bareJidStrArray count] <= 0) {
        return;
    }
    
    [self inviteUser:bareJidStrArray joinChatRoom:bareJidStr];
}

- (BOOL)inviteUser:(NSArray *)userArray andCreateChatRoomWithNickName:(NSString *)room_nickName
{
    if (!room_nickName || [userArray count] <= 0) {
        return  NO;
    }
    
    dispatch_block_t block=^{
        
        @autoreleasepool{
            //we will this xml request to the server to create a chat room and invite some user join it
            /*
             <iq from="13412345678@localhost/caoyue-PC" id="2115763" type="set">
                <query xmlns="aft:groupchat" query_type="group_member" groupname="FirstGroup">
                    ["13411111111@localhost","13422222222@localhost"]
                </query>
             </iq>
             */
            
            NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"aft:groupchat"];
            [query addAttributeWithName:@"query_type" stringValue:@"group_member"];
            [query addAttributeWithName:@"groupname" stringValue:room_nickName];
            
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

- (void)setChatRoomNickName:(NSString *)nickName forBareChatRoomJidStr:(NSString *)bareChatRoomJidStr
{
    if (!nickName || !bareChatRoomJidStr) return;
    
    dispatch_block_t block=^{
        
        @autoreleasepool{
            /*
             <iq from="13412345678@localhost/caoyue-PC" type="set" id="aad5a">
                <query xmlns="aft:groupchat" query_type="set_groupname" groupid="1" groupname="FirstGroup">
                </query>
             </iq>
             */

            
            NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"aft:groupchat"];
            [query addAttributeWithName:@"query_type" stringValue:@"set_groupname"];
            [query addAttributeWithName:@"groupid" stringValue:bareChatRoomJidStr];
            [query addAttributeWithName:@"groupname" stringValue:nickName];
            
            XMPPIQ *iq = [XMPPIQ iqWithType:@"set" elementID:[xmppStream generateUUID]];
            [iq addChild:query];
            
            [xmppIDTracker addElement:iq
                               target:self
                             selector:@selector(handleAlterChatRoomNickNameIQ:withInfo:)
                              timeout:60];
            
            [xmppStream sendElement:iq];
            
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
//MARK:Here
- (void)fetchUserListFromServerWithBareChatRoomJidStr:(NSString *)bareChatRoomJidStr
{
    // This is a public method, so it may be invoked on any thread/queue.
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        [self downloadUserListFromServerWithBareChatRoomJidStr:bareChatRoomJidStr];
        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);

}

- (void)DeleteUserWithBareJidStrArray:(NSArray  *)bareJidStrArray fromChatRoomWithBareJidStr:(NSString *)bareChatRoomJidStr
{
   /*
    <iq from="13412345678@localhost/caoyue-PC" type="set" id="aad5a">
        <query xmlns="aft:groupchat" query_type="remove_members" groupid="1">
            [“13411111111@localhost”,”13422222222@localhost”]
        </query>
    </iq>
    */
    
    if ([bareJidStrArray count] <= 0 || !bareChatRoomJidStr) {
        return;
    }
    
    if (![self isMasterForBareChatRoomJidStr:bareChatRoomJidStr]) {
        return;
    }
    
    dispatch_block_t block=^{
        
        @autoreleasepool{
            
            NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"aft:groupchat"];
            [query addAttributeWithName:@"query_type" stringValue:@"remove_members"];
            [query addAttributeWithName:@"groupid" stringValue:bareChatRoomJidStr];
            
            NSString *jsonStr = [[bareJidStrArray JSONString] copy];
            [query setStringValue:jsonStr];
            
            XMPPIQ *iq = [XMPPIQ iqWithType:@"set" elementID:[xmppStream generateUUID]];
            [iq addChild:query];
            
            [xmppIDTracker addElement:iq
                               target:self
                             selector:@selector(handleDeleteUserFromChatRoomIQ:withInfo:)
                              timeout:60];
            
            [xmppStream sendElement:iq];
            
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
    
}

- (NSArray *)fetchUserListFromLocalWithBareChatRoomJidStr:(NSString *)bareChatRoomJidStr requestFromServerIfNotExist:(BOOL)requestFromServer
{
    if (!bareChatRoomJidStr) return nil;
    
    __block NSArray *userListArray = nil;
    
    dispatch_block_t block=^{
        
        @autoreleasepool{
            
            userListArray = [xmppChatRoomStorage userListForChatRoomWithBareJidStr:bareChatRoomJidStr xmppStream:xmppStream];
            
            if (requestFromServer) {//If we want to request a info from the server when the chat room user list is not exist in local
                if (!userListArray || [userListArray count] <= 0) {//If there is no data in the laocal,we should request from the server
                    [self fetchUserListFromServerWithBareChatRoomJidStr:bareChatRoomJidStr];
                }
            }
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return userListArray;
}

- (BOOL)existChatRoomWithBareJidStr:(NSString *)bareJidStr
{
    if (!bareJidStr) return NO;
    
    __block BOOL result = NO;
    
    dispatch_block_t block=^{
        
        result = [xmppChatRoomStorage existChatRoomWithBareJidStr:bareJidStr xmppStream:xmppStream];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPIDTracker
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)handleSingleChatRoomInfoIQ:(XMPPIQ *)iq withInfo:(XMPPBasicTrackingInfo *)basicTrackingInfo
{
    /*
    <iq type="result" id="aad5ba">
        <query xmlns="aft:groupchat" query_type="get_groupinfo" groupid="1">
            {"groupid":"2","groupname":"FirstGroup","master":"13412345678@localhost"}
        </query>
    </iq>
     */
    
    dispatch_block_t block = ^{ @autoreleasepool {
        //if there is a error attribute
        if ([[iq attributeStringValueForName:@"type"] isEqualToString:@"error"]) {
            [multicastDelegate xmppChatRoom:self didInviteFriendError:iq];
            return ;
        }
        
        //if this action have succeed
        if ([[iq type] isEqualToString:@"result"]) {
            //find the query elment
            NSXMLElement *query = [iq elementForName:@"query" xmlns:@"aft:groupchat"];
            
            if (query && [[query attributeStringValueForName:@"query_type"] isEqualToString:@"get_groupinfo"])
            {
                NSDictionary *tempDictionary = [[query stringValue] objectFromJSONString];
                NSArray *array = [NSArray arrayWithObjects:tempDictionary, nil];
                
                if ([array count] > 0) {
                    [self transFormDataWithArray:array];
                }
            }
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)handleDeleteUserFromChatRoomIQ:(XMPPIQ *)iq withInfo:(XMPPBasicTrackingInfo *)basicTrackingInfo
{
    /*
     <iq from="1341234578@localhost" type="result" to="1341234578@localhost/caoyue-PC" id="aad5a">
        <query xmlns="aft:groupchat" query_type="remove_members" groupid=”1”>
            [“13411111111@localhost”,”13422222222@localhost”]</query>
        </iq>
     */
    
    dispatch_block_t block = ^{ @autoreleasepool {
        //if there is a error attribute
        if ([[iq attributeStringValueForName:@"type"] isEqualToString:@"error"]) {
            [multicastDelegate xmppChatRoom:self didDeleteChatRoomError:iq];
            return ;
        }
        
        //if this action have succeed
        if ([[iq type] isEqualToString:@"result"]) {
            //find the query elment
            NSXMLElement *query = [iq elementForName:@"query" xmlns:@"aft:groupchat"];
            
            if (query && [[query attributeStringValueForName:@"query_type"] isEqualToString:@"remove_members"])
            {
                NSString *groupid = [query attributeStringValueForName:@"groupid"];
                NSArray *tempArray = [[query stringValue] objectFromJSONString];
                NSMutableArray *array = [NSMutableArray array];
                [tempArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString *bareJidStr = obj;
                    NSDictionary *dic = @{
                                          @"bareJidStr":bareJidStr,
                                          @"RoomBareJidStr":groupid
                                          };
                    [array addObject:dic];
                }];

                //Transfor the room user list info
                if ([array count] > 0) {
                    [self transFromDeleteChatRoomUserDataWithArray:array];
                }
            }
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)handleAlterSelfNickNameIQ:(XMPPIQ *)iq withInfo:(XMPPBasicTrackingInfo *)basicTrackingInfo
{
    /*
     <iq to="13412345678@localhost/caoyue-PC" type="result" id="aad5a">
        <query xmlns="aft:groupchat" query_type="set_nickname" groupid="1" groupname=”testnick”>
        </query>
     </iq>
     */
    dispatch_block_t block = ^{ @autoreleasepool {
        //if there is a error attribute
        if ([[iq attributeStringValueForName:@"type"] isEqualToString:@"error"]) {
            [multicastDelegate xmppChatRoom:self didDeleteChatRoomError:iq];
            return ;
        }
        
        //if this action have succeed
        if ([[iq type] isEqualToString:@"result"]) {
            //find the query elment
            NSXMLElement *query = [iq elementForName:@"query" xmlns:@"aft:groupchat"];
            
            if (query && [[query attributeStringValueForName:@"query_type"] isEqualToString:@"set_nickname"])
            {
                NSString *groupid = [query attributeStringValueForName:@"groupid"];
                NSString *nickname = [query attributeStringValueForName:@"groupname"];
                NSString *userid = [[iq to] bare];
                if (!nickname || !userid || !groupid){
                    return;
                }
                NSDictionary *tempDic = @{@"bareJidStr":userid,
                                          @"nicknameStr":nickname,
                                          @"RoomBareJidStr":groupid
                                          };
                NSDictionary* temp1 = [NSDictionary dictionaryWithObjectsAndKeys:userid,@"bareJidStr",nickname, @"nicknameStr",groupid, @"RoomBareJidStr",nil];
                NSArray *array = [NSArray arrayWithObjects:tempDic, nil];

                //Transfor the room user list info
                if ([array count] > 0) {
                    [self transChatRoomUserDataWithArray:array];
                }
            }
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)handleFetchChatRoomUserListQueryIQ:(XMPPIQ *)iq withInfo:(XMPPBasicTrackingInfo *)basicTrackingInfo
{
    /*
     <iq to="jid" id="aad5a" type="result">
        <query xmlns="aft:groupchat" query_type="get_members" groupid="1">
            [{"userjid":"13411111111@localhost","nickname":"张三"},
            {"userjid":"13422222222@localhost","nickname":"李四"}]
        </query>
     </iq>
     */
    dispatch_block_t block = ^{ @autoreleasepool {
        
        NSXMLElement *query = [iq elementForName:@"query" xmlns:@"aft:groupchat"];
        NSArray  *tempArray = [[query stringValue] objectFromJSONString];
        NSString *roomID = [query attributeStringValueForName:@"groupid"];
       
        if ([tempArray count] > 0){
            //clear all the before data
            [xmppChatRoomStorage clearAllUserForBareChatRoomJidStr:roomID xmppStream:xmppStream];
            
            //add new down data
            NSMutableArray *array = [NSMutableArray array];
            
            [tempArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                /*
                 NSString *bareJidStr = [Dic objectForKey:@"bareJidStr"];
                 NSString *roomBareJidStr = [Dic objectForKey:@"RoomBareJidStr"];
                 NSString *nickNameStr = [Dic objectForKey:@"nicknameStr"];
                 NSString *streamBareJidStr = [Dic objectForKey:@"streamBareJidStr"];
                 */
                NSDictionary *tempDic = obj;
                NSDictionary *dic = @{
                                      @"bareJidStr":[tempDic objectForKey:@"userjid"],
                                      @"nicknameStr":[tempDic objectForKey:@"nickname"],
                                      @"RoomBareJidStr":[roomID copy]
                                      };
                [array addObject:dic];
            }];
            
            //Transfor the room user list info
            if ([array count] > 0) {
                [self transChatRoomUserDataWithArray:array];
            }

        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
    
}

- (void)handleExitChatRoomIQ:(XMPPIQ *)iq withInfo:(XMPPBasicTrackingInfo *)basicTrackingInfo
{
    /*
     <iq from="1341234578@localhost" type="result" to="1341234578@localhost/caoyue-PC" id="aad5a">
        <query xmlns="aft:groupchat" query_type="remove_members" groupid=”1”>
            [“13411111111@localhost”,”13422222222@localhost”]
        </query>
     </iq>
     */
    dispatch_block_t block = ^{ @autoreleasepool {
        //if there is a error attribute
        if ([[iq attributeStringValueForName:@"type"] isEqualToString:@"error"]) {
            [multicastDelegate xmppChatRoom:self didDeleteChatRoomError:iq];
            return ;
        }
        
        //if this action have succeed
        if ([[iq type] isEqualToString:@"result"]) {
            //find the query elment
            NSXMLElement *query = [iq elementForName:@"query" xmlns:@"aft:groupchat"];
            
            if (query && [[query attributeStringValueForName:@"query_type"] isEqualToString:@"remove_members"])
            {
                NSString *groupid = [query attributeStringValueForName:@"groupid"];
                [xmppChatRoomStorage deleteChatRoomWithBareJidStr:groupid xmppStream:xmppStream];
            }
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}
- (void)handleInviteFriendIQ:(XMPPIQ *)iq withInfo:(XMPPBasicTrackingInfo *)basicTrackingInfo
{
    /*
     <iq from="13412345678@localhost" type="result" to="13412345678@localhost/caoyue-PC" id="aad5a">
        <query xmlns="aft:groupchat" query_type="add_member" groupid="1">
            [{"userjid":"13411111111@localhost","nickname":"张三"},
             {"userjid":"13411111111@localhost","nickname":"李四"}]
        </query>
     </iq>

     */
    dispatch_block_t block = ^{
        @autoreleasepool {
            //if there is a error attribute
            if ([[iq attributeStringValueForName:@"type"] isEqualToString:@"error"]) {
                [multicastDelegate xmppChatRoom:self didInviteFriendError:iq];
                return ;
            }
            
            //if this action have succeed
            if ([[iq type] isEqualToString:@"result"]) {
                //find the query elment
                NSXMLElement *query = [iq elementForName:@"query" xmlns:@"aft:groupchat"];
                
                NSString *roomID = [query attributeStringValueForName:@"groupid"];
                
                if (query) {
                    
                    //The user list here
                    NSArray *userArray = [[query stringValue] objectFromJSONString];
                    NSMutableArray *array = [NSMutableArray array];
                    [userArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        /*
                         NSString *bareJidStr = [Dic objectForKey:@"bareJidStr"];
                         NSString *roomBareJidStr = [Dic objectForKey:@"RoomBareJidStr"];
                         NSString *nickNameStr = [Dic objectForKey:@"nicknameStr"];
                         NSString *streamBareJidStr = [Dic objectForKey:@"streamBareJidStr"];
                         */
                        NSDictionary *tempDic = obj;
                        NSDictionary *dic = @{
                                              @"bareJidStr":[tempDic objectForKey:@"userjid"],
                                              @"nicknameStr":[tempDic objectForKey:@"nickname"],
                                              @"RoomBareJidStr":[roomID copy]
                                              };
                        [array addObject:dic];
                    }];
                    
                    //Transfor the room user list info
                    if ([array count] > 0) {
                        [self transChatRoomUserDataWithArray:array];
                        [multicastDelegate xmppChatRoom:self didCreateChatRoomID:[roomID copy] roomNickName:nil];
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
- (void)handleDeleteChatRoomIQ:(XMPPIQ *)iq withInfo:(XMPPBasicTrackingInfo *)basicTrackingInfo
{
    /*
     <iq from="1341234578@localhost" type="result" to="1341234578@localhost/caoyue-PC" id="aad5a">
     <query xmlns="aft:groupchat" query_type="dismiss_group" groupid=”1”></query>
     </iq>

     */
    dispatch_block_t block = ^{ @autoreleasepool {
        //if there is a error attribute
        if ([[iq attributeStringValueForName:@"type"] isEqualToString:@"error"]) {
            [multicastDelegate xmppChatRoom:self didDeleteChatRoomError:iq];
            return ;
        }
        
        //if this action have succeed
        if ([[iq type] isEqualToString:@"result"]) {
            //find the query elment
            NSXMLElement *query = [iq elementForName:@"query" xmlns:@"aft:groupchat"];
            
            if (query && [[query attributeStringValueForName:@"query_type"] isEqualToString:@"dismiss_group"])
            {
                NSString *groupid = [query attributeStringValueForName:@"groupid"];
                [xmppChatRoomStorage deleteChatRoomWithBareJidStr:groupid xmppStream:xmppStream];
            }
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)handleFetchChatRoomListQueryIQ:(XMPPIQ *)iq withInfo:(XMPPBasicTrackingInfo *)basicTrackingInfo
{
    //we will
    /*
    <iq from="1341234578@localhost" type="result" to="1341234578@localhost/caoyue-PC" id="aad5a">
     <query xmlns="aft:groupchat" query_type="get_groups">
        [{"groupid": "100001","groupname": "First"，“master“：”123456789@192.168.1.167”},
        {"groupid": "100002","groupname": "Second",“master“：”1234567890@192.168.1.167”}]
     </query>
    </iq>
     */
    dispatch_block_t block = ^{ @autoreleasepool {
        
        NSXMLElement *query = [iq elementForName:@"query" xmlns:@"aft:groupchat"];
        NSString *jsonStr = [query stringValue];
        
        if (!query || !jsonStr) return ;
        
        BOOL hasChatRoom = [self hasChatRoomList];
        
        if (!hasChatRoom){
            [xmppChatRoomStorage clearAllChatRoomsForXMPPStream:xmppStream];
            [self _setPopulatingChatRoom:YES];
            [multicastDelegate xmppChatRoomDidBeginPopulating:self];
            [xmppChatRoomStorage beginChatRoomPopulationForXMPPStream:xmppStream];
        }
        
        //TODO:Save all the chat room list here
        NSArray *array = [jsonStr objectFromJSONString];
        if ([array count] > 0) {
             [self transFormDataAndFetchUseListWithArray:array];
        }
    
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
     <iq from="1341234578@localhost" type="result" to="1341234578@localhost/caoyue-PC" id="aad5a">
        <query xmlns="aft:groupchat" query_type="create_group">
            {"groupid": "100001","groupname": "First","master":"123456789@192.168.1.167"}
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
                NSXMLElement *query = [iq elementForName:@"query" xmlns:@"aft:groupchat"];
            
                if (query && [[query attributeStringValueForName:@"query_type"] isEqualToString:@"create_group"]) {
                    //init a XMPPChatRoomCoreDataStorageObject to restore the info
                    NSDictionary *tempDictionary = [[query stringValue] objectFromJSONString];
                    
                    NSArray *tempArray = @[tempDictionary];

                    /*
                    NSDictionary *dic = [[query stringValue] objectFromJSONString];
                    NSString *roomID = [dic objectForKey:@"groupid"];
                    NSString *roomNickName = [dic objectForKey:@"groupname"];
                    NSString *roomMaster = [dic objectForKey:@"master"];
                    NSDictionary *tempDictionary = @{
                                                     @"jid":roomID,
                                                     @"nickname":roomNickName,
                                                     @"master":roomMaster
                                                     };
                    NSArray *tempArray = @[tempDictionary];
                    
                    NSString *jsonStr = [tempArray JSONString];
                    */
                    if ([tempArray count] > 0) {
                        //TODO:Here need save the room info into the database
                        [self transFormDataWithArray:tempArray];
                        [multicastDelegate xmppChatRoom:self didCreateChatRoomID:[[tempDictionary objectForKey:@"groupid"] copy] roomNickName:[[tempDictionary objectForKey:@"groupname"] copy]];
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
     <iq from="13412345678@localhost" type="result" to="13412345678@localhost/caoyue-PC" id="2115763">
        <query xmlns="aft:groupchat" query_type="group_member" groupid="1" groupname="FirstGroup" master="12345678@120.140.80.54">
            [{"userjid":"13411111111@localhost","nickname":"张三"},
             {"userjid":"13411111111@localhost","nickname":"李四"}]
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
                NSXMLElement *query = [iq elementForName:@"query" xmlns:@"aft:groupchat"];
                
                if (query) {
                    //init a XMPPChatRoomCoreDataStorageObject to restore the info
                    NSString *roomID = [query attributeStringValueForName:@"groupid"];
                    NSString *roomNickName = [query attributeStringValueForName:@"groupname"];
                    NSString *master = [query attributeStringValueForName:@"master"];
                    NSDictionary *tempDictionary = @{
                                                     @"groupid":roomID,
                                                     @"groupname":roomNickName,
                                                     @"master":master
                                                     };
                    NSArray *tempArray = @[tempDictionary];
                    
                    //The user list here
                    NSArray *userArray = [[query stringValue] objectFromJSONString];
                    NSMutableArray *array = [NSMutableArray array];
                    [userArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                      /*
                       NSString *bareJidStr = [Dic objectForKey:@"bareJidStr"];
                       NSString *roomBareJidStr = [Dic objectForKey:@"RoomBareJidStr"];
                       NSString *nickNameStr = [Dic objectForKey:@"nicknameStr"];
                       NSString *streamBareJidStr = [Dic objectForKey:@"streamBareJidStr"];
                       */
                        NSDictionary *tempDic = obj;
                        NSDictionary *dic = @{
                                              @"bareJidStr":[tempDic objectForKey:@"userjid"],
                                              @"nicknameStr":[tempDic objectForKey:@"nickname"],
                                              @"RoomBareJidStr":[roomID copy]
                                              };
                        [array addObject:dic];
                    }];
                    
                    //Transfor the room info
                    if (roomID) {
                        //TODO:Here need save the room info into the database
                        [self transFormDataWithArray:tempArray];
                        [multicastDelegate xmppChatRoom:self didCreateChatRoomID:[roomID copy] roomNickName:[roomNickName copy]];
                    }
                    
                    //Transfor the room user list info
                    if ([array count] > 0) {
                        [self transChatRoomUserDataWithArray:array];
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
    //After we sending the alter nickname for a chat room,we will receice a result xml as below:
    /*
     <iq from="1341234578@localhost" type="result" to="1341234578@localhost/caoyue-PC" id="aad5a">
     <query xmlns="aft:groupchat" query_type="set_groupname" groupname=”FirstGroup”></query>
     </iq>
     */
    dispatch_block_t block = ^{
        @autoreleasepool {
            //if there is a error attribute
            if ([[iq attributeStringValueForName:@"type"] isEqualToString:@"error"]) {
                [multicastDelegate xmppChatRoom:self didAlterChatRoomNickNameError:iq];
                return ;
            }
            
            //if this action have succeed
            if ([[iq type] isEqualToString:@"result"]) {
                //find the query elment
                NSXMLElement *query = [iq elementForName:@"query" xmlns:@"aft:groupchat"];
                
                if (query) {
                    //init a XMPPChatRoomCoreDataStorageObject to restore the info
                    NSString *roomID = [query attributeStringValueForName:@"groupid"];
                    NSString *roomNickName = [query attributeStringValueForName:@"groupname"];
                    NSDictionary *tempDictionary = @{
                                                     @"groupid":roomID,
                                                     @"groupname":roomNickName,
                                                     };
                    NSArray *tempArray = @[tempDictionary];
                    
                    if (roomID) {
                        //TODO:Here need save the room info into the database
                        [self transFormDataWithArray:tempArray];
                        [multicastDelegate xmppChatRoom:self didAlterChatRoomNickNameWithID:[roomID copy] roomNickName:[roomNickName copy]];
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
        [self fetchChatRoomListFromServer];
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    // This method is invoked on the moduleQueue.
    
    XMPPLogTrace();
    
    // Note: Some jabber servers send an iq element with an xmlns.
    // Because of the bug in Apple's NSXML (documented in our elementForName method),
    // it is important we specify the xmlns for the query.
    
    NSXMLElement *query = [iq elementForName:@"query" xmlns:@"aft:groupchat"];
    
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
     <message from="aftgroup_33@localhost" type="groupchat" push="true" xml:lang="en" to="13412345678@localhost">
        <body groupid="33" groupname="FirstGroup" master="13412345678@localhost" type = "groupmember">
            [{"jid":"13412345678@localhost","nickname":"test1123","action":"add"},//or remove,alter
            {"jid":"13412345678@localhost","nickname":"test1123","action":"add"},
            {"jid":"13412345678@localhost","nickname":"test1123","action":"add"}]
        </body>
     </message>
     
     <message from="aftgroup_33@localhost" type="groupchat" push="true" xml:lang="en" to="13412345678@localhost">
        <body  type = "groupinfo">
            [{"groupid":"1","groupname":"testgroup","action":"dismiss"},//dismiss a group
            {"groupid":"1","groupname":"testgroup","action":"rename"}]//modyfy the group nickname
        </body>
     </message>
     */
    
    XMPPLogTrace();
    
    // Is this a message we need to store (a chat message)?
    //
    // A message to all recipients MUST be of type groupchat.
    // A message to an individual recipient would have a <body/>.
    
    NSXMLElement *pushElement = [message psuhElementFromChatRoomPushMessageWithXmlns:GROUP_PUSH_XMLNS];
    
    //This is a chart room push message
    if (pushElement) {
        
        //Note:if this is a push message about the group info
        if ([[pushElement attributeStringValueForName:@"type"] isEqualToString:GROUP_MEMBER_PUSH]){
            
            [self groupMemberPushElement:pushElement];

        //Note:if this is a push message about the group member
        }else if ([[pushElement attributeStringValueForName:@"type"] isEqualToString:GROUP_INFO_PUSH]){
            
            [self groupInfoPushElement:pushElement];
        }
        
        [multicastDelegate xmppChatRoom:self didReceiveSeiverPush:message];
    }
}

- (void)groupInfoPushElement:(NSXMLElement *)push
{
    if (![[push attributeStringValueForName:@"type"] isEqualToString:GROUP_INFO_PUSH]) return;
    
    dispatch_block_t block = ^{
        @autoreleasepool {
            
            NSArray *tempArray = [[push stringValue] objectFromJSONString];
            
            [self transFormDataWithArray:tempArray];
            
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)groupMemberPushElement:(NSXMLElement *)push
{
    if (![[push attributeStringValueForName:@"type"] isEqualToString:GROUP_MEMBER_PUSH]) return;
    
    BOOL isChatRoomExisted = [self existChatRoomWithBareJidStr:[push attributeStringValueForName:@"groupid"]];
    
    dispatch_block_t block = ^{
        @autoreleasepool {
            
            NSString *chatRoomID = [push attributeStringValueForName:@"groupid"];
            NSString *chatRoomNickName = [push attributeStringValueForName:@"groupname"];
            NSString *master = [push attributeStringValueForName:@"master"];
            NSString *jsonStr = [push stringValue];
            
            NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionary];
            if (chatRoomID) [tempDictionary setObject:chatRoomID forKey:@"groupid"];
            if (chatRoomNickName) [tempDictionary setObject:chatRoomNickName forKey:@"groupname"];
            if (master) [tempDictionary setObject:master forKey:@"master"];
            
            //If this chat room has already in the core data system
            if (isChatRoomExisted) {
                //update the chat room info
                [xmppChatRoomStorage InsertOrUpdateChatRoomWith:tempDictionary xmppStream:xmppStream];
                
                //update the user info of this chat room
                if (jsonStr) {
                    
                    [self transChatRoomUserDataWithJsonStr:jsonStr];
                }
            //If this chat room info is new to us
            }else{
                //down the group info and the user info
                
                //If there is a full chat room info,we will insert it into the coredata system
                if (chatRoomID && chatRoomNickName && master) {
                    //Insert the chat room info to the coredata syetem
                    [xmppChatRoomStorage InsertOrUpdateChatRoomWith:tempDictionary xmppStream:xmppStream];
                    
                    //only download the user list info from server
                    [self downloadUserListFromServerWithBareChatRoomJidStr:chatRoomID];
                    
                }else{
                    //download the chat room info and the user list info both
                    [self downloadChatRoomInfoWith:chatRoomID];
                    [self downloadUserListFromServerWithBareChatRoomJidStr:chatRoomID];
                }
            }
            
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

@end
