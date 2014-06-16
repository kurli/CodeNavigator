//
//  CommentViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 5/8/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class CommentWrapper;
@interface CommentViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, unsafe_unretained) NSInteger line;
@property (nonatomic, strong) NSString* fileName;
@property (nonatomic, strong) NSString* upperSource;
@property (nonatomic, strong) NSString* downSource;
@property (nonatomic, strong) CommentWrapper* commentWrapper;

@property (unsafe_unretained, nonatomic) IBOutlet UITextView *upperTextView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *commentTextView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *downTextView;

- (IBAction)closeClicked:(id)sender;

- (IBAction)saveButtonClicked:(id)sender;

- (IBAction)sendButtonClicked:(id)sender;

- (void) initWithFileName:(NSString *)_fileName;

-(void) groupSelected:(NSString*)group;
@end
