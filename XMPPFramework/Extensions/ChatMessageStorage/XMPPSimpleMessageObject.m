//
//  SimpleMessage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/8.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPSimpleMessageObject.h"
#import "XMPPFramework.h"

#define MESSAGE_TEXT_ELEMENT_NAME           @"messageText"
#define FILE_PATH_ELEMENT_NAME              @"filePath"
#define FILE_NAME_ELEMENT_NAME              @"fileName"
#define FILE_DATA_ELEMENT_NAME              @"fileData"
#define LATITUDE_ELEMENT_NAME               @"latitude"
#define LONGITUDE_ELEMENT_NAME              @"longitude"
#define CHATROOM_USERJID_ELEMENT_NAME       @"chatRoomUserJid"
#define TIME_LENGTH_ELEMENT_NAME            @"timeLength"
#define ASPECT_RATIO_USERJID_ELEMENT_NAME   @"aspectRatio"
#define MESSAGE_TAG_ELEMENT_NAME            @"messageTag"

@implementation XMPPSimpleMessageObject

#pragma mark -
#pragma mark - Public  Methods

-(instancetype)initWithDictionary:(NSMutableDictionary *)dictionary
{
    self = [super init];
    if (self) {
        [self fromDictionary:dictionary];
    }
    return self;
}
-(instancetype)initWithXMLElement:(NSXMLElement *)element
{
    self = [super init];
    if (self) {
        [self fromXMLElement:element];
    }
    return self;
}
-(NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (self.messageText)
        [dictionary setObject:self.messageText forKey:@"messageText"];
    
    if (self.filePath)
        [dictionary setObject:self.filePath forKey:@"filePath"];
    
    if (self.longitude)
        [dictionary setObject:self.longitude forKey:@"longitude"];
    if (self.latitude)
        [dictionary setObject:self.latitude forKey:@"latitude"];
    if (self.fileName)
        [dictionary setObject:self.fileName forKey:@"fileName"];
    if (self.fileData)
        [dictionary setObject:[self.fileData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] forKey:@"fileData"];
    if (self.chatRoomUserJid)
        [dictionary setObject:self.chatRoomUserJid forKey:@"chatRoomUserJid"];
    
    [dictionary setObject:[NSNumber numberWithDouble:self.timeLength] forKey:@"timeLength"];
    [dictionary setObject:[NSNumber numberWithFloat:self.aspectRatio] forKey:@"aspectRatio"];
    [dictionary setObject:[NSNumber numberWithBool:self.messageTag] forKey:@"messageTag"];
    
    return dictionary;
}

