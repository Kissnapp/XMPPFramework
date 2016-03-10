//
//  XMPPCloudCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by jeff on 15/10/20.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPManagedObject.h"
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, XMPPCloudCoreDataStorageObjectFolderType) {
    XMPPCloudCoreDataStorageObjectFolderTypeProject = 0,
    XMPPCloudCoreDataStorageObjectFolderTypeProjectSub,
    XMPPCloudCoreDataStorageObjectFolderTypePrivate,
    XMPPCloudCoreDataStorageObjectFolderTypePrivateFullShared,
    XMPPCloudCoreDataStorageObjectFolderTypePrivatePartShared,
    XMPPCloudCoreDataStorageObjectFolderTypePrivateSecret,
    XMPPCloudCoreDataStorageObjectFolderTypeDepartment,
    XMPPCloudCoreDataStorageObjectFolderTypeDepartmentSub,
    XMPPCloudCoreDataStorageObjectFolderTypeFile
};

@interface XMPPCloudCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * cloudID;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSString * creator; // 创建者
@property (nonatomic, retain) NSNumber * hasBeenDownload;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * folderType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * owner; // 拥有者
@property (nonatomic, retain) NSNumber * parent;
@property (nonatomic, retain) NSString * project;
@property (nonatomic, retain) NSString * size; // 文件大小
//@property (nonatomic, retain) NSNumber * folderOrFileType; // 文件夹或者文件 YES : 文件夹
@property (nonatomic, retain) NSString * version_count; // 版本数
@property (nonatomic, retain) NSString * streamBareJidStr;
@property (nonatomic, retain) NSNumber * folderIsMe; // 文件或文件夹是否是自己创建的 YES : 是自己
@property (nonatomic, retain) NSNumber * hasBeenDelete;
@property (nonatomic, retain) NSDate * updateTime;


#pragma mark - 查找
+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc cloudID:(NSString *)cloudID streamBareJidStr:(NSString *)streamBareJidStr;

#pragma mark - 更新
+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc dic:(NSDictionary *)dic streamBareJidStr:(NSString *)streamBareJidStr;
+ (BOOL)updateSpecialInManagedObjectContext:(NSManagedObjectContext *)moc dic:(NSDictionary *)dic streamBareJidStr:(NSString *)streamBareJidStr;

#pragma mark - 新增
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc dic:(NSDictionary *)dic streamBareJidStr:(NSString *)streamBareJidStr;

#pragma mark - 删除
+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc cloudID:(NSString *)cloudID streamBareJidStr:(NSString *)streamBareJidStr;
+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc hasBeenDelete:(NSNumber *)hasBeenDelete project:(NSString *)project streamBareJidStr:(NSString *)streamBareJidStr;

@end
