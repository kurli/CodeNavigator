//
//  HelpViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 7/31/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "HelpViewController.h"
#import "Utils.h"

#define ALERT_DEMO_VIDEO 0
#define ALERT_TWITTER_FOLLOW 1
#define ALERT_WEIBO_FOLLOW 2
#define ALERT_WEIBO_SHARE 3

@interface HelpViewController ()

@end

@implementation HelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) feedbackViaEmail
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    NSArray *toRecipients = [NSArray arrayWithObject:@"guangzhen@hotmail.com"];   
    [picker setToRecipients:toRecipients];
#ifdef LITE_VERSION
    [picker setSubject:@"CodeNavigator Lite v5.1.1 feedback"];
#else
#ifdef IPHONE_VERSION
    [picker setSubject:@"CodeNavigator iPhone v5.1.1.2 feedback"];
#else
    [picker setSubject:@"CodeNavigator v5.1.1 feedback"];
#endif
#endif
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Email send complete, Thanks for your support"];
            break;
        case MFMailComposeResultFailed:
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Email send failed, Please check your Email settings."];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
    NSString *recipients = @"mailto:guangzhenhotmail.com?subject=CodeNavigator v2.3 feedback";
    
    NSString *email = [NSString stringWithFormat:@"%@", recipients];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (void)sendButtonClicked:(id)sender {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self feedbackViaEmail];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
}

- (void) shareWithTwitter
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *sheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        SLComposeViewControllerCompletionHandler completionBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                NSLog(@"Cancelled");
            } else {
                NSLog(@"Done");
            }
            
            [sheet dismissViewControllerAnimated:YES completion:Nil];
        };
        sheet.completionHandler = completionBlock;
        
        //Adding the Text to the post value from iOS
        [sheet addImage:[UIImage imageNamed:@"Icon-72.png"]];
        [sheet addURL:[NSURL URLWithString:@"http://lgzsoftware.blogspot.com/2012/02/2012129-new-features-in-1_8547.html"]];
        [sheet setInitialText:@"I'm enjoying CodeNavigator with my source codes on iPad."];
        [self presentViewController:sheet animated:YES completion:Nil];
    }
    else
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Twitter is not supported in current iOS version."];
    }
}

