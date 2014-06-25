//
//  LoginViewController.m
//  GMA1-0
//
//  Created by Jon Chontelle Vellacott on 03/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "NodeTVC.h"
#import "SettingsViewController.h"


@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize userName;
@synthesize password;
@synthesize saveCredentials ;
@synthesize lblLoginFailed;
@synthesize show ;
@synthesize LogginIn ;
@synthesize loginButton ;
@synthesize cachedServer;
int count =0 ;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        self.cachedServer = [prefs objectForKey:@"gmaServer"];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(changeServer:)];
    [self.changeServerView addGestureRecognizer:singleFingerTap];
    
}
- (void)changeServer:(UITapGestureRecognizer *)recognizer {
    [self changeServerClicked:self];
    
    //Do stuff here...
}

-(void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    
    NSString *_userName = [self.nodesTVC.dataModel getUsername] ;
    NSString *_password = [self.nodesTVC.dataModel getPassword] ;
   	
    if(_userName)
        userName.text = _userName;
    
    if(_password)
        password.text = _password;
    
    if([prefs objectForKey:@"AutoLogin"])
        saveCredentials.on = [(NSNumber *)[prefs objectForKey:@"AutoLogin"]  boolValue];
    if([prefs objectForKey:@"gmaServer"]) self.gmaServer.text = [prefs objectForKey:@"gmaServer"];
    NSLog(@"%@", [prefs objectForKey:@"gmaServer"]);
    [self.loginButton useBlackStyle];
    [self.cancelButton useBlackStyle];
    [self enableControls];
}


-(void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
     if(![prefs objectForKey:@"gmaServer"])[self changeServerClicked:self];

}


- (void)viewDidUnload
{
    [self setUserName:nil];

    [self setPassword:nil];
    [self setLblLoginFailed:nil];
    [self setLogginIn:nil];
    [self setGmaServer:nil];
    [self setChangeServerView:nil];
    [self setCancelButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void) threadStartAnimating {
    [LogginIn startAnimating];
    [loginButton setEnabled:NO];
        [userName setEnabled:NO];
    [password setEnabled:NO];
    [saveCredentials setEnabled:NO];
    
}

- (void) enableControls {
    [LogginIn stopAnimating];
    [loginButton setEnabled:YES];
    [userName setEnabled:YES];
    [password setEnabled:YES];
    [saveCredentials setEnabled:YES];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)changeServerClicked:(id)sender {
    
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Settings"];
    [self presentViewController:viewController animated:NO completion:nil ];
 
//[self.navigationController pushViewController:viewController animated:NO];
    
    
}

- (IBAction)loginButtonPressed:(id)sender
{
    [self threadStartAnimating];
    
        
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
      [prefs setObject:[NSNumber numberWithBool:self.saveCredentials.isOn] forKey:@"AutoLogin"];
    
    [self.nodesTVC.dataModel setUsername:userName.text];
        [prefs synchronize];
    
    self.nodesTVC.dataModel = nil;
    //[self.nodesTVC loginUser:userName.text WithPassword:password.text ];
    [self.view endEditing:YES];
    
    
    }

- (IBAction)cancelButtonPressed:(id)sender
{
    
    
     [self.view endEditing:YES];
    [self.nodesTVC dismissViewControllerAnimated:TRUE completion:nil ];
    
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     
}

@end
