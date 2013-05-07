//
//  QuestionCell.h
//  GMA1-0
//
//  Created by Jon Chontelle Vellacott on 31/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionTVC.h"
#import "QuestionDetailTVC.h"
#import "NWPickerField.h"

@interface QuestionCell : UITableViewCell <NWPickerFieldDelegate>{
   //    NWPickerField *answer;
   
}

@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *subTitle;
@property (nonatomic, strong) IBOutlet NWPickerField *answer;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *lblCalc;
@property (weak, nonatomic) IBOutlet UILabel *lblAnswer;

@property (nonatomic, weak) QuestionTVC *tvc;

@property (weak, nonatomic) IBOutlet UILabel *totalAnswer;

@property (nonatomic, weak) QuestionDetailTVC *tvcd;

@property (nonatomic, strong) NSNumber *nodeId;
@property (nonatomic, strong) NSNumber *staffReportId;
@property (nonatomic, strong) NSNumber *measurementId;
@property (nonatomic, assign) NSInteger oldValue;
@property (nonatomic, strong) NSString *measurementType;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL isDirector;
@property (nonatomic, assign) BOOL hasChanged;
- (IBAction)plusButtonPressed:(id)sender ;

- (IBAction)editingDidBegin:(id)sender;

- (IBAction)textDidChange:(id)sender;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier;
- (IBAction)asnwerChanged:(UITextField *)sender;
+ (void)resizeFontForLabel:(UILabel*)aLabel maxSize:(int)maxSize minSize:(int)minSize labelWidth: (int)labelWidth labelHeight: (int)labelHeight;
@end
