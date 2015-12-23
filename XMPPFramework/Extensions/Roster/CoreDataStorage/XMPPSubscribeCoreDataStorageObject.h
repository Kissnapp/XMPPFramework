//
//  XMPPSubscribeCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/12/23.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSUInteger, XMPPSubscribeState) {
    XMPPSubscribeStateReceive = 0,
    XMPPSubscribeStateIgnore,
    XMPPSubscribeStateAccept,
    XMPPSubscribeStateRefuse
};

@interface XMPPSubscribeCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * bareJidStr;
@property (nonatomic, retain) NSString * streamBareJidStr;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * state;

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                        bareJidStr:(NSString *)bareJidStr
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                        bareJidStr:(NSString *)bareJidStr
                          nickName:(NSString *)nickName
                           message:(NSString *)message
                  streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc
                          bareJidStr:(NSString *)bareJidStr
                            nickName:(NSString *)nickName
                             message:(NSString *)message
                               state:(XMPPSubscribeState)state
                         updateState:(BOOL)updateState
                    streamBareJidStr:(NSString *)streamBareJidStr;

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                          bareJidStr:(NSString *)bareJidStr
                    streamBareJidStr:(NSString *)streamBareJidStr;

@end
