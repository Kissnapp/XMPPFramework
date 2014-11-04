//
//  XMPPChatRoomUserCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/11/4.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface XMPPChatRoomUserCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * bareJidStr;
@property (nonatomic, retain) NSString * chatRoomBareJidStr;
@property (nonatomic, retain) NSString * nickeName;
@property (nonatomic, retain) NSString * streamBareJidStr;

+ (id)fetchObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                 withBareJidStr:(NSString *)bareJidStr
                               streamBareJidStr:(NSString *)streamBareJidStr;

+ (XMPPChatRoomUserCoreDataStorageObject *)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                                                         withBareJidStr:(NSString *)bareJidStr
                                                       streamBareJidStr:(NSString *)streamBareJidStr;

@end
