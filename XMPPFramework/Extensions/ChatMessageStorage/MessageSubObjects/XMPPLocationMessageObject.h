//
//  XMPPLocationMessageObject.h
//  XMPP_Project
//
//  Created by yoolo on 14-11-19.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPBaseMessageObject.h"

#define LOCATION_ELEMENT_NAME @"location"

@interface XMPPLocationMessageObject : XMPPBaseMessageObject

@property (strong, nonatomic) NSString    *longitude;
@property (strong, nonatomic) NSString    *latitude;
@property (strong, nonatomic) NSString    *content;


+ (XMPPLocationMessageObject *)xmppLocationMessageObject;
+ (XMPPLocationMessageObject *)xmppLocationMessageObject:(NSString *)longitude latitude:(NSString *)latitude;
+ (XMPPLocationMessageObject *)xmppLocationMessageObject:(NSString *)longitude latitude:(NSString *)latitude content:(NSString *)content;


+ (XMPPLocationMessageObject *)xmppLocationMessageObjectFromElement:(NSXMLElement *)element;
+ (XMPPLocationMessageObject *)xmppLocationMessageObjectInfoElement:(NSXMLElement *)infoElement;

- (instancetype)init;
- (instancetype)initWithLocation:(NSString *)longitude latitude:(NSString *)latitude;
- (instancetype)initWithLocation:(NSString *)longitude latitude:(NSString *)latitude content:(NSString *)content;

@end

