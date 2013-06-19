//
//  QuestionDetailTVC.m
//  GMA1-0
//
//  Created by Jon Chontelle Vellacott on 01/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuestionDetailTVC.h"
#import "QuestionCell.h"
#import "TextQuestionCell.h"

@interface QuestionDetailTVC ()

@end

@implementation QuestionDetailTVC

@synthesize dataModel;
@synthesize startDate;
@synthesize nodeId;
@synthesize measurement;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)setupFetchedResultsController
{
    
    //self.fethcedResultsController=...
    NSFetchRequest *request = [NSFetchRequest  fetchRequestWithEntityName:@"Answers" ];
    
    request.predicate = [NSPredicate predicateWithFormat:@"measurement.measurementId == %@ AND staffReport.startDate == %@", self.measurement.measurementId, self.startDate] ;
    
    
    request.sortDescriptors =   [NSArray arrayWithObjects: [NSSortDescriptor sortDescriptorWithKey:@"staffReport.type"  ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"staffReport.user.name"  ascending:NO], nil ];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.dataModel.allNodesForUser.managedObjectContext sectionNameKeyPath:@"staffReport.Type" cacheName:nil];
}

- (void)viewWillUnload
{
    [self.dataModel saveModel];
       
}
-(void) viewWillDisappear:(BOOL)animated
{
    [self dismissPickerView];
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

   
  
    
    [self setupFetchedResultsController];
    
    
    
   if(!self.tableView.tableFooterView)
   {
    CGRect footerRect = CGRectMake(0, 0, self.view.frame.size.width, 20);
    UIView *tableFooter = [[UIView alloc] initWithFrame:footerRect];
    tableFooter.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    tableFooter.opaque= NO;
    
    CGRect titleRect = CGRectMake(0, 0, 200, 20);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRect];
    titleLabel.textAlignment= NSTextAlignmentRight;
    [titleLabel setFont: [UIFont boldSystemFontOfSize:18]];
       [titleLabel setTextColor: [UIColor whiteColor]];
    titleLabel.text = @"Total:";
    titleLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    titleLabel.opaque= NO;
    [tableFooter addSubview:titleLabel];
   
    CGRect totalRect = CGRectMake(220, 0,self.view.frame.size.width-220 , 20);
   self.Total= [[UILabel alloc] initWithFrame:totalRect];
    self.Total.textAlignment= NSTextAlignmentLeft;
    [self.Total setFont: [UIFont boldSystemFontOfSize:18]];
   [self.Total setTextColor: [UIColor whiteColor]];
       
       self.Total.text = @"1234";
    self.Total.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
      
    self.Total.opaque= NO;
    [tableFooter addSubview:self.Total];

    
   
    
     self.tableView.tableFooterView = tableFooter;
   }
    [self calculateTotal];
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
//		[[NSNotificationCenter defaultCenter] addObserver:self
//												 selector:@selector(keyboardDidShow:)
//													 name:UIKeyboardDidShowNotification
//												   object:nil];
//	} else {
//		[[NSNotificationCenter defaultCenter] addObserver:self
//												 selector:@selector(keyboardWillShow:)
//													 name:UIKeyboardWillShowNotification
//												   object:nil];
//	}
    
    
    //load the current period
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setTotal:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

-(void) calculateTotal
{
    self.Total.text=[[self.fetchedResultsController.fetchedObjects valueForKeyPath:@"@sum.value"] stringValue];
    
  /*
    int runningTotal = 0;
    
    for (Answers *a in self.fetchedResultsController.fetchedObjects)
    {
        if(a.measurement.type != @"Text" && a.value != @"")
        {
            runningTotal += [a.value intValue];
            
        }
        
    }
     
         self.Total.text = [NSString  stringWithFormat:@"%d", runningTotal];
     
    */
}

