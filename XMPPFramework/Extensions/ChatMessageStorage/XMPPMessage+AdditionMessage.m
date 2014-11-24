//
//  XMPPMessage+AdditionMessage.m
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/27.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPMessage+AdditionMessage.h"
#import "XMPPAdditionalCoreDataMessageObject.h"

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

- (NSDate *)getUTCDateWithLocalDate:(NSDate *)localDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone localTimeZone];
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT

    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:localDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:localDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:localDate];
    
    return destinationDate;
}

- (NSDate *)getLocalDateWithUTCDate:(NSDate *)utcDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:utcDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:utcDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:utcDate];
    return destinationDate;
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
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *ldate = [dateFormatter dateFromString:utc];
//    NSString *str = [self dateToString:ldate];
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

//In this method there is no streamBareJidStr
-(NSMutableDictionary *)toDictionaryWithSendFromMe:(BOOL)sendFromMe active:(BOOL)active
{
    NSXMLElement *info = nil;
    
    if (!(info = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS]))  return nil;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    NSString *userJidStr = sendFromMe ? [[self to] bare]:[[self from] bare];
    NSString *messageID = [info attributeStringValueForName:@"id"];
    NSNumber *unReadMessageCount = [NSNumber numberWithBool:(sendFromMe ? NO:!active)];
    NSUInteger messageType = [info attributeUnsignedIntegerValueForName:@"type"];
    NSDate  *messageTime = sendFromMe ? [NSDate date]:[self getLocalDateWithUTCString:[info attributeStringValueForName:@"timestamp"]];
    NSNumber *hasBeenRead = [NSNumber numberWithBool:(sendFromMe ? (unReadMessageCount > 0):!(unReadMessageCount > 0))];
    NSNumber *isGroupChat = [NSNumber numberWithBool:[info attributeBoolValueForName:@"groupChat"]];
    
    XMPPAdditionalCoreDataMessageObject *xmppAdditionalCoreDataMessageObject = [[XMPPAdditionalCoreDataMessageObject alloc] initWithInfoXMLElement:[self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS]];
    
    if (userJidStr) [dictionary setObject:userJidStr forKey:@"bareJidStr"];
    
    if (messageTime) [dictionary setObject:messageTime forKey:@"messageTime"];
    
    if (xmppAdditionalCoreDataMessageObject) [dictionary setObject:xmppAdditionalCoreDataMessageObject forKey:@"additionalMessage"];
    
    
    
    [dictionary setObject:[NSNumber numberWithBool:sendFromMe] forKey:@"sendFromMe"];
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:messageType] forKey:@"messageType"];
    
    //The readed message's hasBeenRead is 1,unread is 0
    //When is sent from me,we should note that this message is been sent failed as default 0
    //After being sent succeed,we should modify this value into 1
    [dictionary setObject:hasBeenRead forKey:@"hasBeenRead"];
    
    //If the unread message count is equal to zero,we will know that this message has been readed
    [dictionary setObject:unReadMessageCount forKey:@"unReadMessageCount"];
    
    [dictionary setObject:messageID forKey:@"messageID"];
    [dictionary setObject:isGroupChat forKey:@"isGroupChat"];
    
    return dictionary;
}

- (NSString *)messageID
{
    NSXMLElement *info = nil;
    if (!(info = [self elementForName:MESSAGE_ELEMENT_NAME xmlns:MESSAGE_ELEMENT_XMLNS]))  return nil;
    
    return [info attributeStringValueForName:@"id"];
}
@end