-(void)fromDictionary:(NSMutableDictionary *)message
{
    self.messageText = [message objectForKey:@"messageText"];
    self.filePath = [message objectForKey:@"filePath"];
    self.timeLength = [(NSNumber *)[message objectForKey:@"timeLength"] doubleValue];
    self.longitude = [message objectForKey:@"longitude"];
    self.latitude = [message objectForKey:@"latitude"];
    self.fileName = [message objectForKey:@"fileName"];
    self.chatRoomUserJid = [message objectForKey:@"chatRoomUserJid"];
#warning initWithBase64Encoding only used in the system version more than 7.0
    if ([message objectForKey:@"fileData"])
        self.fileData = [[NSData alloc] initWithBase64EncodedString:[message objectForKey:@"fileData"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    self.aspectRatio = [(NSNumber *)[message objectForKey:@"aspectRatio"] floatValue];
    self.messageTag = [(NSNumber *)[message objectForKey:@"messageTag"] boolValue];
}

-(NSXMLElement *)toXMLElement
{
    NSXMLElement *additionalElement = [NSXMLElement elementWithName:ADDITION_ELEMENT_NAME xmlns:ADDITION_ELEMENT_XMLNS];
    if (self.messageText) {
        NSXMLElement *messageText = [NSXMLElement elementWithName:MESSAGE_TEXT_ELEMENT_NAME stringValue:self.messageText];
        [additionalElement addChild:messageText];
    }
    if (self.filePath) {
        NSXMLElement *filePath = [NSXMLElement elementWithName:FILE_PATH_ELEMENT_NAME stringValue:self.filePath];
        [additionalElement addChild:filePath];
    }
    
    if (self.fileName) {
        NSXMLElement *fileName = [NSXMLElement elementWithName:FILE_NAME_ELEMENT_NAME stringValue:self.filePath];
        [additionalElement addChild:fileName];
    }
    
    if (self.fileData) {
        NSXMLElement *fileData = [NSXMLElement elementWithName:FILE_DATA_ELEMENT_NAME stringValue:[self.fileData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
        [additionalElement addChild:fileData];
    }
    
    if (self.latitude) {
        NSXMLElement *latitude = [NSXMLElement elementWithName:LATITUDE_ELEMENT_NAME stringValue:self.latitude];
        [additionalElement addChild:latitude];
    }
    
    if (self.longitude) {
        NSXMLElement *longitude = [NSXMLElement elementWithName:LONGITUDE_ELEMENT_NAME stringValue:self.longitude];
        [additionalElement addChild:longitude];
    }
    
    if (self.chatRoomUserJid) {
        NSXMLElement *chatRoomUserJid = [NSXMLElement elementWithName:CHATROOM_USERJID_ELEMENT_NAME stringValue:self.chatRoomUserJid];
        [additionalElement addChild:chatRoomUserJid];
    }
    
    if (self.timeLength > 0.0) {
        NSXMLElement *timeLength = [NSXMLElement elementWithName:TIME_LENGTH_ELEMENT_NAME numberValue:[NSNumber numberWithDouble:self.timeLength]];
        [additionalElement addChild:timeLength];
    }
    
    if (self.aspectRatio > 0.0) {
        NSXMLElement *aspectRatio = [NSXMLElement elementWithName:ASPECT_RATIO_USERJID_ELEMENT_NAME numberValue:[NSNumber numberWithFloat:self.aspectRatio]];
        [additionalElement addChild:aspectRatio];
    }
    
    if (self.messageTag) {
        NSXMLElement *messageTag = [NSXMLElement elementWithName:MESSAGE_TAG_ELEMENT_NAME numberValue:[NSNumber numberWithBool:self.messageTag]];
        [additionalElement addChild:messageTag];
    }
    
    return additionalElement;
}
-(void)fromXMLElement:(NSXMLElement *)xmlElement
{
    if (![[xmlElement name] isEqualToString:ADDITION_ELEMENT_NAME] || ![[xmlElement xmlns] isEqualToString:ADDITION_ELEMENT_XMLNS]) {
        return;
    }
    self.messageTag = [[xmlElement elementForName:MESSAGE_TAG_ELEMENT_NAME] stringValueAsBool];
    self.aspectRatio = [[xmlElement elementForName:ASPECT_RATIO_USERJID_ELEMENT_NAME] stringValueAsFloat];
    self.timeLength = [[xmlElement elementForName:TIME_LENGTH_ELEMENT_NAME] stringValueAsDouble];
    
    self.messageText = [[xmlElement elementForName:MESSAGE_TEXT_ELEMENT_NAME] stringValue];
    
    NSString *tempString = [[xmlElement elementForName:FILE_DATA_ELEMENT_NAME] stringValue];
    if (tempString)
        self.fileData = [[NSData alloc] initWithBase64EncodedString:tempString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    self.fileName = [[xmlElement elementForName:FILE_NAME_ELEMENT_NAME] stringValue];
    self.filePath = [[xmlElement elementForName:FILE_PATH_ELEMENT_NAME] stringValue];
    self.latitude = [[xmlElement elementForName:LATITUDE_ELEMENT_NAME] stringValue];
    self.longitude = [[xmlElement elementForName:LONGITUDE_ELEMENT_NAME] stringValue];
    self.chatRoomUserJid = [[xmlElement elementForName:CHATROOM_USERJID_ELEMENT_NAME] stringValue];
}

#pragma mark -
#pragma mark NSCopying Methods
- (id)copyWithZone:(NSZone *)zone
{
    XMPPSimpleMessageObject *newObject = [[[self class] allocWithZone:zone] init];
    
    [newObject setMessageText:self.messageText];
    [newObject setMessageTag:self.messageTag];
    [newObject setFileData:self.fileData];
    [newObject setFileName:self.fileName];
    [newObject setFilePath:self.filePath];
    [newObject setTimeLength:self.timeLength];
    [newObject setChatRoomUserJid:self.chatRoomUserJid];
    [newObject setLongitude:self.longitude];
    [newObject setLatitude:self.latitude];
    [newObject setAspectRatio:self.aspectRatio];
    
    return newObject;
}
#pragma mark -
#pragma mark NSCoding Methods
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.messageText forKey:@"messageText"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.messageTag] forKey:@"messageTag"];
    [aCoder encodeObject:self.fileData forKey:@"fileData"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
    [aCoder encodeObject:self.filePath forKey:@"filePath"];
    [aCoder encodeObject:self.latitude forKey:@"latitude"];
    [aCoder encodeObject:self.longitude forKey:@"longitude"];
    [aCoder encodeObject:self.chatRoomUserJid forKey:@"chatRoomUserJid"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.timeLength] forKey:@"timeLength"];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.aspectRatio] forKey:@"aspectRatio"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.messageText = [aDecoder decodeObjectForKey:@"messageText"];
        self.fileData = [aDecoder decodeObjectForKey:@"fileData"];
        self.fileName = [aDecoder decodeObjectForKey:@"fileName"];
        self.filePath = [aDecoder decodeObjectForKey:@"filePath"];
        self.latitude = [aDecoder decodeObjectForKey:@"latitude"];
        self.longitude = [aDecoder decodeObjectForKey:@"longitude"];
        self.chatRoomUserJid = [aDecoder decodeObjectForKey:@"chatRoomUserJid"];
        self.messageTag = [(NSNumber *)[aDecoder decodeObjectForKey:@"messageTag"] boolValue];
        self.timeLength = [(NSNumber *)[aDecoder decodeObjectForKey:@"timeLength"] doubleValue];
        self.aspectRatio = [(NSNumber *)[aDecoder decodeObjectForKey:@"aspectRatio"] floatValue];
    }
    return  self;
}


@end
