//
//  XMPPChatRoomCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 14/9/25.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface XMPPChatRoomCoreDataStorageObject : NSManagedObject
{
    NSString * jid;
    NSString * nickName;
    UIImage  * photo;
    NSString * streamBareJidStr;
    NSString * subscription;
}
@property (nonatomic, strong) NSString * jid;
@property (nonatomic, strong) NSString * nickName;
@property (nonatomic, strong) UIImage  * photo;
@property (nonatomic, strong) NSString * streamBareJidStr;
@property (nonatomic, strong) NSString * subscription;
@property (nonatomic, strong) NSString * masterBareJidStr;
/**
 *  Insert a new XMPPChatRoomCoreDataStorageObject into the CoraData System
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param id               The id of chatroom
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for others
 */
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                           withID:(NSString *)id
                  streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Insert a new XMPPChatRoomCoreDataStorageObject into the CoraData System
 *  with the info Dictionary
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param Dic              A dictionary which contains the info of the chat room
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for others
 */
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                  withNSDictionary:(NSDictionary *)Dic
                  streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Delete the chat room info Which jid is equal to the given id
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param id               The given id
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for others
 */
+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                            withID:(NSString *)id
                  streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Delete the chat room info Which info  is equal to the given info dictionary
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param Dic              A dictionary which contains the info of the chat room
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for others
 */
+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc
                  withNSDictionary:(NSDictionary *)Dic
                  streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Update the chat room info Which info is equal to the given info dictionary
 *  If the chat room is not is not existed, do nothing
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param Dic              A dictionary which contains the info of the chat room
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for others
 */
+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc
                    withNSDictionary:(NSDictionary *)Dic
                    streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Update the chat room info Which info is equal to the given info dictionary
 *  If the chat room is not is not existed, We will insert the new object into
 *  the CoreData syetem
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param Dic              A dictionary which contains the info of the chat room
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return YES,if succeed, NO for other cases
 */
+ (BOOL)updateOrInsertObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                  withNSDictionary:(NSDictionary *)Dic
                                  streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Fetch the chat room info from the CoreData system with room's jid
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param id               The given id
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return Fetched object,if succeed,nil for other cases
 */
+ (id)fetchObjectInManagedObjectContext:(NSManagedObjectContext *)moc
                                 withID:(NSString *)id
                       streamBareJidStr:(NSString *)streamBareJidStr;
/**
 *  Fetch the XMPPChatRoomCoreDataStorageObject object from the CoreData system with room's jid
 *
 *  @param moc              The NSManagedObjectContext object
 *  @param id               The given id
 *  @param streamBareJidStr The jidstr of the xmppstream
 *
 *  @return XMPPChatRoomCoreDataStorageObject object,if succeed,nil for other cases
 */
+ (XMPPChatRoomCoreDataStorageObject *)objectInManagedObjectContext:(NSManagedObjectContext *)moc
                                                             withID:(NSString *)id
                                                   streamBareJidStr:(NSString *)streamBareJidStr;

/**
 *  Update a XMPPChatRoomCoreDataStorageObject object with the chat room info dictionary
 *
 *  @param Dic The given dictionary
 */
- (void)updateWithDictionary:(NSDictionary *)Dic;
/**
 *  Compare two XMPPChatRoomCoreDataStorageObject object
 *
 *  @param another Another XMPPChatRoomCoreDataStorageObject object
 *
 *  @return Compare result
 */
- (NSComparisonResult)compareByName:(XMPPChatRoomCoreDataStorageObject *)another;
- (NSComparisonResult)compareByName:(XMPPChatRoomCoreDataStorageObject *)another options:(NSStringCompareOptions)mask;

- (NSComparisonResult)compareByAvailabilityName:(XMPPChatRoomCoreDataStorageObject *)another;
- (NSComparisonResult)compareByAvailabilityName:(XMPPChatRoomCoreDataStorageObject *)another
                                        options:(NSStringCompareOptions)mask;


@end
