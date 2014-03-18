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

@interface HelpViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>
{
    int alertType;
}
- (IBAction)doneButtonClicked:(id)sender;

@end
