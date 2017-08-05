//
//  OpenGrokViewController.m
//  CodeNavigator
//
//  Created by guangzhen on 2017/6/19.
//
//

#import "OpenGrokViewController.h"
#import "Utils.h"
#import "MasterViewController.h"

@interface OpenGrokViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBar;

@end

@implementation OpenGrokViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* lastUrl = [Utils getInstance].lastUrl;
    if (self.url != nil) {
        lastUrl = self.url;
    }
    if ([lastUrl length] == 0) {
        lastUrl = self.url;
    }
    if ([lastUrl length] == 0) {
        lastUrl = @"http://opengrok.club";
    }

    NSURL *url = [NSURL URLWithString:lastUrl];
    [self loadUrl:url];
    self.titleBar.title = self.titleBarStr;
}

-(void) loadUrl:(NSURL*) url {
    self.webview.delegate = self;
    NSString *oldAgent = [self.webview stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *newAgent = [oldAgent stringByAppendingString:@" CodeNavigator6"];
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    [self.webview loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)doneButtonClicked:(id)sender {
    NSString* currentUrl = [self.webview stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    [Utils getInstance].lastUrl = currentUrl;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)openWithSafari:(id)sender {
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.webview.request.URL.absoluteString]];
    NSURL *url = [NSURL URLWithString:@"http://opengrok.club"];
    if (self.url != nil) {
        url =  [NSURL URLWithString:self.url];
    }
    [self loadUrl:url];
}

- (IBAction)shareButtonClicked:(id)sender {
}

- (void)backButtonClicked {
    [self.webview goBack];
}

- (void)forwardButtonClicked {
    [self.webview goForward];
}

- (IBAction)backForwardClicked:(id)sender {
    UISegmentedControl* controller = sender;
    NSInteger index = [controller selectedSegmentIndex];
    if (index == 0)
        [self backButtonClicked];
    else
        [self forwardButtonClicked];
}

#pragma mark - webview代理方法
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.indicator setHidden:NO];
    [self.indicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicator stopAnimating];
    [self.indicator setHidden:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString* tmp = [request.URL absoluteString];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"codenavigator://git.clone?" withString:@""];
    // treat git repo
    if ([[tmp pathExtension] isEqualToString:@"git"]) {
//#ifdef IPHONE_VERSION
        [self doneButtonClicked:nil];
//#endif
        [[Utils getInstance].masterViewController showGitCloneViewWithUrl:tmp];
        return NO;
    }
    return YES;
}

@end
