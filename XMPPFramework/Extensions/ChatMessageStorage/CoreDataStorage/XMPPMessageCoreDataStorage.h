//
//  XMPPChatMesageCoreDataStorage.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPCoreDataStorage.h"
#import "XMPPAllMessage.h"

@protocol XMPPAllMessageStorage;

@interface XMPPMessageCoreDataStorage : XMPPCoreDataStorage<XMPPAllMessageStorage>

+ (instancetype)sharedInstance;

@end
