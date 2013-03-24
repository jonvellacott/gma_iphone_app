//
//  StaffReports+Create.m
//  GMA1-0
//
//  Created by Jon Vellacott on 05/10/2012.
//
//

#import "StaffReports+Create.h"


@implementation StaffReports (Create)
+(StaffReports *) StaffReportWithStaffReportId: (NSNumber *)staffReportId
                                     startDate: (NSNumber *)startDate
                                       endDate: (NSNumber *)endDate
                                     submitted: (BOOL)submitted
                                         user:  (Users *)user
                                          type: (NSString *)type
                                          node: (NSNumber *)nodeId
                        inManagedObjectContext: (NSManagedObjectContext *) context
{
    
    if(!user)
        return nil;
    
    StaffReports *sr = nil;
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"StaffReports"];
    request.predicate = [NSPredicate predicateWithFormat:@"staffReportId == %@ AND user.renId==%@ AND type==%@ AND node.nodeId = %@", staffReportId, user.renId, type, nodeId] ;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"staffReportId" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    
    //NowI need to get the User
           
    
    
    
    if (!matches || ([matches count] >1)){
        // TODO handle error (Delete extra reports)
        NSLog(@"Error: more than one Staff Report with id:%@ exists in modal.", staffReportId);
        sr = [matches lastObject];
        if(startDate.intValue != sr.startDate.intValue || endDate.intValue != sr.endDate.intValue || sr.submitted.intValue != [NSNumber numberWithBool:submitted].intValue )
        {
            sr.startDate = startDate ;
            sr.endDate = endDate;
            sr.submitted = [NSNumber numberWithBool:submitted];
            sr.type=type;
             
           // [context save: nil];
        }
        
    }else if ([matches count]==0){
        
        sr=[NSEntityDescription insertNewObjectForEntityForName:@"StaffReports" inManagedObjectContext:context];
        
        sr.staffReportId = staffReportId;
        sr.startDate = startDate ;
        sr.endDate = endDate;
        sr.submitted = [NSNumber numberWithBool:submitted];
        sr.type=type;
        if(user)
            [user addStaffReportsObject:sr ] ;
       
        
        NSString *interval = [self getStaffReportType:sr];
        if(![sr.node.interval isEqualToString:  interval]  )
            sr.node.interval=interval;
        
       
       // [context save: nil];
  
        
        
    }else{
        sr = [matches lastObject];
        if(startDate.intValue != sr.startDate.intValue || endDate.intValue != sr.endDate.intValue || sr.submitted.intValue != [NSNumber numberWithBool:submitted].intValue )
        {
            sr.startDate = startDate ;
            sr.endDate = endDate;
            sr.submitted = [NSNumber numberWithBool:submitted];
            sr.type = type;
           //[context save: nil];
        }

    }
    
    
    return sr;
    

}

+(StaffReports *) getLatestStaffReportForNodeId: (NSNumber *)nodeId
                        inManagedObjectContext: (NSManagedObjectContext *) context
{
   
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"StaffReports"];
    request.predicate = [NSPredicate predicateWithFormat:@"node.nodeId = %@ AND renId=nil", nodeId] ;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    
    return [matches lastObject];
  
}

+(NSDictionary *) getIntervalForStaffReport: (NSNumber *)sr inManagedObjectConext:(NSManagedObjectContext *)context
{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"StaffReports"];
    request.predicate = [NSPredicate predicateWithFormat:@"staffReportId = %@", sr] ;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"staffReportId" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if(matches.count >0)
    {
        StaffReports *theSr = [matches lastObject];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        // NSDate *dateFromString = [[NSDate alloc] init];
        // voila!
        NSDate *startDate = [dateFormatter dateFromString:[theSr.startDate stringValue]];
        NSDate *endDate = [dateFormatter dateFromString:[theSr.endDate stringValue]];
         NSDictionary *rtn= [NSDictionary dictionaryWithObjectsAndKeys:theSr.node.interval, @"interval", startDate, @"startDate", endDate, @"endDate", theSr.startDate, @"rawStartDate", nil];
        
        
        return rtn;
    }
    return nil;
    
}


#define WEEKLY @"Daily"
#define MONTHLY @"Daily"
#define QUARTERLY @"Daily"
#define YEARLY @"Daily"


+(NSString *) getStaffReportType: (StaffReports *)sr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
   // NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    NSDate *startDate = [dateFormatter dateFromString:[sr.startDate stringValue]];
    NSDate *endDate = [dateFormatter dateFromString:[sr.endDate stringValue]];
    
    int diff = abs( [self daysBetweenDate:startDate andDate:endDate]);
  
    if(diff<10)
        return WEEKLY;
    else if(diff<40)
        return MONTHLY;
    else if(diff<100)
        return QUARTERLY;
    else
        return YEARLY;
  
    
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}


@end
