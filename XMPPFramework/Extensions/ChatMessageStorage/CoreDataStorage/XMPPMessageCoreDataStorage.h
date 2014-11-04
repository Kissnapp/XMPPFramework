//
//  XMPPChatMesageCoreDataStorage.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/30.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "XMPPCoreDataStorage.h"
#import "XMPPAllMessage.h"

@protocol XMPPAllMessageStorage;

@interface XMPPMessageCoreDataStorage : XMPPCoreDataStorage<XMPPAllMessageStorage>

+ (instancetype)sharedInstance;


//@property (strong) NSString *messageEntityName;
//@property (strong) NSString *unReadMessageCountEntityName;
//
//- (NSEntityDescription *)messageEntity:(NSManagedObjectContext *)moc;
//- (NSEntityDescription *)unReadMessageCount:(NSManagedObjectContext *)moc;
//
//- (t *)contactForMessage:(XMPPMessageArchiving_Message_CoreDataObject *)msg;
//
//- (XMPPMessageArchiving_Contact_CoreDataObject *)contactWithJid:(XMPPJID *)contactJid
//                                                      streamJid:(XMPPJID *)streamJid
//                                           managedObjectContext:(NSManagedObjectContext *)moc;
//
//- (XMPPMessageArchiving_Contact_CoreDataObject *)contactWithBareJidStr:(NSString *)contactBareJidStr
//                                                      streamBareJidStr:(NSString *)streamBareJidStr
//                                                  managedObjectContext:(NSManagedObjectContext *)moc;

@end
