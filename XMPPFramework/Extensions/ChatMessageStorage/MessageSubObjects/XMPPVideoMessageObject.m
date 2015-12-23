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
#define FILE_PATH_ATTRIBUTE_NAME            @"filePath"
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

+ (XMPPVideoMessageObject *)xmppVideoMessageObjectWithFilePath:(NSString *)filePath
                                                          size:(NSString *)size
                                                          time:(NSTimeInterval)time
{
    return [XMPPVideoMessageObject xmppVideoMessageObjectWithFileName:nil
                                                             filePath:filePath
                                                            thumbnail:nil
                                                                 size:size
                                                                 time:time];
}

+ (XMPPVideoMessageObject *)xmppVideoMessageObjectWithFileName:(NSString *)fileName
                                                      filePath:(NSString *)filePath
                                                          size:(NSString *)size
                                                          time:(NSTimeInterval)time
{
    return [XMPPVideoMessageObject xmppVideoMessageObjectWithFileName:fileName
                                                             filePath:filePath
                                                            thumbnail:nil
                                                                 size:size
                                                                 time:time];
}

+ (XMPPVideoMessageObject *)xmppVideoMessageObjectWithFileName:(NSString *)fileName
                                                      filePath:(NSString *)filePath
                                                     thumbnail:(NSData *)thumbnail
                                                          size:(NSString *)size
                                                          time:(NSTimeInterval)time
{
    
    XMPPVideoMessageObject *xmppVideoMessageObject = nil;
    NSXMLElement *element = [NSXMLElement elementWithName:VIDEO_ELEMENT_NAME];
    xmppVideoMessageObject = [XMPPVideoMessageObject xmppVideoMessageObjectFromElement:element];
    
    [xmppVideoMessageObject setFileName:fileName];
    [xmppVideoMessageObject setFilePath:filePath];
    [xmppVideoMessageObject setFileSize:size];
    [xmppVideoMessageObject setTimeLength:time];
    [xmppVideoMessageObject setThumbnail:thumbnail];
    
    return xmppVideoMessageObject;
}


- (instancetype)init
{
    return [self initWithFilePath:nil
                             size:nil
                             time:0.0];
}
- (instancetype)initWithFilePath:(NSString *)filePath
                            size:(NSString *)size
                            time:(NSTimeInterval)time
{
    return [self initWithFileName:nil
                         filePath:filePath
                        thumbnail:nil
                             size:size
                             time:time];
}

- (instancetype)initWithFileName:(NSString *)fileName
                        filePath:(NSString *)filePath
                            size:(NSString *)size
                            time:(NSTimeInterval)time
{
    return [self initWithFileName:filePath
                         filePath:filePath
                        thumbnail:nil
                             size:size
                             time:time];
}

- (instancetype)initWithFileName:(NSString *)fileName
                        filePath:(NSString *)filePath
                       thumbnail:(NSData *)thumbnail
                            size:(NSString *)size
                            time:(NSTimeInterval)time
{
    self = [super initWithName:VIDEO_ELEMENT_NAME];
    if (self) {
        [self setFileName:fileName];
        [self setFilePath:filePath];
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

- (NSString *)filePath
{
    return [self attributeStringValueForName:FILE_PATH_ATTRIBUTE_NAME];
}

- (void)setFilePath:(NSString *)filePath
{
    if (!filePath) return;
    XMPP_SUB_MSG_SET_STRING_ATTRIBUTE(filePath, FILE_PATH_ATTRIBUTE_NAME);
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
