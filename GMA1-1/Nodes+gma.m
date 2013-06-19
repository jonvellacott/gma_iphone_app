//Nodes+gma.m  GMA1-0
// Created by Jon Vellacott on 05/10/2012.
//
//

#import "Nodes+gma.h"
#import "Nodes.h"
#import "StaffReports+Create.h"
#import "Measurements+Create.h"
#import "Users+Create.h"
@implementation Nodes (gma)



+  (Nodes *)nodeFromGmaInfoStaffReport:(NSArray *)gmaInfo
                 inManagedObjectConext:(NSManagedObjectContext *)context
                        asDirectorNode:(BOOL)directorNode
                             fromRenId:(NSNumber *) renId


{
    
    
    
    
    
    
    
    Nodes *node =  nil ;
    if([gmaInfo count] == 0)
		return node;
    
    NSString *nodeId = [(NSDictionary *)[[gmaInfo objectAtIndex:0] objectForKey:@"node"] objectForKey:@"nodeId"];
    if(directorNode)
        nodeId= [NSString stringWithFormat:@"-%@",nodeId];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Nodes"];
    request.predicate = [NSPredicate predicateWithFormat:@"nodeId == %@", nodeId] ;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches|| ([matches count] >1)){
        //handle error (NEED TO DELETE ONE OR BOTH)
        NSLog(@"Error: more than one node with id:%@ exists in modal.", nodeId);
        node = [matches lastObject];
        node.name = [(NSDictionary *)[[gmaInfo objectAtIndex:0] objectForKey:@"node"] objectForKey:@"shortName"];
         node.directorNode =  [NSNumber numberWithBool:directorNode];
        
    
    }else if ([matches count]==0){
           node=[NSEntityDescription insertNewObjectForEntityForName:@"Nodes" inManagedObjectContext:context];
        node.nodeId = [NSNumber numberWithInt:[nodeId intValue]];
        node.name = [(NSDictionary *)[[gmaInfo objectAtIndex:0] objectForKey:@"node"] objectForKey:@"shortName"];
        node.directorNode =  [NSNumber numberWithBool:directorNode];
       
            
                        
        
    }else{
        node = [matches lastObject];
        node.name = [(NSDictionary *)[[gmaInfo objectAtIndex:0] objectForKey:@"node"] objectForKey:@"shortName"];
         node.directorNode =  [NSNumber numberWithBool:directorNode];
    
    }
  
    
    for(NSDictionary *report in gmaInfo){
        NSNumber *staffReportId = [NSNumber numberWithInt:[[report valueForKey:@"staffReportId"] intValue]];
        if(directorNode)
        {
            staffReportId =  [NSNumber numberWithInt:-[[report valueForKey:@"directorReportId"] intValue]];
            
        }
        else
        {
            staffReportId = [NSNumber numberWithInt:[[report valueForKey:@"staffReportId"] intValue]];
        }
        NSNumber *thisRenId = [report valueForKey:@"renId"];
        if(thisRenId.intValue == 0)
            thisRenId = renId;
        
        //get the User
        NSFetchRequest *requestUser = [NSFetchRequest fetchRequestWithEntityName:@"Users"];
        requestUser.predicate = [NSPredicate predicateWithFormat:@"renId == %@", thisRenId] ;
       
        
        NSArray *users = [context executeFetchRequest:requestUser error:&error];
        Users *user ;
        if(users.count ==0)
        {
            //create an unkown user
           user = [Users userWithRenId:thisRenId Name:@"Unknown" inManagedObjectContext:context ];
        }
        else
            user = [users objectAtIndex:0];
        
        NSString *type = @"Staff";
        if(directorNode)
        {
            type=@"Director";
        }
        
               [node addStaffReportsObject:
                [StaffReports
                 StaffReportWithStaffReportId:  staffReportId
                 startDate:[NSNumber numberWithInt:[[report valueForKey:@"startDate"] intValue]]
                 endDate:[NSNumber numberWithInt:[[report valueForKey:@"endDate"] intValue]]
                 submitted: [[report valueForKey:@"submitted"] boolValue]
                 user:user
                 type: type
                 node: node.nodeId
                 inManagedObjectContext:context]];
        
                
                
        }
    
   
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        NSError *err = nil;
//        
//        if(![context save:&err])
//        {
//            NSLog(@"Unresolved error %@, %@, %@", err, [err userInfo],[err localizedDescription]);
//            
//        }
//        
//        
//    });
  //  [context save:nil];
    
    return node;
    

}



