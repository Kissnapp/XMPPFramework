//
//  XMPPMessage+ChatRoomMessage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/26.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPMessage+ChatRoomMessage.h"

@implementation XMPPMessage (ChatRoomMessage)

- (BOOL)isChatRoomMessage
{
    return ([[[self attributeForName:@"type"] stringValue] isEqualToString:@"chat"] & ([self attributeStringValueForName:@"user"] != nil));
}

- (BOOL)isChatRoomPushMessage
{
    return ([[[self attributeForName:@"type"] stringValue] isEqualToString:@"aft_groupchat"] & [[self attributeStringValueForName:@"push"] isEqualToString:@"true"]);
}


- (BOOL)isChatRoomMessageWithBody
{
    if ([self isChatRoomMessage])
    {
        NSString *body = [[self elementForName:@"body"] stringValue];
        
        return ([body length] > 0);
    }
    
    return NO;
}

- (BOOL)isChatRoomMessageWithSubject
{
    if ([self isChatRoomMessage])
    {
        NSString *subject = [[self elementForName:@"subject"] stringValue];
        
        return ([subject length] > 0);
    }
    
    return NO;
}

- (NSXMLElement *)bodyElementFromChatRoomPushMessage
{
    NSXMLElement *body = nil;
    if ([self isChatRoomPushMessage]) {
        body = [self elementForName:@"body"];
    }
    
    return body;
}

@end
