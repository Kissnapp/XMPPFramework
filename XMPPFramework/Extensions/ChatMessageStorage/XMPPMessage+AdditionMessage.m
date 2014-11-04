//
//  XMPPMessage+AdditionMessage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/27.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPMessage+AdditionMessage.h"
#import "XMPPSimpleMessageObject.h"

@implementation XMPPMessage (AdditionMessage)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Tool methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *  Get the UTC string from the local date string
 *
 *  @param localDate The local date string
 *
 *  @return The UTC string we will get
 */
-(NSString *)getUTCStringWithLocalDateString:(NSString *)localDate
{
    //将本地日期字符串转为UTC日期字符串
    //本地日期格式:2013-08-03 12:53:51
    //可自行指定输入输出格式
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:localDate];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}
/**
 *  The local date string we get with the UTC date string
 *
 *  @param utcDate The UTC date string
 *
 *  @return The local date string we will get
 */
-(NSString *)getLocalDateStringWithUTCDateString:(NSString *)utcDate
{
    //将UTC日期字符串转为本地时间字符串
    //输入的UTC日期格式2013-08-03T04:53:51+0000
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}
/**
 *  Get the UTC date string from the local date object
 *
 *  @param localDate The local date object
 *
 *  @return The UTC date string we will get
 */
- (NSString *)getUTCStringWithLocalDate:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}
/**
 *  Get the local date object with the given UTC date string
 *
 *  @param utc The utc date string
 *
 *  @return The local date obejct we will get
 */
- (NSDate *)getLocalDateWithUTCString:(NSString *)utc
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate *ldate = [dateFormatter dateFromString:utc];
    return ldate;
}
/**
 *  Get the date obejct With the given date string
 *
 *  @param strdate The given date string
 *
 *  @return The Date object we will get
 */
- (NSDate *)stringToDate:(NSString *)strdate
{
    //NSString 2 NSDate
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *retdate = [dateFormatter dateFromString:strdate];
    return retdate;
}
/**
 *  Get the date string with the given date object
 *
 *  @param date The given object
 *
 *  @return The string we will get
 */
- (NSString *)dateToString:(NSDate *)date
{
    //NSDate 2 NSString
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK:There is no fromUser,toUser,sendFromMe,hasBeenRead
-(NSMutableDictionary *)toDictionary
{
    NSXMLElement *body = [self elementForName:@"body"];
    if (!body)  return nil;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    //TODO:Here we should
    
    return dictionary;
}
//In this method there is no streamBareJidStr
-(NSMutableDictionary *)toDictionaryWithSendFromMe:(BOOL)sendFromMe activeUser:(NSString *)activeUser
{
    /*
    //[self setMessageID:[messageDic objectForKey:@"messageID"]];
    //[self setMessageTime:[messageDic objectForKey:@"messageTime"]];
    //[self setIsPrivate:[messageDic objectForKey:@"isPrivate"]];
    //[self setBareJidStr:[messageDic objectForKey:@"bareJidStr"]];
    //[self setSendFromMe:[messageDic objectForKey:@"sendFromMe"]];
    //[self setHasBeenRead:[messageDic objectForKey:@"hasBeenRead"]];
    //[self setMessageType:[messageDic objectForKey:@"messageType"]];
    //[self setStreamBareJidStr:streamBareJidStr];
    //[self setIsChatRoomMessage:[messageDic objectForKey:@"isChatRoomMessage"]];
    [self setMessageBody:[messageDic objectForKey:@"messageBody"]];
     */
    NSXMLElement *body = [self elementForName:@"body"];
    if (!body)  return nil;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    NSString *myBareJidStr = sendFromMe ? [[self from] bare]:[[self to] bare];
    NSString *userJidStr = sendFromMe ? [[self to] bare]:[[self from] bare];
    NSUInteger unReadMessageCount = sendFromMe ? 0:([[[self from] bare] isEqualToString:activeUser] ? 0:1);
    NSUInteger messageType = [[body elementForName:@"messageType"] stringValueAsNSUInteger];
    NSDate  *messageTime = sendFromMe ? [NSDate date]:[self getLocalDateWithUTCString:[[body elementForName:@"messageTime"] stringValue]];
    XMPPSimpleMessageObject *xmppSimpleMessageObject = [[XMPPSimpleMessageObject alloc] initWithXMLElement:[body elementForName:ADDITION_ELEMENT_NAME]];
    
    [dictionary setObject:myBareJidStr forKey:@"streamBareJidStr"];
    [dictionary setObject:userJidStr forKey:@"bareJidStr"];
    [dictionary setObject:[NSNumber numberWithBool:sendFromMe] forKey:@"sendFromMe"];
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:messageType] forKey:@"messageType"];
    //The readed message's hasBeenRead is 1,unread is 0
    //When is sent from me,we should note that this message is been sent failed as default 0
    //After being sent succeed,we should modify this value into 1
    [dictionary setObject:[NSNumber numberWithBool:(sendFromMe ? (unReadMessageCount > 0):!(unReadMessageCount > 0))] forKey:@"hasBeenRead"];
    [dictionary setObject:messageTime forKey:@"messageTime"];
    //If the unread message count is equal to zero,we will know that this message has been readed
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:unReadMessageCount] forKey:@"unReadMessageCount"];
    
    [dictionary setObject:[[body elementForName:@"messageID"] stringValue] forKey:@"messageID"];
    [dictionary setObject:[NSNumber numberWithBool:[[body elementForName:@"isPrivate"] stringValueAsBool]] forKey:@"isPrivate"];
    [dictionary setObject:[NSNumber numberWithBool:[[body elementForName:@"isChatRoomMessage"] stringValueAsBool]] forKey:@"isChatRoomMessage"];
    
    if (xmppSimpleMessageObject)
        [dictionary setObject:xmppSimpleMessageObject forKey:@"messageBody"];
    
    return dictionary;
}

- (NSString *)messageID
{
    NSXMLElement *body = [self elementForName:@"body"];
    if (!body)  return nil;
    
    return [[body elementForName:@"messageID"] stringValue];
}
@end
