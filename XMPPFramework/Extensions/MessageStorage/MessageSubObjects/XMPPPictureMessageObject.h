//
//  XMPPPictureMessageObject.h
//  XMPP_Project
//
//  Created by carl on 14-11-18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPBaseMessageSubObject.h"
#define PICTURE_ELEMENT_NAME                  @"picture"

@interface XMPPPictureMessageObject : XMPPBaseMessageSubObject
@property (strong, nonatomic) NSString          *fileName;
@property (strong, nonatomic) NSString          *fileId;
@property (strong, nonatomic) NSString          *fileSize;
@property (strong, nonatomic) NSData            *fileData;
@property (assign, nonatomic) CGFloat           aspectRatio;      //Picture width&height

//class init methods
+ (XMPPPictureMessageObject *)xmppPictureMessageObject;
+ (XMPPPictureMessageObject*)xmppPictureMessageObjectFromElement:(NSXMLElement *)element;
+ (XMPPPictureMessageObject *)xmppPictureMessageObjectFromInfoElement:(NSXMLElement *)infoElement;
+ (XMPPPictureMessageObject *)xmppPictureMessageObjectWithFileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio fileSize:(NSString *)fileSize;
+ (XMPPPictureMessageObject *)xmppPictureMessageObjectWithFileId:(NSString *)fileId fileData:(NSData *)fileData  aspectRatio:(CGFloat)aspectRatio fileSize:(NSString *)fileSize;
+ (XMPPPictureMessageObject *)xmppPictureMessageObjectWithFileName:(NSString *)fileName fileId:(NSString *)fileId fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio fileSize:(NSString *)fileSize;

//object init objects
- (instancetype)initWithFileName:(NSString *)fileName fileId:(NSString *)fileId fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio fileSize:(NSString *)fileSize;
- (instancetype)initWithFileId:(NSString *)fileId fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio fileSize:(NSString *)fileSize;
- (instancetype)initWithFileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio fileSize:(NSString *)fileSize;
@end
