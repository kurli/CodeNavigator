//
//  GitDiffViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 4/2/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPPopoverController.h"

#define DIFF_HTML @"<html>\
<frameset cols=\"50%,50%\">\
<frame id=\"newFile\" src=\"%@\">\
<frame id=\"oldFile\" src=\"%@\">\
</frameset>\
</html>"

@interface GitDiffViewController : UIViewController
{
    int currentDisplayIndex;
    int colorStep;
}

@property (nonatomic, strong) NSMutableArray* diffFileArray;
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;
#ifdef IPHONE_VERSION
@property (nonatomic, strong) FPPopoverController* popOverController;
#else
@property (nonatomic, strong) UIPopoverController* popOverController;
#endif
@property (nonatomic, strong) NSMutableArray* diffAnalyzeArray;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

- (IBAction)backbuttonClicked:(id)sender;

- (IBAction)diffFileListClicked:(id)sender;

- (void) setCurrentDisplayIndex:(int)index;

- (int) getCurrentDisplayIndex;

- (IBAction)diffInfoClicked:(id)sender;

- (void) showDiffInfo:(int) index;

@end
