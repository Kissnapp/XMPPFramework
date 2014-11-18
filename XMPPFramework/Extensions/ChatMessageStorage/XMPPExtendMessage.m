//
//  XMPPExtendMessage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/11/17.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPExtendMessage.h"

#pragma mark - object object

#pragma mark - setters and getters
- (NSString *)fromUser
{
    return self.from.bare;
}

- (void)setFromUser:(NSString *)fromUser
{
    self.from = [XMPPJID jidWithString:fromUser];
}

@end
