//
//  SettingsViewController.h
//  GMA1-0
//
//  Created by Jon Chontelle Vellacott on 05/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDataSource>{
    
   // UIPickerView *gmaPicker;
  // NSArray *arrServers;
   // NSDictionary *gmaServers;

}
@property (nonatomic, strong) NSDictionary *gmaServers;


@property (weak, nonatomic) IBOutlet UIPickerView *gmaPicker;
@property (weak, nonatomic) IBOutlet UITextField *customServer;
- (IBAction)customServerChanged:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UINavigationItem *myNavigationItem;



	
@end
