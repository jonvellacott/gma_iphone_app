//
//  Measurements.h
//  GMA1-1
//
//  Created by Jon Vellacott on 14/05/2013.
//  Copyright (c) 2013 Jon Vellacott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Answers, Nodes;

@interface Measurements : NSManagedObject

@property (nonatomic, retain) NSString * mcc;
@property (nonatomic, retain) NSNumber * measurementId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * viewOrder;
@property (nonatomic, retain) NSSet *answers;
@property (nonatomic, retain) Nodes *node;
@end

@interface Measurements (CoreDataGeneratedAccessors)

- (void)addAnswersObject:(Answers *)value;
- (void)removeAnswersObject:(Answers *)value;
- (void)addAnswers:(NSSet *)values;
- (void)removeAnswers:(NSSet *)values;

@end