+  (void)addMeasurements:(NSDictionary *)measurements
                     toNode:(NSNumber *)nodeId
      inManagedObjectConext:(NSManagedObjectContext *)context
 asDirectorNode:(BOOL)directorNode
{
    
    
    
    
    Nodes *node =  nil ;
    if(directorNode)
        nodeId = [NSNumber numberWithInt:-[nodeId intValue]];
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Nodes"];
    request.predicate = [NSPredicate predicateWithFormat:@"nodeId == %@", nodeId] ;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches|| ([matches count] >1)){
        //handle error (NEED TO DELETE ONE OR BOTH)
        NSLog(@"Error: more than one node with id:%@ exists in modal.", nodeId);
        node = [matches lastObject];
        
        
    }else if ([matches count]==0){
        node=[NSEntityDescription insertNewObjectForEntityForName:@"Nodes" inManagedObjectContext:context];
        node.nodeId = nodeId;
        node.directorNode=[NSNumber numberWithBool:directorNode];
        node.name = @"Unknown";
        
    }else{
        node = [matches lastObject];
        
    }
    
  
    int viewOrder=0;
    //Process Numeric Measurements
    NSArray *mNumeric = [measurements objectForKey:@"numericMeasurements"] ;
       if(mNumeric != (id)[NSNull null]){
       for(NSDictionary *mccs  in mNumeric)
       {
           for(NSString *mcc in mccs.allKeys)
           {
               for(NSDictionary *ms in [mccs objectForKey:mcc])
               {
               
                   //NSLog(@"%@: %@", [m   objectForKey: @"measurementName" ], [m objectForKey:  @"measurementId"]);
                   //Add Questions to node...
                   
                   [node addMeasurementsObject: [Measurements
                                                 MeasurementWithMeasurementId:[ms objectForKey:  @"measurementId"]
                                                 Name:[ms objectForKey:  @"measurementName"]
                                                 Type:@"Numeric" Mcc:mcc
                                                 ViewOrder:[NSNumber numberWithInt: viewOrder]
                                                 inManagedObjectContext:context]  ];
                   viewOrder+=1;
               
           }
           }
    
       }
       }
    
       //Process Text  Measurements
       NSArray *mText = [measurements objectForKey:@"textMeasurement		"] ;
       if(mText != (id)[NSNull null]){
    
               for(NSDictionary *m in mText)
               {
                   //NSLog(@"%@: %@", [m   objectForKey: @"measurementName" ], [m objectForKey:  @"measurementId"]);
                   //Add Questions to node...
    
                   [node addMeasurementsObject:
                    [Measurements MeasurementWithMeasurementId: [m objectForKey:  @"measurementId"]
                                                          Name:[m objectForKey:  @"measurementName"]
                                                          Type:@"Text"
                                                           Mcc: @"zzz"
                     ViewOrder:[NSNumber numberWithInt: viewOrder]
                                        inManagedObjectContext:context]  ];
                     viewOrder+=1;
               }
    
           }
    
       //Process Calculated Measurements
       NSArray *mCalc = [measurements objectForKey:@"calculatedMeasurements"] ;
       if(mCalc != (id)[NSNull null]){
           for(NSDictionary *mccs  in mCalc)
           {
               for(NSString *mcc in mccs.allKeys)
               {
                   for(NSDictionary *ms in [mccs objectForKey:mcc])
                   {
                       
                       //NSLog(@"%@: %@", [m   objectForKey: @"measurementName" ], [m objectForKey:  @"measurementId"]);
                       //Add Questions to node...
                       
                       [node addMeasurementsObject: [Measurements
                                                     MeasurementWithMeasurementId:[ms objectForKey:  @"measurementId"]
                                                     Name:[ms objectForKey:  @"measurementName"]
                                                     Type:@"Calculated" Mcc:mcc
                                                     ViewOrder:[NSNumber numberWithInt: viewOrder]
                                                     inManagedObjectContext:context]  ];
                       
                       viewOrder+=1;
                   }
               }
               
           }
       }
           
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        NSError *err = nil;
//        
//        if(![context save:&err])
//        {
//            NSLog(@"Unresolved error %@, %@, %@", err, [err userInfo],[err localizedDescription]);
//            
//        }
//        
//        
//    });
   // [context save:nil];

}

