//
//  XMPPOrgPositionCoreDataStorageObject.h
//  XMPP_Project
//
//  Created by Peter Lee on 15/5/26.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface XMPPOrgPositionCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * ptId;
@property (nonatomic, retain) NSString * ptName;
@property (nonatomic, retain) NSNumber * ptLeft;
@property (nonatomic, retain) NSNumber * ptRight;
@property (nonatomic, retain) NSString * dpId;
@property (nonatomic, retain) NSString * orgId;
@property (nonatomic, retain) NSString * dpName;

@end
