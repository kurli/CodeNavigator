//
//  GitDiffViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 4/2/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

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
@property (nonatomic, strong) UIPopoverController* popOverController;
@property (nonatomic, strong) NSMutableArray* diffAnalyzeArray;

- (IBAction)backbuttonClicked:(id)sender;

- (IBAction)diffFileListClicked:(id)sender;

- (void) setCurrentDisplayIndex:(int)index;

- (int) getCurrentDisplayIndex;

- (IBAction)diffInfoClicked:(id)sender;

- (void) showDiffInfo:(int) index;

@end
