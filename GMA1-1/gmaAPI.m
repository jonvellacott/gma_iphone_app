//
//  gmaAPI.m
//  GMA1-0
//
//  Created by Jon Vellacott on 10/12/2012.
//
//

#import "gmaAPI.h"
#import <AFNetworking.h>
@implementation gmaAPI

@synthesize gmaURL;

@synthesize targetService;
@synthesize KeyGUID;
@synthesize csrf_token;

#define MOBILECAS_URL @"https://agapeconnect.me/MobileCAS/MobileCAS.svc/AuthenticateWithTheKey"

#define TARGET_SERVICE_SUFFIX @"/?q=gmaservices&destination=gmaservices"
#define CSRF_TOKEN_URL @"/?q=services/session/token"
#define GMA_Nodes_SUFFIX @" "
#define GMA_StaffReport_SearchOwn @"gma_staffReport/searchOwn"
#define GMA_DirectorReport_SearchOwn @"gma_directorReport/searchOwn"
#define GMA_StaffReport @"gma_staffReport"
#define GMA_DirectorReport @"gma_directorReport"
#define GMA_StaffReport_Search @"gma_staffReport/searchAll"
#define GMA_DirectorReport_Search @"gma_directorReport/searchAll"
#define GMA_User_Active @"gma_user/&type=active"
#define GMA_User_Current @"gma_user/&type=current"
#define CAS_URL  @"https://thekey.me/cas/"

int counter =0 ;

- (id)initWithBaseURL: (NSString *)URL
{
    self = [super init];
    gmaURL = URL;
    return self;
}

- (void) targetServerForGmaServer: (NSString *)gmaServer {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
        NSLog(@"deleted cookie");
    }
    NSURL *url = [NSURL URLWithString:gmaServer];
    NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [httpRequest setHTTPMethod:@"HEAD"];
    [httpRequest setHTTPShouldHandleCookies:YES];
    
   // NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self];
        
  //  if(false) urlConnection = urlConnection;  //Get rid of the unused field warning
    
}

