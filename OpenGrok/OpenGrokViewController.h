//
//  OpenGrokViewController.h
//  CodeNavigator
//
//  Created by guangzhen on 2017/6/19.
//
//

#import <UIKit/UIKit.h>

@interface OpenGrokViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString* titleBarStr;

@end
