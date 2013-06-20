//
//  Answers+Create.m
//  GMA1-0
//
//  Created by Jon Vellacott on 07/12/2012.
//
//

#import "Answers+Create.h"

@implementation Answers (Create)

+(Answers *) AnswerForMeasurementId: (NSNumber *) measurementId
                    MeasurementType: (NSString *) measurementType
                     InStaffReport: (NSNumber *) staffReportId
                         WithValue:  (NSString *)value
                             InNode: (NSNumber *) node
                               type: (NSString *)type
            inManagedObjectContext: (NSManagedObjectContext *) context
{
    Answers *a = nil;
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Answers"];
    request.predicate = [NSPredicate predicateWithFormat:@"measurement.measurementId == %@ && measurement.type == %@ && staffReport.staffReportId == %@ && staffReport.type == %@ && staffReport.node.nodeId == %@" , measurementId, measurementType, staffReportId, type, node] ;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] >1)){
        // TODO handle error (Delete extra reports)
        NSLog(@"Error: more than one answer exisist for measurementId:%@ in StaffReportId:%@ in modal.", measurementId, staffReportId);
        a = [matches lastObject];
        if( ![a.value isEqualToString:value])
        {
            a.value = value;
            //[context save: nil];
            
            
        }

        // [context save: nil];
        NSLog(@"edited Value: %@", value);
       
    }else if ([matches count]==0){
        
               //Get Both Measurement and Staff Report , and add this answer
        NSArray *matches1 ;
       
            NSFetchRequest *request1 = [NSFetchRequest fetchRequestWithEntityName:@"StaffReports"];
            request1.predicate = [NSPredicate predicateWithFormat:@"staffReportId == %@ AND type == %@ && node.nodeId == %@",  staffReportId, type, node] ;
            NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"staffReportId" ascending:YES];
            request1.sortDescriptors = [NSArray arrayWithObject:sortDescriptor1];
            matches1 = [context executeFetchRequest:request1 error:&error];
       
        NSFetchRequest *request2= [NSFetchRequest fetchRequestWithEntityName:@"Measurements"];
        request2.predicate = [NSPredicate predicateWithFormat:@"measurementId == %@ && type == %@",  measurementId, measurementType] ;
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"measurementId" ascending:YES];
        request2.sortDescriptors = [NSArray arrayWithObject:sortDescriptor2];
        NSArray *matches2 = [context executeFetchRequest:request2 error:&error];
        
            if([matches1 count] == 0 || [matches2 count] ==0)
            {
               

                //ERROR: one of these does not exists
                NSLog(@"ERROR, Either the measurement or the staff report does not exist. Cannot add answer");
                return nil;
            
            }else{
                a=[NSEntityDescription insertNewObjectForEntityForName:@"Answers" inManagedObjectContext:context];
                
                a.value=value;
              //  a.mcc= ((Measurements *)[matches2 lastObject] ).mcc;
              //  NSLog(@"Added Value: %@", value);
                [(StaffReports *)[matches1 lastObject] addAnswersObject: a];
                [(Measurements *)[matches2 lastObject] addAnswersObject: a];
            }
        
       // [context save: nil];
                
    }else{
        a = [matches lastObject];
        
        if( ![a.value isEqualToString:value])
        {
            a.value = value;
            //[context save: nil];
          
            
        }
        

        
    }

    

    return a;
    
    
    
    
}
@end
