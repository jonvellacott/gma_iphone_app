//
//  TheKey.m
//  TheKey
//
//  Created by Brian Zoetewey on 7/12/13.
//  Copyright (c) 2013 Campus Crusade for Christ, Intl. All rights reserved.
//

#import "TheKey.h"
#import <UIKit/UIKit.h>
#import <GTMOAuth2Authentication.h>
#import <GTMOAuth2ViewControllerTouch.h>
#import <GTMHTTPFetcher.h>

static NSString *const oAuthTokenPath      = @"api/oauth/token";
static NSString *const oAuthTicketPath     = @"api/oauth/ticket";
static NSString *const oAuthAuthorizePath  = @"oauth/authorize";
static NSString *const oAuthScope          = @"fullticket";
static NSString *const oAuthRedirectURI    = @"thekey:/oauth/mobile/ios";
static NSString *const authFromKeychainKey = @"TheKeyOAuth";

static NSString *const kTheKeyClientID = @"TheKeyClientID";
static NSString *const kTheKeyServerURL = @"TheKeyServerURL";
static NSString *const kTheKeyGUID = @"TheKeyUserGUID";

//NSUserDefaults Keys
static NSString *const guidKey = @"TheKeyGUID";

@interface TheKey ()
@property (strong, nonatomic) GTMOAuth2Authentication *auth;
-(GTMOAuth2Authentication *)getTheKeyAuth;
-(void)setGuid:(NSString *)guid;
@end

@implementation TheKey

@synthesize clientId = _clientId;
@synthesize casServer = _casServer;
@synthesize auth = _auth;

+(TheKey *)theKey {
    static dispatch_once_t once_t;
    __strong static TheKey *_theKey;
    dispatch_once(&once_t, ^{
        NSString *clientId = [[NSBundle mainBundle] objectForInfoDictionaryKey:kTheKeyClientID];
        NSString *serverURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:kTheKeyServerURL];
        _theKey = [[self alloc] initWithClientId:clientId CASServerURL:[NSURL URLWithString:serverURL]];
    });
    return _theKey;
}

-(id)initWithClientId:(NSString *)clientId CASServerURL:(NSURL *)casServer {
    self = [super init];
    if(self) {
        _clientId = [clientId copy];
        _casServer = [casServer copy];
        _auth = [self getTheKeyAuth];
        if( _auth) {
            [GTMOAuth2ViewControllerTouch authorizeFromKeychainForName:authFromKeychainKey authentication:[self auth] error:nil];
        }
    }
    return self;
}

-(id)initWithClientId:(NSString *)clientId CASServerString:(NSString *)casServer {
    return [self initWithClientId:clientId CASServerURL:[NSURL URLWithString:casServer]];
}

-(NSURL *)getCasUriWithPath:(NSString *)path {
    return [[self getCasUri] URLByAppendingPathComponent:path];
}

-(NSString *)getGuid {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kTheKeyGUID];
}

-(void)setGuid:(NSString *)guid {
    NSLog(@"Set GUID = %@", guid);
    [[NSUserDefaults standardUserDefaults] setValue:guid forKey:kTheKeyGUID];
}

-(GTMOAuth2Authentication *)getTheKeyAuth {
    NSURL *tokenURL = [self getCasUriWithPath:oAuthTokenPath];
    
    GTMOAuth2Authentication *auth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"Ekko" tokenURL:tokenURL redirectURI:oAuthRedirectURI clientID:[self clientId] clientSecret:@""];
    auth.scope = oAuthScope;
    return auth;
}

-(BOOL)canAuthenticate {
    BOOL canAuth = [[self auth] canAuthorize];
    return canAuth;
}

-(void)signOut {
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:authFromKeychainKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTheKeyGUID];
    self.auth = [self getTheKeyAuth];
}

-(void)getTicketForService:(NSURL *)serviceURL
         completionHandler:(void (^)(NSString *, NSError *))handler {
    NSDictionary *queryParams = @{@"service": [serviceURL absoluteString]};
    NSString *queryString = [GTMOAuth2Authentication encodedQueryParametersForDictionary:queryParams];

    NSURL *ticketURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [[self getCasUriWithPath:oAuthTicketPath] absoluteString], queryString]];

    NSMutableURLRequest *ticketRequest = [NSMutableURLRequest requestWithURL:ticketURL];
    [[self auth] authorizeRequest:ticketRequest completionHandler:^(NSError *error) {
        if(error == nil) {
            NSHTTPURLResponse *ticketResponse = nil;
            NSError *ticketError = nil;

            

            NSData *data = [NSURLConnection sendSynchronousRequest:ticketRequest returningResponse:&ticketResponse error:&ticketError];
            if(data && [ticketResponse statusCode] == 200) {
                NSError *jsonError = nil;
                NSDictionary *json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:nil error:&jsonError];
                NSString *ticket = (NSString *)[json valueForKey:@"ticket"];
                if(handler) {
                    NSLog(@"getTicketForService: %@", ticket);
                    handler(ticket, nil);
                    return;
                }
            }
        }
        if(handler)
            handler(nil, nil);
    }];
}

-(UIViewController *)showDialog:(id<TheKeyLoginDialogDelegate>)delegate {
    GTMOAuth2ViewControllerTouch *viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithAuthentication:[self auth] authorizationURL:[self getCasUriWithPath:oAuthAuthorizePath] keychainItemName:authFromKeychainKey completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
        if(error) {
            [delegate loginFailure];
        }
        else {
            [self setGuid:[[auth parameters] objectForKey:@"thekey_guid"]];
            [delegate loginSuccess];
        }
    }];
    viewController.initialHTMLString = @"<html><body style=\"background-color:#2a5087;\"></body></html>";
    return viewController;
}

@end
