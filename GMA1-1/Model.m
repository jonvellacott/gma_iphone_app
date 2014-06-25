	//
//  Model.m
//  GMA1-0
//
//  Created by Jon Vellacott on 10/12/2012.
//
//

#import "Model.h"
#import "PDKeychainBindings.h"

@implementation Model
@synthesize allNodesForUser = _allNodesForUser;
@synthesize api ;
@synthesize alertBarController;
@synthesize myRenId;
@synthesize gma_Api;
@synthesize gma_Moc;
@synthesize offlineMode;
@synthesize forceSave;
@synthesize fileName;
@synthesize myusername    ;
@synthesize mypassword;


typedef void(^MyCustomBlock)(BOOL success);

MyCustomBlock openBlock;

typedef  void(^gmaAuthCompletionBlock)(NSDictionary *status);
typedef void (^theKeyLoginBlock)(BOOL);

gmaAuthCompletionBlock authBlock;
theKeyLoginBlock authLoginBock;
//Standard Colors:

-(void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(id) initWithCompletionHander: (void (^)(BOOL  success))block
{
    self = [super init];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userName =  [[PDKeychainBindings sharedKeychainBindings]  objectForKey:@"UserName"];

    NSString *gmaServer = [prefs objectForKey:@"gmaServer"];
   
    
    
    
    
    
    
    self.myRenId = [prefs objectForKey:@"renId"];
    self.gma_Api=dispatch_queue_create("gma-api", NULL);
    
    self.gma_Moc=dispatch_queue_create("gma-moc", NULL);

    
    self.offlineMode = NO;
    self.forceSave = NO;
    
    
    

        
    
    
    
    

    
    if (!self.allNodesForUser){
        openBlock = block;
        api = [[gmaAPI alloc] initWithBaseURL:gmaServer] ;
        
        
        if (![prefs objectForKey:@"gmaTargetService"] || [[prefs objectForKey:@"gmaTargetService"] hasPrefix:@"q="])
        {
            self.api.targetService = nil;
            [self.api targetServerForGmaServer:gmaServer];
        }
        
        
        else self.api.targetService = (NSString *)[prefs objectForKey:@"gmaTargetService"];
        
        NSLog(@"tg:%@", (NSString *)[prefs objectForKey:@"gmaTargetService"]);
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject];
      
            
        if(userName)
        {
        
            
            self.fileName = [self getFileNameForUser:userName atGMAServer:gmaServer] ;
        
            //NSLog(@"Filename: %@",fileName);
        
        
            url = [url URLByAppendingPathComponent:self.fileName] ;
       // dispatch_async(self.gma_Moc, ^{
            self.allNodesForUser= [[UIManagedDocument alloc] initWithFileURL:url] ;
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                     [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
            self.allNodesForUser.persistentStoreOptions = options;
        //});
        }
    }

   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gmaSeverDidChange:)name:@"gmaServerChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveGmaLoginComplete:)
                                                 name:@"gmaLoginComplete"
                                               object:nil];
    

    
    
    return self;
}

- (void) receiveGmaLoginComplete:(NSNotification *) notification
{
   
    
    if([notification.object isEqualToString:@"Success"]){
        NSLog(@"GMA Authentication Complete");
        
        NSDictionary *rtn= [NSDictionary dictionaryWithObjectsAndKeys:@"SUCCESS", @"Status", @"", @"Reason",[NSNumber numberWithBool:self.filenameChanged], @"filenameChanged",nil];
    
        self.filenameChanged = NO;
    authLoginBock(YES);
        authBlock(rtn) ;
        [self.alertBarController hideAlertBar];
        return;
    }
    else if([notification.object isEqualToString:@"NoServiceTicket"])
    {
        NSLog(@"No Servcie Ticket on Attempt: %d", self.api.counter);
        self.api.counter++;
        if(self.api.counter<4) { [api AuthenticateUser:self.api.username WithPassword:self.api.password ]; return;}
       
       
    }
    else if([notification.object isEqualToString:@"NoCookie"])
    {
         NSLog(@"No Cookie on Attempt: %d", self.api.counter);
        self.api.counter++;
        if(self.api.counter<4) { [api AuthenticateUser:self.api.username WithPassword:self.api.password ]; return;}
    }
    else if([notification.object isEqualToString:@"AuthFailed"])
    {
        NSLog(@"Key Authentication Failed");
    
        authLoginBock(NO);
        NSDictionary *rtn= [NSDictionary dictionaryWithObjectsAndKeys:@"ERROR", @"Status", @"Invalid Username or Password", @"Reason", [NSNumber numberWithBool:self.filenameChanged],@"filenameChanged", nil];
        
        self.filenameChanged = NO;
        
        authBlock(rtn) ;
        [self.alertBarController hideAlertBar];
        return ;
       
    }

    
    NSDictionary *rtn= [NSDictionary dictionaryWithObjectsAndKeys:@"ERROR", @"Status", GMA_OFFLINE, @"Reason", [NSNumber numberWithBool:self.filenameChanged],@"filenameChanged", nil];
    
    self.filenameChanged = NO;
    
    authBlock(rtn) ;
    [self.alertBarController hideAlertBar];
    
    
}


