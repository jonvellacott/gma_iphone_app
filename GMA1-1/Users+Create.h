//
//  Users+Create.h
//  GMA1-1
//
//  Created by Jon Vellacott on 31/01/2013.
//  Copyright (c) 2013 Jon Vellacott. All rights reserved.
//

#import "Users.h"

@interface Users (Create)
+(Users *) userWithRenId: (NSNumber *)renId
                    Name: (NSString *)name
  inManagedObjectContext: (NSManagedObjectContext *) context;

@end
