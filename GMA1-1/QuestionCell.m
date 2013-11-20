//
//  QuestionCell.m
//  GMA1-0
//
//  Created by Jon Chontelle Vellacott on 31/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuestionCell.h"




@implementation QuestionCell
@synthesize title;
@synthesize subTitle;
@synthesize answer;
@synthesize addButton;
@synthesize tvc;
@synthesize tvcd;
@synthesize staffReportId ;
@synthesize measurementId;
@synthesize isDirector = _isDirector;
@synthesize nodeId;
@synthesize measurementType;
@synthesize hasChanged;
@synthesize oldValue;



-(void) setIsDirector:(BOOL)isDirector
{
    _isDirector = isDirector;
    if(isDirector){
       
        self.accessoryType = UITableViewCellAccessoryDetailButton ;
        [self.addButton setHidden:YES];
    }
    else{
        self.accessoryType = UITableViewCellAccessoryNone ;
       [self.addButton setHidden:NO];
    }
    [answer setDelegate:self];
   
}



- (IBAction)plusButtonPressed:(id)sender
{

   self.oldValue= answer.text.integerValue;
    NSInteger value = [answer.text intValue ] +1;
    
    answer.text = [NSString stringWithFormat:@"%d",value];
    dispatch_queue_t fetchQ =dispatch_queue_create("UpdateNumber", nil);
    dispatch_async(fetchQ, ^{

        if(tvc)
            [tvc saveAnswerForMeasurementId:measurementId measurementType: measurementType inStaffReport:staffReportId withValue:answer.text  oldValue:[NSString stringWithFormat:@"%d",self.oldValue] ];
        else if(tvcd)
        {
            [tvcd saveAnswerForMeasurementId:measurementId  measurementType: measurementType  inStaffReport:staffReportId atNodeId: self.nodeId withValue:answer.text  oldValue:[NSString stringWithFormat:@"%d",self.oldValue] ];
        }
    });
}

/*- (IBAction)editingDidBegin:(id)sender {
    
    self.oldValue= answer.text.integerValue;
                                              
    
}*/

/*- (IBAction)textDidChange:(id)sender {
    
    hasChanged=YES;

}*/

- (void)asnwerChanged:(UITextField *)sender
{
    //if(hasChanged)
    //{
        //hasChanged=NO;
       // if(answer.text.length==0)
        //    answer.text = @"0";
        dispatch_queue_t fetchQ =dispatch_queue_create("UpdateNumber", nil);
        dispatch_async(fetchQ, ^{
            if(tvc)
                [tvc saveAnswerForMeasurementId:measurementId  measurementType: measurementType  inStaffReport:staffReportId withValue:answer.text oldValue:[NSString stringWithFormat:@"%d",self.oldValue]];
            else if(tvcd)
            {
                [tvcd saveAnswerForMeasurementId:measurementId  measurementType: measurementType  inStaffReport:staffReportId atNodeId: nodeId  withValue:answer.text  oldValue:[NSString stringWithFormat:@"%d",self.oldValue] ];
                
            }
        });
    //}
}


- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        //UIImage *btnAdd = [[UIImage alloc]  initWithContentsOfFile:@"32.png"];
     self.accessoryType = UITableViewCellAccessoryNone ;
      //  hasChanged=NO;
       
        
        
    }
    return self;
}








+ (void)resizeFontForLabel:(UILabel*)aLabel maxSize:(int)maxSize minSize:(int)minSize labelWidth: (int)labelWidth labelHeight: (int)labelHeight{
    // use font from provided label so we don't lose color, style, etc
   
    
    UIFont *font = aLabel.font;
  
    
    // start with maxSize and keep reducing until it doesn't clip
    for(int i = maxSize; i >= minSize; i--) {
        font = [font fontWithSize:i];
        CGSize constraintSize = CGSizeMake(labelWidth, MAXFLOAT);
        
        // This step checks how tall the label would be with the desired font.
       CGSize labelSize = [aLabel.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        
        
        //CGRect labelSize = [aLabel.text boundingRectWithSize:CGSizeMake(300.f, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading) attributes: nil context:nil];
        
        if(labelSize.height <= labelHeight)
            break;
    }
    // Set the UILabel's font to the newly adjusted font.
    aLabel.font = font;
}


-(NSInteger)numberOfComponentsInPickerField:(NWPickerField *)pickerField{
	return 1;
    
}
- (NSInteger)pickerField:(NWPickerField *)pickerField numberOfRowsInComponent:(NSInteger)component{
	return (self.answer.text.intValue + 1000)  ;
}
-(NSString *)pickerField:(NWPickerField *)pickerField titleForRow:(NSInteger)row forComponent:(NSInteger)component{
     return [NSNumber numberWithInteger:row].stringValue;
   
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(tvc){
        [self.tvc dismissPickerView];
        [self.tvc.view endEditing:YES];
        
    }
    else{
       [self.tvcd dismissPickerView];
         [self.tvcd.view endEditing:YES];
    }
        
    



    
}


@end