- (void) removeDatabase
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    [prefs setObject:nil forKey:[@"cacheStack" stringByAppendingString:self.fileName]];
    
    [prefs synchronize];
    
    [self.allNodesForUser.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:self.allNodesForUser.fileURL error:&error];
    }];
    
}


-(void) setUsername: (NSString *)username
{
    PDKeychainBindings* prefs = [PDKeychainBindings sharedKeychainBindings] ;
    [prefs setObject:username forKey:@"UserName"];
   
}
-(void) setPassword: (NSString *)password
{
    PDKeychainBindings* prefs = [PDKeychainBindings sharedKeychainBindings] ;
   [prefs setObject:password forKey:@"Password"];
}
-(NSString *) getUsername
{
    PDKeychainBindings* prefs = [PDKeychainBindings sharedKeychainBindings] ;
    return [prefs objectForKey:@"UserName"];
}
-(NSString *) getPassword
{
    PDKeychainBindings* prefs = [PDKeychainBindings sharedKeychainBindings] ;
    return [prefs objectForKey:@"Password"];
}

-(void) addItemToCacheStackForMeasurementId:(NSNumber *)measurementId measurementType: (NSString *) measurementType inStaffReport:(NSNumber *)  staffReportId     withValue:(NSString *)value oldValue:(NSString *) oldValue
{
    int _oldValue, _newValue, _diffValue;
    BOOL isNumber = NO;
    if(oldValue)
    {
        isNumber = YES;
        _oldValue = [oldValue intValue];
        _newValue = [value intValue];
        _diffValue =_newValue - _oldValue;
        
    }

    
    NSMutableDictionary *newStackItem= [NSMutableDictionary dictionaryWithObjectsAndKeys:measurementId, @"measurementId", measurementType, @"measurementType", staffReportId, @"staffReportId",  value, @"value", oldValue, @"oldValue", nil];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *cacheStack;
    if([prefs objectForKey:[@"cacheStack" stringByAppendingString:self.fileName]])
    {
        //If the Cache exists, look for existing Item
        cacheStack = [NSMutableArray arrayWithArray:[prefs objectForKey:[@"cacheStack" stringByAppendingString:self.fileName]] ];
         NSDictionary *existingItem;
        for (NSDictionary* dict in cacheStack) {
            if([[dict objectForKey:@"measurementId"] isEqualToNumber: measurementId] && [[dict objectForKey:@"staffReportId"] isEqualToNumber: staffReportId]  ){
                existingItem = dict;
                break ;
            }
        }
        if(existingItem)
        {
         // if an existing item exists...
         
                // change the new value of the existing item.
                [cacheStack removeObject:existingItem];
                newStackItem = [existingItem mutableCopy];
                [newStackItem setValue:value forKey:@"value" ];
                [cacheStack addObject:newStackItem.copy ];
                 //NSLog(@"cacheStack merged for m%@, s%@, old:%@, new:%@", measurementId, staffReportId,[existingItem valueForKey:@"oldValue"] , value );
            
        }
        else{
            //if an existing item cant be found (but the cache exists)... add it
            [cacheStack addObject:newStackItem.copy ];
            //NSLog(@"cacheStack added for m%@, s%@, old:%@, new:%@", measurementId, staffReportId,oldValue , value );
        }
        
        
    }else
    {
        //Create a new cache with the new object
        cacheStack = [NSMutableArray arrayWithObject: newStackItem];
                      
    }
   
    [prefs setObject:cacheStack forKey:[@"cacheStack" stringByAppendingString:self.fileName]];
   
       
    
    
    [prefs synchronize];
}

