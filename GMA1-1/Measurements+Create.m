//
//  Measurements+Create.m
//  GMA1-0
//
//  Created by Jon Vellacott on 07/12/2012.
//
//

#import "Measurements+Create.h"

@implementation Measurements (Create)
+(Measurements *) MeasurementWithMeasurementId: (NSNumber *)measurementId
                                          Name: (NSString *)name
                                          Type: (NSString *)type
                                           Mcc: (NSString *)mcc
                                     ViewOrder: (NSNumber *)viewOrder
                        inManagedObjectContext: (NSManagedObjectContext *) context
{
    
    Measurements *m = nil;
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurements"];
    request.predicate = [NSPredicate predicateWithFormat:@"measurementId == %@ AND type= %@" , measurementId, type] ;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"measurementId" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] >1)){
        // TODO handle error (Delete extra reports)
        NSLog(@"Error: more than one Measurement with id:%@ exists in modal.", measurementId);
        if(![m.name isEqualToString: name])
            m.name=name;
        
        if(![m.type isEqualToString: type]){
            m.type=type;
        }
        if(![m.mcc isEqualToString: mcc])
            m.mcc=mcc;
        if(![m.viewOrder isEqualToNumber: viewOrder])
            m.viewOrder=viewOrder;
       // [context save: nil];
    }else if ([matches count]==0){
        
        m=[NSEntityDescription insertNewObjectForEntityForName:@"Measurements" inManagedObjectContext:context];
        m.measurementId = measurementId;
        m.name=name;
        m.type=type;
        m.mcc=mcc;
        m.viewOrder=viewOrder;
      //  [context save: nil];
    }else{
        m = [matches lastObject];
        if(![m.name isEqualToString: name])
            m.name=name;
        
       // if(![m.type isEqualToString: type]){
        //   m.type=type;
       // }
        if(![m.mcc isEqualToString: mcc])
            m.mcc=mcc;
        if(![m.viewOrder isEqualToNumber: viewOrder])
            m.viewOrder=viewOrder;
        //[context save: nil];
    }
    
   
    
    return m;
    
    
}
@end
