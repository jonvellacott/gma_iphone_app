//
//  Measurements+Create.h
//  GMA1-0
//
//  Created by Jon Vellacott on 07/12/2012.
//
//

#import "Measurements.h"

@interface Measurements (Create)
+(Measurements *) MeasurementWithMeasurementId: (NSNumber *)measurementId
                                          Name: (NSString *)name
                                          Type: (NSString *)type
                                           Mcc: (NSString *)mcc
                        inManagedObjectContext: (NSManagedObjectContext *) context;

@end
