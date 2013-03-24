//
//  Nodes.h
//  GMA1-1
//
//  Created by Jon Vellacott on 07/03/2013.
//  Copyright (c) 2013 Jon Vellacott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Measurements, StaffReports;

@interface Nodes : NSManagedObject

@property (nonatomic, retain) NSString * autoSubmitReport;
@property (nonatomic, retain) NSNumber * autoSubmitWHQReport;
@property (nonatomic, retain) NSNumber * directorNode;
@property (nonatomic, retain) NSNumber * dueDate;
@property (nonatomic, retain) NSString * interval;
@property (nonatomic, retain) NSNumber * isInactive;
@property (nonatomic, retain) NSNumber * isWHQReportingNode;
@property (nonatomic, retain) NSNumber * locationId;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * nodeId;
@property (nonatomic, retain) NSString * passPhrase;
@property (nonatomic, retain) NSNumber * reportStartDate;
@property (nonatomic, retain) NSNumber * sendStaffRemiderEmail;
@property (nonatomic, retain) NSNumber * timezone;
@property (nonatomic, retain) NSSet *measurements;
@property (nonatomic, retain) NSSet *staffReports;
@end

@interface Nodes (CoreDataGeneratedAccessors)

- (void)addMeasurementsObject:(Measurements *)value;
- (void)removeMeasurementsObject:(Measurements *)value;
- (void)addMeasurements:(NSSet *)values;
- (void)removeMeasurements:(NSSet *)values;

- (void)addStaffReportsObject:(StaffReports *)value;
- (void)removeStaffReportsObject:(StaffReports *)value;
- (void)addStaffReports:(NSSet *)values;
- (void)removeStaffReports:(NSSet *)values;

@end
