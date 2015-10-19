//
//  XMPPCloudCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by jeff on 15/10/9.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "XMPPCloudCoreDataStorageObject.h"
#import "NSString+NSDate.h"


@implementation XMPPCloudCoreDataStorageObject

@dynamic cloudID;
@dynamic createTime;
@dynamic creator;
@dynamic download;
@dynamic fileID;
@dynamic folderType;
@dynamic name;
@dynamic owner;
@dynamic parent;
@dynamic project;
@dynamic size;
@dynamic folderOrFileType;
@dynamic updateTime;
@dynamic versionCount;
@dynamic streamBareJidStr;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - primitive Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (NSMutableDictionary *)propertyTransformDictionary
{
    NSMutableDictionary *keysMapDic = [super propertyTransformDictionary];
    return keysMapDic;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//- (NSString *)cloudID
//{
//    [self willAccessValueForKey:@"id"];
//    NSString *value = [self primitiveValueForKey:@"id"];
//    [self didAccessValueForKey:@"id"];
//    return value;
//}
//- (void)setCloudID:(NSString *)value
//{
//    [self willChangeValueForKey:@"id"];
//    [self setPrimitiveValue:value forKey:@"id"];
//    [self didChangeValueForKey:@"id"];
//}
//
//
//- (NSDate *)createTime
//{
//    [self willAccessValueForKey:@"Time"];
//    NSDate *value = [self primitiveValueForKey:@"Time"];
//    [self didAccessValueForKey:@"Time"];
//    return value;
//}
//- (void)setCreateTime:(NSString *)value
//{
//    [self willChangeValueForKey:@"Time"];
//    [self setPrimitiveValue:value forKey:@"Time"];
//    [self didChangeValueForKey:@"Time"];
//}
//
//
//- (NSString *)creator
//{
//    [self willAccessValueForKey:@"creator"];
//    NSString *value = [self primitiveValueForKey:@"creator"];
//    [self didAccessValueForKey:@"creator"];
//    return value;
//}
//- (void)setCreator:(NSDate *)value
//{
//    [self willChangeValueForKey:@"creator"];
//    [self setPrimitiveValue:value forKey:@"creator"];
//    [self didChangeValueForKey:@"creator"];
//}
//
//
//- (NSNumber *)download
//{
//    [self willAccessValueForKey:@"download"];
//    NSNumber *value = [self primitiveValueForKey:@"download"];
//    [self didAccessValueForKey:@"download"];
//    return value;
//}
//- (void)setDownload:(NSString *)value
//{
//    [self willChangeValueForKey:@"download"];
//    [self setPrimitiveValue:value forKey:@"download"];
//    [self didChangeValueForKey:@"download"];
//}
//
//
//- (NSString *)fileID
//{
//    [self willAccessValueForKey:@"fileID"];
//    NSString *value = [self primitiveValueForKey:@"fileID"];
//    [self didAccessValueForKey:@"fileID"];
//    return value;
//}
//- (void)setFileID:(NSString *)value
//{
//    [self willChangeValueForKey:@"fileID"];
//    [self setPrimitiveValue:value forKey:@"fileID"];
//    [self didChangeValueForKey:@"fileID"];
//}
//
//
//- (NSNumber *)folderType
//{
//    [self willAccessValueForKey:@"type"];
//    NSNumber *value = [self primitiveValueForKey:@"type"];
//    [self didAccessValueForKey:@"type"];
//    return value;
//}
//- (void)setFolderType:(NSString *)value
//{
//    [self willChangeValueForKey:@"type"];
//    [self setPrimitiveValue:value forKey:@"type"];
//    [self didChangeValueForKey:@"type"];
//}
//
//
//- (NSString *)name
//{
//    [self willAccessValueForKey:@"name"];
//    NSString *value = [self primitiveValueForKey:@"name"];
//    [self didAccessValueForKey:@"name"];
//    return value;
//}
//- (void)setName:(NSString *)value
//{
//    [self willChangeValueForKey:@"name"];
//    [self setPrimitiveValue:value forKey:@"name"];
//    [self didChangeValueForKey:@"name"];
//}
//
//
//- (NSString *)owner
//{
//    [self willAccessValueForKey:@"owner"];
//    NSString *value = [self primitiveValueForKey:@"owner"];
//    [self didAccessValueForKey:@"owner"];
//    return value;
//}
//- (void)setOwner:(NSString *)value
//{
//    [self willChangeValueForKey:@"owner"];
//    [self setPrimitiveValue:value forKey:@"owner"];
//    [self didChangeValueForKey:@"owner"];
//}
//
//
//- (NSNumber *)parent
//{
//    [self willAccessValueForKey:@"parent"];
//    NSNumber *value = [self primitiveValueForKey:@"parent"];
//    [self didAccessValueForKey:@"parent"];
//    return value;
//}
//- (void)setParent:(NSString *)value
//{
//    [self willChangeValueForKey:@"parent"];
//    [self setPrimitiveValue:value forKey:@"parent"];
//    [self didChangeValueForKey:@"parent"];
//}
//
//
//- (NSString *)project
//{
//    [self willAccessValueForKey:@"project"];
//    NSString *value = [self primitiveValueForKey:@"project"];
//    [self didAccessValueForKey:@"project"];
//    return value;
//}
//- (void)setProject:(NSString *)value
//{
//    [self willChangeValueForKey:@"project"];
//    [self setPrimitiveValue:value forKey:@"project"];
//    [self didChangeValueForKey:@"project"];
//}
//
//
//- (NSString *)size
//{
//    [self willAccessValueForKey:@"size"];
//    NSString *value = [self primitiveValueForKey:@"size"];
//    [self didAccessValueForKey:@"size"];
//    return value;
//}
//- (void)setSize:(NSString *)value
//{
//    [self willChangeValueForKey:@"size"];
//    [self setPrimitiveValue:value forKey:@"size"];
//    [self didChangeValueForKey:@"size"];
//}
//
//
//- (NSNumber *)folderOrFileType
//{
//    [self willAccessValueForKey:@"folderOrFileType"];
//    NSNumber *value = [self primitiveValueForKey:@"folderOrFileType"];
//    [self didAccessValueForKey:@"folderOrFileType"];
//    return value;
//}
//- (void)setFolderOrFileType:(NSString *)value
//{
//    [self willChangeValueForKey:@"folderOrFileType"];
//    [self setPrimitiveValue:value forKey:@"folderOrFileType"];
//    [self didChangeValueForKey:@"folderOrFileType"];
//}
//
//
//- (NSDate *)updateTime
//{
//    [self willAccessValueForKey:@"updateTime"];
//    NSDate *value = [self primitiveValueForKey:@"updateTime"];
//    [self didAccessValueForKey:@"updateTime"];
//    return value;
//}
//- (void)setUpdateTime:(NSString *)value
//{
//    [self willChangeValueForKey:@"updateTime"];
//    [self setPrimitiveValue:value forKey:@"updateTime"];
//    [self didChangeValueForKey:@"updateTime"];
//}
//
//
//- (NSString *)versionCount
//{
//    [self willAccessValueForKey:@"versionCount"];
//    NSString *value = [self primitiveValueForKey:@"versionCount"];
//    [self didAccessValueForKey:@"versionCount"];
//    return value;
//}
//- (void)setVersionCount:(NSString *)value
//{
//    [self willChangeValueForKey:@"versionCount"];
//    [self setPrimitiveValue:value forKey:@"versionCount"];
//    [self didChangeValueForKey:@"versionCount"];
//}
//
//- (NSString *)streamBareJidStr
//{
//    [self willAccessValueForKey:@"streamBareJidStr"];
//    NSString *value = [self primitiveValueForKey:@"streamBareJidStr"];
//    [self didAccessValueForKey:@"streamBareJidStr"];
//    return value;
//}
//- (void)setStreamBareJidStr:(NSString *)value
//{
//    [self willChangeValueForKey:@"streamBareJidStr"];
//    [self setPrimitiveValue:value forKey:@"streamBareJidStr"];
//    [self didChangeValueForKey:@"streamBareJidStr"];
//}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Creation & Updates
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc
//                             orgId:(NSString *)orgId
//                           cloudID:(NSString *)cloudID
//                  streamBareJidStr:(NSString *)streamBareJidStr
//{
//    if (orgId == nil) return nil;
//    if (cloudID == nil) return nil;
//    if (moc == nil) return nil;
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPCloudCoreDataStorageObject" inManagedObjectContext:moc];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orgId == %@ AND streamBareJidStr == %@ AND cloudID == %@", orgId, streamBareJidStr, cloudID];
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    [fetchRequest setEntity:entity];
//    [fetchRequest setPredicate:predicate];
//    [fetchRequest setIncludesPendingChanges:YES];
//    [fetchRequest setFetchLimit:1];
//    
//    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
//    
//    return (XMPPCloudCoreDataStorageObject *)[results lastObject];
//}