- (void) saveAnswerForMeasurementId:(NSNumber *)measurementId  measurementType: (NSString *) measurementType inStaffReport:(NSNumber *)  staffReportId atNodeId: (NSNumber *)childNodeId withValue:(NSString *)value oldValue: (NSString *) oldValue
{
    
    [self.dataModel saveModelAnswerForMeasurementId:measurementId measurementType: measurementType inStaffReport:staffReportId atNodeId: childNodeId  withValue:value oldValue:oldValue completionHandler:^(NSString *result) {
        
        [self.dataModel.allNodesForUser.managedObjectContext performBlock:^{
            [self performFetch];
            [self calculateTotal];
            
        }];
        
        

        
        if([result isEqualToString:GMA_NO_CONNECT] )
        {
            UIAlertView *av = [[UIAlertView alloc]  initWithTitle:@"Connect Failed" message:GMA_NOCONNECT_Message delegate:self cancelButtonTitle:GMA_OFFLINE otherButtonTitles:GMA_TRY_AGAIN, nil];
            dispatch_async(dispatch_get_main_queue(), ^{  [av show]; });
            
            
            [self.dataModel addItemToCacheStackForMeasurementId:measurementId measurementType:measurementType inStaffReport:staffReportId withValue:value
                                                       oldValue:oldValue ];
            
            
            
        }
        else if([result isEqualToString:GMA_NO_AUTH])
        {
            UIAlertView *av = [[UIAlertView alloc]  initWithTitle:@"Session Expired" message:GMA_LOGIN_EXPIRED delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{  [av show]; });
            [self.dataModel.alertBarController showMessage:GMA_OFFLINE_MODE withBackgroundColor:[UIColor redColor] withSpinner: NO];
            
        }
        else if([result isEqualToString:GMA_SUCCESS])
        {
            
            [self.dataModel.alertBarController hideAlertBar];
        }
        else if([result isEqualToString:GMA_OFFLINE_MODE])
        {
            [self.dataModel.alertBarController showMessage:GMA_OFFLINE_MODE withBackgroundColor:[UIColor redColor] withSpinner: NO];
        }
        else
        {
            //FAIL
            UIAlertView *av = [[UIAlertView alloc]  initWithTitle:@"Error" message:@"GMA Server did not allow you to save this measurement. The value has been reverted back to its original value" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{  [av show]; });
            
            
            
            
        }
        

        
        
        
        
        
              
    }]; 
    
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
            [self.dataModel.alertBarController showMessage:GMA_OFFLINE_MODE withBackgroundColor:[UIColor redColor] withSpinner: NO];
        }
    }
    
    
    
    if (buttonIndex == 0){
        //delete it
    }
    
}
//-(UIView *)findFirstResponderFrom:(UIView *)thisView
//{
//    if ([thisView isFirstResponder])
//        return thisView;
//    
//    for (UIView * subView in thisView.subviews)
//    {
//        UIView * fr = [self findFirstResponderFrom:subView];
//        if (fr != nil)
//            return fr;
//    }
//    
//    return nil;
//}
//
//- (void)addButtonToKeyboard {
//	// create custom button
//    BOOL isQuestionCell = NO;
//    
//    for(UIView *subView in self.tableView.subviews)
//    {
//        if ([subView isKindOfClass: [QuestionCell class]])
//        {
//            if([self findFirstResponderFrom:subView])
//                isQuestionCell = YES;
//            
//        }
//    }
//    if(!isQuestionCell) return ;
//    
//    
//    
//    
//	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	doneButton.frame = CGRectMake(0, 163, 106, 53);
//	doneButton.adjustsImageWhenHighlighted = NO;
//	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.0) {
//		[doneButton setImage:[UIImage imageNamed:@"DoneUp3.png"] forState:UIControlStateNormal];
//		[doneButton setImage:[UIImage imageNamed:@"DoneDown3.png"] forState:UIControlStateHighlighted];
//	} else {
//		[doneButton setImage:[UIImage imageNamed:@"DoneUp.png"] forState:UIControlStateNormal];
//		[doneButton setImage:[UIImage imageNamed:@"DoneDown.png"] forState:UIControlStateHighlighted];
//	}
//	[doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
//	// locate keyboard view
//	UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
//	UIView* keyboard;
//	for(int i=0; i<[tempWindow.subviews count]; i++) {
//		keyboard = [tempWindow.subviews objectAtIndex:i];
//		// keyboard found, add the button
//        
//        
//        
//        
//		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
//			if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
//				[keyboard addSubview:doneButton];
//		} else {
//			if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
//				[keyboard addSubview:doneButton];
//		}
//	}
//}
//- (void)keyboardWillShow:(NSNotification *)note {
//    
//	// if clause is just an additional precaution, you could also dismiss it
//	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 3.2) {
//		[self addButtonToKeyboard];
//	}
//    
//}
//
//- (void)keyboardDidShow:(NSNotification *)note {
//    
//	// if clause is just an additional precaution, you could also dismiss it
//	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
//		[self addButtonToKeyboard];
//    }
//    
//}
//
//- (void)doneButton:(id)sender {
//	[self.tableView indexPathsForVisibleRows] ;
//    for(NSIndexPath *ip in  [self.tableView indexPathsForVisibleRows])
//    {
//        
//        QuestionCell *cell= (QuestionCell *) [self.tableView  cellForRowAtIndexPath:ip ];
//        
//        if([cell.answer isFirstResponder]){
//            [cell.answer resignFirstResponder];
//            [cell asnwerChanged:nil ];
//        }
//        
//    }
//    
//}