//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//   //Save TargetService to to UserDefaults...
//    if([[response.URL query] hasPrefix:@"q=" ])
//    {
//        NSLog(@"Error, session still active!!! Can't get redirect URL");
//        
//    }
//    else
//    {
//        self.targetService = [[response.URL query] stringByReplacingOccurrencesOfString:@"service=" withString:@""] ;  // get the service from the querystring
//        
//        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        
//        [prefs setObject: self.targetService forKey:@"gmaTargetService"];
//        [prefs synchronize];
//    }
//    
//    
//    
//}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"gmaLoginComplete"
     object:@"GMA_OFFLINE"];
    }

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    
      
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    if(httpResponse.statusCode ==302 && (self.authMode==1))
    {
       
        if(self.targetService)
        {
            
            NSString *newUrl = [[[httpResponse.allHeaderFields valueForKey:@"Location"] stringByReplacingOccurrencesOfString:@"https://thekey.me/cas/login?service=" withString:@""] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSMutableURLRequest *httpRequest = [NSMutableURLRequest  requestWithURL:[NSURL URLWithString:newUrl]  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
            [httpRequest setHTTPMethod:@"HEAD"];
            [httpRequest setHTTPShouldHandleCookies:YES];
            [httpRequest setValue: self.csrf_token forHTTPHeaderField:@"X-CSRF-Token"];
            self.authMode=2;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self startImmediately:YES];
            if(false) urlConnection = urlConnection;
            });
            
            
        }
        else{
            self.authMode=0;
            self.targetService = [[httpResponse.allHeaderFields valueForKey:@"Location"] stringByReplacingOccurrencesOfString:@"https://thekey.me/cas/login?service=" withString:@""] ;
              NSString *service = [self.targetService stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // NSString *tmpCookie = [[[httpResponse.allHeaderFields valueForKey:@"Set-Cookie"] stringByReplacingOccurrencesOfString:@"https://thekey.me/cas/login?service=" withString:@""] stringByRemovingPercentEncoding];
            //NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            //NSArray *cookies = [cookieStorage cookies];
            //for (NSHTTPCookie *cookie in cookies) {
            //    NSLog(@"%@=%@", cookie.name, cookie.value);
            //}
            
            [[TheKeyOAuth2Client sharedOAuth2Client] ticketForServiceURL:[NSURL URLWithString:service ] complete:^(NSString *ticket) {
                                   
                                   NSMutableURLRequest *httpRequest = [NSMutableURLRequest  requestWithURL:[NSURL URLWithString:[[service stringByAppendingString:@"&ticket="]stringByAppendingString:ticket]]  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
                                   [httpRequest setHTTPMethod:@"HEAD"];
                                   [httpRequest setHTTPShouldHandleCookies:YES];
                                   [httpRequest setValue: self.csrf_token forHTTPHeaderField:@"X-CSRF-Token"];
                                   self.authMode=1;
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self startImmediately:YES];
                                       if(false) urlConnection = urlConnection;
                                   });

                               }
             ];
                                   
                                   
            
            
            
           
            
        }
        
        
        return nil;
    }
    else if(response && self.authMode==2)
    {
//        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//        NSArray *cookies = [cookieStorage cookies];
//        for (NSHTTPCookie *cookie in cookies) {
//            NSLog(@"%@=%@", cookie.name, cookie.value);
//        }
        NSString *newCookie = [httpResponse.allHeaderFields valueForKey:@"Set-Cookie"];
        self.authMode=0;
        NSString *csrf_url = [self.gmaRootURL stringByAppendingString:CSRF_TOKEN_URL];
        
        self.csrf_token = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:csrf_url] encoding:nil error:nil];
        
        
        if(!newCookie)
        {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"gmaLoginComplete"
             object:@"NoCookie"];

        }
        
        
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"gmaLoginComplete"
         object:@"Success"];
    
        
    }

  
    return request;
}
-(void)AuthenticateUser
{
    
    self.gmaRootURL = [self.gmaURL stringByReplacingOccurrencesOfString:@"index.php?q=gmaservices" withString:@""];
    
   
    
   
    // NSLog(@"%@", self.gmaURL);
    //  NSMutableDictionary *rtn= [NSMutableDictionary dictionaryWithObjectsAndKeys:@"ERROR", @"Status", @"Unknown", @"Reason", nil];
    self.targetService=nil;
    ///Delete existing cookie session:
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
        NSLog(@"deleted cookie");
    }
    //Try to get csrf-token
    //Get Service
    
    NSMutableURLRequest *httpRequest1 = [NSMutableURLRequest  requestWithURL:[NSURL URLWithString:self.gmaURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    [httpRequest1 setHTTPMethod:@"HEAD"];
    [httpRequest1 setHTTPShouldHandleCookies:YES];
    
    
    
    
    self.authMode=1;
    //  [NSURLConnection  sendSynchronousRequest:httpRequest1 returningResponse:&resp error:&err];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:httpRequest1 delegate:self startImmediately:YES];
        if(false) urlConnection = urlConnection;
        
    });
  
    
    return  ;
    

    
    
}


- (void)AuthenticateUser: (NSString *)Username WithPassword: (NSString *)Password
{
    self.gmaRootURL = [self.gmaURL stringByReplacingOccurrencesOfString:@"index.php?q=gmaservices" withString:@""];
    
    self.username=Username;
    self.password = Password;
   // NSLog(@"%@", self.gmaURL);
  //  NSMutableDictionary *rtn= [NSMutableDictionary dictionaryWithObjectsAndKeys:@"ERROR", @"Status", @"Unknown", @"Reason", nil];
    self.targetService=nil;
    ///Delete existing cookie session:
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
        NSLog(@"deleted cookie");
    }
     //Try to get csrf-token
   
   
    
    

   
  
    
    
    //Get Service

    NSMutableURLRequest *httpRequest1 = [NSMutableURLRequest  requestWithURL:[NSURL URLWithString:self.gmaURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    [httpRequest1 setHTTPMethod:@"HEAD"];
    [httpRequest1 setHTTPShouldHandleCookies:YES];

    
    
    
    self.authMode=1;
  //  [NSURLConnection  sendSynchronousRequest:httpRequest1 returningResponse:&resp error:&err];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:httpRequest1 delegate:self startImmediately:YES];
    if(false) urlConnection = urlConnection;
    });
    
  //  [rtn setObject:@"SUCCESS" forKey:@"Status"];
 //   counter = 0;
    
    
    return  ;
    
    
