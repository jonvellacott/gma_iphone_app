//
//  Answers.h
//  GMA1-1
//
//  Created by Jon Vellacott on 14/05/2013.
//  Copyright (c) 2013 Jon Vellacott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Measurements, StaffReports;

@interface Answers : NSManagedObject

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) Measurements *measurement;
@property (nonatomic, retain) StaffReports *staffReport;

@end
