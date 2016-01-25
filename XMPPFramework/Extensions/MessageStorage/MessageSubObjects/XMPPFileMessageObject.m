//
//  XMPPFileMessageObject.m
//  XMPP_Project
//
//  Created by Peter Lee on 16/1/23.
//  Copyright © 2016年 Peter Lee. All rights reserved.
//

#import "XMPPFileMessageObject.h"
#import "NSData+XMPP.h"
#import <objc/runtime.h>


#define FILE_NAME_ATTRIBUTE_NAME            @"fileName"
#define FILE_ID_ATTRIBUTE_NAME              @"fileId"
#define FILE_THUMBNAIL_ATTRIBUTE_NAME       @"thumbnail"
#define FILE_SIZE_ATTRIBUTE_NAME            @"fileSize"

@implementation XMPPFileMessageObject

+ (XMPPFileMessageObject *)xmppFileMessageObjectFromElement:(NSXMLElement *)element
{
    
    object_setClass(element, [XMPPFileMessageObject class]);
    return (XMPPFileMessageObject *)element;
}

+ (XMPPFileMessageObject *)xmppFileMessageObjectFromInfoElement:(NSXMLElement *)infoElement
{
    
    XMPPFileMessageObject *xmppFileMessageObject = nil;
    
    NSXMLElement *element = [infoElement elementForName:FILE_ELEMENT_NAME];
    if (element) {
        
        xmppFileMessageObject = [XMPPFileMessageObject xmppFileMessageObjectFromElement:element];Id
    }
    
    return xmppFileMessageObject;
}


+ (XMPPFileMessageObject *)xmppFileMessageObject
{
    NSXMLElement *fileElement = [NSXMLElement elementWithName:FILE_ELEMENT_NAME];
    return [XMPPFileMessageObject xmppFileMessageObjectFromInfoElement:fileElement];
}

+ (XMPPFileMessageObject *)xmppFileMessageObjectWithFileId:(NSString *)fileId
                                                          size:(NSString *)size
{
    return [XMPPFileMessageObject xmppFileMessageObjectWithFileName:nil
                                                           fileId:fileId
                                                          thumbnail:nil
                                                               size:size];
}

+ (XMPPFileMessageObject *)xmppFileMessageObjectWithFileName:(NSString *)fileName
                                                    fileId:(NSString *)fileId
                                                        size:(NSString *)size
{
    return [XMPPFileMessageObject xmppFileMessageObjectWithFileName:fileName
                                                             fileId:fileId
                                                            thumbnail:nil
                                                                 size:size];
}

+ (XMPPFileMessageObject *)xmppFileMessageObjectWithFileName:(NSString *)fileName
                                                    fileId:(NSString *)fileId
                                                   thumbnail:(NSData *)thumbnail
                                                        size:(NSString *)size
{
    
    XMPPFileMessageObject *xmppFileMessageObject = nil;
    NSXMLElement *element = [NSXMLElement elementWithName:FILE_ELEMENT_NAME];
    xmppFileMessageObject = [XMPPFileMessageObject xmppFileMessageObjectFromElement:element];
    
    [xmppFileMessageObject setFileName:fileName];
    [xmppFileMessageObject setFileId:fileId];
    [xmppFileMessageObject setFileSize:size];
    [xmppFileMessageObject setThumbnail:thumbnail];
    
    return xmppFileMessageObject;
}


- (instancetype)init
{
    return [self initWithFileId:nil
                             size:nil];
}
- (instancetype)initWithFileId:(NSString *)fileId
                            size:(NSString *)size
{
    return [self initWithFileName:nil
                         fileId:fileId
                        thumbnail:nil
                             size:size];
}

- (instancetype)initWithFileName:(NSString *)fileName
                        fileId:(NSString *)fileId
                            size:(NSString *)size
{
    return [self initWithFileName:fileId
                         fileId:fileId
                        thumbnail:nil
                             size:size];
}

- (instancetype)initWithFileName:(NSString *)fileName
                        fileId:(NSString *)fileId
                       thumbnail:(NSData *)thumbnail
                            size:(NSString *)size
{
    self = [super initWithName:VIDEO_ELEMENT_NAME];
    if (self) {
        [self setFileName:fileName];
        [self setFileId:fileId];
        [self setFileSize:size];
        [self setThumbnail:thumbnail];
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

@end
