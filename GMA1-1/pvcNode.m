//
//  pvcNode.m
//  GMA1-0
//
//  Created by Jon Vellacott on 13/12/2012.
//
//

#import "pvcNode.h"
#import "QuestionTVC.h"
#import "StaffReports.h"
@interface pvcNode ()

@end

@implementation pvcNode

@synthesize node;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSDictionary *options= [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger: UIPageViewControllerSpineLocationMax] forKey:UIPageViewControllerOptionSpineLocationKey];
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    [self.pageViewController setDataSource:self];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"user.renId==%@ AND type!='SubNode'", self.dataModel.myRenId] ;
    
    
    NSSortDescriptor *startDate = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
    
    StaffReports *sr = [[[self.node.staffReports filteredSetUsingPredicate:pred] sortedArrayUsingDescriptors:[NSArray arrayWithObject:startDate] ]  lastObject];

    
    
    self.lastStaffReport = sr.staffReportId;
    NSSortDescriptor *startDateDesc = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO];
    self.firstStaffReport = ((StaffReports *)[[self.node.staffReports sortedArrayUsingDescriptors:[NSArray arrayWithObject:startDateDesc] ]  lastObject]).staffReportId;
    
    
    
    QuestionTVC *initialViewController = [self getViewControllerForStaffReport:sr.staffReportId];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    
    [self.pageViewController.view setFrame: self.view.bounds];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    for (UIGestureRecognizer *gR in self.pageViewController.gestureRecognizers) {
        if ([gR isKindOfClass:[UITapGestureRecognizer class]])
        {
            gR.enabled = NO;
        }
        else if ([gR isKindOfClass:[UIPanGestureRecognizer class]])
        {
            gR.delegate = self;
        }
      
    }

    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)turnLeftFromSender: (UIViewController *)sender
{
    UIViewController *prev= [self pageViewController:self.pageViewController viewControllerBeforeViewController:sender];
    if(prev)
    {
         NSArray *viewControllers = [NSArray arrayWithObject:prev];
        
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }
    
}

- (void)turnRightFromSender: (UIViewController *)sender
{
    UIViewController *next= [self pageViewController:self.pageViewController viewControllerAfterViewController:sender];
    if(next)
    {
        NSArray *viewControllers = [NSArray arrayWithObject:next];
        	
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    QuestionTVC *qTVC=(QuestionTVC *)viewController;
   
    NSSet *o = [self.node.staffReports objectsPassingTest:^(id obj,BOOL *stop){
        StaffReports *sr = (StaffReports *)obj;
        
        
        // accept objects less or equal to two
        BOOL r = (sr.startDate.intValue > qTVC.startDate.intValue) && (![sr.type isEqualToString: @"SubNode"]);
        
        return r;
    }];
    
    if(o.count>0)
    {
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"staffReportId" ascending:NO];
        NSArray *oArray = [o sortedArrayUsingDescriptors: [NSArray arrayWithObject: sort ]];
        return [self getViewControllerForStaffReport:((StaffReports *)[oArray lastObject]).staffReportId] ;
        
        
        
    }
    return nil;
    
}


-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    QuestionTVC *qTVC=(QuestionTVC *)viewController;
    
    
    NSSet *o = [self.node.staffReports objectsPassingTest:^(id obj,BOOL *stop){
        StaffReports *sr = (StaffReports *)obj;
        
        
        // accept objects less or equal to two
        
        
        BOOL r = (sr.startDate.intValue < qTVC.startDate.intValue) && [sr.user.renId intValue] == [self.dataModel.myRenId intValue];
        
        return r;
    }];
    
    if(o.count>0)
    {
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
        NSArray *oArray = [o sortedArrayUsingDescriptors: [NSArray arrayWithObject: sort]];
        return [self getViewControllerForStaffReport:((StaffReports *)[oArray lastObject]).staffReportId];
        
        
        
    }
    return nil;
    
    
    
}

-(QuestionTVC *) getViewControllerForStaffReport: (NSNumber *)staffReportId
{
   // QuestionTVC *detailViewController = [[QuestionTVC alloc] init];
  
  
    
      QuestionTVC *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionsTableView"];
    
    detailViewController.nodeId = self.node.nodeId ;
    
    detailViewController.staffReportId = staffReportId;
    detailViewController.dataModel = self.dataModel ;
   
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"staffReportId == %@", staffReportId];
    NSArray *results = [self.node.staffReports.allObjects filteredArrayUsingPredicate:predicate];
    detailViewController.startDate = ((StaffReports *)results.lastObject).startDate;
    detailViewController.pvc = self;
   
    
    detailViewController.isLast=[staffReportId isEqualToNumber:self.lastStaffReport];
    detailViewController.isFirst=[staffReportId isEqualToNumber:self.firstStaffReport];
    

    
        
    
    detailViewController.navigationItem.title = self.node.name ;
    return detailViewController;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer  class]]){
      
        return NO;
        
    }
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] ) {
      
        
        
        
        
        CGPoint point = [touch locationInView:self.view];
        
        if(point.x < self.view.bounds.size.width *0.75) return YES;
        
    }
    return NO;
}
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] ) {
        UIView *cell = [gestureRecognizer view];
        UIPanGestureRecognizer *p = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point =  [ p velocityInView:cell] ;
        QuestionTVC *qTVC=(QuestionTVC *)self.pageViewController.viewControllers.lastObject;
        
        if(point.x > point.y)
        {
            
            
            NSSet *o = [self.node.staffReports objectsPassingTest:^(id obj,BOOL *stop){
                StaffReports *sr = (StaffReports *)obj;
                
                BOOL r = (sr.startDate.intValue < qTVC.startDate.intValue) && [sr.user.renId intValue] == [self.dataModel.myRenId intValue];
                
                return r;
            }];
             return o.count>0;
            
        }
        else{
            NSSet *o = [self.node.staffReports objectsPassingTest:^(id obj,BOOL *stop){
                StaffReports *sr = (StaffReports *)obj;
                
                
                // accept objects less or equal to two
                BOOL r = (sr.startDate.intValue > qTVC.startDate.intValue) && (![sr.type isEqualToString: @"SubNode"]);
                
                return r;
            }];
            
            return o.count>0 ;
        }
       
        
    }
    
return YES;
}

@end