-(NSString *) getFileNameForUser: (NSString *) userName atGMAServer: (NSString *)gmaServer
{
    //Filename consists of the GMA Server Id , the UsernameId, and the
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *fn = @"Gma_" ;
    NSMutableDictionary *fileIds=[prefs objectForKey:@"FileIds"];
    
    NSString *fileKey = [[[userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] substringToIndex:MIN([userName length], 30)]stringByAppendingString:[[gmaServer stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] substringToIndex:MIN([gmaServer length], 30)]]  ;
    
    
    
    if(fileIds)
    {
        if(![fileIds objectForKey:fileKey])
        {
          [fileIds  setObject:[NSString stringWithFormat:@"%lu", (unsigned long)fileIds.count ] forKey: fileKey];
            [prefs synchronize];
            
        }
       fn = [fn stringByAppendingString:[fileIds objectForKey:fileKey] ];
        
    }
    else
    {
        NSMutableDictionary *fileIds = [NSMutableDictionary dictionaryWithObject:@"0" forKey: fileKey] ;
        [prefs setObject:fileIds forKey:@"FileIds"];
        [prefs synchronize];
        fn = [fn stringByAppendingString:@"0"] ;
    }
    NSLog(@"filename: %@",  fn);
    return fn ;
}


-(void) authenticateUserWithLoginSuccessHandler:(void (^)(BOOL))loginBlock CompletionHander: (void (^)(NSDictionary *status))block
{
    [self.alertBarController showMessage:@"Authenticating..." withBackgroundColor: activityColor withSpinner: YES];
    self.api.counter = 0;
    //verify fileId
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
    NSString *gmaServer = [prefs objectForKey:@"gmaServer"];
    self.myusername =[TheKeyOAuth2Client sharedOAuth2Client].guid;
      
    self.fileName = [self getFileNameForUser:self.myusername atGMAServer:gmaServer ];
    NSLog(@"Username: %@", self.myusername);
    self.filenameChanged = NO;
    if( ![self.allNodesForUser.fileURL.absoluteString hasSuffix: [fileName stringByAppendingString:@"/"]])
    {
        //  the username has changed... the database is incorrected and needs changing.
        
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject];
        
               
        url = [url URLByAppendingPathComponent:self.fileName] ;
        
        self.allNodesForUser= [[UIManagedDocument alloc] initWithFileURL:url] ;
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        self.allNodesForUser.persistentStoreOptions = options;

        
        self.api.gmaURL = gmaServer;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:nil forKey:@"renId"];
        [prefs synchronize];
        self.myRenId=nil;
        
        [self setUsername:nil];
        [self setPassword:nil];
        
        
        self.filenameChanged= YES;
        
    }
    //loginBlock(YES);
     
    [self.alertBarController showMessage:@"Contacting GMA..." withBackgroundColor:activityColor withSpinner: YES];
    authLoginBock = loginBlock;
    authBlock = block;
    //Authenticate user in API Thread
    dispatch_async(self.gma_Api, ^{
        for(int i =1; i<20; i++)  //TODO:  This is a bit ugly. Open Document thread and Get Service Thread (if called) must complete before continuing.
        {
            if(!self.api.targetService) sleep(0.5);
            else break;
        }

        
         [api AuthenticateUser];
       // [status setObject:[NSNumber numberWithBool:filenameChanged] forKey:@"filenameChanged"] ;
        
               
       // block(status.copy) ;
        
        
        
      //  [self.alertBarController hideAlertBar];
    });
    
}
-(void) saveModel
{
    //Thread Safe save model - which will actually write to disk
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.allNodesForUser.managedObjectContext performBlockAndWait:^{
        
        
        [self.allNodesForUser.managedObjectContext save:nil];
        [self.allNodesForUser savePresentedItemChangesWithCompletionHandler:nil];
              
    }];
    });
}