//+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
//                           withDic:(NSDictionary *)dic
//                  streamBareJidStr:(NSString *)streamBareJidStr
//{
//    if (moc == nil) return nil;
//    if (dic == nil) return nil;
//    if (streamBareJidStr == nil) return nil;
//
//    NSString *entityName = NSStringFromClass([XMPPCloudCoreDataStorageObject class]);
//    XMPPCloudCoreDataStorageObject *newCloud = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
//    newCloud.streamBareJidStr = streamBareJidStr;
//    [newCloud updateWithDic:dic];
//    return newCloud;
//}
//
//+ (BOOL)updateInManagedObjectContext:(NSManagedObjectContext *)moc withDic:(NSDictionary *)dic orgID:(NSString *)orgID streamBareJidStr:(NSString *)streamBareJidStr
//{
//    BOOL result = NO;
//    if (moc == nil)  return result;
//    
//    NSString *tempOrgID = orgID ? : dic[@"orgID"];
//    NSString *temCloudID = dic[@"cloudID"];
//    
//    if (tempOrgID == nil)  return result;
//    if (temCloudID == nil)  return result;
//    
//    XMPPCloudCoreDataStorageObject *folder = [XMPPCloudCoreDataStorageObject objectInManagedObjectContext:moc orgId:tempOrgID cloudID:temCloudID streamBareJidStr:streamBareJidStr];
//    if (folder) {
//        [folder updateWithDic:dic];
//        result = YES;
//    } else {
//        folder = [XMPPCloudCoreDataStorageObject insertInManagedObjectContext:moc withDic:dic streamBareJidStr:streamBareJidStr];
//        result = YES;
//    }
//    return result;
//}


