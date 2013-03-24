//
//  NodeTVC.h
//  GMA1-0
//
//  Created by Jon Chontelle Vellacott on 31/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Model.h"
#import "alertViewController.h"
@interface NodeTVC : CoreDataTableViewController <UIAlertViewDelegate>

@property (nonatomic, strong) UIManagedDocument *allNodesForUser;
@property (nonatomic, strong)  Model *dataModel;
@property (nonatomic, strong) UIActivityIndicatorView *activity;
@property (nonatomic, strong) UIBarButtonItem *loginButton;

-(void) loginUser: (NSString *)username WithPassword: (NSString *)password;
- (void)doReconnect;
@end
