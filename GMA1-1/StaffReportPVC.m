//
//  StaffReportPVC.m
//  GMA1-0
//
//  Created by Jon Vellacott on 13/12/2012.
//
//

#import "StaffReportPVC.h"
#import "QuestionTVC.h"
@interface StaffReportPVC ()

@end

@implementation StaffReportPVC
@synthesize nodeId ;
@synthesize dataModel ;
@synthesize nodeName;

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
    [self addChildViewController: [self getViewControllerForStaffReport:[NSNumber numberWithInt:4693]]];
     
   
    //self.viewcontrollers = [NSArray arrayWithObjects:<#(id), ...#>, nil]
   
}

-(QuestionTVC *) getViewControllerForStaffReport: (NSNumber *)staffReportId
{
    QuestionTVC *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionsTableView"];
    
    
    detailViewController.dataModel = self.dataModel ;
    
    detailViewController.nodeId = self.nodeId ;
    detailViewController.staffReportId = staffReportId;
    
    detailViewController.navigationItem.title = self.nodeName ;	
    return detailViewController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