+  (void)addStaffReport: (NSNumber *)origStaffReportId
                 toNode: (NSNumber *)nodeId
               withName: (NSString *) nodeName
   inManagedObjectConext:(NSManagedObjectContext *)context
{
    
    //First Check the node exists and fetch it
    Nodes *node =  nil ;
   
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Nodes"];
    request.predicate = [NSPredicate predicateWithFormat:@"nodeId == %@", nodeId] ;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches|| ([matches count] >1)){
        //handle error (NEED TO DELETE ONE OR BOTH)
        NSLog(@"Error: more than one node with id:%@ exists in modal.", nodeId);
        node = [matches lastObject];
        node.name = nodeName;
    }else if ([matches count]==0){
        node=[NSEntityDescription insertNewObjectForEntityForName:@"Nodes" inManagedObjectContext:context];
        node.nodeId = nodeId;
        node.name = nodeName;
    }else{
        node = [matches lastObject];
        node.name = nodeName;
    }
   
    
    
    //Next check if the measurementId exists
  
    
    NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:@"StaffReports"];
    request2.predicate = [NSPredicate predicateWithFormat:@"staffReportId == %@  AND  type=='SubNode' AND node.nodeId==%@ ", origStaffReportId,  nodeId] ;
    NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"staffReportId" ascending:YES];
    request2.sortDescriptors = [NSArray arrayWithObject:sortDescriptor2];
   
    NSArray *matches2 = [context executeFetchRequest:request2 error:&error];
    if(matches2.count ==0)
    {
        NSFetchRequest *request3 = [NSFetchRequest fetchRequestWithEntityName:@"StaffReports"];
        request3.predicate = [NSPredicate predicateWithFormat:@"staffReportId == %@ AND type == 'Director'", origStaffReportId] ;
        NSSortDescriptor *sortDescriptor3 = [NSSortDescriptor sortDescriptorWithKey:@"staffReportId" ascending:YES];
        request3.sortDescriptors = [NSArray arrayWithObject:sortDescriptor3];
        NSArray *matches3 = [context executeFetchRequest:request3 error:&error];
        if(matches3.count>0)
        {
            StaffReports *oldreport = matches3.lastObject;
            StaffReports *newreport = [StaffReports StaffReportWithStaffReportId:oldreport.staffReportId startDate:oldreport.startDate endDate: oldreport.endDate submitted:YES user:oldreport.user type:@"SubNode"
                                                                            node: nodeId inManagedObjectContext:context];
            
            [node addStaffReportsObject:newreport ];
          
        }
            
    }
//    dispatch_sync(dispatch_get_main_queue() ,^{
//        NSError *err = nil;
//        
//        if(![context save:&err])
//        {
//            NSLog(@"Unresolved error %@, %@, %@", err, [err userInfo],[err localizedDescription]);
//            
//        }
//        
//        
//    });
    //[context save:nil];
}



@end