-(void) fetchAllUserNodesWithCompletionHandler: (void (^)())block
{
    //Get Users Reports (Staff/Director/Node) for past three months, grouped by Report Type then Node
    
    
    //if offline node - don't try to fetch data
    
    if(self.offlineMode) return ;
    
        
    //dispatch on the API thread
    dispatch_async(self.gma_Api, ^{
        [self.alertBarController showMessage:@"Downloading..." withBackgroundColor:activityColor withSpinner: YES];
        
        NSArray *users= [api getUsers: YES];  //TODO: THis might need to switch to Get All Users - but requires GMA permissions
        NSArray *groupedData = [api getAllUserNodes]; // Get Staff Reports 
        //NSArray *groupedData2 = [api getAllDirectorNodes];  // Get Director Reports
        dispatch_async(dispatch_get_main_queue(), ^{
         [self.allNodesForUser.managedObjectContext performBlock:^{
       
             
                        
             
        if(users)
        {
            //Save my User details to UserDefaults
            //self.myRenId=[user objectForKey:@"renId"];
           // NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
           // [prefs setObject:self.myRenId forKey:@"renId"];
           // [prefs synchronize];
           
                for(NSDictionary *user in users)
                {
                    if([[user objectForKey:@"GUID"] isEqualToString:self.api.KeyGUID])
                    {
                        self.myRenId=[user objectForKey:@"renId"];
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        [prefs setObject:self.myRenId forKey:@"renId"];
                        [prefs synchronize];
                            
                    }
                    [Users userWithRenId:[user objectForKey:@"renId"] Name:[user objectForKey:@"preferredName"] inManagedObjectContext:self.allNodesForUser.managedObjectContext ];
                }
        }
             [self saveModel] ;
             
        //Load data into Model in the managedObjectContext
   
           
            for (NSArray *nodeInfo in groupedData){
               // NSLog(@"Processing Node: %@", [(NSDictionary *)[(NSDictionary *)[nodeInfo objectAtIndex:0] valueForKey:@"node"] valueForKey:@"nodeId"] );
                                
                [Nodes nodeFromGmaInfoStaffReport:nodeInfo  inManagedObjectConext:self.allNodesForUser.managedObjectContext asDirectorNode:NO fromRenId:self.myRenId];
                
                
            }
              [self saveModel];
         
             
            //For now: Director Reports are being excluded
           /* for (NSArray *nodeInfo in groupedData2){
                //NSLog(@"Processing Director Node: %@", [(NSDictionary *)[(NSDictionary *)[nodeInfo objectAtIndex:0] valueForKey:@"node"] valueForKey:@"nodeId"]);
                [Nodes nodeFromGmaInfoStaffReport:nodeInfo  inManagedObjectConext:self.allNodesForUser.managedObjectContext asDirectorNode:YES  fromRenId:self.myRenId];
                
                
            }
            
            [self saveModel];*/
             
            [self.alertBarController hideAlertBar];
           
            if(block) block();
        }];
        });
        

        
        
        
        
        
        
        
    });
    
}


