//
//  QuestionTVC.m
//  GMA1-0
//
//  Created by Jon Chontelle Vellacott on 30/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuestionTVC.h"




#import "NodeTVC.h"
#import "QuestionCell.h"
#import "TextQuestionCell.h"
#import "QuestionDetailTVC.h"
#import "gmaAPI.h"
#import "LoginViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
@interface QuestionTVC ()

@end

@implementation QuestionTVC


@synthesize dateSegmentedControl = _dateSegmentedControl;

@synthesize staffReportId = _staffReportId ;
@synthesize nodeId = _nodeId ;
@synthesize dataModel = _dataModel;
@synthesize pvc = _pvc;
@synthesize isFirst;
@synthesize isLast;
@synthesize bbSubmit;



#define GMA_Nodes @"gma_node"
#define GMA_StaffReport @"gma_staffReport"

typedef void(^saveBlock)(NSString *);

saveBlock saveValueBlock;
BOOL refreshAfterSave = NO;

-(void)setupFetchedResultsController
{
    
    //self.fethcedResultsController=...
    NSFetchRequest *request = [NSFetchRequest  fetchRequestWithEntityName:@"Answers" ];

     request.predicate = [NSPredicate predicateWithFormat:@"staffReport.staffReportId == %@ AND staffReport.user.renId == %@ AND staffReport.type != 'SubNode' and staffReport.node.nodeId=%@", self.staffReportId, self.dataModel.myRenId, self.nodeId] ;
                         
                         
    request.sortDescriptors =   [NSArray arrayWithObjects: [NSSortDescriptor sortDescriptorWithKey:@"measurement.mcc"  ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"measurement.viewOrder"  ascending:YES] , nil];
   
    NSString * cacheName = [NSString stringWithFormat:@"QuestionTVC-%@",self.staffReportId];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.dataModel.allNodesForUser.managedObjectContext sectionNameKeyPath:@"measurement.mcc" cacheName:cacheName];
     //self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.dataModel.allNodesForUser.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(void)setNodeId:(NSNumber *)nodeId{
    if(self.nodeId!= nodeId){
        _nodeId = nodeId;
        
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
      [prefs setObject:nodeId forKey:@"CurrentNode"] ;
    [prefs synchronize];

    
}

-(void) setStaffReportId:(NSNumber *)staffReportId
{
    if(self.staffReportId!= staffReportId){
        _staffReportId = staffReportId;
        
        
        
        
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:staffReportId forKey:@"CurrentReport"] ;
    

    [prefs synchronize];
}

-(void) setIsSubmitted:(BOOL)isSubmitted
{
    if(isSubmitted!=_isSubmitted){
        
      
        self.bbSubmit.enabled = !isSubmitted;
        
        //self.btnSubmit.enabled = !isSubmitted;
        if(isSubmitted){
            [self.bbSubmit  setTitle:@"Submitted" ];
           
            
        }
        else{
            
                [self.bbSubmit setTitle:@"Submit" ];
           // self.bbSubmit.hidden=NO;
        }
    }
}












- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //self.debug=YES;
              
    }
    
    return self;
}



