//
//  alertViewController.m
//  GMA1-0
//
//  Created by Jon Vellacott on 28/01/2013.
//
//

#import "alertViewController.h"

@interface alertViewController ()

@end

@implementation alertViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
        UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.alertBar addGestureRecognizer:singleFingerTap];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    if([self.alertBar.backgroundColor isEqual:[UIColor redColor]])
    {
          if ( [delegate respondsToSelector:@selector(doReconnect)])
          {
                [delegate doReconnect];
          }
    }

            
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setAlertBar:nil];
    [self setAlertText:nil];
    [self setSpinner:nil];
    [super viewDidUnload];
}

- (void) showMessage: (NSString *) message withBackgroundColor: (UIColor *) color withSpinner: (BOOL) showSpinner
{
     dispatch_async(dispatch_get_main_queue(), ^{
          [self.alertBar setHidden:NO];
    
         
    self.alertText.Text = message;
    [self.alertBar setBackgroundColor:color];
    if(showSpinner)
    {
        [self.spinner startAnimating];
    }
    else{
        [self.spinner stopAnimating];
    }
     });
                    
    
}	

-(void) hideAlertBar
{
    
     dispatch_async(dispatch_get_main_queue(), ^{
         [self.alertBar  setHidden:YES ];
   
   // [self.view setNeedsLayout];
    
     });
    
}
@end
