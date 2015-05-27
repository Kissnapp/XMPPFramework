//
//  XMPPOrgUserCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/26.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface XMPPOrgUserCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userJidStr;
@property (nonatomic, retain) NSString * orgId;
@property (nonatomic, retain) NSString * ptId;

@end