-(void) awakeFromNib
{
    [super awakeFromNib];     
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // returns the same tracker you created in your app delegate
    // defaultTracker originally declared in AppDelegate.m
    id tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-29919940-5"];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value: self.navigationItem.title ];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
  
  

       
        // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    
        
    saveValueBlock = ^(NSString *result) {
         self.suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
        if([result isEqualToString:GMA_NO_CONNECT] )
        {
            UIAlertView *av = [[UIAlertView alloc]  initWithTitle:@"Connect Failed" message:GMA_NOCONNECT_Message delegate:self cancelButtonTitle:GMA_OFFLINE otherButtonTitles:GMA_TRY_AGAIN, nil];
            dispatch_async(dispatch_get_main_queue(), ^{  [av show]; });
        }
        else if([result isEqualToString:GMA_NO_AUTH])
        {
            
            self.dataModel.offlineMode = YES;
            [self.dataModel.alertBarController showMessage:GMA_OFFLINE_MODE withBackgroundColor: [UIColor redColor]  withSpinner: NO];
            
            [self showLoginScreenWithError:NO];
            
            
            
            
        }
        else if([result isEqualToString:GMA_SUCCESS])
        {
            
            [self.dataModel.alertBarController hideAlertBar];
            
            //if(refreshAfterSave)
            //{
           //     [self refresh];
                
            //}
        }
        else if([result isEqualToString:GMA_OFFLINE_MODE])
        {
            [self.dataModel.alertBarController showMessage:GMA_OFFLINE_MODE withBackgroundColor: [UIColor redColor]   withSpinner: NO];
        }
        else
        {
            //FAIL
            if(refreshAfterSave)
            {
                UIAlertView *av = [[UIAlertView alloc]  initWithTitle:@"Error" message:@"One or more of your measurements was rejected by the GMA server, and has been reverted to its original value. This probably because you do not have permission to change this measurement." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                dispatch_async(dispatch_get_main_queue(), ^{  [av show];  [self.refreshControl endRefreshing]; });
                
                
            }
            else{
                UIAlertView *av = [[UIAlertView alloc]  initWithTitle:@"Error" message:@"GMA Server did not allow you to save this measurement. The value has been reverted back to its original value" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                dispatch_async(dispatch_get_main_queue(), ^{  [av show]; });
            }
            
            [self performFetch];
            
            [self.dataModel.alertBarController hideAlertBar];
            
            
        }
        
        
        
    } ;

    
    
}



-(void) setHeader
{
    NSDictionary *interval = [StaffReports getIntervalForStaffReport:self.staffReportId inManagedObjectConext:self.dataModel.allNodesForUser.managedObjectContext];
    if(interval)
    {
        if([[interval objectForKey:@"interval"] isEqualToString:@"Monthly"])
            [self.dateSegmentedControl setTitle: [self getMonthNameFromDate:[interval objectForKey:@"startDate"] ] forSegmentAtIndex:1 ];
        self.startDate = [interval objectForKey:@"rawStartDate"] ;
        
            
   }
    [self.dateSegmentedControl setEnabled:isFirst==NO forSegmentAtIndex:0];
    [self.dateSegmentedControl setEnabled:isLast==NO forSegmentAtIndex:2];
   
    self.bbSubmit = [[UIBarButtonItem alloc] initWithTitle:@"Submitted" style:UIBarButtonItemStylePlain target: self action:@selector(submitReport:)];
    self.bbSubmit.enabled = !self.isSubmitted;
    self.bbSubmit.title = self.isSubmitted ? @"Submitted" : @"Submit" ;
    //removed submit button for now
   // self.pvc.navigationItem.rightBarButtonItem = self.bbSubmit;
    
    
    
}



- (NSString *)getMonthNameFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    [dateFormatter setDateFormat:@"MMM yyyy"];
    return [dateFormatter stringFromDate:date];
    
}
-(void) refresh {
    self.dataModel.offlineMode = NO;
    if(!self.dataModel.isCacheEmpty)
    {
        //We must first save these
        refreshAfterSave=YES;
        UIAlertView *av = [[UIAlertView alloc]  initWithTitle: GMA_REFRESH_CACHE message:GMA_REFRESH_CACHE_Message delegate:self cancelButtonTitle:@"Refresh" otherButtonTitles:@"Save Changes", nil];
        dispatch_async(dispatch_get_main_queue(), ^{  [av show]; });
        
      
    }
    else{
        refreshAfterSave=NO;
        [self.dataModel fetchStaffReport:self.staffReportId forNode:self.nodeId  atDate: self.startDate completionHandler:^{
            // run on main thread.
           // [self.dataModel.allNodesForUser.managedObjectContext performBlock:^{
                [self performFetch];
                
            //}];
            
            
            [self.refreshControl endRefreshing];
        }] ;
        
    }
   
    
    
    
    
          
    
}

-(void) reloadTheStupidTable
{
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.tableView reloadData];
    NSLog(@"Sections: %ld",(long)self.tableView.numberOfSections);
    });
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated] ;
    

 

    
 
    if(!self.fetchedResultsController)
    {
        [self setupFetchedResultsController];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                 (unsigned long)NULL), ^(void) {
            [self.dataModel fetchStaffReport:self.staffReportId forNode:self.nodeId  atDate: self.startDate completionHandler:^{
                [self performFetch];
            }] ;
        });
        
    }
    [self setHeader];
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        
        [NSThread sleepForTimeInterval:0.2f];
        dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        });
    });
                   
    
  
}



