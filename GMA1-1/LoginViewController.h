//
//  LoginViewController.h
//  GMA1-0
//
//  Created by Jon Chontelle Vellacott on 03/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NodeTVC.h"
#import "GradientButton.h"
@interface LoginViewController : UIViewController 
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIView *changeServerView;
@property (weak, nonatomic) IBOutlet UILabel *lblLoginFailed;
@property (weak, nonatomic) IBOutlet UISwitch *saveCredentials;
@property (weak, nonatomic) IBOutlet GradientButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *gmaServer;
@property (weak, nonatomic) IBOutlet GradientButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *LogginIn;
@property (nonatomic, assign) BOOL show;
@property (nonatomic, strong) NodeTVC *nodesTVC;
@property (nonatomic, strong) NSString *cachedServer;
- (IBAction)changeServerClicked:(id)sender;

- (IBAction)loginButtonPressed:(id)sender ;
- (IBAction)cancelButtonPressed:(id)sender ;
@end
