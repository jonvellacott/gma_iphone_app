//
//  Users+Create.m
//  GMA1-1
//
//  Created by Jon Vellacott on 31/01/2013.
//  Copyright (c) 2013 Jon Vellacott. All rights reserved.
//

#import "Users+Create.h"

@implementation Users (Create)
+(Users *) userWithRenId: (NSNumber *)renId
                    Name: (NSString *)name
  inManagedObjectContext: (NSManagedObjectContext *) context
{
    
    Users *u = nil;
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    request.predicate = [NSPredicate predicateWithFormat:@"renId == %@", renId] ;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"renId" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] >1)){
        // TODO handle error (Delete extra reports)
        NSLog(@"Error: more than one User with renId:%@ exists in modal.", renId);
        if(![u.name isEqualToString: name])
            u.name=name;
  
        //[context save: nil];
    }else if ([matches count]==0){
        
        u=[NSEntityDescription insertNewObjectForEntityForName:@"Users" inManagedObjectContext:context];
        u.renId = renId;
        u.name=name;
              
      //  [context save: nil];
    }else{
        u = [matches lastObject];
        if(![u.name isEqualToString: name])
            u.name=name;
        
               
       // [context save: nil];
    }
    
       return u;
    
    
}
@end
