//
//  XMPPImageMessageObject.h
//  XMPP_Project
//
//  Created by carl on 14-11-18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPBaseMessageSubObject.h"

@interface XMPPImageMessageObject : XMPPBaseMessageSubObject
@property (strong, nonatomic) NSString          *fileName;
@property (strong, nonatomic) NSString          *filePath;
@property (strong, nonatomic) NSData            *fileData;
@property (assign, nonatomic) CGFloat          aspectRatio;      //image width&height

+(XMPPImageMessageObject*)xmppImageMessageObjectFromElement:(NSXMLElement *)element;
@end
