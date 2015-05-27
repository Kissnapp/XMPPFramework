//
//  XMPPOrgCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/26.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface XMPPOrgCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * orgId;
@property (nonatomic, retain) NSString * orgName;
@property (nonatomic, retain) NSNumber * orgState;
@property (nonatomic, retain) NSDate * orgStartTime;
@property (nonatomic, retain) NSDate * orgEndTime;
@property (nonatomic, retain) NSString * orgAdminJidStr;
@property (nonatomic, retain) NSString * orgDescription;

@end
