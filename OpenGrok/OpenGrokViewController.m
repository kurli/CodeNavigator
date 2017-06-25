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

@end

@implementation OpenGrokViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* lastUrl = [Utils getInstance].lastUrl;
    if ([lastUrl length] == 0) {
        lastUrl = @"http://opengrok.club:8080";
    }
    NSURL *url = [NSURL URLWithString:lastUrl];
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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.webview.request.URL.absoluteString]];
}

- (IBAction)shareButtonClicked:(id)sender {
}

- (IBAction)backButtonClicked:(id)sender {
    [self.webview goBack];
}

- (IBAction)forwardButtonClicked:(id)sender {
    [self.webview goForward];
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
    // treat git repo
    if ([[tmp pathExtension] isEqualToString:@"git"]) {
        [[Utils getInstance].masterViewController showGitCloneViewWithUrl:tmp];
        return NO;
    }
    return YES;
}

@end
