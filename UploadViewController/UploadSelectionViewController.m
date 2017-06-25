//
//  UploadSelectionViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 9/29/13.
//
//

#import "UploadSelectionViewController.h"
#import "MasterViewController.h"
#import "Utils.h"

@interface UploadSelectionViewController ()

@end

@implementation UploadSelectionViewController

@synthesize masterViewController;

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
    [self setMasterViewController:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.contentSizeForViewInPopover = self.view.frame.size;
}

- (void) dealloc
{
    [self setMasterViewController:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [masterViewController showWebUploadService];
            [[Utils getInstance] addGAEvent:@"Add" andAction:@"WebUploadService" andLabel:nil andValue:nil];
            break;
        case 1:
#ifndef LITE_VERSION
            [masterViewController showGitCloneView];
            [[Utils getInstance] addGAEvent:@"Add" andAction:@"GitClone" andLabel:nil andValue:nil];
#endif
            break;
#ifdef IPHONE_VERSION
        case 2:
#ifndef LITE_VERSION
            [masterViewController downloadZipFromGitHub];
            [[Utils getInstance] addGAEvent:@"Add" andAction:@"GitHubZip" andLabel:nil andValue:nil];
#endif
            break;
        case 3:
#ifndef LITE_VERSION
            [masterViewController uploadFromITunes];
            [[Utils getInstance] addGAEvent:@"Add" andAction:@"iTunes Transfer" andLabel:nil andValue:nil];
#endif
            break;
#else
        case 2:
#ifndef LITE_VERSION
            [masterViewController downloadZipFromGitHub];
            [[Utils getInstance] addGAEvent:@"Add" andAction:@"GitHubZip" andLabel:nil andValue:nil];
#endif
            break;
        case 3:
#ifndef LITE_VERSION
            [masterViewController uploadFromITunes];
            [[Utils getInstance] addGAEvent:@"Add" andAction:@"iTunes Transfer" andLabel:nil andValue:nil];
#endif
            break;
#endif
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *itemIdentifier = @"UploadSelectionViewCell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:itemIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemIdentifier];
    }
    if (indexPath.row == 0) {
        //cell.imageView.image = [UIImage imageNamed:@"twitter.png"];
        cell.textLabel.text = @"Web Upload Service";
        cell.imageView.image = [UIImage imageNamed:@"web_upload.png"];
    } else if (indexPath.row == 1) {
        //cell.imageView.image = [UIImage imageNamed:@"share.png"];
        cell.textLabel.text = @"Git Clone";
        cell.imageView.image = [UIImage imageNamed:@"git_clone.png"];

#ifdef LITE_VERSION
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.textLabel setTextColor: [UIColor grayColor]];
#endif
#ifdef IPHONE_VERSION
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"From OpenGrok.Club";
        cell.imageView.image = [UIImage imageNamed:@"open_grok_2.png"];
#ifdef LITE_VERSION
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.textLabel setTextColor: [UIColor grayColor]];
#endif
    } else {
        cell.textLabel.text = @"iTunes Transfer";
        cell.imageView.image = [UIImage imageNamed:@"itunes_transfer"];
#ifdef LITE_VERSION
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.textLabel setTextColor: [UIColor grayColor]];
#endif
    }
#else
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"From OpenGrok.Club";
        cell.imageView.image = [UIImage imageNamed:@"open_grok_2.png"];
#ifdef LITE_VERSION
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.textLabel setTextColor: [UIColor grayColor]];
#endif
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"iTunes Transfer";
        cell.imageView.image = [UIImage imageNamed:@"itunes_transfer"];
#ifdef LITE_VERSION
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.textLabel setTextColor: [UIColor grayColor]];
#endif
    }
#endif
CGSize itemSize = CGSizeMake(35, 35);

UIGraphicsBeginImageContext(itemSize);

CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);

[cell.imageView.image drawInRect:imageRect];

cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
UIGraphicsEndImageContext();

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Sync your project with:";
}


@end
