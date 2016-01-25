//
//  XMPPFileMessageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 16/1/23.
//  Copyright © 2016年 Peter Lee. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>

#define FILE_ELEMENT_NAME                  @"file"

@interface XMPPFileMessageObject : XMPPBaseMessageSubObject

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *fileSize;
@property (strong, nonatomic) NSData   *thumbnail;

//class init methods
+ (XMPPFileMessageObject *)xmppFileMessageObject;
+ (XMPPFileMessageObject *)xmppFileMessageObjectWithFilePath:(NSString *)filePath
                                                        size:(NSString *)size;

+ (XMPPFileMessageObject *)xmppFileMessageObjectWithFileName:(NSString *)fileName
                                                    filePath:(NSString *)filePath
                                                        size:(NSString *)size;

+ (XMPPFileMessageObject *)xmppFileMessageObjectWithFileName:(NSString *)fileName
                                                    filePath:(NSString *)filePath
                                                   thumbnail:(NSData *)thumbnail
                                                        size:(NSString *)size;

+ (XMPPFileMessageObject *)xmppFileMessageObjectFromElement:(NSXMLElement *)element;

+ (XMPPFileMessageObject *)xmppFileMessageObjectFromInfoElement:(NSXMLElement *)infoElement;

- (instancetype)init;

- (instancetype)initWithFilePath:(NSString *)filePath
                            size:(NSString *)size;

- (instancetype)initWithFileName:(NSString *)fileName
                        filePath:(NSString *)filePath
                            size:(NSString *)size;

- (instancetype)initWithFileName:(NSString *)fileName
                        filePath:(NSString *)filePath
                       thumbnail:(NSData *)thumbnail
                            size:(NSString *)size;


@end
