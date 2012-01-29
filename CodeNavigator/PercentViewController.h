//
//  PercentViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 1/29/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface PercentViewController : UIViewController
{
    int bodyHeight;
}

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *percentLable;

@property (unsafe_unretained, nonatomic) IBOutlet UISlider *percentProgressBar;

@property (assign, nonatomic) DetailViewController* detailViewController;

- (IBAction)sliderChanged:(id)sender;

@end
