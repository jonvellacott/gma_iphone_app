//
//  QuestionTVC.h
//  GMA1-0
//
//  Created by Jon Chontelle Vellacott on 30/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Nodes.h"
#import "Model.h"
#import "pvcNode.h"

@interface QuestionTVC : CoreDataTableViewController <UIAlertViewDelegate>



@property (nonatomic, strong) NSNumber *staffReportId;
@property (nonatomic, strong) NSNumber *nodeId;

@property (nonatomic, strong) UIBarButtonItem *bbSubmit;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dateSegmentedControl;
@property (nonatomic, weak)  Model *dataModel;
@property (nonatomic, strong) NSNumber *startDate;
@property (nonatomic, assign) BOOL isLast;
@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, assign) BOOL isSubmitted;

@property (nonatomic, weak)  pvcNode *pvc;

- (void) saveAnswerForMeasurementId:(NSNumber *)measurementId measurementType: (NSString *) measurementType inStaffReport:(NSNumber *)  staffReportId withValue:(NSString *)value oldValue:(NSString *) oldValue ;

- (IBAction)segmentAction:(id)sender;

- (IBAction)submitReport:(id)sender;
-(void) refresh ;
-(void) dismissPickerView;

@end
