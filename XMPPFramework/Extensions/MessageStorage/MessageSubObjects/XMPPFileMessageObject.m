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
#define FILE_PATH_ATTRIBUTE_NAME            @"filePath"
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
        
        xmppFileMessageObject = [XMPPFileMessageObject xmppFileMessageObjectFromElement:element];
    }
    
    return xmppFileMessageObject;
}


+ (XMPPFileMessageObject *)xmppFileMessageObject
{
    NSXMLElement *fileElement = [NSXMLElement elementWithName:FILE_ELEMENT_NAME];
    return [XMPPFileMessageObject xmppFileMessageObjectFromInfoElement:fileElement];
}

+ (XMPPFileMessageObject *)xmppFileMessageObjectWithFilePath:(NSString *)filePath
                                                          size:(NSString *)size
{
    return [XMPPFileMessageObject xmppFileMessageObjectWithFileName:nil
                                                           filePath:filePath
                                                          thumbnail:nil
                                                               size:size];
}

+ (XMPPFileMessageObject *)xmppFileMessageObjectWithFileName:(NSString *)fileName
                                                    filePath:(NSString *)filePath
                                                        size:(NSString *)size
{
    return [XMPPFileMessageObject xmppFileMessageObjectWithFileName:fileName
                                                             filePath:filePath
                                                            thumbnail:nil
                                                                 size:size];
}

+ (XMPPFileMessageObject *)xmppFileMessageObjectWithFileName:(NSString *)fileName
                                                    filePath:(NSString *)filePath
                                                   thumbnail:(NSData *)thumbnail
                                                        size:(NSString *)size
{
    
    XMPPFileMessageObject *xmppFileMessageObject = nil;
    NSXMLElement *element = [NSXMLElement elementWithName:FILE_ELEMENT_NAME];
    xmppFileMessageObject = [XMPPFileMessageObject xmppFileMessageObjectFromElement:element];
    
    [xmppFileMessageObject setFileName:fileName];
    [xmppFileMessageObject setFilePath:filePath];
    [xmppFileMessageObject setFileSize:size];
    [xmppFileMessageObject setThumbnail:thumbnail];
    
    return xmppFileMessageObject;
}


- (instancetype)init
{
    return [self initWithFilePath:nil
                             size:nil];
}
- (instancetype)initWithFilePath:(NSString *)filePath
                            size:(NSString *)size
{
    return [self initWithFileName:nil
                         filePath:filePath
                        thumbnail:nil
                             size:size];
}

- (instancetype)initWithFileName:(NSString *)fileName
                        filePath:(NSString *)filePath
                            size:(NSString *)size
{
    return [self initWithFileName:filePath
                         filePath:filePath
                        thumbnail:nil
                             size:size];
}

- (instancetype)initWithFileName:(NSString *)fileName
                        filePath:(NSString *)filePath
                       thumbnail:(NSData *)thumbnail
                            size:(NSString *)size
{
    self = [super initWithName:VIDEO_ELEMENT_NAME];
    if (self) {
        [self setFileName:fileName];
        [self setFilePath:filePath];
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

@end