-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self calculateTotal];
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
    
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSArray *objects = [sectionInfo objects];
    NSManagedObject *managedObject = [objects objectAtIndex:0];
    StaffReports *s =[managedObject valueForKey:@"staffReport"];
     NSString *title = @"";
    if(s)
    {
        if([s.type isEqualToString:@"SubNode"])
            title= @"Nodes:";
        else
            title= [s.type stringByAppendingString:@":"] ;
    }

    
        
    
    
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init] ;
    label.frame = CGRectMake(10, 0, self.view.frame.size.width-20, 23);
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont italicSystemFontOfSize:20.0f];
    label.text = title	;
    label.backgroundColor = [UIColor clearColor];
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    
    [view addSubview:label];
    
    return view;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSArray *objects = [sectionInfo objects];
    NSManagedObject *managedObject = [objects objectAtIndex:0];
    StaffReports *s =[managedObject valueForKey:@"staffReport"];
    if(s)
    {
        if([s.type isEqualToString:@"SubNode"])
            return @"Nodes";
        else
            return s.type;
    }

    return @"";
        
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        
    
    Answers *a = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //NSLog(@"Type: %@",a.measurement.type );
    if([a.measurement.type isEqualToString: @"Numeric"])
    {
        static NSString *CellIdentifier = @"QuestionCellD";
        QuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[QuestionCell alloc]   initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier ] ;
            
        }
         cell.isDirector =NO;  //!!!!! SET TO YES TO SHOW DETAIL DISCLOSURE INTICATOR (ACCESSSORY)
        cell.tvcd=self;
        cell.tvc = nil;
        if([a.staffReport.type isEqualToString:@"SubNode"]){
            if(a.staffReport.node.name)
                cell.title.text = [NSString stringWithFormat:@"SubNode: %@",  a.staffReport.node.name];
            else
                cell.title.text = [NSString stringWithFormat:@"SubNode: %@", a.staffReport.node.nodeId];
        }
        else if([a.staffReport.staffReportId intValue] < 0){
            
            cell.title.text = a.staffReport.node.name ;
        }
        else{
            cell.title.text=  [NSString stringWithFormat:@"%@ ", a.staffReport.user.name] ; //a.measurement.name;
        }
             [QuestionCell resizeFontForLabel:cell.title maxSize:17 minSize:10 labelWidth:159 labelHeight:32];
        cell.subTitle.text = a.measurement.type;
        //cell.textLabel.text = a.measurement.name;
        // cell.detailTextLabel.text = a.measurement.type;
        cell.answer.text=a.value;
        
        
        [cell.answer setEnabled:YES];
        cell.answer.hidden = NO ;
        cell.lblAnswer.hidden = YES;
        [cell.addButton setHidden:NO];
        cell.measurementId  =a.measurement.measurementId;
        cell.measurementType = a.measurement.type ;
        cell.staffReportId = a.staffReport.staffReportId;
        cell.lblCalc.hidden = YES;
       
        cell.addButton.hidden = [a.staffReport.type isEqualToString:@"SubNode"];
        cell.nodeId = a.staffReport.node.nodeId;
    
        cell.answer.rightViewMode = UITextFieldViewModeUnlessEditing ;
        //cell.answer.rightView = btnAdd;
        
        return cell;
        
    }
    else if([a.measurement.type isEqualToString: @"Text"])
    {
        static NSString *CellIdentifier = @"TextQuestionCell";
        TextQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[TextQuestionCell alloc]   initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier ] ;
            
        }
        
        cell.tvcd=self;
        cell.tvc=nil;
        if([a.staffReport.type isEqualToString:@"SubNode"]){
            if(a.staffReport.node.name)
                cell.title.text = [NSString stringWithFormat:@"SubNode: %@",  a.staffReport.node.name];
            else
                cell.title.text = [NSString stringWithFormat:@"SubNode: %@", a.staffReport.node.nodeId];
        }
        else if([a.staffReport.staffReportId intValue] < 0){
            
            cell.title.Text = a.staffReport.node.name ;
        }
        else{
            cell.title.text=  [NSString stringWithFormat:@"%@ ", a.staffReport.user.name] ; //a.measurement.name;
        }
        
      
        [QuestionCell resizeFontForLabel:cell.title maxSize:17 minSize:10 labelWidth:159 labelHeight:32];

        
        
        
        //cell.title.text= a.measurement.name;
        cell.answer.text= a.value;
      
        cell.measurementId  =a.measurement.measurementId;
        
        cell.staffReportId = a.staffReport.staffReportId;
        
        
        
        return cell;
    }
    
    //Calculated Measurement
    
    static NSString *CellIdentifier = @"QuestionCellD";
    QuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[QuestionCell alloc]   initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier ] ;
        
    }
    
      
    cell.tvcd=self;
    cell.tvc=nil;
    if([a.staffReport.type isEqualToString:@"SubNode"]){
        if(a.staffReport.node.name)
            cell.title.text = [NSString stringWithFormat:@"SubNode: %@",  a.staffReport.node.name];
        else
            cell.title.text = [NSString stringWithFormat:@"SubNode: %@", a.staffReport.node.nodeId];
    }
    else if([a.staffReport.staffReportId intValue] < 0){
        
        cell.title.Text = a.staffReport.node.name ;
    }
    else{
        cell.title.text=  [NSString stringWithFormat:@"%@ ", a.staffReport.user.name] ; //a.measurement.name;
    }
    [QuestionCell resizeFontForLabel:cell.title maxSize:17 minSize:10 labelWidth:159 labelHeight:32];
    cell.subTitle.text = a.measurement.type;
    //cell.textLabel.text = a.measurement.name;
    // cell.detailTextLabel.text = a.measurement.type;
    cell.answer.text= a.value;
    [cell.answer setEnabled:NO];
    [cell.addButton setHidden:YES];
    cell.measurementId  =a.measurement.measurementId;
    cell.measurementType = a.measurement.type ;
    cell.staffReportId = a.staffReport.staffReportId;
    
    cell.isDirector =NO;  //!!!!! SET TO YES TO SHOW DETAIL DISCLOSURE INTICATOR (ACCESSSORY)
    cell.addButton.hidden = [a.staffReport.type isEqualToString:@"SubNode"];
    cell.nodeId = a.staffReport.node.nodeId;
    
    cell.answer.rightViewMode = UITextFieldViewModeUnlessEditing ;
    //cell.answer.rightView = btnAdd;
    
    return cell;

    

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




- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    Answers *a = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    pvcNode *pvc =  [self.storyboard instantiateViewControllerWithIdentifier:@"Pvc Node"];
    pvc.node=a.staffReport.node;
    
    pvc.dataModel = self.dataModel;
    pvc.navigationItem.title = [NSString stringWithFormat:@"%@(%@)", a.staffReport.user.name, a.staffReport.node.name]  ;
    [self.navigationController pushViewController:pvc animated:YES];

    
    
    
        
}
-(void) dismissPickerView
{
    //[self.tableView indexPathsForVisibleRows] ;
    
   // QuestionCell *cell= (QuestionCell *) [self.tableView  cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow ];
    //[cell resignFirstResponder] ;
    //[cell asnwerChanged:nil ];
    for(UITableViewCell *cell in self.tableView.visibleCells)
    {
        if([cell isMemberOfClass: [QuestionCell class]]){
        QuestionCell *qc = (QuestionCell *)cell;
        
        
            if([qc.answer dismissPickerView ])
                [qc asnwerChanged:nil ];
        
        }
    }
    

    
}	


@end
