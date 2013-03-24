//
//  TextQuestionCell.m
//  GMA1-0
//
//  Created by Jon Vellacott on 11/12/2012.
//
//

#import "TextQuestionCell.h"

@implementation TextQuestionCell
@synthesize title;

@synthesize answer;

@synthesize tvc;
@synthesize tvcd;

@synthesize staffReportId ;
@synthesize measurementId;
@synthesize indexPath;
@synthesize nodeId;
@synthesize isDirector = _isDirector;
@synthesize hasChanged;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        hasChanged= NO;
    }
    return self;
}

-(void) setIsDirector:(BOOL)isDirector
{
    _isDirector = isDirector;
    if(isDirector){
        
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
       
    }
    else{
        self.accessoryType = UITableViewCellAccessoryNone ;
    }
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void) textViewDidEndEditing:(UITextView *)textView{
    if(hasChanged)
    {
        hasChanged = NO;
        //NSLog(@"Text changed");
        if(tvc)
            [tvc saveAnswerForMeasurementId:measurementId measurementType:@"Text" inStaffReport:staffReportId withValue:answer.text oldValue:nil];
        else
            [tvcd saveAnswerForMeasurementId:measurementId measurementType:@"Text" inStaffReport:staffReportId atNodeId: nodeId  withValue:answer.text oldValue:nil];
    }
}
-(void) textViewDidChange:(UITextView *)textView
{	
    hasChanged=YES;
    
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;
    
}


@end
