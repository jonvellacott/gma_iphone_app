//
//  GMA_Servers.m
//  GMA1-1
//
//  Created by Jon Vellacott on 29/01/2013.
//  Copyright (c) 2013 Jon Vellacott. All rights reserved.
//

#import "GMA_Servers.h"

@implementation GMA_Servers
@synthesize servers;

- (id)init{
   self = [super init];
    if(!self.servers)
    {
        self.servers = [[NSDictionary alloc] initWithObjectsAndKeys:@"https://www.einsteinsgravity.com/index.php?q=gmaservices", @"Einstiens Gravity" ,
                                      @"https://www.globalopsccci.org/gma41demo15/index.php?q=gmaservices", @"Global Ops (Demo)",
                                      @"http://gma.agapeconnect.me/index.php?q=gmaservices" ,     @"AgapeConnect",nil];
        
    }
    
    return self;
}

@end