-(void) fetchStaffReport:(NSNumber *) sr forNode: (NSNumber *) nodeId atDate: (NSNumber *)date completionHandler:(void (^)())block
{
    

    if(self.offlineMode){if(block) block(); return ;}
   
    [self.alertBarController showMessage:@"Downloading..." withBackgroundColor:activityColor withSpinner: YES];
   
    //Call api on the	 API Thread
    dispatch_async(self.gma_Api, ^{
      
        //NSLog(@"Getting Staff Report: %@", sr);
        
        
        //NSDictionary *measurements;
        NSArray *groupedData ;
        NSString *type=@"Staff";
        NSNumber *absSr = [sr copy];
        if([nodeId intValue]<0){
         //    measurements=[self.api getMeasurementsForNode:[NSNumber numberWithInt: abs([nodeId intValue])]];
            absSr = [NSNumber numberWithInt:-[absSr intValue]];
            type=@"Director";
        }
        //else{
                //measurements=[self.api getMeasurementsForNode:nodeId];
        //}
       
        //dispatch managedObjectContext to load into model
       // [self.allNodesForUser.managedObjectContext performBlock:^{
       // [Nodes addMeasurements:measurements toNode:nodeId inManagedObjectConext:self.allNodesForUser.managedObjectContext asDirectorNode:[nodeId intValue]<0];
       // }];
        
        
      
        //back on API thread - get answers for the current staff report
            NSDictionary *answers ;
            if([nodeId intValue]<0)
            {
                answers =  [self.api  getDirectorReportAnswers:absSr];
                groupedData =  [self.api getReportsForDirectorNode:[NSNumber numberWithInt:-[nodeId intValue]] atDate:date];
                
            }
            else
            {
                   answers = [self.api  getStaffReportAnswers:absSr];
                
            }
          
        //Switch to managedObjectConext to load answers into model
        [self.allNodesForUser.managedObjectContext performBlock:^{
            //previous ensure changes are saved - to avoid duplicates
            [self saveModel];
       
            [Nodes addMeasurements:answers toNode:nodeId inManagedObjectConext:self.allNodesForUser.managedObjectContext asDirectorNode:[nodeId intValue]<0];
            
            
            
            //Answers is broken down by Question Type
            
            //Iterate through the Numeric Answers
            //int vieworder = 0;
            
            NSArray *mNumeric = [answers objectForKey:@"numericMeasurements"] ;
                
            if(mNumeric != (id)[NSNull null]){
                for(NSDictionary *mccs  in mNumeric)
                {
                    //int mccCount = 0;
                    
                    for(NSArray *mcc in mccs.allValues)
                    {
                        
                        for(NSDictionary *m in mcc)
                        {
                        
                            [Answers AnswerForMeasurementId:[m objectForKey: @"measurementId"] MeasurementType: @"Numeric" InStaffReport:sr WithValue:[[m objectForKey:  @"measurementValue"] stringValue]  InNode: nodeId
                                                       type: type
                                     inManagedObjectContext:self.allNodesForUser.managedObjectContext ] ;
                            
                
                            
                            
                            
                            
                        }
                        
                        
                    }
                    
                }
            }
            
            
            //Process Text  Measurements
            NSArray *mText = [answers objectForKey:@"textMeasurement"] ;
            if(!mText)
                mText= [answers objectForKey:@"textMeasurements"] ;
            
            if(mText != (id)[NSNull null]){
                
                for(NSDictionary *m in mText)
                {
                    
                    [Answers AnswerForMeasurementId:[m objectForKey:  @"measurementId"]  MeasurementType: @"Text"  InStaffReport:sr WithValue:[m objectForKey:  @"measurementValue"]  InNode: nodeId type:type inManagedObjectContext:self.allNodesForUser.managedObjectContext ] ;
                    
                    
                }
                
                
            }
            
            
            
            //Process Calculated Measurements
            NSArray *mCalc = [answers objectForKey:@"calculatedMeasurements"] ;
            if(mCalc != (id)[NSNull null]){
                for(NSDictionary *mccs  in mCalc)
                {
                    for(NSArray *mcc in mccs.allValues)
                    {
                        for(NSDictionary *m in mcc)
                        {
                          
                            [Answers AnswerForMeasurementId:[m objectForKey:  @"measurementId"]  MeasurementType: @"Calculated"  InStaffReport:sr WithValue:[[m objectForKey:  @"measurementValue"] stringValue]  InNode: nodeId  type:type   inManagedObjectContext:self.allNodesForUser.managedObjectContext ] ;
                            
                            
                        }
                        
                        
                    }
                    
                }
            }
            
            //Save model to file
            
            //gma.agapeconnect.me has hacked gma services to add SubNode Reports to the Director Report Retrieve.
            //see: https://docs.google.com/a/agape.org.uk/document/d/1L1k5CH2bHzbFYHDz7a1YL4ofe3hDCz5-dWsgmz3bZ5M/edit
            
            NSArray *mSubNodes = [answers objectForKey:@"child_nodes"] ;
            if(mSubNodes != (id)[NSNull null]){
                //Get the Directors SubNodeData
                
                for(NSDictionary *qs  in mSubNodes)
                {
                    NSNumber *measurementId = [qs objectForKey:@"measurementId"] ;
                    for(NSDictionary * a in [qs objectForKey:@"answers"])
                    {
                      
                        
                        
                        NSNumber *subNodeId = [a objectForKey:@"nodeId"];
                        NSString *subNodeName = [a objectForKey:@"nodeName"];
                        NSString *measurementAnswer = [[a objectForKey:@"measurementValue"] stringValue];
                        
                        [Nodes addStaffReport:sr toNode:subNodeId withName:subNodeName inManagedObjectConext:self.allNodesForUser.managedObjectContext];
                        NSString *mType=@"Numeric";
                        if (!stringIsNumeric(measurementAnswer)) mType=@"Text";
                            
                        [self saveModel];
                        
                        
                        [Answers AnswerForMeasurementId:measurementId MeasurementType:mType InStaffReport:sr WithValue:measurementAnswer  InNode: subNodeId type: @"SubNode" inManagedObjectContext:self.allNodesForUser.managedObjectContext];
                    
                       [self saveModel];
                    }
                }
              
                
                
                
            }
          

        //Save model to disk
        [self saveModel];
           
          
        
        //Now get all the staff reports (if director)
        if([nodeId intValue]<0){
             
           
                for (NSArray *nodeInfo in groupedData){
                    
                    
                    [Nodes nodeFromGmaInfoStaffReport:nodeInfo  inManagedObjectConext:self.allNodesForUser.managedObjectContext asDirectorNode:NO fromRenId: self.myRenId];
                       [self saveModel];
                    
                    //On each Director Report: Retrieve the staff reports for each of the staff members who report at this node
                    for(NSDictionary *report in nodeInfo){
                        
                        //add this user
                        
                        if([[report valueForKey:@"renId"] intValue] != self.myRenId.intValue)
                            [Users userWithRenId:[report valueForKey:@"renId"] Name:[NSString stringWithFormat:@"Unknown(%@)",[report valueForKey:@"renId"] ]inManagedObjectContext:self.allNodesForUser.managedObjectContext ];
                        
                        
                        [self fetchStaffReport:[report valueForKey:@"staffReportId"] forNode:[NSNumber numberWithInt:-[nodeId intValue]] atDate:date completionHandler:block] ;
                    }
                   [self saveModel];
                
                }
               
            
           
            
            
            
            
            
        }
         [self.alertBarController hideAlertBar];
         //NSLog(@"Finished Adding Answers");
         if(block)
            block();
         }];
     
 });
    
    
}



