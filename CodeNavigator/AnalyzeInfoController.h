//
//  AnalyzeInfoController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnalyzeInfoController : UIViewController
{
    BOOL analyzeFinished;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *infoLabel;

-(void) finishAnalyze;

@end
