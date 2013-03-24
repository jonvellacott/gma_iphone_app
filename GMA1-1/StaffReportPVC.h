//
//  StaffReportPVC.h
//  GMA1-0
//
//  Created by Jon Vellacott on 13/12/2012.
//
//

#import <UIKit/UIKit.h>
#import "Model.h"
@interface StaffReportPVC : UIPageViewController
@property (nonatomic, strong) NSNumber * nodeId;
@property (nonatomic, strong) NSString * nodeName;
@property (nonatomic, weak)  Model *dataModel;

@end
