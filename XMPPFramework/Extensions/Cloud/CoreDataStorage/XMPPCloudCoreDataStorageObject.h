//
//  XMPPCloudCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by jeff on 15/10/20.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPManagedObject.h"

typedef NS_ENUM(NSInteger, XMPPCloudCoreDataStorageObjectFolderType){
    XMPPCloudCoreDataStorageObjectFolderTypeRoot = -1,
    XMPPCloudCoreDataStorageObjectFolderTypePublic,
    XMPPCloudCoreDataStorageObjectFolderTypePublicSub,
    XMPPCloudCoreDataStorageObjectFolderTypePrivate,
    XMPPCloudCoreDataStorageObjectFolderTypePrivateFullShared,
    XMPPCloudCoreDataStorageObjectFolderTypePrivatePartShared,
    XMPPCloudCoreDataStorageObjectFolderTypePrivateSecret
};

@interface XMPPCloudCoreDataStorageObject : XMPPManagedObject

@property (nonatomic, retain) NSString * cloudID;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSString * creator;
@property (nonatomic, retain) NSNumber * download;
@property (nonatomic, retain) NSString * fileID;
@property (nonatomic, retain) NSNumber * folderType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSNumber * parent;
@property (nonatomic, retain) NSString * project;
@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) NSNumber * folderOrFileType;
@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) NSString * versionCount;
@property (nonatomic, retain) NSString * streamBareJidStr;
@property (nonatomic, retain) NSNumber * folderIsMe;


+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc cloudID:(NSString *)cloudID streamBareJidStr:(NSString *)streamBareJidStr;
+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc dic:(NSDictionary *)dic streamBareJidStr:(NSString *)streamBareJidStr;
+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc cloudID:(NSString *)cloudID streamBareJidStr:(NSString *)streamBareJidStr;
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc dic:(NSDictionary *)dic streamBareJidStr:(NSString *)streamBareJidStr;
- (void)updateWithDic:(NSDictionary *)dic;

@end
