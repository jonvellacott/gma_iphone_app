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




#define Global_Ops @"https://www.globalopsccci.org/gma41demo15/index.php?q=gmaservices"
#define Ensteins_Gravity @"https://www.einsteinsgravity.com/index.php?q=gmaservices"



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
    //arrServers = [[NSArray alloc] initWithObjects: @"Africa", @"Australia", @"Asia",  @"Canada", @"Europe",  @"South America",@"USA",@"Custom",  nil];
    
   gmaServers =  [[NSDictionary alloc] initWithObjectsAndKeys:@"https://www.einsteinsgravity.com/index.php?q=gmaservices", @"Einstiens Gravity" ,
     @"https://www.globalopsccci.org/gma41demo15/index.php?q=gmaservices", @"Global Ops (Demo)",
            @"http://gma.agapeconnect.me/index.php?q=gmaservices" ,     @"AgapeConnect",nil];
    
    
    //Need to set the current server
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [self.customServer setText: @""];
    [self.customServer setEnabled:NO];
    NSArray *servers = [[gmaServers allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare: )];
    
    if([prefs objectForKey:@"gmaServer"])
    {
        int i = 0;
        for(NSString *s in servers)
        {
            if([[gmaServers objectForKey:s] isEqualToString: [prefs objectForKey:@"gmaServer"]])
            {
                [self.gmaPicker selectRow:i inComponent:0 animated:NO];
                return ;
            }
            i+=1;
        }
        [self.gmaPicker selectRow:servers.count inComponent:0 animated:NO];
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
    [self pickerView:self.gmaPicker didSelectRow:0 inComponent:0] ;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if(![[prefs objectForKey:@"casServicePrefix"] isEqualToString:  self.cas_service_prefix.text])
    {
        
        [prefs setObject:self.cas_service_prefix.text forKey:@"casServicePrefix"];
        [prefs synchronize];
        
    }
    [self dismissModalViewControllerAnimated:YES];
}
- (void)viewDidUnload
{
    
    [self setGmaPicker:nil];
    [self setCustomServer:nil];
    [self setMyNavigationItem:nil];
    
    [self setCas_service_prefix:nil];
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
    
    NSArray *servers = [[gmaServers allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare: )];
    if(servers.count == row)
        return @"Custom...";
    else
        return [servers objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *serverName = [self pickerView:pickerView titleForRow:row forComponent:component];
    NSString *gmaServer ;
    if([serverName isEqualToString:@"Custom..."])
    {
        gmaServer = self.customServer.text;
        [self.customServer setEnabled:YES];
    }
    else
    {
        gmaServer = [gmaServers objectForKey:  serverName];
        [self.customServer setEnabled:NO];
        
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if(![[prefs objectForKey:@"gmaServer"] isEqualToString:  gmaServer])
    {
        
        [prefs setObject:gmaServer forKey:@"gmaServer"];
        [prefs synchronize];

    }   
}

- (IBAction)customServerChanged:(id)sender {
    
   }

- (IBAction)doneButtonPressed:(id)sender {
    

    
}
@end