//    self.targetService = [[resp.URL query] stringByReplacingOccurrencesOfString:@"service=" withString:@""] ;  // get the service from the querystring
//    
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    
//    [prefs setObject: self.targetService forKey:@"gmaTargetService"];
//    [prefs synchronize];
//     NSString *service = [self.targetService stringByRemovingPercentEncoding];
//    NSLog(@"Service: %@", service);
//    
//    
//    //Log Into CAS and get TGT
//    
//    httpRequest1.URL=[NSURL URLWithString:[CAS_URL stringByAppendingString:@"v1/tickets"]];
//    NSString *post = [NSString stringWithFormat:@"username=%@&password=%@", Username, Password];
//
//    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
//    
//    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
//                      
//    [httpRequest1 setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [httpRequest1 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [httpRequest1 setHTTPBody:postData];
//    [httpRequest1 setHTTPMethod:@"POST"];
//[NSURLConnection  sendSynchronousRequest:httpRequest1 returningResponse:&resp error:&err];
//    NSString *tgt;
//    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)resp;
//    if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
//        NSDictionary *dictionary = [httpResponse allHeaderFields];
//        //tgt=[[dictionary valueForKey:@"location"] stringByReplacingOccurrencesOfString:[httpRequest1.URL.absoluteString stringByAppendingString:@"/"] withString:@""];
//        tgt=[dictionary valueForKey:@"location"];
//        
//        NSLog(@"tgt: %@", tgt);
//
//    }
//    
//
//    //GET ST
//    httpRequest1.URL=[NSURL URLWithString:tgt];
//    post = [NSString stringWithFormat:@"service=%@", self.targetService];
//    postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
//    
//    postLength = [NSString stringWithFormat:@"%d", [postData length]];
//    
//    [httpRequest1 setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [httpRequest1 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [httpRequest1 setHTTPBody:postData];
//    NSData *data = [NSURLConnection  sendSynchronousRequest:httpRequest1 returningResponse:&resp error:&err];
//    NSString *st= [[NSString alloc] initWithData:data
//                                             encoding:NSUTF8StringEncoding] ;
//    
//    
//    NSLog(@"%@", st);
//    
//    
//    //Log into GMA
//    
//    
//  
//    
//    
//    NSMutableURLRequest *httpRequest = [NSMutableURLRequest  requestWithURL:[NSURL URLWithString:service] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
//    [httpRequest setHTTPMethod:@"HEAD"];
//    [httpRequest setHTTPShouldHandleCookies:YES];
//  dispatch_async(dispatch_get_main_queue(), ^{
//    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self startImmediately:YES];
//    });
//     
//    [rtn setObject:@"SUCCESS" forKey:@"Status"];
//    counter = 0;
//    
//    
//    return rtn ;
//    
//    
//    
//    
//   //[NSURLConnection  sendSynchronousRequest:httpRequest returningResponse:&resp error:&err];
//    
////    httpRequest.URL = resp.URL;  // get the service from the querystring
////   NSData *data2= [NSURLConnection  sendSynchronousRequest:httpRequest returningResponse:&resp error:&err];
//    cookies = [cookieStorage cookies];
//    NSString *myCookieName;
//    NSString *myCookieValue;
//    for (NSHTTPCookie *cookie in cookies) {
//        if (!([cookie.name isEqualToString:@"JSESSIONID"]))
//        {
//            myCookieName = cookie.name;
//            myCookieValue = cookie.value;
//        }
//          }
//    NSLog(@"%@=%@",myCookieName, myCookieValue);
//
//    
//    httpRequest.HTTPMethod=@"GET";
//    httpRequest.URL=[NSURL URLWithString:[gmaURL stringByAppendingString:@"?q=gmaservices/gma_user&type=active"]];
//    
//    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
//                                @"/", NSHTTPCookiePath,  // IMPORTANT!
//                                myCookieName, NSHTTPCookieName,
//                                myCookieValue, NSHTTPCookieValue,
//                                nil];
//    NSHTTPCookie *mycookie = [NSHTTPCookie cookieWithProperties:properties];
//    
//    NSArray* mycookies = [NSArray arrayWithObjects: mycookie, nil];
//    
//    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:mycookies];
//    
//    [httpRequest setAllHTTPHeaderFields:headers];
//    
//    NSData *data2= [NSURLConnection  sendSynchronousRequest:httpRequest returningResponse:&resp error:&err];
//    NSDictionary *results=data2 ? [NSJSONSerialization JSONObjectWithData:data2 options:0 error:&err]: nil;
//    
//
//    [rtn setObject:@"SUCCESS" forKey:@"Status"];
//    counter = 0;
//    
//    
//    return rtn ;
//    
//    
//    
//    
//    
//    
//    
//    self.targetService = @"https://aseaconnexion.org/ASEA/?q=node&destination=node";
//    //self.targetService=@"https%3A%2F%2Faseaconnexion.org%2FASEA%2F%3Fq%3Dgmaservices%26destination%3Dgmaservices";
//    
//   
//   // NSMutableDictionary *rtn= [NSMutableDictionary dictionaryWithObjectsAndKeys:@"ERROR", @"Status", @"Unknown", @"Reason", nil];
//    
//    NSString *query=  [MOBILECAS_URL  stringByAppendingFormat: @"?username=%@&password=%@&targetService=%@", Username, Password, service];
//  
//    	query =[query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//      NSLog(@"%@", query);
//    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString: query]   encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
//    
//    NSError *error = nil;
//    results=jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error]: nil;
//    
//    if((!results) ){
//        NSLog(@"Could not connect");
//        [rtn setObject:GMA_OFFLINE forKey:@"Reason" ];
//       if(loginBlock) loginBlock(NO);
//        return rtn;
//    }
//    BOOL success = [(NSString *)[results  objectForKey:@"LoginSuccess"] boolValue];
//   self.KeyGUID = (NSString *)[results  objectForKey:@"GUID"];
//   
//    
//    
//    if(success == YES)
//    {
//        //Save GUID (so I can recognise my own RenId
//         
//        
//
//        
//        
//        NSString *proxyTicket = (NSString *)[results  objectForKey:@"ProxyTicket"];
//        NSLog(@"Authanticated with TheKey. GUID:%@ Ticket:%@", self.KeyGUID, proxyTicket);
//        if(loginBlock) loginBlock(YES);
//        //AuthenticateWithGMA
//        NSString *gmaQuery = [service stringByAppendingFormat: @"&ticket=%@", proxyTicket];
//        NSLog(@"%@", gmaQuery);
//        
//        
//        NSURL *url = [NSURL URLWithString:gmaQuery];
//        
//   
//        NSMutableURLRequest *httpRequest = [NSMutableURLRequest  requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
//        [httpRequest setHTTPMethod:@"HEAD"];
//        [httpRequest setHTTPShouldHandleCookies:YES];
//        NSURLResponse *resp;
//        NSError *err;
//       cookies = [cookieStorage cookies];
//        for (NSHTTPCookie *cookie in cookies) {
//            [cookieStorage deleteCookie:cookie];
//            NSLog(@"deleted cookie");
//        }
//       NSData *data= [NSURLConnection  sendSynchronousRequest:httpRequest returningResponse:&resp error:&err];
//        NSString *gmaAuth= [[NSString alloc] initWithData:data
//                                                  encoding:NSUTF8StringEncoding] ;
//        NSLog(@"%@",gmaAuth);
//       // NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//        cookies = [cookieStorage cookies];
//        for (NSHTTPCookie *cookie in cookies) {
//            NSLog(@"%@=%@",cookie.name , cookie.value);
//        }
//        httpRequest.URL = [NSURL URLWithString:service];
//        
//         NSData *data2= [NSURLConnection  sendSynchronousRequest:httpRequest returningResponse:&resp error:&err];
//        cookies = [cookieStorage cookies];
//        for (NSHTTPCookie *cookie in cookies) {
//            NSLog(@"%@=%@",cookie.name , cookie.value);
//        }
//
//        [rtn setObject:@"SUCCESS" forKey:@"Status"];
//        counter = 0;
//return rtn ;
//        
//        
//        
//        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)resp;
//        if ([httpResponse statusCode] == 200 ) {
//            NSLog(@"GMA Login Successful");
//            [rtn setObject:@"SUCCESS" forKey:@"Status"];
//            counter = 0;
//           gmaAuth = [NSString stringWithContentsOfURL:[NSURL URLWithString: gmaQuery] encoding:NSUTF8StringEncoding error:nil] ;
//              NSLog(@"%@",gmaAuth);
//            return rtn ;
//        
//        }
//        else{
//            counter +=1 ;
//            
//            NSLog(@"Proxy Authentication via GMA Failed Attempt: %d", counter);
//            if(counter <4)
//            {
//                [self AuthenticateUser:Username WithPassword:Password LoginSuccessHandler: loginBlock] ;
//                
//            }
//            else{
//                //TheKey successfully authenticated, but GMA failed proxy authentication
//                //Show login error at footer.
//                counter = 0;
//                NSLog(@"TheKey successfully authenticated , but ProxyAuthentication failed after four attempts") ;
//                [rtn setObject:@"Proxy Authentication Error (4 Attempts)" forKey:@"Reason"];
//                
//                //Target Service might be incorrect - so reset it.
//                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//                self.targetService = nil;
//                [prefs setObject: nil forKey:@"gmaTargetService"];
//                [prefs synchronize];
//                
//                return rtn;
//            }
//
//        
//        }
//        
//        
////        NSString *gmaAuth = [NSString stringWithContentsOfURL:[NSURL URLWithString: gmaQuery] encoding:NSUTF8StringEncoding error:nil] ;
////        
////        if (gmaAuth && [gmaAuth rangeOfString:@"successfully"].location != NSNotFound) {
////            //The string has been found
////            
////            [rtn setObject:@"SUCCESS" forKey:@"Status"];
////            counter = 0;
////            return rtn ;
////        }
////        else{
////            
////            //lblLoginFailed.Text=@"GMA Login Failed";
////            
////            counter +=1 ;
////            NSLog(@"%@", gmaAuth);
////            NSLog(@"Proxy Authentication via GMA Failed Attempt: %d", counter);
////            if(counter <4)
////            {
////                [self AuthenticateUser:Username WithPassword:Password LoginSuccessHandler: loginBlock] ;
////                
////            }
////            else{
////                //TheKey successfully authenticated, but GMA failed proxy authentication
////                //Show login error at footer.
////                counter = 0;
////                NSLog(@"TheKey successfully authenticated , but ProxyAuthentication failed after four attempts") ;
////                [rtn setObject:@"Proxy Authentication Error (4 Attempts)" forKey:@"Reason"];
////                
////                //Target Service might be incorrect - so reset it.
////                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
////                self.targetService = nil;
////                [prefs setObject: nil forKey:@"gmaTargetService"];
////                [prefs synchronize];
////                
////                return rtn;
////            }
////           
////            
////            
////        }
////        
//       
//        
//    }
//    else {
//        NSLog(@"Authentication Failed");
//        [rtn setObject:@"Invalid Username or Password" forKey:@"Reason"];
//        return rtn ;
//      
//    }
//
//    return rtn ;
}

