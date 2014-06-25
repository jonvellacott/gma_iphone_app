//
//  NodeTVC.m
//  GMA1-0
//
//  Created by Jon Chontelle Vellacott on 31/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeTVC.h"
#import "QuestionTVC.h"
#import "Nodes+gma.h"
#import "StaffReports.h"
#import "LoginViewController.h"
#import "pvcNode.h"
#import <AFNetworking.h>
#import "PDKeychainBindings.h"
#import <TheKeyOAuth2Client.h>

#import "GMALoginViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@interface NodeTVC ()
@end

@implementation NodeTVC

@synthesize allNodesForUser = _allNodesForUser;
@synthesize dataModel = _dataModel;
typedef void(^saveBlock)(NSString *);

saveBlock cacheCompletionBlock;




#define GMA_Nodes @"gma_node"
#define GMA_StaffReport @"gma_staffReport/searchOwn"

-(void)setupFetchedResultsController
{
    //self.fethcedResultsController=...
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Nodes"];
   // request.predicate = [NSPredicate predicateWithFormat:@"ANY staffReports.type != 'SubNode'"] ;
    request.predicate = [NSPredicate predicateWithFormat:@"ANY staffReports.type == 'Staff'"] ;
    
     request.sortDescriptors =   [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"  ascending:YES]];
      //request.sortDescriptors =   [NSArray arrayWithObjects: [NSSortDescriptor sortDescriptorWithKey:@"directorNode"  ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name"  ascending:YES] , nil];
        
   self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.dataModel.allNodesForUser.managedObjectContext sectionNameKeyPath:@"directorNode" cacheName:nil];
   
}










- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //Handles the responsed from the various alert views
    NSString *message = alertView.message;
    NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if([alertView.title isEqualToString:@"Offline Changes"])  //TODO: change to Defined TAG
    {
        if([btnTitle isEqualToString: @"Save Changes"])
        {
        [self.dataModel clearCacheStackWithCompletionHandler:cacheCompletionBlock];
        }
        else [self.dataModel emptyCacheStack];

    }
    else if([message isEqualToString: KEY_NOCONNECT_Message] || [message isEqualToString: GMA_NOCONNECT_Message]  ){
        if([btnTitle isEqualToString: GMA_TRY_AGAIN])
        {
            //Try Again...
            self.dataModel=nil;
            [self setupNodeList];
        }
        else{
            self.dataModel.offlineMode = YES;
              dispatch_async(dispatch_get_main_queue(), ^{   [self dismissViewControllerAnimated:YES completion:nil]; });
            [self.loginButton setEnabled:YES];
            [self.dataModel.alertBarController showMessage:GMA_OFFLINE_MODE withBackgroundColor: [UIColor redColor ] withSpinner: NO];
        }
    }
    else if([btnTitle isEqualToString:@"Reset"])
    {
        [self.dataModel removeDatabase];
       
        
        self.dataModel = nil;
        [self setupNodeList];
      
    
    }
       
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
     //   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(theKeyOAuth2ClientDidChangeGuid:) name:TheKeyOAuth2ClientDidChangeGuidNotification object:[TheKeyOAuth2Client sharedOAuth2Client]];

            }
         
    
   
        return self;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return nil;
}