-(void) viewWillDisappear:(BOOL)animated
{	
    [self.view endEditing:YES];
    [self dismissPickerView];
    [super viewWillDisappear:animated];
    
}

- (void)viewWillUnload
{
   
    [self.dataModel saveModel];
  
     [super viewWillUnload];
    
 
    
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
   return  nil;
}



- (void)viewDidUnload
{
      [super viewDidUnload];
    
    [self setDateSegmentedControl:nil];
   
    [self setBbSubmit:nil];
    [self dismissPickerView];
    [self.view endEditing:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void) saveAnswerForMeasurementId:(NSNumber *)measurementId measurementType: (NSString *) measurementType inStaffReport:(NSNumber *)  staffReportId withValue:(NSString *)value oldValue:(NSString *) oldValue
{
  // [self  performFetch];
    id tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-29919940-5"];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"measurement changed"  // Event action (required)
                                                           label:staffReportId.stringValue         // Event label
                                                           value:measurementId ] build]];    // Event value

    self.suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    [self.dataModel saveModelAnswerForMeasurementId:measurementId measurementType:measurementType inStaffReport:staffReportId atNodeId:self.nodeId  withValue:value oldValue:oldValue completionHandler: saveValueBlock];
        
}
-(void) showLoginScreenWithError: (BOOL) error
{
    //need to detect if autolog has already displayed login
    LoginViewController *lvc =   [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    if(error)
        lvc.lblLoginFailed.Text = @"Login Failed";
    else
        lvc.lblLoginFailed.Text = @"";
    
    lvc.nodesTVC = [self.navigationController.viewControllers objectAtIndex:0] ;
     self.dataModel.forceSave = YES;
    // [self.navigationController  pushViewController:lvc  animated:YES ];
    dispatch_async(dispatch_get_main_queue(), ^{  [self presentViewController:lvc animated: YES completion:nil  ];
 });
    }

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *message = alertView.message;
    NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([message isEqualToString: GMA_NOCONNECT_Message]){
        if([btnTitle isEqualToString: GMA_TRY_AGAIN])
        {
           //Try Again...
            
        }
        else{
            self.dataModel.offlineMode = YES;
            [self.dataModel.alertBarController showMessage:GMA_OFFLINE_MODE withBackgroundColor:[UIColor redColor]  withSpinner: NO];
        }
    }
    else if ([alertView.title isEqualToString: GMA_REFRESH_CACHE])
    {
        if (buttonIndex == 0) {
            [self.dataModel emptyCacheStack];
            [self refresh];
        }
        else
        {
            [self.dataModel clearCacheStackWithCompletionHandler:saveValueBlock];
        }
          
    }
   
        
    
    
}



- (IBAction)segmentAction:(id)sender {
    UISegmentedControl * control = sender;
    long selectedIndex = [control selectedSegmentIndex];
    if(selectedIndex==0)
    {
        [self.pvc turnLeftFromSender:self];
        
        
    }
    else if (selectedIndex==2){
        
        [self.pvc turnRightFromSender:self];
    }

}

