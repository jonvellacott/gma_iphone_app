//
//  InstancesViewController.h
//  GMA1-1
//
//  Created by Jon Vellacott on 22/04/2014.
//  Copyright (c) 2014 Jon Vellacott. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TheKeyOAuth2Client.h>
@interface InstancesViewController : UITableViewController <UIAlertViewDelegate,TheKeyOAuth2ClientLoginDelegate>
@property (nonatomic, strong) NSMutableArray *instances;

@end