-(NSArray *)getAllUserNodes
{
    NSString *getReportsURL = [gmaURL  stringByAppendingFormat: @"/%@", GMA_StaffReport_SearchOwn];

    NSString *post = [NSString stringWithFormat:@"{ \"maxResult\": 0,\"orderBy\" : \"startDate\" }" ];
   //  NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //NSArray *cookies = [cookieStorage cookies];
    //for (NSHTTPCookie *cookie in cookies) {
    //    if([cookie.name isEqualToString:@"JSESSIONID"]){
    //        [cookieStorage deleteCookie:cookie];
    //        NSLog(@"Deleted: %@",cookie.name);
    //    }
    //    else{
    //    NSLog(@"%@ ; %@",cookie.name, cookie.domain);
    //    }
    //}
    
    
    
   // NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: getReportsURL ]];
    [request setHTTPMethod:@"POST"];
   // NSString *csrf_url = [self.gmaRootURL stringByAppendingString:CSRF_TOKEN_URL];
    
    //self.csrf_token = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:csrf_url] encoding:nil error:nil];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue: self.csrf_token forHTTPHeaderField:@"X-CSRF-Token"];
    [request setHTTPBody:postData];
    
    
    NSURLResponse *response;
    NSError *err;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
   
    
    NSDictionary *results=returnData ? [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&err]: nil;
 
    
    NSArray *data =(NSArray *)[[results  objectForKey:@"data"] objectForKey:@"staffReports"];
    NSArray *groupedData = [self groupNodes: data];
    return groupedData ;
  
}