-(void)refresh {
    //NSLog(@"Refreshing...");
     
    [self.dataModel fetchAllUserNodesWithCompletionHandler:^{
        
        [self.refreshControl endRefreshing];
    }] ;
    
    
}
- (void)doReconnect{
   // NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [self setupNodeList];
}
-(void)resetPressed:(id)sender{
    UIAlertView *av = [[UIAlertView alloc]  initWithTitle:@"Reset Connection" message:@"Resetting the connection will remove the GMA data stored locally on this device (for this GMA instance), and re-download the data from the GMA server. Any unsaved changes will be lost." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Reset", nil];
    [av show];
}



-(void)setupNodeList
{
    
    
    if(!self.dataModel){
        [NSFetchedResultsController deleteCacheWithName:nil];
        
        self.fetchedResultsController=nil;
        
        self.dataModel = [[Model alloc] initWithCompletionHander:^(BOOL success){
            [self setupFetchedResultsController];
            [self.tableView reloadData];
        } ];
        
        //The root view is a container with an overlay view at the bottom, which allows me to display status messages
        
        alertViewController *rootViewController = (alertViewController *)[self.navigationController parentViewController];
        [rootViewController setDelegate:self];
        
        if(rootViewController)
        {
            self.dataModel.alertBarController = rootViewController;
        }
        
        
    }
    
    
    
    
    [self.dataModel authenticateUserWithLoginSuccessHandler:^(BOOL success){
        dispatch_async(dispatch_get_main_queue(), ^{
            //GCX authentication returned
            if(success)
                [self dismissViewControllerAnimated:YES completion: nil];
            
        });
        
        
    } CompletionHander:^(NSDictionary *status){
        //GMA Authentication Returned
        if((BOOL)[status objectForKey:@"filenameChanged"] )
        {
            [self setupFetchedResultsController];
        }
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        if([(NSString *)[status objectForKey:@"Status"] isEqualToString:@"SUCCESS"])
        {
            //check cacheStack for items
            self.dataModel.offlineMode = NO;
            
            //check cacheStack for pending transaction to upload
            if([prefs objectForKey:[@"cacheStack" stringByAppendingString:self.dataModel.fileName]])
            {
                //If the Cache exists, look for existing Item
                NSMutableArray *cacheStack = [NSMutableArray arrayWithArray:[prefs objectForKey:[@"cacheStack" stringByAppendingString:self.dataModel.fileName]] ];
                if(self.dataModel.forceSave)
                {
                    self.dataModel.forceSave = false;
                    [self.dataModel clearCacheStackWithCompletionHandler:cacheCompletionBlock];
                    
                }
                else if(cacheStack.count > 0)
                {
                    UIAlertView *av = [[UIAlertView alloc]  initWithTitle:@"Offline Changes" message:GMA_CACHEITEMS delegate:self cancelButtonTitle:@"Save Changes" otherButtonTitles:@"Undo Changes", nil];
                    dispatch_async(dispatch_get_main_queue(), ^{  [av show]; });
                    
                }
                
            }
            [self.dataModel fetchAllUserNodesWithCompletionHandler:nil] ;
            
            
            self.dataModel.loggedIn = true;
            
            
            [prefs synchronize];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //Change the login button on the main thread
                [self.loginButton setTitle:@"Login"];
                [self.loginButton setEnabled:YES];
                
            });
            
        }
        else   //Login Failed
        {
            if([(NSString *)[status objectForKey:@"Reason"] isEqualToString: GMA_OFFLINE]){
                //show connect fail message
                UIAlertView *av = [[UIAlertView alloc]  initWithTitle:@"Connect Failed" message:KEY_NOCONNECT_Message delegate:self cancelButtonTitle:GMA_OFFLINE otherButtonTitles:GMA_TRY_AGAIN, nil];
                dispatch_async(dispatch_get_main_queue(), ^{  [av show]; });
            }
            else if([(NSString *)[status objectForKey:@"Reason"] isEqualToString: @"Invalid Username or Password"]){
                //show connect fail message
                UIAlertView *av = [[UIAlertView alloc]  initWithTitle:@"Invalid Login" message:KEY_INVALID_LOGIN_Message delegate:self cancelButtonTitle:GMA_OFFLINE otherButtonTitles:GMA_TRY_AGAIN, nil];
                dispatch_async(dispatch_get_main_queue(), ^{  [av show]; });
            }
            else
            {
                //show connect fail message
                UIAlertView *av = [[UIAlertView alloc]  initWithTitle:@"Connect Failed" message:GMA_NOCONNECT_Message delegate:self cancelButtonTitle:GMA_OFFLINE otherButtonTitles:GMA_TRY_AGAIN, nil];
                dispatch_async(dispatch_get_main_queue(), ^{  [av show]; });
                
                
                
            }
            
            
        }
        
        
        
        
        
        
        
    }];

    
    
    
    
    
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // returns the same tracker you created in your app delegate
    // defaultTracker originally declared in AppDelegate.m
    id tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-29919940-5"];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:self.navigationItem.title];
    
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
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset..." style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(resetPressed:)];
    
    self.navigationItem.rightBarButtonItem = backButton;

    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    if(!self.dataModel){
        [self setupNodeList];
    }
    
   
    cacheCompletionBlock =^(NSString *result) {
        if([result isEqualToString:GMA_NO_CONNECT] || [result isEqualToString:GMA_NO_AUTH] )
        {
            UIAlertView *av = [[UIAlertView alloc]  initWithTitle:@"Save Failed" message:@"Could not reach the GMA server. You can continue to work in offline mode and your changes will be stored locally. Next time you login in, you will be asked if you you would like to upload your saved results to the GMA Server" delegate:self cancelButtonTitle:GMA_OFFLINE otherButtonTitles: nil];
            dispatch_async(dispatch_get_main_queue(), ^{  [av show]; });
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
            UIAlertView *av = [[UIAlertView alloc]  initWithTitle:@"Error" message:@"GMA Server did not allow you to save this measurement. The values will been reverted back to its original value" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{  [av show]; });
            
            
            
            
        }
        
    };
        
       
    }











