//
//  StaffReports.h
//  GMA1-1
//
//  Created by Jon Vellacott on 07/03/2013.
//  Copyright (c) 2013 Jon Vellacott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Answers, Nodes, Users;

@interface StaffReports : NSManagedObject

@property (nonatomic, retain) NSNumber * endDate;
@property (nonatomic, retain) NSNumber * staffReportId;
@property (nonatomic, retain) NSNumber * startDate;
@property (nonatomic, retain) NSNumber * submitted;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *answers;
@property (nonatomic, retain) Nodes *node;
@property (nonatomic, retain) Users *user;
@end

@interface StaffReports (CoreDataGeneratedAccessors)

- (void)addAnswersObject:(Answers *)value;
- (void)removeAnswersObject:(Answers *)value;
- (void)addAnswers:(NSSet *)values;
- (void)removeAnswers:(NSSet *)values;

@end
