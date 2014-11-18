//
//  XMPPBaseMessageSubObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/11/18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSXMLElement+XMPP.h"

#define XMPP_SUB_MSG_SET_BOOL_ATTRIBUTE(Value, Name) [self addAttributeWithName:Name boolValue:Value]
#define XMPP_SUB_MSG_SET_STRING_ATTRIBUTE(Value, Name) [self addAttributeWithName:Name  stringValue:Value]
#define XMPP_SUB_MSG_SET_DOUBLE_ATTRIBUTE(Value, Name) [self addAttributeWithName:Name  doubleValue:Value]
#define XMPP_SUB_MSG_SET_UNSIGEND_INREGER_ATTRIBUTE(Value, Name) [self addAttributeWithName:Name  unsignedIntegerValue:Value]
#define XMPP_SUB_MSG_SET_INREGER_ATTRIBUTE(Value, Name) [self addAttributeWithName:Name  integerValue:Value]
#define XMPP_SUB_MSG_SET_OBJECT_ATTRIBUTE(Value, Name) [self addAttributeWithName:Name  objectValue:Value]

#define XMPP_SUB_MSG_SET_STRING_VALUE(Value) [self setStringValue:Value]



@interface XMPPBaseMessageSubObject : NSXMLElement<NSCoding, NSCopying>

@end