- (void)setAllNodesForUser:(UIManagedDocument *)allNodesForUser
{
    //Set the manageddocument
    if(_allNodesForUser!=allNodesForUser){
        _allNodesForUser = allNodesForUser;
        [self useDocument];
    }
    
}

-(void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.allNodesForUser.fileURL path] ]){
        [self.allNodesForUser saveToURL:self.allNodesForUser.fileURL  forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            openBlock(success);
                    } ];
        
    }else if (self.allNodesForUser.documentState == UIDocumentStateClosed){
        [self.allNodesForUser openWithCompletionHandler:^(BOOL success){
            openBlock(success);
            
        }];
    }else if (self.allNodesForUser.documentState == UIDocumentStateNormal){
        openBlock(YES);
       
    }
    
    
}

BOOL stringIsNumeric(NSString *str) {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:str];
   
    return !!number; // If the string is not numeric, number will be nil
}

-(BOOL) isCacheEmpty
{
    //Are there transactions queued that have not been uploaded
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([prefs objectForKey:[@"cacheStack" stringByAppendingString:self.fileName]])
    {
        return ((NSArray *)[prefs objectForKey:[@"cacheStack" stringByAppendingString:self.fileName]]).count ==0;
    }
    else
        return YES;

}
-(void) emptyCacheStack
{
    //Clear any pending transactions
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:nil forKey:[@"cacheStack" stringByAppendingString:self.fileName]];
    [prefs synchronize];
    
}


