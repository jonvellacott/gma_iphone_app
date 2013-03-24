//
//  Nodes+gma.h
//  GMA1-0
//
//  Created by Jon Vellacott on 05/10/2012.
//
//

#import "Nodes.h"

@interface Nodes (gma)
+  (Nodes *)nodeFromGmaInfoStaffReport:(NSArray *)gmaInfo
                 inManagedObjectConext:(NSManagedObjectContext *)context
                        asDirectorNode:(BOOL)directorNode
                             fromRenId:(NSNumber *) renId;
+  (void)addMeasurements:(NSDictionary *)measurements
                  toNode:(NSNumber *)nodeId
   inManagedObjectConext:(NSManagedObjectContext *)context
          asDirectorNode:(BOOL)directorNode;


+  (void)addStaffReport: (NSNumber *)origStaffReportId
                 toNode: (NSNumber *)nodeId
               withName: (NSString *) nodeName
  inManagedObjectConext:(NSManagedObjectContext *)context;
@end
