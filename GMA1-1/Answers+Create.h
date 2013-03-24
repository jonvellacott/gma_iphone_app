//
//  Answers+Create.h
//  GMA1-0
//
//  Created by Jon Vellacott on 07/12/2012.
//
//

#import "Answers.h"
#import "StaffReports.h"
#import "Measurements.h"

@interface Answers (Create)
+(Answers *) AnswerForMeasurementId: (NSNumber *) measurementId
                    MeasurementType: (NSString *) measurementType
                      InStaffReport: (NSNumber *) staffReportId
                          WithValue:  (NSString *)value
                             InNode: (NSNumber *) node
                               type: (NSString *)type
             inManagedObjectContext: (NSManagedObjectContext *) context;


@end
