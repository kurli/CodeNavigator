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

- (void) checkoutDone{
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

- (void)checkoutTask:(GTBranch*)branch {
    NSError* error;
    if (branch == nil) {
        return;
    }
    if (branch.branchType == GTBranchTypeLocal) {
        [repo checkoutReference:branch.reference strategy:GTCheckoutStrategySafe
                    notifyFlags:GTCheckoutNotifyNone error:&error progressBlock:nil notifyBlock:nil];
        [self checkoutDone];
        return;
    }
    // Remote branch selected
    // Check whether previously checked out
    NSArray* localBranchs = [repo localBranchesWithError:&error];
    for (int i=0; i<[localBranchs count]; i++) {
        GTBranch* tmp = [localBranchs objectAtIndex:0];
        if ([tmp.shortName compare:branch.shortName] == NSOrderedSame) {
            [repo checkoutReference:tmp.reference strategy:GTCheckoutStrategySafe
                        notifyFlags:GTCheckoutNotifyNone error:&error progressBlock:nil notifyBlock:nil];
            [self checkoutDone];
            return;
        }
    }
    GTBranch *newBranch = [repo createBranchNamed:branch.shortName fromOID:[[GTOID alloc] initWithSHA:branch.SHA] committer:nil message:nil error:&error];
    [repo checkoutReference:newBranch.reference strategy:GTCheckoutStrategySafe
                notifyFlags:GTCheckoutNotifyNone error:&error progressBlock:nil notifyBlock:nil];

    [self checkoutDone];
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

-(GTBranch*) getCurrentTrackingBranch{
    NSError* error;
    BOOL success;
    GTBranch* trackingBranch = [self.currentBranch trackingBranchWithError:&error success:&success];
    if (trackingBranch == nil) {
        error = nil;
        NSArray* remoteBranches = [self.repo remoteBranchesWithError:&error];
        for (int i=0; i<[remoteBranches count]; i++) {
            GTBranch* branch = [remoteBranches objectAtIndex:i];
            if ([branch.shortName compare:self.currentBranch.shortName] == NSOrderedSame) {
                trackingBranch = branch;
                break;
            }
        }
        if (trackingBranch == nil) {
            return nil;
        }
    }
    return trackingBranch;
}

//- (void)hudWasHidden:(MBProgressHUD *)_hud {
//    [_hud removeFromSuperview];
//	self.hud = nil;
//}

typedef void (^GitUpdateProcessCB)(NSString* str);
typedef void (^GitUpdateUpdateCB)(NSString* str);
typedef int (^GitUpdateCredAcquireCB)(git_cred **out);

struct GTUpdatePayload {
	// credProvider must be first for compatibility with GTCredentialAcquireCallbackInfo
	__unsafe_unretained GitUpdateProcessCB processCB;
	__unsafe_unretained GitUpdateUpdateCB updateCB;
    __unsafe_unretained GitUpdateCredAcquireCB credAcquireCB;
};

static int progress_cb(const char *str, int len, void *data)
{
    if (data == NULL) {
        return 0;
    }
    struct GTUpdatePayload *payload = (struct GTUpdatePayload *)data;
	NSString *message = [[NSString alloc] initWithBytes:str length:len encoding:NSUTF8StringEncoding];
    NSString* _str = [NSString stringWithFormat:@"remote: %@", message];
    payload->processCB(_str);
	return 0;
}

/**
 * This function gets called for each remote-tracking branch that gets
 * updated. The message we output depends on whether it's a new one or
 * an update.
 */
static int update_cb(const char *refname, const git_oid *a, const git_oid *b, void *data)
{
	char a_str[GIT_OID_HEXSZ+1], b_str[GIT_OID_HEXSZ+1];
    if (data == NULL) {
        return 0;
    }
    struct GTUpdatePayload *payload = (struct GTUpdatePayload *)data;
    
	git_oid_fmt(b_str, b);
	b_str[GIT_OID_HEXSZ] = '\0';
    
    NSString* str;
	if (git_oid_iszero(a)) {
        str = [NSString stringWithFormat:@"[new]     %.20s %s\n", b_str, refname];
	} else {
		git_oid_fmt(a_str, a);
		a_str[GIT_OID_HEXSZ] = '\0';
        str = [NSString stringWithFormat:@"[updated] %.10s..%.10s %s\n", a_str, b_str, refname];
	}
    payload->updateCB(str);
	return 0;
}

#ifdef UNUSED
#elif defined(__GNUC__)
# define UNUSED(x) UNUSED_ ## x __attribute__((unused))
#elif defined(__LCLINT__)
# define UNUSED(x) /*@unused@*/ x
#else
# define UNUSED(x) x
#endif


static int cred_acquire_cb(git_cred **out,
                    const char * UNUSED(url),
                    const char * UNUSED(username_from_url),
                    unsigned int UNUSED(allowed_types),
                    void * (payload))
{
    if (payload == NULL) {
        return 0;
    }
    struct GTUpdatePayload *_payload = (struct GTUpdatePayload *)payload;
	return _payload->credAcquireCB(out);
}

-(void) appendLog:(UITextView*)logView andStr: (NSString*) str{
    dispatch_async(dispatch_get_main_queue(), ^{
        logView.text = [logView.text stringByAppendingString:str];
        NSRange range;
        range.location= [logView.text length] -6;
        range.length= 5;
        [logView scrollRangeToVisible:range];
    });
}

-(void) appendLog:(UITextView*)logView andStr: (NSString*) _str andReplace:(NSString*)replace{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray* array = [logView.text componentsSeparatedByString:@"\n"];
        NSArray* inArray = [_str componentsSeparatedByString:@"\n"];
        NSString* str = _str;
        if ([inArray count] > 1) {
            str = [NSString stringWithFormat:@"remote: %@\n", [inArray lastObject]];
        }
        
        NSMutableString* mulStr = [[NSMutableString alloc] init];
        BOOL appended = NO;
        for (int i=0; i<[array count]; i++) {
            if ([(NSString*)[array objectAtIndex:i] rangeOfString:replace].location != NSNotFound) {
                [mulStr appendString:str];
                appended = YES;
            } else {
                [mulStr appendFormat:@"%@\n", [array objectAtIndex:i]];
            }
        }
        if (appended == NO) {
            [mulStr appendFormat:@"%@\n", str];
        }
        logView.text = mulStr;
//        NSRange range;
//        range.location= [logView.text length] -6;
//        range.length= 5;
//        [logView scrollRangeToVisible:range];
    });
}

