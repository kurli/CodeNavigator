//
//  VersionViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/17/14.
//
//

#import <UIKit/UIKit.h>

@interface VersionViewController : UIViewController

-(void) checkVersion;

@property (weak, nonatomic) IBOutlet UITextView *versionDetailView;
@end
