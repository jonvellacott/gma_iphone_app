//
//  GMAAppDelegate.m
//  GMA1-1
//
//  Created by Jon Vellacott on 29/01/2013.
//  Copyright (c) 2013 Jon Vellacott. All rights reserved.
//

#import "GMAAppDelegate.h"
#import <AFNetworking.h>
@implementation GMAAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Activate Network Activity handling in AFNetworking
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    TheKey *theKey = [TheKey theKey];
    if([theKey canAuthenticate] && [theKey getGuid]) {
       // [[CourseManager sharedManager] syncAllCoursesFromHub];
    }
    else {
        [self performSelector:@selector(showLoginDialog) withObject:nil afterDelay:0.1];
    }
    
    return YES;
}

-(void)showLoginDialog {
    UIViewController *loginDialog = [[TheKey theKey] showDialog:self];
    [loginDialog setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self.window.rootViewController presentViewController:loginDialog animated:YES completion:^{}];
}

-(void)loginSuccess {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{}];
    //[[CourseManager sharedManager] syncAllCoursesFromHub];
}

-(void)loginFailure {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{}];
}


							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}


@end
