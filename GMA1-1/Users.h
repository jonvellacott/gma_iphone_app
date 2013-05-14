//
//  Users.h
//  GMA1-1
//
//  Created by Jon Vellacott on 14/05/2013.
//  Copyright (c) 2013 Jon Vellacott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StaffReports;

@interface Users : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * renId;
@property (nonatomic, retain) NSSet *staffReports;
@end

@interface Users (CoreDataGeneratedAccessors)

- (void)addStaffReportsObject:(StaffReports *)value;
- (void)removeStaffReportsObject:(StaffReports *)value;
- (void)addStaffReports:(NSSet *)values;
- (void)removeStaffReports:(NSSet *)values;

@end
