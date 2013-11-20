//
//  Model.h
//  GMA1-0
//
//  Created by Jon Vellacott on 10/12/2012.
//
//

#import <Foundation/Foundation.h>
#import "gmaAPI.h"
#import "CoreDataTableViewController.h"
#import "Nodes+gma.h"
#import "StaffReports+Create.h"
#import "Answers+Create.h"
#import "alertViewController.h"
#import "Users+Create.h"
#import "Measurements+Create.h"




@interface Model : NSObject

@property (nonatomic, strong) UIManagedDocument *allNodesForUser;
@property (nonatomic, strong) gmaAPI *api;
@property (nonatomic) BOOL loggedIn;
@property (nonatomic, strong) alertViewController *alertBarController;
@property (nonatomic, strong) NSNumber *myRenId;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *myusername;
@property (nonatomic, strong) NSString *mypassword;
@property (nonatomic, strong) dispatch_queue_t gma_Api;
@property (nonatomic, strong) dispatch_queue_t gma_Moc;
@property (nonatomic) BOOL offlineMode;
@property (nonatomic) BOOL forceSave ;
@property (nonatomic, assign) BOOL filenameChanged;





-(id) initWithCompletionHander: (void (^)(BOOL  success))block ;
-(void) addItemToCacheStackForMeasurementId:(NSNumber *)measurementId measurementType: (NSString *) measurementType inStaffReport:(NSNumber *)  staffReportId withValue:(NSString *)value oldValue:(NSString *) oldValue;
-(void) clearCacheStackWithCompletionHandler:(void (^)(NSString *))block;
-(void) authenticateUser: (NSString *)Username WithPassword:(NSString *)Password LoginSuccessHandler:(void (^)(BOOL))loginBlock CompletionHander: (void (^)(NSDictionary *status))block;
-(void) fetchAllUserNodesWithCompletionHandler: (void (^)())block;

-(void) fetchStaffReport:(NSNumber *) sr forNode: (NSNumber *) nodeId atDate: (NSNumber *)date completionHandler:(void (^)())block;
- (void) saveModelAnswerForMeasurementId:(NSNumber *)measurementId measurementType: (NSString *) measurementType  inStaffReport:(NSNumber *)  staffReportId  atNodeId: (NSNumber *) nodeId withValue:(NSString *)value  oldValue: (NSString *) oldValue completionHandler:(void (^)(NSString *))block;
- (void) submitStaffReportId: (NSNumber *)  staffReportId;
-(BOOL) isCacheEmpty ;
-(void) emptyCacheStack;
-(void) setUsername: (NSString *)username;
-(void) setPassword: (NSString *)password;
-(NSString *) getUsername;
-(NSString *) getPassword;
-(void) saveModel;
- (void) receiveGmaLoginComplete:(NSNotification *) notification;

- (void) removeDatabase;
@end