-(NSMutableArray *)groupNodes: (NSArray *)gcxIn
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"node.nodeId" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSMutableArray *sections = [NSMutableArray array];
    
	// If we don't contain any items, return an empty collection of sections.
	if(gcxIn== (NSArray *)[NSNull null])
		return sections;
    if(gcxIn.count == 0)
        return sections;
    
    NSMutableArray *sortedInArray = gcxIn.mutableCopy;
    [sortedInArray sortUsingDescriptors:sortDescriptors];
    
    
    NSMutableArray *sectionItems = [NSMutableArray array];
    NSString *currentGroup = [(NSDictionary *)[(NSDictionary *)[gcxIn objectAtIndex:0] valueForKey:@"node"] valueForKey:@"nodeId"];
    for(NSDictionary *item in sortedInArray)
	{
		// Retrieve the grouping value from the current item.
		NSString* itemGroup = [(NSDictionary *)[item valueForKey:@"node"] valueForKey:@"nodeId"];
        
		// Compare the current item's grouping value to the current section's
		// grouping value.
		if(![itemGroup isEqual:currentGroup])
		{
			// The current item doesn't belong in the current section, so
			// store the section we've been building and create a new one,
			// caching the new grouping value.
			[sections addObject:sectionItems];
			sectionItems = [NSMutableArray array];
			currentGroup = itemGroup;
		}
        
		// Add the item to the appropriate section.
		[sectionItems addObject:item];
	}
    
	// If we were adding items to a section that has not yet been added
	// to the aggregate section collection, add it now.
	if([sectionItems count] > 0)
		[sections addObject:sectionItems];
    
    
    
    
    
	return sections;
    
    
}

	
-(NSArray *)getAllDirectorNodes
{
    NSString *getReportsURL = [gmaURL  stringByAppendingFormat: @"/%@", GMA_DirectorReport_SearchOwn];

    NSString *post = [NSString stringWithFormat:@"{ \"maxResult\": 0,\"orderBy\" : \"startDate\" }" ];
    
    
    
    
   // NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: getReportsURL ]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setValue: self.csrf_token forHTTPHeaderField:@"X-CSRF-Token"];

    
    NSURLResponse *response;
    NSError *err;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSDictionary *results=returnData ? [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&err]: nil;

    
    NSArray *data =(NSArray *)[[results  objectForKey:@"data"] objectForKey:@"directorReports"];
    NSArray *groupedData = [self groupNodes: data];
    return groupedData ;
    
}


