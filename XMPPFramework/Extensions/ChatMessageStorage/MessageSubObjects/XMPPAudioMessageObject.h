//
//  XMPPAudioMessageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/11/18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPBaseMessageSubObject.h"

@interface XMPPAudioMessageObject : XMPPBaseMessageSubObject

@property (strong, nonatomic) NSString          *fileName;
@property (strong, nonatomic) NSString          *filePath;
@property (strong, nonatomic) NSData            *fileData;
@property (assign, nonatomic) NSTimeInterval    timeLength;

+ (XMPPAudioMessageObject *)xmppAudioMessageObjectFromElement:(NSXMLElement *)element;

@end