- (void)viewWillUnload
{
    //Last ditched attempt to ensure data is saved
    [self.dataModel.allNodesForUser.managedObjectContext save:nil];
   
}



- (void)viewDidUnload
{
    [super viewDidUnload];
        // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.dataModel = nil;
    self.allNodesForUser=nil;
    self.activity=nil;
    self.loginButton=nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //Only support portrait orientation
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source







-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    //TODO: Is this section really needed any more - allow fetchedresultscontroller to define its sections
    switch (section) {
        case 0:
            return  [sectionInfo numberOfObjects];
            break;
        case 1:
            return [sectionInfo numberOfObjects]  ;
            break;
        
    
        default:
            return 0;
            break;
    }
    
    
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSArray *objects = [sectionInfo objects];
    NSManagedObject *managedObject = [objects objectAtIndex:0];
    NSNumber *n =[managedObject valueForKey:@"nodeId"];
    if(n)
    {
        if(n.intValue>0)
            return @"Personal Reports";  //TODO: Use Defined Text.. Translation?
        else
            return @"Director Reports";  //TODO: Use Defined Text.. Translation?
    }
    
    
    
  
    
    
    //NSFetchedResultsController *sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
   // NSLog(@"%@", sectionInfo.sectionNameKeyPath);
   // x=  [self.fetchedResultsController.sections objectAtIndex:section];
    
    
   // if(((Nodes *)[sectionInfo.fetchedObjects lastObject]).nodeId.intValue >0) return @"Personal Nodes";
   // else return @"Director Nodes";
    return @"";
    
      
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    
 
    
    if(indexPath.section<2)
    {
        static NSString *CellIdentifier = @"NodeCell";
    
    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        
        }
    
        Nodes *node = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
        cell.textLabel.text = node.name ;	//[NSString stringWithFormat:@"%@%@", node.nodeId, node.name];
        cell.detailTextLabel.text = [node.nodeId stringValue];
        return cell;

    }
    
    return nil;
}






#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    
    
    
    if(indexPath.section == 1 && indexPath.row >=   [sectionInfo numberOfObjects])
    {

    
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Settings"];
                
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else{
        
            Nodes *node = [self.fetchedResultsController objectAtIndexPath:indexPath];
           
            pvcNode *pvc =  [self.storyboard instantiateViewControllerWithIdentifier:@"Pvc Node"];
            pvc.node=node;
            pvc.dataModel = self.dataModel;
            pvc.navigationItem.title = node.name ;
            
            [self.navigationController pushViewController:pvc animated:YES];
         
        
        
    }
    
    
}


@end
