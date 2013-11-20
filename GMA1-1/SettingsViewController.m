//
//  SettingsViewController.m
//  GMA1-0
//
//  Created by Jon Chontelle Vellacott on 05/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize gmaPicker;
@synthesize gmaServers;
@synthesize customServer;




//#define Global_Ops @"https://www.globalopsccci.org/gma41demo15/index.php?q=gmaservices"
//#define Ensteins_Gravity @"https://www.einsteinsgravity.com/index.php?q=gmaservices"
#define GetAllServers @"https://agapeconnect.me/GMA/gma_global_directory.svc/GetAllGmaServers?authKey=zRm7aQB4TLzLKH"


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //arrServers = [[NSArray alloc] initWithObjects: @"Africa", @"Australia", @"Asia",  @"Canada", @"Europe",  @"South America",@"USA",@"Custom",  nil];
    
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString: GetAllServers]   encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
   gmaServers=jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error]: nil;
    
    if(!gmaServers ){
        
        NSLog(@"Error retrieving servers");
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"No Connection" message:@"Unable to download the list of servers from the internet at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        
        return ;
    }
    
    
    
    
     NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [self.customServer setText: @""];
    [self.customServer setEnabled:NO];
    //NSArray *servers = [sortedArrayUsingSelector:@selector( )];
    
    
    
    
    if([prefs objectForKey:@"gmaServer"])
    { 
        int i = 0;
        for(NSDictionary *d in gmaServers)
        {
            if([[d objectForKey: @"rootUrl"] hasPrefix:[prefs objectForKey:@"gmaServer"]])
             {
                [self.gmaPicker selectRow:i inComponent:0 animated:NO];
                return ;
            }
            i+=1;
        }
        [self.gmaPicker selectRow:gmaServers.count inComponent:0 animated:NO];
        [self.customServer setText: [prefs objectForKey:@"gmaServer"]];
        [self.customServer setEnabled: YES];
        
        
    }
    else
    {
       
       // [servers objectAtIndex:0]
        
    }
    
    
    
    //[self.view setBackgroundColor:  [UIColor groupTableViewBackgroundColor]];
   
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self
                                                                  action:@selector(barButtonBackPressed:)];
    
    self.myNavigationItem.leftBarButtonItem = backButton;
    
}
-(void)barButtonBackPressed:(id)sender{
    [self pickerView:self.gmaPicker didSelectRow: [self.gmaPicker selectedRowInComponent:0] inComponent:0] ;
    
        
    //}
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidUnload
{
    
    [self setGmaPicker:nil];
    [self setCustomServer:nil];
    [self setMyNavigationItem:nil];
    
    //[self setCas_service_prefix:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    //One column
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //set number of rows
    return gmaServers.count +1 ;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //set item per row
    
    
    if(gmaServers.count == row)
        return @"Custom...";
    else
        return [((NSDictionary *)[gmaServers objectAtIndex:row])  objectForKey: @"displayName" ]  ;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if(gmaServers.count == row)
    {
        [prefs setObject:self.customServer.text forKey:@"gmaServer"];
        [prefs setObject: nil forKey:@"gmaTargetService"];
    }
    else
    {
         NSDictionary *thisServer= [gmaServers objectAtIndex:row] ;
        
        [prefs setObject:[[thisServer objectForKey:@"rootUrl"] stringByAppendingString:@"index.php?q=gmaservices"] forKey:@"gmaServer" ];
       // [prefs setObject:[thisServer objectForKey:@"rootUrl"] forKey:@"gmaServer" ];
        [prefs setObject: [thisServer objectForKey:@"serviceUrl"] forKey:@"gmaTargetService"];
       
    }
    [prefs synchronize];

    

    
}

- (IBAction)customServerChanged:(id)sender {
    
   }

- (IBAction)doneButtonPressed:(id)sender {
    
    [self barButtonBackPressed:self];
    
}
@end
