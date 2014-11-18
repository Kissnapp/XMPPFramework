//
//  XMPPTextMessageObject.h
//  XMPP_Project
//
//  Created by carl on 14-11-18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPBaseMessageSubObject.h"

@interface XMPPTextMessageObject : XMPPBaseMessageSubObject
@property (strong, nonatomic)NSString * text;
@end
