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
@property (strong, nonatomic) NSString *fileId;
@property (strong, nonatomic) NSString *fileSize;
@property (strong, nonatomic) NSData   *thumbnail;

//class init methods
+ (XMPPFileMessageObject *)xmppFileMessageObject;
+ (XMPPFileMessageObject *)xmppFileMessageObjectWithFileId:(NSString *)fileId
                                                        size:(NSString *)size;

+ (XMPPFileMessageObject *)xmppFileMessageObjectWithFileName:(NSString *)fileName
                                                    fileId:(NSString *)fileId
                                                        size:(NSString *)size;

+ (XMPPFileMessageObject *)xmppFileMessageObjectWithFileName:(NSString *)fileName
                                                    fileId:(NSString *)fileId
                                                   thumbnail:(NSData *)thumbnail
                                                        size:(NSString *)size;

+ (XMPPFileMessageObject *)xmppFileMessageObjectFromElement:(NSXMLElement *)element;

+ (XMPPFileMessageObject *)xmppFileMessageObjectFromInfoElement:(NSXMLElement *)infoElement;

- (instancetype)init;

- (instancetype)initWithFileId:(NSString *)fileId
                            size:(NSString *)size;

- (instancetype)initWithFileName:(NSString *)fileName
                        fileId:(NSString *)fileId
                            size:(NSString *)size;

- (instancetype)initWithFileName:(NSString *)fileName
                        fileId:(NSString *)fileId
                       thumbnail:(NSData *)thumbnail
                            size:(NSString *)size;


@end