- (IBAction)submitReport:(id)sender {
    //Submit
    
    [self.dataModel submitStaffReportId: self.staffReportId ];
    self.isSubmitted = YES;
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSArray *objects = [sectionInfo objects];
    NSString *title = @"";
    if(objects.count>0){
    NSManagedObject *managedObject = [objects objectAtIndex:0];
    Measurements *m =[managedObject valueForKey:@"measurement"];
    
    if(m)
    {
        if(![m.mcc isEqualToString:@"zzz"])
           title= [m.mcc stringByAppendingString:@":"];
    }
        
    }
    return title;
    
  }





- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    Answers *a = [self.fetchedResultsController objectAtIndexPath:indexPath];
     self.isSubmitted = [a.staffReport.submitted boolValue];
    //NSLog(@"Type: %@",a.measurement.type );
    if([a.measurement.type isEqualToString: @"Numeric"])
    {
         NSString *CellIdentifier = @"QuestionCell";
        if([self.nodeId intValue] <0){
            CellIdentifier = @"DirectorQuestionCell";
        }
        QuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[QuestionCell alloc]   initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier ] ;
            
        }
        
        cell.tvc=self;
        cell.tvcd=nil;
        cell.title.text= a.measurement.name;
        
        [QuestionCell resizeFontForLabel:cell.title maxSize:14 minSize:10 labelWidth:202 labelHeight:32];
        
        
        cell.answer.text= a.value;
        cell.answer.hidden = NO;
        [cell.answer setEnabled:YES];
        cell.lblAnswer.hidden = YES;
        [cell.addButton setHidden:NO];
        cell.measurementId  =a.measurement.measurementId;
        cell.measurementType = a.measurement.type ;
        cell.staffReportId = a.staffReport.staffReportId;
        cell.lblCalc.hidden = YES;
        
        
        
        
        cell.isDirector = [self.nodeId intValue] <0;
        
    
        if(cell.isDirector)
        {
            
            
            NSFetchRequest *request = [NSFetchRequest  fetchRequestWithEntityName:@"Answers" ];
             NSError *error = nil;
            request.predicate = [NSPredicate predicateWithFormat:@"measurement.measurementId == %@ AND staffReport.startDate == %@", a.measurement.measurementId, a.staffReport.startDate] ;
            
            NSArray *matches = [self.dataModel.allNodesForUser.managedObjectContext executeFetchRequest:request error:&error];
            if(matches)
                cell.totalAnswer.text=[[matches valueForKeyPath:@"@sum.value"] stringValue];
            else
                cell.totalAnswer.Text = @"0";
            
            
        }
        
        cell.answer.rightViewMode = UITextFieldViewModeUnlessEditing ;
        //cell.answer.rightView = btnAdd;
        
        return cell;

    }
    else if([a.measurement.type isEqualToString: @"Text"])
    {
         NSString *CellIdentifier = @"TextQuestionCell";
        
        TextQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[TextQuestionCell alloc]   initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier ] ;
            
        }
        
        cell.tvc=self;
        cell.tvcd=nil;
        cell.title.text= a.measurement.name;
        [QuestionCell resizeFontForLabel:cell.title maxSize:14 minSize:10 labelWidth:202 labelHeight:32];
        
        cell.answer.text= a.value;
        cell.measurementId  =a.measurement.measurementId;
        cell.staffReportId = a.staffReport.staffReportId;
        
       

        
        return cell;

    }
        //Calculated measurement
    
    NSString *CellIdentifier = @"QuestionCell";
    
   // if([self.nodeId intValue] <0){
   //     CellIdentifier = @"DirectorQuestionCell";
    //}
    QuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[QuestionCell alloc]   initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier ] ;
        
    }
  
    cell.tvc=self;
    cell.tvcd=nil;
    cell.title.text= a.measurement.name;
    [QuestionCell resizeFontForLabel:cell.title maxSize:14 minSize:10 labelWidth:202 labelHeight:32];
    cell.lblCalc.hidden = NO;
    cell.subTitle.text = a.measurement.type;
    //cell.textLabel.text = a.measurement.name;
   // cell.detailTextLabel.text = a.measurement.type;
   // cell.answer.text= a.value;
    cell.answer.hidden=YES;
    cell.lblAnswer.text = a.value;
    cell.lblAnswer.hidden = NO;
    
    cell.measurementId  =a.measurement.measurementId;
    cell.measurementType = a.measurement.type ;
    cell.staffReportId = a.staffReport.staffReportId;
    
    cell.isDirector = [self.nodeId intValue] <0;
    if(cell.isDirector)
    {
        
        cell.accessoryType = UITableViewCellAccessoryNone ;
        NSFetchRequest *request = [NSFetchRequest  fetchRequestWithEntityName:@"Answers" ];
        NSError *error = nil;
        request.predicate = [NSPredicate predicateWithFormat:@"measurement.measurementId == %@ AND staffReport.startDate == %@", a.measurement.measurementId, a.staffReport.startDate] ;
        
        NSArray *matches = [self.dataModel.allNodesForUser.managedObjectContext executeFetchRequest:request error:&error];
        if(matches)
            cell.totalAnswer.text=[[matches valueForKeyPath:@"@sum.value"] stringValue];
        else
            cell.totalAnswer.Text = @"0";
        
      
    }
    
    cell.answer.rightViewMode = UITextFieldViewModeUnlessEditing ;
    //cell.answer.rightView = btnAdd;
    [cell.answer setEnabled:NO];
    [cell.addButton setHidden:YES];
    return cell;
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Answers *a = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //NSLog(@"Type: %@",a.measurement.type );
    if([a.measurement.type isEqualToString: @"Text"])
    {
        return 100;
    }
    if([a.measurement.type isEqualToString: @"Calculated"])
    {
        return 45;
    }
    else 
    {
        if([self.nodeId intValue]<0)
            return 55;
        else
             return 45;
    }
    
    
}



