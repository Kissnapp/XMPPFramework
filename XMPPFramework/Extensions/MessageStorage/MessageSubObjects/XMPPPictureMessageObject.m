//
//  XMPPPictureMessageObject.m
//  XMPP_Project
//
//  Created by carl on 14-11-18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPPictureMessageObject.h"
#import <objc/runtime.h>
#import "NSData+XMPP.h"


#define FILE_NAME_ATTRIBUTE_NAME            @"fileName"
#define FILE_DATA_ATTRIBUTE_NAME            @"fileData"
#define FILE_ID_ATTRIBUTE_NAME              @"fileId"
#define FILE_SIZE_ATTRIBUTE_NAME              @"fileSize"
#define ASPECT_RATIO_ATTRIBUTE_NAME        @"aspectRatio"

@implementation XMPPPictureMessageObject
//class init methods

+ (XMPPPictureMessageObject *)xmppPictureMessageObject
{
    NSXMLElement *audioElement = [NSXMLElement elementWithName:PICTURE_ELEMENT_NAME];
    return [XMPPPictureMessageObject xmppPictureMessageObjectFromElement:audioElement];
}
+(XMPPPictureMessageObject*)xmppPictureMessageObjectFromElement:(NSXMLElement *)element
{
    object_setClass(element, [XMPPPictureMessageObject class]);
    return (XMPPPictureMessageObject *)element;
}
+ (XMPPPictureMessageObject *)xmppPictureMessageObjectFromInfoElement:(NSXMLElement *)infoElement
{
    XMPPPictureMessageObject *xmppPictureMessageObject = nil;
    
    NSXMLElement *element = [infoElement elementForName:PICTURE_ELEMENT_NAME];
    if (element) {
        xmppPictureMessageObject = [XMPPPictureMessageObject xmppPictureMessageObjectFromElement:element];
    }
    
    return xmppPictureMessageObject;
}

+ (XMPPPictureMessageObject *)xmppPictureMessageObjectWithFileId:(NSString *)fileId fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio
{
    return [XMPPPictureMessageObject xmppPictureMessageObjectWithFileName:nil fileId:fileId fileData:fileData aspectRatio:aspectRatio];
}
+ (XMPPPictureMessageObject *)xmppPictureMessageObjectWithFileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio
{
    return [XMPPPictureMessageObject xmppPictureMessageObjectWithFileName:nil fileId:nil fileData:fileData aspectRatio:aspectRatio];
}

+ (XMPPPictureMessageObject *)xmppPictureMessageObjectWithFileName:(NSString *)fileName fileId:(NSString *)fileId fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio
{
    XMPPPictureMessageObject *xmppPictureMessageObject = nil;
    xmppPictureMessageObject = [[XMPPPictureMessageObject alloc] initWithFileName:fileName fileId:fileId fileData:fileData aspectRatio:aspectRatio];
    [xmppPictureMessageObject setFileName:fileName];
    [xmppPictureMessageObject setFileId:fileId];
    [xmppPictureMessageObject setFileData:fileData];
    [xmppPictureMessageObject setAspectRatio:aspectRatio];
    
    return xmppPictureMessageObject;
}

//object init objects
- (instancetype)initWithFileName:(NSString *)fileName fileId:(NSString *)fileId fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio

{
    self = [super initWithName:PICTURE_ELEMENT_NAME];
    if (self) {
        [self setFileName:fileName];
        [self setFileId:fileId];
        [self setFileData:fileData];
        
    }
    return self;
}
- (instancetype)initWithFleId:(NSString *)fileId fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio

{
    return [self initWithFileName:nil fileId:fileId fileData:fileData aspectRatio:aspectRatio];
}
- (instancetype)initWithFileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio
{
    return  [self initWithFleId:nil fileData:fileData aspectRatio:aspectRatio];
}

#pragma mark - getters and setters

- (NSString *)fileName
{
    return [self attributeStringValueForName:FILE_NAME_ATTRIBUTE_NAME];
}

- (void)setFileName:(NSString *)fileName
{
    if (!fileName) {
        return;
    }
    XMPP_SUB_MSG_SET_STRING_ATTRIBUTE(fileName, FILE_NAME_ATTRIBUTE_NAME);
}

- (NSString *)fileId
{
    return [self attributeStringValueForName:FILE_ID_ATTRIBUTE_NAME];
}

- (void)setFileId:(NSString *)fileId
{
    if (!fileId) {
        return;
    }
    XMPP_SUB_MSG_SET_STRING_ATTRIBUTE(fileId, FILE_ID_ATTRIBUTE_NAME);
}

- (NSData *)fileData
{
    NSData *data = nil;
    
    NSString *dataString = [self stringValue];
    
    if (dataString) {
        NSData *base64Data = [dataString dataUsingEncoding:NSASCIIStringEncoding];
        data = [base64Data xmpp_base64Decoded];
    }
    
    return data;
}

- (void)setFileData:(NSData *)fileData
{
    XMPP_SUB_MSG_SET_STRING_VALUE([fileData xmpp_base64Encoded]);
}
-(void)setAspectRatio:(CGFloat)aspectRatio
{
   
    XMPP_SUB_MSG_SET_FLOAT_ATTRIBUTE(aspectRatio, ASPECT_RATIO_ATTRIBUTE_NAME);
}
-(CGFloat)aspectRatio
{
    return [self attributeFloatValueForName:ASPECT_RATIO_ATTRIBUTE_NAME];
}


@end
