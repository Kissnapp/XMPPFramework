//
//  XMPPCloudCoreDataStorageObject.m
//  XMPP_Project
//
//  Created by jeff on 15/10/20.
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
@dynamic folderIsMe;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - primitive Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//- (NSMutableDictionary *)propertyTransformDictionary
//{
//    NSMutableDictionary *keysMapDic = [super propertyTransformDictionary];
//    return keysMapDic;
//}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)cloudID
{
    [self willAccessValueForKey:@"cloudID"];
    NSString *value = [self primitiveValueForKey:@"cloudID"];
    [self didAccessValueForKey:@"cloudID"];
    return value;
}
- (void)setCloudID:(NSString *)value
{
    [self willChangeValueForKey:@"cloudID"];
    [self setPrimitiveValue:value forKey:@"cloudID"];
    [self didChangeValueForKey:@"cloudID"];
}

- (NSDate *)createTime
{
    [self willAccessValueForKey:@"createTime"];
    NSDate *value = [self primitiveValueForKey:@"createTime"];
    [self didAccessValueForKey:@"createTime"];
    return value;
}
- (void)setCreateTime:(NSDate *)value
{
    [self willChangeValueForKey:@"createTime"];
    [self setPrimitiveValue:value forKey:@"createTime"];
    [self didChangeValueForKey:@"createTime"];
}


- (NSString *)creator
{
    [self willAccessValueForKey:@"creator"];
    NSString *value = [self primitiveValueForKey:@"creator"];
    [self didAccessValueForKey:@"creator"];
    return value;
}
- (void)setCreator:(NSString *)value
{
    [self willChangeValueForKey:@"creator"];
    [self setPrimitiveValue:value forKey:@"creator"];
    [self didChangeValueForKey:@"creator"];
}


- (NSNumber *)folderType
{
    [self willAccessValueForKey:@"folderType"];
    NSNumber *value = [self primitiveValueForKey:@"folderType"];
    [self didAccessValueForKey:@"folderType"];
    return value;
}
- (void)setFolderType:(NSNumber *)value
{
    [self willChangeValueForKey:@"folderType"];
    [self setPrimitiveValue:value forKey:@"folderType"];
    [self didChangeValueForKey:@"folderType"];
}

- (NSString *)name
{
    [self willAccessValueForKey:@"name"];
    NSString *value = [self primitiveValueForKey:@"name"];
    [self didAccessValueForKey:@"name"];
    return value;
}
- (void)setName:(NSString *)value
{
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveValue:value forKey:@"name"];
    [self didChangeValueForKey:@"name"];
}

- (NSString *)owner
{
    [self willAccessValueForKey:@"owner"];
    NSString *value = [self primitiveValueForKey:@"owner"];
    [self didAccessValueForKey:@"owner"];
    return value;
}
- (void)setOwner:(NSString *)value
{
    [self willChangeValueForKey:@"owner"];
    [self setPrimitiveValue:value forKey:@"owner"];
    [self didChangeValueForKey:@"owner"];
}

- (NSNumber *)parent
{
    [self willAccessValueForKey:@"parent"];
    NSNumber *value = [self primitiveValueForKey:@"parent"];
    [self didAccessValueForKey:@"parent"];
    return value;
}
- (void)setParent:(NSNumber *)value
{
    [self willChangeValueForKey:@"parent"];
    [self setPrimitiveValue:value forKey:@"parent"];
    [self didChangeValueForKey:@"parent"];
}

- (NSString *)project
{
    [self willAccessValueForKey:@"project"];
    NSString *value = [self primitiveValueForKey:@"project"];
    [self didAccessValueForKey:@"project"];
    return value;
}
- (void)setProject:(NSString *)value
{
    [self willChangeValueForKey:@"project"];
    [self setPrimitiveValue:value forKey:@"project"];
    [self didChangeValueForKey:@"project"];
}

- (NSString *)streamBareJidStr
{
    [self willAccessValueForKey:@"streamBareJidStr"];
    NSString *value = [self primitiveValueForKey:@"streamBareJidStr"];
    [self didAccessValueForKey:@"streamBareJidStr"];
    return value;
}
- (void)setStreamBareJidStr:(NSString *)value
{
    [self willChangeValueForKey:@"streamBareJidStr"];
    [self setPrimitiveValue:value forKey:@"streamBareJidStr"];
    [self didChangeValueForKey:@"streamBareJidStr"];
}