- (void) shareWithWeibo
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
        SLComposeViewController *sheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
        
        SLComposeViewControllerCompletionHandler completionBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                NSLog(@"Cancelled");
            } else {
                NSLog(@"Done");
            }
            
            [sheet dismissViewControllerAnimated:YES completion:Nil];
        };
        sheet.completionHandler = completionBlock;
        
        //Adding the Text to the post value from iOS
        [sheet addImage:[UIImage imageNamed:@"Icon-72.png"]];
        [sheet addURL:[NSURL URLWithString:@"http://guangzhen.cublog.cn"]];
        [sheet setInitialText:@"我正在使用CodeNavigator在我的iPad上Review我的代码."];
        [self presentViewController:sheet animated:YES completion:Nil];
    }
    else
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Weibo is not supported in current iOS version."];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView* alertConfirmView;
    switch (indexPath.section) {
        case 0:
            [[Utils getInstance] addGAEvent:@"Help" andAction:@"Demo Video" andLabel:nil andValue:nil];
            //demoVideo
            alertType = ALERT_DEMO_VIDEO;
            alertConfirmView = [[UIAlertView alloc] initWithTitle:@"Do you want to open this link in Safari?" message:@"http://v.youku.com/v_show/id_XNzQwMDEyMjE2.html" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            [alertConfirmView show];
            break;
        case 1:
            [self sendButtonClicked:nil];
            break;
        case 2:
#ifdef LITE_VERSION
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/codenavigator/id492480832?mt=8"]];
#else
#ifdef IPHONE_VERSION
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=536268810"]];
#else
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=492480832"]];
#endif
#endif
            [[Utils getInstance] addGAEvent:@"Help" andAction:@"Rate" andLabel:nil andValue:nil];
            break;
        case 3:
            // Twitter
            if (indexPath.row == 0) {
                //Follow
                alertType = ALERT_TWITTER_FOLLOW;
                alertConfirmView = [[UIAlertView alloc] initWithTitle:@"Do you want to open this link in Safari?" message:@"http://twitter.com/intent/user?screen_name=CodeNavigator" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
                [alertConfirmView show];
            }
            else {
                //Share
                [self shareWithTwitter];
            }
            break;
        case 4:
            // Weibo
            if (indexPath.row == 0) {
                //Follow
                alertType = ALERT_WEIBO_FOLLOW;
                alertConfirmView = [[UIAlertView alloc] initWithTitle:@"Do you want to open Sina Weibo in Safari?" message:@"http://www.weibo.com/u/2069009174\nYou need to have Sina Weibo account!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
                [alertConfirmView show];
            }
            else {
                //Share
                [self shareWithWeibo];
            }
            break;
            
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section > 2)
        return 2;
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *itemIdentifier = @"HelpCell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:itemIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemIdentifier];
    }
    switch (indexPath.section) {
        case 0:
            cell.imageView.image = [UIImage imageNamed:@"demoVideo.png"];
            cell.textLabel.text = @"Demo Video";
            break;
        case 1:
            cell.imageView.image = [UIImage imageNamed:@"feedback.png"];
            cell.textLabel.text = @"Contact Developer";
            break;
        case 2:
            cell.imageView.image = [UIImage imageNamed:@"appstore.png"];
#ifdef LITE_VERSION
            cell.textLabel.text = @"Get Full Version";
#else
            cell.textLabel.text = @"Rate CodeNavigator";
#endif
            break;
        case 3:
            //Twitter
            if (indexPath.row == 0) {
                cell.imageView.image = [UIImage imageNamed:@"twitter.png"];
                cell.textLabel.text = @"Follow me via Twitter";
            } else {
                cell.imageView.image = [UIImage imageNamed:@"share.png"];
                cell.textLabel.text = @"Share with others";
            }
            break;
        case 4:
            //Weibo
            if (indexPath.row == 0) {
                cell.imageView.image = [UIImage imageNamed:@"weibo.png"];
                cell.textLabel.text = @"Follow me via Weibo";
            } else {
                cell.imageView.image = [UIImage imageNamed:@"share.png"];
                cell.textLabel.text = @"Share with others";
            }            
            break;
        default:
            break;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 4) {
#ifdef LITE_VERSION
        return @"CodeNavigatorLite 5.1.1 Guangzhen Li\n@2011-2014";
#else
#ifdef IPHONE_VERSION
        return @"CodeNavigator 5.1.1.2 Guangzhen Li\n@2011-2014";
#else
        return @"CodeNavigator 5.1.1 Guangzhen Li\n@2011-2014";
#endif
#endif
    }
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Help";
    else if (section == 2)
#ifdef LITE_VERSION
        return @"No Ads, No limits, latest version";
#else
        return @"Rate me to make me better";
#endif
    else if (section == 3)
        return @"Twitter";
    else if (section == 4)
        return @"Weibo";
    return @"";
}

- (void) doneButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 1) {
        return;
    }
#ifdef LITE_VERSION
    NSString* url = @"http://itunes.apple.com/us/app/codenavigatorlite/id494004821?mt=8";
#else
    NSString* url = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=492480832";
#endif
    switch (alertType) {
        case ALERT_DEMO_VIDEO:
            url = @"http://v.youku.com/v_show/id_XNzQwMDEyMjE2.html";
            break;
        case ALERT_TWITTER_FOLLOW:
            url = @"http://twitter.com/intent/user?screen_name=CodeNavigator";
            break;
        case ALERT_WEIBO_FOLLOW:
            url = @"http://www.weibo.com/u/2069009174";
            break;
        case ALERT_WEIBO_SHARE:
            url = @"http://v.t.sina.com.cn/share/share.php?title=I'm%20enjoying%20CodeNavigator%20with%20my%20source%20codes%20on%20iPad&url=http%3A%2F%2Fblog.chinaunix.net%2Fuid-1738642-id-3055586.html&source=bookmark&appkey=2992571369&pic=&ralateUid=";
            break;
        default:
            break;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
