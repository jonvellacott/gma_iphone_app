//
//  alertViewController.h
//  GMA1-0
//
//  Created by Jon Vellacott on 28/01/2013.
//
//

#import <UIKit/UIKit.h>
@protocol alertViewDelegate

@optional

- (void)doReconnect;
@end
@interface alertViewController : UIViewController{
    
   
}


@property (weak, nonatomic) IBOutlet UIView *alertBar;
@property (weak, nonatomic) IBOutlet UILabel *alertText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;


@property (nonatomic, assign) id  delegate;


-(void) hideAlertBar;
- (void) showMessage: (NSString *) message withBackgroundColor: (UIColor *) color withSpinner: (BOOL) showSpinner;
@end