+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc withDic:(NSDictionary *)dic
{
    NSString *entityName = NSStringFromClass([XMPPCloudCoreDataStorageObject class]);
    XMPPCloudCoreDataStorageObject *newOrg = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
    [newOrg updateWithDic:dic];
    return newOrg;
}

- (void)updateWithDic:(NSDictionary *)dic
{
    NSString *tempCloudID = [dic objectForKey:@"id"];
    NSString *tempCreateTime = [dic objectForKey:@"Time"];
    NSString *tempCreator = [dic objectForKey:@"creator"];
    NSNumber *tempFolderType = [NSNumber numberWithInteger:[[dic objectForKey:@"type"] integerValue]];
    NSString *tempName = [dic objectForKey:@"name"];
    NSString *tempOwner = [dic objectForKey:@"owner"];
    NSNumber *tempParent = [NSNumber numberWithInteger:[[dic objectForKey:@"parent"] integerValue]];
    NSString *tempProject = [dic objectForKey:@"project"];
    NSString *tempStreamBareJidStr = [dic objectForKey:@"streamBareJidStr"];
    
//    NSNumber *tempFolderOrFileType = [NSNumber numberWithInteger:[[dic objectForKey:@"folderOrFileType"] boolValue]];
//    NSString *tempUpdateTime = [dic objectForKey:@"updateTime"];
//    NSString *tempVersionCount = [dic objectForKey:@"versionCount"];
//    NSString *tempFileID = [dic objectForKey:@"fileID"];
//    NSNumber *tempDownload = [NSNumber numberWithInteger:[[dic objectForKey:@"download"] boolValue]];
    
    
    if (tempCloudID)            self.cloudID = tempCloudID;
    if (tempCreateTime)         self.createTime = [tempCreateTime StringToDate];
    if (tempCreator)            self.creator = tempCreator;
    if (tempFolderType)         self.folderType = tempFolderType;
    if (tempName)               self.name = tempName;
    if (tempOwner)              self.owner = tempOwner;
    if (tempParent)             self.parent = tempParent;
    if (tempProject)            self.project = tempProject;
    if (tempStreamBareJidStr)   self.streamBareJidStr = tempStreamBareJidStr;
    
//    if (tempVersionCount)       self.versionCount = tempVersionCount;
//    if (tempDownload)           self.download = tempDownload;
//    if (tempFileID)             self.fileID = tempFileID;
//    if (tempFolderOrFileType)   self.folderOrFileType = tempFolderOrFileType;
//    if (tempUpdateTime)         self.updateTime = [tempUpdateTime StringToDate];
}

@end
