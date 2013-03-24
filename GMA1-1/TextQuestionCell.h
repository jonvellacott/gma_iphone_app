//
//  TextQuestionCell.h
//  GMA1-0
//
//  Created by Jon Vellacott on 11/12/2012.
//
//

#import <UIKit/UIKit.h>
#import "QuestionTVC.h"
#import "QuestionDetailTVC.h"
@interface TextQuestionCell : UITableViewCell<UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *title;

@property (nonatomic, weak) IBOutlet UITextView *answer;

@property (nonatomic, weak) QuestionTVC *tvc;
@property (nonatomic, strong) NSNumber *staffReportId;
@property (nonatomic, strong) NSNumber *measurementId;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) QuestionDetailTVC *tvcd;
@property (nonatomic, strong) NSNumber *nodeId;
@property (nonatomic, assign) BOOL isDirector;
@property (nonatomic, assign) BOOL hasChanged;




@end
