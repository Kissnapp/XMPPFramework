//
//  XMPPVideoMessageObject.m
//  XMPP_Project
//
//  Created by yoolo on 14-11-18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPVideoMessageObject.h"
#import "NSData+XMPP.h"
#import <objc/runtime.h>


#define FILE_NAME_ATTRIBUTE_NAME            @"fileName"
#define FILE_ID_ATTRIBUTE_NAME              @"fileId"
#define FILE_THUMBNAIL_ATTRIBUTE_NAME       @"thumbnail"
#define FILE_SIZE_ATTRIBUTE_NAME            @"fileSize"
#define TIME_LENGTH_ATTRIBUTE_NAME          @"timeLength"

@implementation XMPPVideoMessageObject


+ (XMPPVideoMessageObject *)xmppVideoMessageObjectFromElement:(NSXMLElement *)element
{
    
    object_setClass(element, [XMPPVideoMessageObject class]);
    return (XMPPVideoMessageObject *)element;
}

+ (XMPPVideoMessageObject *)xmppVideoMessageObjectFromInfoElement:(NSXMLElement *)infoElement
{
    
    XMPPVideoMessageObject *xmppVideoMessageObject = nil;
    
    NSXMLElement *element = [infoElement elementForName:VIDEO_ELEMENT_NAME];
    if (element) {
    
        xmppVideoMessageObject = [XMPPVideoMessageObject xmppVideoMessageObjectFromElement:element];
    }
    
    return xmppVideoMessageObject;
}


+ (XMPPVideoMessageObject *)xmppVideoMessageObject
{
    NSXMLElement *videoElement = [NSXMLElement elementWithName:VIDEO_ELEMENT_NAME];
    return [XMPPVideoMessageObject xmppVideoMessageObjectFromInfoElement:videoElement];
}

+ (XMPPVideoMessageObject *)xmppVideoMessageObjectWithFileId:(NSString *)fileId
                                                          size:(NSString *)size
                                                          time:(NSTimeInterval)time
{
    return [XMPPVideoMessageObject xmppVideoMessageObjectWithFileName:nil
                                                             fileId:fileId
                                                            thumbnail:nil
                                                                 size:size
                                                                 time:time];
}

+ (XMPPVideoMessageObject *)xmppVideoMessageObjectWithFileName:(NSString *)fileName
                                                      fileId:(NSString *)fileId
                                                          size:(NSString *)size
                                                          time:(NSTimeInterval)time
{
    return [XMPPVideoMessageObject xmppVideoMessageObjectWithFileName:fileName
                                                             fileId:fileId
                                                            thumbnail:nil
                                                                 size:size
                                                                 time:time];
}

+ (XMPPVideoMessageObject *)xmppVideoMessageObjectWithFileName:(NSString *)fileName
                                                      fileId:(NSString *)fileId
                                                     thumbnail:(NSData *)thumbnail
                                                          size:(NSString *)size
                                                          time:(NSTimeInterval)time
{
    
    XMPPVideoMessageObject *xmppVideoMessageObject = nil;
    NSXMLElement *element = [NSXMLElement elementWithName:VIDEO_ELEMENT_NAME];
    xmppVideoMessageObject = [XMPPVideoMessageObject xmppVideoMessageObjectFromElement:element];
    
    [xmppVideoMessageObject setFileName:fileName];
    [xmppVideoMessageObject setFileId:fileId];
    [xmppVideoMessageObject setFileSize:size];
    [xmppVideoMessageObject setTimeLength:time];
    [xmppVideoMessageObject setThumbnail:thumbnail];
    
    return xmppVideoMessageObject;
}


- (instancetype)init
{
    return [self initWithFileId:nil
                             size:nil
                             time:0.0];
}
- (instancetype)initWithFileId:(NSString *)fileId
                            size:(NSString *)size
                            time:(NSTimeInterval)time
{
    return [self initWithFileName:nil
                         fileId:fileId
                        thumbnail:nil
                             size:size
                             time:time];
}

- (instancetype)initWithFileName:(NSString *)fileName
                        fileId:(NSString *)fileId
                            size:(NSString *)size
                            time:(NSTimeInterval)time
{
    return [self initWithFileName:fileId
                         fileId:fileId
                        thumbnail:nil
                             size:size
                             time:time];
}

- (instancetype)initWithFileName:(NSString *)fileName
                        fileId:(NSString *)fileId
                       thumbnail:(NSData *)thumbnail
                            size:(NSString *)size
                            time:(NSTimeInterval)time
{
    self = [super initWithName:VIDEO_ELEMENT_NAME];
    if (self) {
        [self setFileName:fileName];
        [self setFileId:fileId];
        [self setFileSize:size];
        [self setThumbnail:thumbnail];
        [self setTimeLength:time];
        
    }
    return  self;
}


- (NSString *)fileName
{
    return [self attributeStringValueForName:FILE_NAME_ATTRIBUTE_NAME];
}

- (void)setFileName:(NSString *)fileName
{
    if (!fileName) return;
    XMPP_SUB_MSG_SET_STRING_ATTRIBUTE(fileName, FILE_NAME_ATTRIBUTE_NAME);
}

- (NSString *)fileId
{
    return [self attributeStringValueForName:FILE_ID_ATTRIBUTE_NAME];
}

- (void)setFileId:(NSString *)fileId
{
    if (!fileId) return;
    XMPP_SUB_MSG_SET_STRING_ATTRIBUTE(fileId, FILE_ID_ATTRIBUTE_NAME);
}

- (NSString *)fileSize
{
    return [self attributeStringValueForName:FILE_SIZE_ATTRIBUTE_NAME];
}

- (void)setFileSize:(NSString *)fileSize
{
    if (!fileSize) return;
    
    XMPP_SUB_MSG_SET_STRING_ATTRIBUTE(fileSize, FILE_SIZE_ATTRIBUTE_NAME);
}

- (NSData *)thumbnail
{
    NSData *data = nil;
    
    NSString *dataString = [self stringValue];
    
    if (dataString) {
        NSData *base64Data = [dataString dataUsingEncoding:NSASCIIStringEncoding];
        data = [base64Data xmpp_base64Decoded];
    }
    
    return data;
}

- (void)setThumbnail:(NSData *)thumbnail
{
    if (!thumbnail) return;
    
    XMPP_SUB_MSG_SET_STRING_VALUE([thumbnail xmpp_base64Encoded]);
}

- (NSTimeInterval)timeLength
{
    return [self attributeDoubleValueForName:TIME_LENGTH_ATTRIBUTE_NAME];
}

- (void)setTimeLength:(NSTimeInterval)timeLength
{
    XMPP_SUB_MSG_SET_DOUBLE_ATTRIBUTE(timeLength, TIME_LENGTH_ATTRIBUTE_NAME);
}

@end
