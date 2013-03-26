//
//  gmaAPI.m
//  GMA1-0
//
//  Created by Jon Vellacott on 10/12/2012.
//
//

#import "gmaAPI.h"

@implementation gmaAPI

@synthesize gmaURL;

@synthesize targetService;
#define MOBILECAS_URL @"https://agapeconnect.me/MobileCAS/MobileCAS.svc/AuthenticateWithTheKey"
//#define TARGET_SERVICE @"https%3a%2f%2fwww.globalopsccci.org%2fgma41demo15%2f%3fq%3den%2fgmaservices%26destination%3dgmaservices"

//#define TARGET_SERVICE_SUFFIX @"/?q=en/gmaservices&destination=gmaservices"
#define TARGET_SERVICE_SUFFIX @"/?q=gmaservices&destination=gmaservices"
//#define TARGET_SERVICE_SUFFIX @"/?q=gmaservices"
//#define GMA_API_URL @"https://www.globalopsccci.org/gma41demo15/index.php?q=gmaservices"
#define GMA_Nodes_SUFFIX @"gma_node"
#define GMA_StaffReport_SearchOwn @"gma_staffReport/searchOwn"
#define GMA_DirectorReport_SearchOwn @"gma_directorReport/searchOwn"
#define GMA_StaffReport @"gma_staffReport"
#define GMA_DirectorReport @"gma_directorReport"
#define GMA_StaffReport_Search @"gma_staffReport/searchAll"
#define GMA_DirectorReport_Search @"gma_directorReport/searchAll"
#define GMA_User_Active @"gma_user/&type=active"
#define GMA_User_Current @"gma_user/&type=current"


int counter =0 ;


- (id)initWithBaseURL: (NSString *)URL
{
    self = [super init];
    gmaURL = URL;
    return self;
}

- (void) targetServerForGmaServer: (NSString *)gmaServer {
    
    NSURL *url = [NSURL URLWithString:gmaServer];
    NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [httpRequest setHTTPMethod:@"HEAD"];
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self];
        
    if(false) urlConnection = urlConnection;  //Get rid of the unused field warning
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
   //Save TargetService to to UserDefaults...
    self.targetService = [[response.URL query] stringByReplacingOccurrencesOfString:@"service=" withString:@""] ;  // get the service from the querystring
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject: self.targetService forKey:@"gmaTargetService"];
    [prefs synchronize];
    
    
}


- (NSDictionary *)AuthenticateUser: (NSString *)Username WithPassword: (NSString *)Password LoginSuccessHandler:(void (^)(BOOL))loginBlock
{
    NSMutableDictionary *rtn= [NSMutableDictionary dictionaryWithObjectsAndKeys:@"ERROR", @"Status", @"Unknown", @"Reason", nil];
    
    NSString *query=  [MOBILECAS_URL  stringByAppendingFormat: @"?username=%@&password=%@&targetService=%@", Username, Password, self.targetService];
    
    query =[query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString: query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSDictionary *results=jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error]: nil;
    
    if((!results) ){
        NSLog(@"Could not connect");
        [rtn setObject:GMA_OFFLINE forKey:@"Reason" ];
       if(loginBlock) loginBlock(NO);
        return rtn;
    }
    BOOL success = [(NSString *)[results  objectForKey:@"LoginSuccess"] boolValue];
    NSString *guid = (NSString *)[results  objectForKey:@"GUID"];
   
    
    
    if(success == YES)
    {
        NSString *proxyTicket = (NSString *)[results  objectForKey:@"ProxyTicket"];
        NSLog(@"Authanticated with TheKey. GUID:%@ Ticket:%@", guid, proxyTicket);
        if(loginBlock) loginBlock(YES);
        //AuthenticateWithGMA
        NSString *gmaQuery = [gmaURL  stringByAppendingFormat: @"&ticket=%@", proxyTicket];
        NSLog(@"%@", gmaQuery);
        NSString *gmaAuth = [NSString stringWithContentsOfURL:[NSURL URLWithString: gmaQuery] encoding:NSUTF8StringEncoding error:nil] ;
        
        if (gmaAuth && [gmaAuth rangeOfString:@"successfully"].location != NSNotFound) {
            //The string has been found
            
            [rtn setObject:@"SUCCESS" forKey:@"Status"];
            counter = 0;
            return rtn ;
        }
        else{
            
            //lblLoginFailed.Text=@"GMA Login Failed";
            
            counter +=1 ;
            NSLog(@"%@", gmaAuth);
            NSLog(@"Proxy Authentication via GMA Failed Attempt: %d", counter);
            if(counter <4)
            {
                [self AuthenticateUser:Username WithPassword:Password LoginSuccessHandler: loginBlock] ;
                
            }
            else{
                //TheKey successfully authenticated, but GMA failed proxy authentication
                //Show login error at footer.
                counter = 0;
                NSLog(@"TheKey successfully authenticated , but ProxyAuthentication failed after four attempts") ;
                [rtn setObject:@"Proxy Authentication Error (4 Attempts)" forKey:@"Reason"];
                return rtn;
            }
           
            
            
        }
        
       
        
    }
    else {
        NSLog(@"Authentication Failed");
        [rtn setObject:@"Invalid Username or Password" forKey:@"Reason"];
        return rtn ;
      
    }

    return rtn ;
}