- (NSNumber *)folderOrFileType
{
    [self willAccessValueForKey:@"folderOrFileType"];
    NSNumber *value = [self primitiveValueForKey:@"folderOrFileType"];
    [self didAccessValueForKey:@"folderOrFileType"];
    return value;
}
- (void)setFolderOrFileType:(NSNumber *)value
{
    [self willChangeValueForKey:@"folderOrFileType"];
    [self setPrimitiveValue:value forKey:@"folderOrFileType"];
    [self didChangeValueForKey:@"folderOrFileType"];
}

- (NSNumber *)folderIsMe
{
    [self willAccessValueForKey:@"folderIsMe"];
    NSNumber *value = [self primitiveValueForKey:@"folderIsMe"];
    [self didAccessValueForKey:@"folderIsMe"];
    return value;
}
- (void)setFolderIsMe:(NSNumber *)value
{
    [self willChangeValueForKey:@"folderIsMe"];
    [self setPrimitiveValue:value forKey:@"folderIsMe"];
    [self didChangeValueForKey:@"folderIsMe"];
}




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



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Creation & Updates
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ (BOOL)deleteInManagedObjectContext:(NSManagedObjectContext *)moc cloudID:(NSString *)cloudID streamBareJidStr:(NSString *)streamBareJidStr
{
    if (cloudID == nil) return NO;
    if (moc == nil) return NO;
    if (streamBareJidStr == nil) return NO;
    
    XMPPCloudCoreDataStorageObject *deleteObject = [XMPPCloudCoreDataStorageObject objectInManagedObjectContext:moc cloudID:cloudID streamBareJidStr:streamBareJidStr];
    if (deleteObject) {
        [moc deleteObject:deleteObject];
        return YES;
    }
    return NO;
}

+ (id)objectInManagedObjectContext:(NSManagedObjectContext *)moc cloudID:(NSString *)cloudID streamBareJidStr:(NSString *)streamBareJidStr
{
    if (cloudID == nil) return nil;
    if (moc == nil) return nil;
    if (streamBareJidStr == nil) return nil;
    
    NSString *entityName = NSStringFromClass([XMPPCloudCoreDataStorageObject class]);
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cloudID == %@ AND streamBareJidStr == %@", cloudID, streamBareJidStr];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    return (XMPPCloudCoreDataStorageObject *)[results lastObject];
}


+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc dic:(NSDictionary *)dic streamBareJidStr:(NSString *)streamBareJidStr
{
    NSString *entityName = NSStringFromClass([XMPPCloudCoreDataStorageObject class]);
    XMPPCloudCoreDataStorageObject *newCloud = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
    newCloud.streamBareJidStr = streamBareJidStr;
    [newCloud updateWithDic:dic];
    return newCloud;
}

- (void)updateWithDic:(NSDictionary *)dic
{
    NSString *tempCloudID = [dic objectForKey:@"id"];
    NSString *tempCreateTime = [NSString stringWithFormat:@"%@", [dic objectForKey:@"Time"]];
    NSString *tempCreator = [dic objectForKey:@"creator"];
    NSNumber *tempFolderType = [NSNumber numberWithInteger:[[dic objectForKey:@"type"] integerValue]];
    NSString *tempName = [NSString stringWithFormat:@"%@", [dic objectForKey:@"name"]];
    NSString *tempOwner = [dic objectForKey:@"owner"];
    NSNumber *tempParent = [NSNumber numberWithInteger:[[dic objectForKey:@"parent"] integerValue]];
    NSString *tempProject = [dic objectForKey:@"project"];
    NSString *tempStreamBareJidStr = [dic objectForKey:@"streamBareJidStr"];
    NSNumber *tempFolderOrFileType = [NSNumber numberWithInteger:[[dic objectForKey:@"folderOrFileType"] integerValue]];
    NSNumber *tempFolderIsMe = [NSNumber numberWithInteger:[[dic objectForKey:@"folderIsMe"] integerValue]];
    
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
    if (tempFolderOrFileType)   self.folderOrFileType = tempFolderOrFileType;
    if (tempFolderIsMe)         self.folderIsMe = tempFolderIsMe;;
    
    
    //    if (tempVersionCount)       self.versionCount = tempVersionCount;
    //    if (tempDownload)           self.download = tempDownload;
    //    if (tempFileID)             self.fileID = tempFileID;
    //    if (tempUpdateTime)         self.updateTime = [tempUpdateTime StringToDate];
}

@end