-(void) clearCacheStackWithCompletionHandler:(void (^)(NSString *))block
{
    //upload pending transactions
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
   
    if([prefs objectForKey:[@"cacheStack" stringByAppendingString:self.fileName]])
    {
        //If the Cache exists, look for existing Item
         
        dispatch_async(self.gma_Api, ^{
            NSMutableArray *cacheStack = [NSMutableArray arrayWithArray:[prefs objectForKey:[@"cacheStack" stringByAppendingString:self.fileName]] ] ;
            NSMutableArray *cacheStack2 = cacheStack.mutableCopy;

            
            NSString *result = @"";
            [self.alertBarController showMessage:@"Saving..." withBackgroundColor:activityColor withSpinner: YES];
            BOOL fail = NO;
        for(NSDictionary *thisItem in cacheStack)
        {
            
            if([[thisItem objectForKey:@"staffReportId"] intValue]<0)
            {
                result = [self.api saveAnswerForMeasurementId:[thisItem objectForKey:@"measurementId"] inDirectorReport:[NSNumber numberWithInt:-[[thisItem objectForKey:@"staffReportId"] intValue]] withValue:[thisItem objectForKey:@"value"] ofType:[[thisItem objectForKey:@"measurementType"] lowercaseString]];
            }
            else{
                
                result = [self.api saveAnswerForMeasurementId:[thisItem objectForKey:@"measurementId"] inStaffReport:[thisItem objectForKey:@"staffReportId"] withValue:[thisItem objectForKey:@"value"] ofType:[[thisItem objectForKey:@"measurementType"] lowercaseString]];
            }
            if([result isEqualToString:GMA_SUCCESS]) [cacheStack2 removeObject:thisItem];
            else if([result isEqualToString:GMA_FAIL]) {[cacheStack2 removeObject:thisItem]; fail=YES;}
            else{
                
                
                break;
            }
            
            
        }
            
            
        [prefs setObject:cacheStack2 forKey:[@"cacheStack" stringByAppendingString:self.fileName]];
        [prefs synchronize];
        if(fail) result = GMA_FAIL;
        if (block) block(result);
        });
        
    }
    
}


- (void) saveModelAnswerForMeasurementId:(NSNumber *)measurementId measurementType: (NSString *) measurementType  inStaffReport:(NSNumber *)  staffReportId  atNodeId: (NSNumber *) nodeId withValue:(NSString *)value  oldValue: (NSString *) oldValue  completionHandler:(void (^)(NSString *))block
{
    //Save an Answer
    
    [self.alertBarController showMessage:@"Saving..." withBackgroundColor:activityColor withSpinner: YES];
    NSString *type=@"Staff";
    
    //If the Staff ReportId <0, it is a Director Report. (I know this is horrible. )
    if(staffReportId.intValue <0)
        type=@"Director";

    
    			
       
    if(offlineMode)
    {
        [self.allNodesForUser.managedObjectContext performBlock:^{
            [Answers AnswerForMeasurementId:measurementId MeasurementType: measurementType InStaffReport:staffReportId WithValue:value InNode: nodeId type: type inManagedObjectContext:self.allNodesForUser.managedObjectContext];
            
        }];

        [self addItemToCacheStackForMeasurementId:measurementId measurementType:measurementType inStaffReport:staffReportId withValue:value
                                         oldValue:oldValue];
        block(GMA_OFFLINE_MODE);
    }
    else{
        dispatch_async(self.gma_Api, ^{
            
            NSString *result = @"";
            if([staffReportId intValue]<0)
            {
                result = [self.api saveAnswerForMeasurementId:measurementId inDirectorReport:[NSNumber numberWithInt:-[staffReportId intValue]] withValue:value ofType:[measurementType lowercaseString]];
            }
            else{
                
                result = [self.api saveAnswerForMeasurementId:measurementId inStaffReport:staffReportId withValue:value ofType:[measurementType lowercaseString]];
            }
            
            if([result isEqualToString:GMA_NO_CONNECT]  || [result isEqualToString:GMA_NO_AUTH] || [result isEqualToString:GMA_SUCCESS]){
                [self.allNodesForUser.managedObjectContext performBlock:^{
                    [Answers AnswerForMeasurementId:measurementId MeasurementType: measurementType InStaffReport:staffReportId WithValue:value InNode: nodeId type: type inManagedObjectContext:self.allNodesForUser.managedObjectContext];
                
                }];
            }
            
            if([result isEqualToString:GMA_NO_CONNECT]  || [result isEqualToString:GMA_NO_AUTH])
                [self addItemToCacheStackForMeasurementId:measurementId measurementType:measurementType inStaffReport:staffReportId withValue:value
                                                 oldValue:oldValue];
            
                        
            block(result);
        });

    }
    
    
   
   
    

    
}

- (void) submitStaffReportId: (NSNumber *)  staffReportId
{
   
    
    [self.alertBarController showMessage:@"Submitting..." withBackgroundColor:activityColor withSpinner: YES];
   
    dispatch_async(self.gma_Api, ^{
        if([staffReportId intValue]<0)
        {
            [self.api submitDirectorReport:[NSNumber numberWithInt:-[staffReportId intValue]]];
        }
        else
        {
             [self.api submitStaffReport:staffReportId];
        }
        [self.alertBarController hideAlertBar];
    });
}




@end