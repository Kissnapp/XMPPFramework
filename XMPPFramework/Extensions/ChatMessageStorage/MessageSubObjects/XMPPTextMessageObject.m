//
//  XMPPTextMessageObject.m
//  XMPP_Project
//
//  Created by carl on 14-11-18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPTextMessageObject.h"
#import <objc/runtime.h>

@implementation XMPPTextMessageObject
-(instancetype)initWithText:(NSString*)string
{
    self = [super  init];
    if (self) {
       
    }
    return self;
}
+(instancetype)initWithText:(NSString*)string
{
    return [self initWithText:string];
}
-(XMPPTextMessageObject *)xmppTextMessageObjectFromElement:(NSXMLElement *)element
{
    object_setClass(element, [XMPPTextMessageObject class]);
    
    return (XMPPTextMessageObject *)element;

}
+(XMPPTextMessageObject *)xmppTextMessageObjectFromElement:(NSXMLElement *)element
{
    return  [self xmppTextMessageObjectFromElement:element];
}
-(void)setText:(NSString *)text
{
    [self setStringValue:text];
}
-(NSString*)text
{
    return [self stringValue];
}
@end
