//
//  XMPPPictureMessageObject.h
//  XMPP_Project
//
//  Created by carl on 14-11-18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPBaseMessageSubObject.h"

@interface XMPPPictureMessageObject : XMPPBaseMessageSubObject
@property (strong, nonatomic) NSString          *fileName;
@property (strong, nonatomic) NSString          *filePath;
@property (strong, nonatomic) NSData            *fileData;
@property (assign, nonatomic) CGFloat           aspectRatio;      //Picture width&height

+(XMPPPictureMessageObject*)xmppPictureMessageObjectFromElement:(NSXMLElement *)element;
@end