-(void) calculateTotalsForCell: (QuestionCell   *) cell{
    NSFetchRequest *request = [NSFetchRequest  fetchRequestWithEntityName:@"Answers" ];
    NSError *error = nil;
    request.predicate = [NSPredicate predicateWithFormat:@"measurement.measurementId == %@ AND staffReport.startDate == %@", cell.measurementId, self.startDate] ;
    
    NSArray *matches = [self.dataModel.allNodesForUser.managedObjectContext executeFetchRequest:request error:&error];
    if(matches)
        cell.totalAnswer.text=[[matches valueForKeyPath:@"@sum.value"] stringValue];
    else
        cell.totalAnswer.Text = @"0";
    
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
  }
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
   
    QuestionDetailTVC *qdtvc =  [self.storyboard instantiateViewControllerWithIdentifier:@"Question Detail"];
    
    qdtvc.nodeId = self.nodeId;
    qdtvc.dataModel = self.dataModel;
    qdtvc.startDate = self.startDate;
    
    Answers *a = [self.fetchedResultsController objectAtIndexPath:indexPath];
    qdtvc.measurement = a.measurement;
     qdtvc.navigationItem.title = a.measurement.name;
    
    [self.navigationController pushViewController:qdtvc animated:YES];
        
    
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //resign all keypads of all textfields use array containing keypads
    [self.view endEditing:YES];
}
-(void) dismissPickerView
{
    
    for(UITableViewCell *cell in self.tableView.visibleCells)
    {
        if([cell isMemberOfClass: [QuestionCell class]]){
            QuestionCell *qc = (QuestionCell *)cell;
            
            
            if([qc.answer dismissPickerView ])
            {
              [qc asnwerChanged:nil ];
                if(self.staffReportId.intValue<0)  //Director Report
                {
                    [self calculateTotalsForCell:qc];
                    
                }
            }
            
        }
    }
    
   
    
}

@end
