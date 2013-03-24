//
//  QuestionDetailTVC.h
//  GMA1-0
//
//  Created by Jon Chontelle Vellacott on 01/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Model.h"



@interface QuestionDetailTVC : CoreDataTableViewController <UIAlertViewDelegate>

@property (nonatomic, weak)  Model *dataModel;
@property (nonatomic, strong) NSNumber *startDate;
@property (nonatomic, strong) NSNumber *nodeId;
@property (nonatomic, strong) Measurements *measurement;
@property (nonatomic, strong)  UILabel *Total;

-(void) calculateTotal;
- (void) saveAnswerForMeasurementId:(NSNumber *)measurementId  measurementType: (NSString *) measurementType inStaffReport:(NSNumber *)  staffReportId atNodeId: (NSNumber *)childNodeId withValue:(NSString *)value oldValue: (NSString *) oldValue;
@end