-(NSDictionary *)getMeasurementsForNode: (NSNumber *) nodeId
{
    NSString *query=  [self.gmaURL  stringByAppendingFormat: @"/gma_node/%@/measurements", nodeId];
    
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString: query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results=jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error]: nil;
    
    
    NSDictionary *thedata = [results objectForKey: @"data"];
    return thedata;
    
    
}

-(NSDictionary *)getStaffReportAnswers: (NSNumber *) staffReportId
{
    NSString *getStaffReport = [self.gmaURL  stringByAppendingFormat: @"/%@/%@", GMA_StaffReport, staffReportId];
        
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString: getStaffReport] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    
    	
    NSError *error = nil;
    NSDictionary *results=jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error]: nil;
    
    
    
    NSDictionary *measurements = [results objectForKey: @"data"];
    return measurements ;
    
}

-(NSDictionary *)getDirectorReportAnswers: (NSNumber *) directorReportId
{
    if([directorReportId intValue] <0) directorReportId=[NSNumber numberWithLong: -[directorReportId integerValue]];
    
    NSString *getDirectorReport = [self.gmaURL  stringByAppendingFormat: @"/%@/%@", GMA_DirectorReport, directorReportId ];
    
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString: getDirectorReport] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSError *error = nil;
    NSDictionary *results=jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error]: nil;
    
    
    
    NSDictionary *measurements = [results objectForKey: @"data"];
    return measurements ;
    
}

