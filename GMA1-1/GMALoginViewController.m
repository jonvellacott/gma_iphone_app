//
//  EkkoLoginViewController.m
//  Ekko
//
//  Created by Brian Zoetewey on 11/15/13.
//  Copyright (c) 2013 Ekko Project. All rights reserved.
//

#import "GMALoginViewController.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
@interface GMALoginViewController ()

@end

@implementation GMALoginViewController

+(NSString *)authNibName {
    return @"GMALoginViewController";
}

-(void)viewWillAppear:(BOOL)animated {
    self.webView.backgroundColor = [UIColor lightGrayColor];
    [super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // returns the same tracker you created in your app delegate
    // defaultTracker originally declared in AppDelegate.m
    id tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-29919940-5"];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value: @"The Key Login (OAUTH)" ];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
}

@end