-(void) updateRepo:(UITextView*) logView andUsername:(NSString*)username andPassword:(NSString*)password {
    NSError *error = nil;
	GTConfiguration *configuration = [self.repo configurationWithError:&error];
    NSArray* remoteArray = configuration.remotes;
    if ([remoteArray count] == 0) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"There is no remote to fetch."];
        return;
    }
    GTRemote* _remote = remoteArray[0];
    GTBranch* trackingBranch = [self getCurrentTrackingBranch];
    if (trackingBranch == nil) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"There is no tracking branch. Please checkout to other branch"];
        return;
    }
    
    git_remote *remote = _remote.git_remote;
	const git_transfer_progress *stats;
	git_remote_callbacks callbacks = GIT_REMOTE_CALLBACKS_INIT;
    git_remote_check_cert(remote, 0);
    
    struct GTUpdatePayload payload;
    payload.credAcquireCB = ^(git_cred **_out){
        return git_cred_userpass_plaintext_new(_out, [username UTF8String], [password UTF8String]);
    };
    payload.processCB = ^(NSString* str){
        if ([str length] == 0) {
            return;
        }
        [self appendLog:logView andStr:str];
    };
    payload.updateCB = ^(NSString* str){
        if ([str length] == 0) {
            return;
        }
        [self appendLog:logView andStr:str];
    };

    callbacks.update_tips = &update_cb;
	callbacks.sideband_progress = &progress_cb;
	callbacks.credentials = &cred_acquire_cb;
    callbacks.payload = &payload;
	git_remote_set_callbacks(remote, &callbacks);
    
    stats = git_remote_stats(remote);
    
    // Connect to the remote end specifying that we want to fetch
	// information from it.
    BOOL networkError = NO;
    [self appendLog:logView andStr:@"Connecting...\n"];
    [self appendLog:logView andStr:_remote.URLString];
    [self appendLog:logView andStr:@"\n"];
	if (git_remote_connect(remote, GIT_DIRECTION_FETCH) < 0) {
		networkError = YES;
        [self appendLog:logView andStr:[NSString stringWithFormat:@"Can't connect to remote server:\n %@\n", _remote.URLString ]];
	}
    
	// Download the packfile and index it. This function updates the
	// amount of received data and the indexer stats which lets you
	// inform the user about progress.
    if (!networkError) {
        [self appendLog:logView andStr:@"Checking & Downloading...\n"];
        int ret = git_remote_download(remote);
        if (ret < 0) {
            [self appendLog:logView andStr:[NSString stringWithFormat:@"Internal error: %d\n", ret]];
        }
        git_remote_disconnect(remote);
        git_remote_update_tips(remote, NULL, NULL);
    }

    // Merge branch
    // Workaround: checkout new branch and
    trackingBranch = [trackingBranch reloadedBranchWithError:&error];
    NSArray* array = [trackingBranch uniqueCommitsRelativeToBranch:self.currentBranch error:&error];
    if ([array count] > 0) {
        [self appendLog:logView andStr:@"Merging...\n"];
        NSString* newBranchName = [trackingBranch.shortName stringByAppendingString:@"--kurli"];
        // Checkout to tracking brnch
        GTBranch *newBranch = [repo createBranchNamed:newBranchName fromOID:[[GTOID alloc] initWithSHA:trackingBranch.SHA] committer:nil message:nil error:&error];
        if (newBranch == nil) {
            BOOL success = NO;
            GTBranch* tmpBranch = [repo lookUpBranchWithName:newBranchName type:GTBranchTypeLocal success:&success error:&error];
            [tmpBranch deleteWithError:&error];
            newBranch = [repo createBranchNamed:newBranchName fromOID:[[GTOID alloc] initWithSHA:trackingBranch.SHA] committer:nil message:nil error:&error];
            if (newBranch == nil) {
                [self appendLog:logView andStr:@"Merge failed.\nerr code:1\n"];
                return;
            }
        }
        [repo checkoutReference:newBranch.reference strategy:GTCheckoutStrategySafe
                notifyFlags:GTCheckoutNotifyNone error:&error progressBlock:nil notifyBlock:nil];
        // Remove need updated branch
        [self.currentBranch deleteWithError:&error];
        // Checkout to new branch
        newBranchName = [newBranchName stringByReplacingOccurrencesOfString:@"--kurli" withString:@""];
        self.currentBranch = [repo createBranchNamed:newBranchName fromOID:[[GTOID alloc] initWithSHA:trackingBranch.SHA] committer:nil message:nil error:&error];
        if (self.currentBranch == nil) {
            [self appendLog:logView andStr:@"Merge failed.\nerr code:2\n"];
            return;
        }
        [repo checkoutReference:self.currentBranch.reference strategy:GTCheckoutStrategySafe
                notifyFlags:GTCheckoutNotifyNone error:&error progressBlock:nil notifyBlock:nil];
        // Delete tmp branch
        [newBranch deleteWithError:&error];
        [self appendLog:logView andStr:@"Done\n"];
    } else {
        if (!networkError) {
            [self appendLog:logView andStr:@"Already up to date.\n"];
        }
    }
}

@end