-(NSString *) saveAnswerForMeasurementId:(NSNumber *)measurementId inStaffReport:(NSNumber *)  staffReportId withValue:(NSString *)value ofType:(NSString *)type
{
    NSString *getReportsURL = [gmaURL  stringByAppendingFormat: @"/%@/%@", GMA_StaffReport, staffReportId];
   //NSLog(@"Uploading Answer");
    if([type isEqualToString: @"text"]){
       value=[NSString stringWithFormat:@"\"%@\"", value];
    }
    NSString *post = [NSString stringWithFormat:@"[{ \"measurementId\": \"%@\",\"type\": \"%@\",\"value\" : %@ }]", measurementId, type, value  ];
    //NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: getReportsURL ]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setValue: self.csrf_token forHTTPHeaderField:@"X-CSRF-Token"];

    
    NSURLResponse *response;
    NSError *err;	
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
  
    if(!returnData)
   {
       NSLog(@"Error: %@", err);
       return GMA_NO_CONNECT;
       
       
   }
    else
    {
        
        NSDictionary *results=returnData ? [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&err]: nil ;
        

        
        if(err){
            
            return GMA_NO_AUTH ;
        }
        BOOL success = [(NSString *)[results  objectForKey:@"success"] boolValue];
        return success ? GMA_SUCCESS : GMA_FAIL;
    }
    
}

- (NSString *) submitStaffReport:(NSNumber *) staffReportId
{
    NSString *getReportsURL = [gmaURL  stringByAppendingFormat: @"/%@/%@", GMA_StaffReport, staffReportId];
    //NSLog(@"Submitting StaffReport: %@", staffReportId);
    
    NSString *post = @"[]" ;
    //NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: getReportsURL ]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setValue: self.csrf_token forHTTPHeaderField:@"X-CSRF-Token"];

    
    NSURLResponse *response;
    NSError *err;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    if(!returnData)
    {
        NSLog(@"Error: %@", err);
        return GMA_NO_CONNECT;
        
        
    }
    else
    {
        
        NSDictionary *results=returnData ? [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&err]: nil ;
        

        
        if(err){
            
            return GMA_NO_AUTH ;
        }
        BOOL success = [(NSString *)[results  objectForKey:@"success"] boolValue];
        return success ? GMA_SUCCESS : GMA_FAIL;
    }
    
    
}

