//
//  GotoLineViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@interface GotoLineViewController : UIViewController <UITextFieldDelegate>

@property (retain, nonatomic) DetailViewController* detailViewController;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textField;

- (IBAction)goButtonClicked:(id)sender;

@end
