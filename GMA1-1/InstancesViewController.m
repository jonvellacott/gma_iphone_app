//
//  InstancesViewController.m
//  GMA1-1
//
//  Created by Jon Vellacott on 22/04/2014.
//  Copyright (c) 2014 Jon Vellacott. All rights reserved.
//

#import "InstancesViewController.h"
#import <TheKeyOAuth2Client.h>

#import "GMALoginViewController.h"
#import "NodeTVC.h"

#import "GMALoginViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#define GMA_SERVICE_URL  @"https://services.gcx.org/gma/auth/service"
#define GMA_SERVICE_LOGIN  @"https://services.gcx.org/gma/auth/login?ticket="
#define GMA_SERVICE_GET  @"https://services.gcx.org/gma/{session_id}/servers"

@interface InstancesViewController ()

@end

@implementation InstancesViewController
@synthesize instances;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
        

        
    }
    return self;
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
           value:@"Home Screen (Instances)"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view.
    if(self.instances.count==0)
    {
        if([TheKeyOAuth2Client sharedOAuth2Client].isAuthenticated && [TheKeyOAuth2Client sharedOAuth2Client].guid )
        {
            [self getGmaInstancesWithCompletionHander:nil];
            
        }
        else
            [self  presentLoginDialog];
        
    }
    else if (self.instances.count==1)
    {
        [self.navigationController pushViewController:self.instances.firstObject  animated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(theKeyOAuth2ClientDidChangeGuid:) name:TheKeyOAuth2ClientDidChangeGuidNotification object:[TheKeyOAuth2Client sharedOAuth2Client]];
    
    
    
    
    
    
    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(backBarButtonItem:)];
    
    [[self navigationItem] setLeftBarButtonItem:loginButton];
    self.instances=[[NSMutableArray alloc] init];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSArray *results= [prefs objectForKey:@"gma_instances"];

   
    for(NSDictionary *inst in results)
    {
        NodeTVC *ntvc =[self.storyboard instantiateViewControllerWithIdentifier:@"NodeTVC"];
        
        ntvc.uri=[inst objectForKey:@"uri"];
        
        ntvc.navigationItem.title=[inst objectForKey:@"name"];
        [self.instances addObject:ntvc];
    }
    
    
    
  
    
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];

    
   // [[self navigationItem] setHidesBackButton:YES];
    
    
}

-(void)getGmaInstancesWithCompletionHander: (void (^)())block
{

    NSString *gma_service =  [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:GMA_SERVICE_URL] encoding:NSUTF8StringEncoding error:nil];
    if(gma_service){
    [[TheKeyOAuth2Client sharedOAuth2Client] ticketForServiceURL:[NSURL URLWithString:gma_service] complete:^(NSString *ticket) {
        
        NSString *url = [GMA_SERVICE_LOGIN stringByAppendingString:ticket ];
        
        NSLog(@"%@", url);
        NSLog(@"%@", ticket);
        
        // NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        //NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: url]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
        
        //[request setHTTPBody:postData];
        
        
        
        NSURLResponse *response;
        NSError *err;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err ];
        NSDictionary *results1=returnData ? [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&err]: nil;
        
        NSString *session =[results1 valueForKey:@"id"];
        NSLog(@"%@", session);
        if(session){
        NSString *url2 =[GMA_SERVICE_GET stringByReplacingOccurrencesOfString:@"{session_id}" withString:session];
        
        
        
        
        NSMutableURLRequest *request2 = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url2]];
        
        [request2 setHTTPMethod:@"GET"];
        [request2 setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSData *returnData2 = [NSURLConnection sendSynchronousRequest:request2 returningResponse:&response error:&err ];
        
        NSArray *results=returnData2 ? [NSJSONSerialization JSONObjectWithData:returnData2 options:0 error:&err]: nil;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:results forKey:@"gma_instances"];
        [prefs synchronize];
        
        [self.instances removeAllObjects];
        for(NSDictionary *inst in results)
        {
            NodeTVC *ntvc =[self.storyboard instantiateViewControllerWithIdentifier:@"NodeTVC"];
            
            ntvc.uri=[inst objectForKey:@"uri"];
            
            ntvc.navigationItem.title=[inst objectForKey:@"name"];
            [self.instances addObject:ntvc];
        }
        if(self.instances.count==1){
            [self.navigationController pushViewController:self.instances.firstObject  animated:YES];
        }
        }
        if(block) block();
        // NSLog(@"%d" ,results.count);
            
        
    }];
    }
    else
    {
         if(block) block();
    }
    
    
    }

-(void)refresh {
    //NSLog(@"Refreshing...");
    
    [self getGmaInstancesWithCompletionHander:^{
        [self.refreshControl endRefreshing];
    }];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)presentLoginDialog {
    [[TheKeyOAuth2Client sharedOAuth2Client] presentLoginViewController:[GMALoginViewController class] fromViewController:self loginDelegate:self];
}

-(void)theKeyOAuth2ClientDidChangeGuid:(NSNotification *)notification {
   
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:nil forKey:@"gma_instances"];
    [prefs synchronize];
    [self.tableView reloadData];
    [(UINavigationController *)self.navigationController popToRootViewControllerAnimated:YES];
    [self getGmaInstancesWithCompletionHander:nil];
    for(NodeTVC *n in self.instances)
    {
        n.dataModel.offlineMode=NO;
    }
    alertViewController *rootViewController = (alertViewController *)[self.navigationController parentViewController];
    
    if(rootViewController)
    {
        [rootViewController hideAlertBar];
    }
}

-(void)loginViewController:(TheKeyOAuth2LoginViewController *)loginViewController loginError:(NSError *)error      {
    for(NodeTVC *n in self.instances)
    {
        n.dataModel.offlineMode=YES;
    }
    alertViewController *rootViewController = (alertViewController *)[self.navigationController parentViewController];
    
    if(rootViewController)
    {
       [rootViewController showMessage:GMA_OFFLINE_MODE withBackgroundColor: [UIColor redColor ] withSpinner: NO];
    }
    
}
- (void)backBarButtonItem:(id)sender
{
    [[TheKeyOAuth2Client sharedOAuth2Client] logout];
     [self  presentLoginDialog];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
      NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return((NSArray *)[prefs objectForKey:@"gma_instances"]).count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"InstanceCell";
  
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        
    }
       NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *inst = [((NSArray *)[prefs objectForKey:@"gma_instances"]) objectAtIndex:indexPath.row];
    
    
    cell.textLabel.text = [inst objectForKey:@"name"] ;	//[NSString stringWithFormat:@"%@%@", node.nodeId, node.name];
    //cell.detailTextLabel.text = [inst objectForKey:@"uri"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *inst = [((NSArray *)[prefs objectForKey:@"gma_instances"]) objectAtIndex:indexPath.row];
    [prefs setObject:[[inst objectForKey:@"uri"] stringByAppendingString:@"index.php?q=gmaservices"] forKey:@"gmaServer"];
    [prefs synchronize];
    
  
    [self.navigationController pushViewController:[self.instances objectAtIndex:indexPath.row] animated:YES];

    
    
}
@end
