//
//  GitBranchController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 3/12/14.
//
//

#import "GitBranchController.h"
#import "ObjectiveGit.h"
#import "Utils.h"

@implementation GitBranchController

@synthesize repo;
@synthesize projectPath;
@synthesize branches;
//@synthesize parentView;
//@synthesize hud;
//@synthesize checkoutFinishBlock;

-(BOOL) initWithRepo:(GTRepository *)_repo {
    NSError* error;
    self.repo = _repo;
    NSString* projPath = [[_repo gitDirectoryURL] path];
    projPath = [projPath stringByDeletingLastPathComponent];
    [self setProjectPath:projPath];
    self.branches = [_repo allBranchesWithError:&error];
    if (error != nil || [self.branches count] == 0) {
        return NO;
    }
    self.currentBranch = [_repo currentBranchWithError:&error];
    if (error != nil) {
        return NO;
    } else {
        return YES;
    }
}

-(BOOL) initWithProjectPath:(NSString *)projPath {
    if (projPath == nil || [projPath length] == 0) {
        return NO;
    }
    
    [self setProjectPath:projPath];
    NSString* gitFolder = [projPath stringByAppendingPathComponent:@".git"];
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:gitFolder];
    self.repo = [GTRepository repositoryWithURL:url error:&error];
    return [self initWithRepo:self.repo];
}

- (void)checkoutTask:(GTBranch*)branch {
    NSError* error;
    [repo checkoutReference:branch.reference strategy:GTCheckoutStrategyForce
                notifyFlags:GTCheckoutNotifyNone error:&error progressBlock:nil notifyBlock:nil];
    if (error == nil) {
        // If it's remote branch
        // Checkout to that ranch and create a new branch named xxx-working
        if (branch.branchType == GTBranchTypeRemote) {
            NSString* newName = [NSString stringWithFormat:@"%@-working", branch.shortName];
            GTBranch* cBranch = [repo currentBranchWithError:&error];
            GTBranch *newBranch = [repo createBranchNamed:newName fromOID:[[GTOID alloc] initWithSHA:cBranch.SHA] committer:nil message:nil error:&error];
            [repo checkoutReference:newBranch.reference strategy:GTCheckoutStrategyForce
                        notifyFlags:GTCheckoutNotifyNone error:&error progressBlock:nil notifyBlock:nil];
            self.currentBranch = [repo currentBranchWithError:&error];
        }
    }
    [self update];
    dispatch_async(dispatch_get_main_queue(), ^{
        // No need remove, has check the md5  :-)
//        [[Utils getInstance] removeDisplayFilesForProject:projectPath];
        [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
        // Re-analyze project
        [[Utils getInstance] analyzeProject:self.projectPath andForceCreate:YES];
        // Comments file 
        if (self.checkoutFinishBlock) {
            self.checkoutFinishBlock();
        }
    });
}

-(void) checkoutToBranch:(GTBranch*)branch andFinishBlock:(CheckoutFinishBlock)block{
//    if (parentView == nil) {
//        return;
//    }
    self.alertView = [[Utils getInstance] showActivityIndicator:@"Checking out..." andDelegate:nil];
    [self.alertView show];
//    hud = [[MBProgressHUD alloc] initWithView:parentView];
//    [parentView addSubview:hud];
//    hud.delegate = self;
//
    [self setCheckoutFinishBlock:block];
//    [hud showWhileExecuting:@selector(checkoutTask:) onTarget:self withObject:branch animated:YES];
    [NSThread detachNewThreadSelector:@selector(checkoutTask:) toTarget:self withObject:branch];
}

-(void) update {
    NSError* error;
    self.branches = [self.repo allBranchesWithError:&error];
    self.currentBranch = [self.repo currentBranchWithError:&error];
}

//- (void)hudWasHidden:(MBProgressHUD *)_hud {
//    [_hud removeFromSuperview];
//	self.hud = nil;
//}

@end
