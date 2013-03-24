//
//  StaffReports+Create.h
//  GMA1-0
//
//  Created by Jon Vellacott on 05/10/2012.
//
//

#import "StaffReports.h"
#import "Nodes.h"
#import "Users.h"

@interface StaffReports (Create)
+(StaffReports *) StaffReportWithStaffReportId: (NSNumber *)staffReportId
                                     startDate: (NSNumber *)startDate
                                       endDate: (NSNumber *)endDate
                                     submitted: (BOOL)submitted
                                          user:  (Users *)user
                                          type: (NSString *)type
                                          node: (NSNumber *)nodeId
                        inManagedObjectContext: (NSManagedObjectContext *) context;

+(StaffReports *) getLatestStaffReportForNodeId: (NSNumber *)nodeId
                         inManagedObjectContext: (NSManagedObjectContext *) context;
+(NSDictionary *) getIntervalForStaffReport: (NSNumber *)sr inManagedObjectConext:(NSManagedObjectContext *)context ;
@end
