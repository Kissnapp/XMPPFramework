//
//  XMPPMessageCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/10/10.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPPMessageHistoryCoreDataStorageObject.h"
#import "XMPPExtendMessage.h"
#import "XMPPBaseMessageObject.h"

@interface XMPPMessageCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString                              * msgId;
@property (nonatomic, retain) NSString                              * sender;
@property (nonatomic, retain) NSString                              * bareJidStr;
@property (nonatomic, retain) NSString                              * streamBareJidStr;

@property (nonatomic, retain) NSNumber                              * msgType;
@property (nonatomic, retain) NSNumber                              * outgoing;
@property (nonatomic, retain) NSNumber                              * beenRead;
@property (nonatomic, retain) NSNumber                              * sendState;
@property (nonatomic, retain) NSNumber                              * isGroup;

@property (nonatomic, retain) NSDate                                * msgTime;
@property (nonatomic, retain) XMPPBaseMessageObject                 * subData;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                         predicate:(NSPredicate *)predicate;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                             msgId:(NSString *)msgId
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                            active:(BOOL)active
                 xmppExtendMessage:(XMPPExtendMessage *)xmppExtendMessage
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)updateOrInsertObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                            active:(BOOL)active
                                 xmppExtendMessage:(XMPPExtendMessage *)xmppExtendMessage
                                  streamBareJidStr:(NSString *)streamBareJidStr;

- (void)updateFromXMPPExtendMessage:(XMPPExtendMessage *)xmppExtendMessage streamBareJidStr:(NSString *)streamBareJidStr;

@end
