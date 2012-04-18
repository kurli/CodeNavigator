//
//  VersionControlController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 4/18/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MasterViewController;

@interface VersionControlController : UIViewController

@property (nonatomic, unsafe_unretained) MasterViewController* masterViewController;

- (IBAction)dropboxClicked:(id)sender;

- (IBAction)gitClicked:(id)sender;

@end
