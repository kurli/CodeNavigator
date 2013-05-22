//
//  HelpViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 7/31/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Twitter/Twitter.h>

#ifdef LITE_VERSION
#import "GAITrackedViewController.h"
#endif

#ifdef LITE_VERSION
@interface HelpViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>
#else
@interface HelpViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>
#endif
{
    int alertType;
}
- (IBAction)doneButtonClicked:(id)sender;

@end
