//
//  pvcNode.h
//  GMA1-0
//
//  Created by Jon Vellacott on 13/12/2012.
//
//

#import <UIKit/UIKit.h>
#import "Model.h"
#import "Nodes.h"
@interface pvcNode : UIViewController<UIPageViewControllerDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, weak) Nodes * node;

@property (nonatomic, weak)  Model *dataModel;
@property (nonatomic, strong) NSNumber *firstStaffReport;
@property (nonatomic, strong) NSNumber *lastStaffReport;


@property (nonatomic, strong) UIPageViewController *pageViewController;
- (void)turnLeftFromSender: (UIViewController *)sender;
- (void)turnRightFromSender: (UIViewController *)sender;
@end
