//
//  GitBranchController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/12/14.
//
//

#import <Foundation/Foundation.h>
//#import "MBProgressHUD.h"

@class GTRepository;
@class GTBranch;

typedef void (^CheckoutFinishBlock)();

@interface GitBranchController : NSObject

@property (nonatomic, strong) GTRepository* repo;
@property (nonatomic, strong) NSString* projectPath;
@property (nonatomic, strong) NSArray* branches;
@property (nonatomic, strong) GTBranch* currentBranch;
//@property (nonatomic, strong) UIView* parentView;
//@property (nonatomic, strong) MBProgressHUD* hud;
@property (nonatomic, strong) CheckoutFinishBlock checkoutFinishBlock;
@property (nonatomic, strong) UIAlertView* alertView;

-(BOOL) initWithRepo:(GTRepository*)_repo;
-(BOOL) initWithProjectPath:(NSString*)projPath;
-(void) checkoutToBranch:(GTBranch*)branch andFinishBlock:(CheckoutFinishBlock)block;
-(void) update;
-(void) updateRepo:(UITextView*) logView andUsername:(NSString*)username andPassword:(NSString*)password;
-(GTBranch*) getCurrentTrackingBranch;

@end
