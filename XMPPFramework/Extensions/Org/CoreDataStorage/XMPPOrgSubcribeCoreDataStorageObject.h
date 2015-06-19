//
//  XMPPOrgSubcribeCoreDataStorageObject.h
//  
//
//  Created by Peter Lee on 15/6/18.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSUInteger, XMPPOrgSubcribeState) {
    XMPPOrgSubcribeStateNotHandle = 0,
    XMPPOrgSubcribeStateAccept,
    XMPPOrgSubcribeStateRefuse
};

@interface XMPPOrgSubcribeCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * formOrgId;
@property (nonatomic, retain) NSString * fromOrgName;
@property (nonatomic, retain) NSString * toOrgId;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * streamBareJidStr;




@end
