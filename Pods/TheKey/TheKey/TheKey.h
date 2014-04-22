//
//  TheKey.h
//  TheKey
//
//  Created by Brian Zoetewey on 7/12/13.
//  Copyright (c) 2013 Campus Crusade for Christ, Intl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TheKeyLoginDialogDelegate;

@interface TheKey : NSObject
@property (readonly, nonatomic) NSString *clientId;
@property (readonly, nonatomic, getter = getCasUri) NSURL *casServer;

+(TheKey *)theKey;

-(id) initWithClientId:(NSString *)clientId CASServerString:(NSString *)casServer;
-(id) initWithClientId:(NSString *)clientId CASServerURL:(NSURL *)casServer;

-(NSURL *)getCasUriWithPath:(NSString *)path;

-(NSString *)getGuid;
-(BOOL)canAuthenticate;

-(void)signOut;

-(void)getTicketForService:(NSURL *)serviceURL
         completionHandler:(void (^)(NSString *ticket, NSError *error))handler;

-(UIViewController *)showDialog:(id<TheKeyLoginDialogDelegate>)delegate;
@end

@protocol TheKeyLoginDialogDelegate
-(void)loginSuccess;
-(void)loginFailure;
@end