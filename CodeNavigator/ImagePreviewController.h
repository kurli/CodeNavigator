//
//  ImagePreviewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 2/26/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VirtualizeViewController;

@interface ImagePreviewController : UIViewController

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;

@property (unsafe_unretained, nonatomic) VirtualizeViewController* viewController;

- (IBAction)closeButtonClicked:(id)sender;

- (IBAction)exportButtonClicked:(id)sender;

@end
