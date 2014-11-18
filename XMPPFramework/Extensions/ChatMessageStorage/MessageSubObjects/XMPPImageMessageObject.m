//
//  XMPPImageMessageObject.m
//  XMPP_Project
//
//  Created by carl on 14-11-18.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//
#define IMAGE_ELEMENT_NAME                  @"image"
#import "XMPPImageMessageObject.h"
#import <objc/runtime.h>
#import "NSData+XMPP.h"


#define FILE_NAME_ATTRIBUTE_NAME            @"fileName"
#define FILE_DATA_ATTRIBUTE_NAME            @"fileData"
#define FILE_PATH_ATTRIBUTE_NAME            @"filePath"

@implementation XMPPImageMessageObject

+(XMPPImageMessageObject*)xmppImageMessageObjectFromElement:(NSXMLElement *)element
{
    object_setClass(element, [XMPPImageMessageObject class]);
    return (XMPPImageMessageObject *)element;
}
+ (XMPPImageMessageObject *)xmppAudioMessageObjectFromInfoElement:(NSXMLElement *)infoElement
{
    XMPPImageMessageObject *xmppAudioMessageObject = nil;
    
    NSXMLElement *element = [infoElement elementForName:IMAGE_ELEMENT_NAME];
    if (element) {
        xmppAudioMessageObject = [XMPPImageMessageObject xmppImageMessageObjectFromElement:element];
    }
    
    return xmppAudioMessageObject;
}

+ (XMPPImageMessageObject *)xmppAudioMessageObject
{
    NSXMLElement *audioElement = [NSXMLElement elementWithName:IMAGE_ELEMENT_NAME];
    return [XMPPImageMessageObject xmppImageMessageObjectFromElement:audioElement];
}

+ (XMPPImageMessageObject *)xmppImageMessageObjectWithFileName:(NSString *)fileName filePath:(NSString *)filePath fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio
{
    XMPPImageMessageObject *xmppImageMessageObject = nil;
    NSXMLElement *element = [NSXMLElement elementWithName:IMAGE_ELEMENT_NAME];
    
    xmppImageMessageObject = [XMPPImageMessageObject xmppImageMessageObjectFromElement:element];
    
    [xmppImageMessageObject setName:fileName];
    [xmppImageMessageObject setFilePath:filePath];
    [xmppImageMessageObject setFileData:fileData];
    
    
    
    return xmppImageMessageObject;
}
+ (XMPPImageMessageObject *)xmppImageMessageObjectWithFilePath:(NSString *)filePath fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio
{
    return [self xmppImageMessageObjectWithFileName:nil filePath:filePath fileData:fileData aspectRatio:aspectRatio];
}
+ (XMPPImageMessageObject *)xmppImageMessageObjectWithFileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio
{
    return [self xmppImageMessageObjectWithFileName:nil filePath:nil fileData:fileData aspectRatio:aspectRatio];
}
- (instancetype)initWithFileName:(NSString *)fileName filePath:(NSString *)filePath fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio

{
    self = [super initWithName:IMAGE_ELEMENT_NAME];
    if (self) {
        [self setFileName:fileName];
        [self setFilePath:filePath];
        [self setFileData:fileData];
        
    }
    return self;
}
- (instancetype)initWithFlePath:(NSString *)filePath fileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio

{
    return [self initWithFileName:nil filePath:filePath fileData:fileData aspectRatio:aspectRatio];
}
- (instancetype)initWithFileData:(NSData *)fileData aspectRatio:(CGFloat)aspectRatio
{
    return  [self initWithFlePath:nil fileData:fileData aspectRatio:aspectRatio];
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

- (NSString *)filePath
{
    return [self attributeStringValueForName:FILE_PATH_ATTRIBUTE_NAME];
}

- (void)setFilePath:(NSString *)filePath
{
    if (!filePath) {
        return;
    }
    XMPP_SUB_MSG_SET_STRING_ATTRIBUTE(filePath, FILE_PATH_ATTRIBUTE_NAME);
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
    if (!fileData) {
        return;
    }
    XMPP_SUB_MSG_SET_STRING_VALUE([fileData xmpp_base64Encoded]);
}
-(void)setAspectRatio:(CGFloat)aspectRatio
{
    [self setAspectRatio:aspectRatio];
}
-(CGFloat)aspectRatio
{
    return [self aspectRatio];
}


@end
