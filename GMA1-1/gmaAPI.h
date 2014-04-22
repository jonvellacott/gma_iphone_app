//
//  gmaAPI.h
//  GMA1-0
//
//  Created by Jon Vellacott on 10/12/2012.
//
//

#import <Foundation/Foundation.h>

@interface gmaAPI : NSObject<NSURLConnectionDelegate>


#define GMA_SUCCESS @"SUCCESS"
#define GMA_NO_CONNECT @"NO_CONNECT"
#define GMA_NO_AUTH @"NO_AUTH"
#define GMA_FAIL @"FAIL"
#define GMA_OFFLINEMODE @"OFFLINE_MODE"
#define GMA_NOCONNECT_Message @"Unable to to connect to GMA server. Would you like to try again, or work offline? If you work offline your your changes will be stored locally and sumbitted the next time you connect."
#define KEY_NOCONNECT_Message @"Unable to connect to TheKey. Would you like to try again, or work offline? If you work offline your your changes will be stored locally and sumbitted the next time you connect."
#define KEY_INVALID_LOGIN_Message @"Invalid username or password. Would you like to try again, or work offline? If you work offline your your changes will be stored locally and sumbitted the next time you connect."


#define GMA_TRY_AGAIN @"Try Again"
#define GMA_OFFLINE @"Work Offline"
#define GMA_NOINTERNET_Message @"Unable to to connect to GMA server, as you do not currently have an internet connection. You can continue to work offline and your changes will be stored locally. Next time you connect, you will be asked if you would like to commit your changes to the GMA Server."
#define GMA_LOGIN_EXPIRED @"You session has expired and you need to login again."
#define GMA_OFFLINE_MODE @"OFFLINE: Click here to reconnect"
#define GMA_CACHEITEMS @"You have unsaved measurements (which have not yet been saved to the GMA Server. Would you like to upload those measurements"
#define GMA_REFRESH_CACHE @"Unsaved Changes"
#define GMA_REFRESH_CACHE_Message @"You have unsaved measurements on this page - which will be overwritten by the values on the GMA server. Would you like to save your changes first?"

#define activityColor  [UIColor colorWithRed:0 green:0 blue:200 alpha:0.5]
#define offlineColor [UIColor redColor]

@property (nonatomic, strong) NSString *gmaURL;
@property (nonatomic, strong) NSString *gmaRootURL;
@property (nonatomic, strong) NSString *targetService;
@property (nonatomic, strong) NSString *KeyGUID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *csrf_token;
@property (nonatomic, assign) int authMode;
@property (nonatomic, assign) int counter;
- (id)initWithBaseURL: (NSString *)URL;

- (void )AuthenticateUser: (NSString *)Username WithPassword: (NSString *)Password ;
-(NSArray *)getAllUserNodes ;
-(NSArray *)getAllDirectorNodes;
-(NSDictionary *)getMeasurementsForNode: (NSNumber *) nodeId;
-(NSDictionary *)getStaffReportAnswers: (NSNumber *) staffReportId ;
-(NSDictionary *)getDirectorReportAnswers: (NSNumber *) directorReportId;
-(NSString *) saveAnswerForMeasurementId:(NSNumber *)measurementId inStaffReport:(NSNumber *)  staffReportId withValue:(NSString *)value ofType:(NSString *)type;
- (NSString *) submitStaffReport:(NSNumber *) staffReportId;
- (NSString *) saveAnswerForMeasurementId:(NSNumber *)measurementId inDirectorReport:(NSNumber *)  directorReportId withValue:(NSString *)value ofType:(NSString *)type;
- (NSString *) submitDirectorReport:(NSNumber *) directorReportId;
-(NSArray *)getReportsForDirectorNode: (NSNumber *)nodeId atDate: (NSNumber *)date;
-(NSArray *)getUsers: (BOOL) active;
- (void) targetServerForGmaServer: (NSString *)gmaServer ;



@end
;