-(NSArray *)getAllUserNodes
{
    NSString *getReportsURL = [gmaURL  stringByAppendingFormat: @"/%@", GMA_StaffReport_SearchOwn];
    //NSLog(@"%@", getReportsURL);
   // NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //NSDate *since= [NSDate dateWithTimeIntervalSinceNow:-(3600*24*7*(27))]; //27 weeks
   // [formatter setDateFormat:@"yyyyMMdd"];
    
   // NSString *post = [NSString stringWithFormat:@"{ \"dateWithin\": \"%@\",\"maxResult\": 0,\"orderBy\" : \"nodeId\" }", [formatter stringFromDate:since]   ];
    NSString *post = [NSString stringWithFormat:@"{ \"maxResult\": 0,\"orderBy\" : \"startDate\" }" ];
    
    
    
    
   // NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: getReportsURL ]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
    NSURLResponse *response;
    NSError *err;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSDictionary *results=returnData ? [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&err]: nil;
    //NSString *content = [NSString stringWithUTF8String:[returnData bytes]];
    //NSLog(@"responseData: %@", content);
    //    NSArray *nodes =  getNodes from Web service
    
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
    //NSLog(@"%@", getReportsURL);
    // NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //NSDate *since= [NSDate dateWithTimeIntervalSinceNow:-(3600*24*7*(27))]; //27 weeks
    // [formatter setDateFormat:@"yyyyMMdd"];
    
    // NSString *post = [NSString stringWithFormat:@"{ \"dateWithin\": \"%@\",\"maxResult\": 0,\"orderBy\" : \"nodeId\" }", [formatter stringFromDate:since]   ];
    NSString *post = [NSString stringWithFormat:@"{ \"maxResult\": 0,\"orderBy\" : \"startDate\" }" ];
    
    
    
    
   // NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: getReportsURL ]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
    NSURLResponse *response;
    NSError *err;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSDictionary *results=returnData ? [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&err]: nil;
   // NSString *content = [NSString stringWithUTF8String:[returnData bytes]];
    //NSLog(@"responseData: %@", content);
    
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
    NSString *getDirectorReport = [self.gmaURL  stringByAppendingFormat: @"/%@/%@", GMA_DirectorReport, directorReportId];
    
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
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: getReportsURL ]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
   
    
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
        
       // NSString *content = [[NSString alloc]  initWithBytes:[returnData bytes]
       //                                               length:[returnData length] encoding: NSUTF8StringEncoding];
        //NSLog(@"responseData: %@", content);
        
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
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: getReportsURL ]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
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
        
        // NSString *content = [[NSString alloc]  initWithBytes:[returnData bytes]
        //                                               length:[returnData length] encoding: NSUTF8StringEncoding];
        //NSLog(@"responseData: %@", content);
        
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
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: getReportsURL ]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
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
        
        // NSString *content = [[NSString alloc]  initWithBytes:[returnData bytes]
        //                                               length:[returnData length] encoding: NSUTF8StringEncoding];
        //NSLog(@"responseData: %@", content);
        
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
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: getReportsURL ]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
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
        
        // NSString *content = [[NSString alloc]  initWithBytes:[returnData bytes]
        //                                               length:[returnData length] encoding: NSUTF8StringEncoding];
        //NSLog(@"responseData: %@", content);
        
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
    //NSLog(@"%@", getReportsURL);
    // NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //NSDate *since= [NSDate dateWithTimeIntervalSinceNow:-(3600*24*7*(27))]; //27 weeks
    // [formatter setDateFormat:@"yyyyMMdd"];
    
    // NSString *post = [NSString stringWithFormat:@"{ \"dateWithin\": \"%@\",\"maxResult\": 0,\"orderBy\" : \"nodeId\" }", [formatter stringFromDate:since]   ];
    NSString *post = [NSString stringWithFormat:@"{ \"nodeId\": %d,\"dateWithin\": \"%d\",\"maxResult\": 0}", [nodeId intValue], [date intValue] ];
    
    
    
    
    //NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: getReportsURL ]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
    NSURLResponse *response;
    NSError *err;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSDictionary *results=returnData ? [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&err]: nil;
   // NSString *content = [NSString stringWithUTF8String:[returnData bytes]];
    //NSLog(@"responseData: %@", content);
    //    NSArray *nodes =  getNodes from Web service
    
    NSArray *data =(NSArray *)[[results  objectForKey:@"data"] objectForKey:@"staffReports"];
    if(data)
    {
        NSArray *groupedData = [self groupNodes: data];
         return groupedData ;
    }
    else return nil;
   
    
}

-(NSDictionary *)getCurrentUser
{
    NSString *query=  [self.gmaURL   stringByAppendingFormat: @"/%@", GMA_User_Current];
    
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString: query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results=jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error]: nil;
    
    
    NSArray *thedata = [results objectForKey: @"data"];
    
    return (NSDictionary *)[thedata objectAtIndex:0];
    
    
}



@end