- (NSString *) saveAnswerForMeasurementId:(NSNumber *)measurementId inDirectorReport:(NSNumber *)  directorReportId withValue:(NSString *)value ofType:(NSString *)type
{
    NSString *getReportsURL = [gmaURL  stringByAppendingFormat: @"/%@/%@", GMA_DirectorReport, directorReportId];
    //NSLog(@"Uploading Answer");
    if([type isEqualToString: @"text"]){
        type=[NSString stringWithFormat:@"\"%@\"", type];
    }
    NSString *post = [NSString stringWithFormat:@"[{ \"measurementId\": \"%@\",\"type\": \"%@\",\"value\" : %@ }]", measurementId, type, value  ];
    //NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: getReportsURL ]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setValue: self.csrf_token forHTTPHeaderField:@"X-CSRF-Token"];

    
    NSURLResponse *response;
    NSError *err;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    if(!returnData)
    {
        //NSLog(@"Error: %@", err);
        return GMA_NO_CONNECT;
        
        
    }
    else
    {
        
        NSDictionary *results=returnData ? [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&err]: nil ;
        

        
        if(err){
            
            return GMA_NO_AUTH ;
        }
        BOOL success = [(NSString *)[results  objectForKey:@"success"] boolValue];
        return success ? GMA_SUCCESS : GMA_FAIL;
    }
    
}

- (NSString *) submitDirectorReport:(NSNumber *) directorReportId
{
    NSString *getReportsURL = [gmaURL  stringByAppendingFormat: @"/%@/%@", GMA_DirectorReport, directorReportId];
    //NSLog(@"Submitting DirectorReport: %@", directorReportId);
    
    NSString *post = @"[]" ;
    //NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: getReportsURL ]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setValue: self.csrf_token forHTTPHeaderField:@"X-CSRF-Token"];

    
    NSURLResponse *response;
    NSError *err;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    if(!returnData)
    {
        //NSLog(@"Error: %@", err);
        return GMA_NO_CONNECT;
        
        
    }
    else
    {
        
        NSDictionary *results=returnData ? [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&err]: nil ;
        
        
        
        if(err){
            
            return GMA_NO_AUTH ;
        }
        BOOL success = [(NSString *)[results  objectForKey:@"success"] boolValue];
        return success ? GMA_SUCCESS : GMA_FAIL;
    }
    
    
}


-(NSArray *)getReportsForDirectorNode: (NSNumber *)nodeId atDate: (NSNumber *)date
{
    
    NSString *getReportsURL = [gmaURL  stringByAppendingFormat: @"/%@", GMA_StaffReport_Search];
    
    NSString *post = [NSString stringWithFormat:@"{ \"nodeId\":[%d],\"dateWithin\": \"%d\",\"maxResult\": 0}", [nodeId intValue], [date intValue] ];
    
    
    
    
    //NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: getReportsURL ]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setValue: self.csrf_token forHTTPHeaderField:@"X-CSRF-Token"];

    
    NSURLResponse *response;
    NSError *err;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSDictionary *results=returnData ? [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&err]: nil;

    
    NSArray *data =(NSArray *)[[results  objectForKey:@"data"] objectForKey:@"staffReports"];
    if(data)
    {
        NSArray *groupedData = [self groupNodes: data];
         return groupedData ;
    }
    else return nil;
   
    
}

-(NSArray *)getUsers: (BOOL) active
{
    
    NSString *query=  [self.gmaURL   stringByAppendingFormat: @"/%@", GMA_User_Current];
    if(active)
        query=  [self.gmaURL   stringByAppendingFormat: @"/%@", GMA_User_Active];
    
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString: query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results=jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error]: nil;
    
    
    NSArray *thedata = [results objectForKey: @"data"];
    
    BOOL success = [(NSString *)[results  objectForKey:@"success"] boolValue];
    if(!success && active)
        thedata = [self getUsers: NO];
    
    return thedata;
    
    
}



@end
