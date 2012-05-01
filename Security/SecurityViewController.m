//
//  SecurityViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 4/30/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "SecurityViewController.h"
#import "Utils.h"

@interface SecurityViewController ()

@end

@implementation SecurityViewController
@synthesize informationLabel;
@synthesize pas1;
@synthesize pas2;
@synthesize pas3;
@synthesize pas4;
@synthesize password;
@synthesize needConfirmPassword;
@synthesize resetButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        passwordStat = ENTER_PASSWORD;
        password = [[NSMutableString alloc] initWithString:@""];
        needConfirmPassword = [[NSMutableString alloc] initWithString:@""];
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
    [self setInformationLabel:nil];
    [self setPas1:nil];
    [self setPas2:nil];
    [self setPas3:nil];
    [self setPas4:nil];
    [self setPassword:nil];
    [self setNeedConfirmPassword:nil];
    [self setResetButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)setPasToFile
{
    NSError* error;
    NSString* pasFile = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/Password"];
    if (password == nil || [password length] != 4) {
        [[NSFileManager defaultManager] removeItemAtPath:pasFile error:&error];
        return;
    }
    [password writeToFile:pasFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[Utils getInstance] setIsScreenLocked:YES];
    
    NSString* pas = [[Utils getInstance] isPasswardSet];
    if (pas == nil) {
        passwordStat = RESET_PASSWORD;
        [informationLabel setText:@"You can set password to protect your projects"];
        [resetButton setTitle:@"Exit" forState:UIControlStateNormal];
        return;
    }
    pas = nil;
    passwordStat = ENTER_PASSWORD;
    [informationLabel setText:@"Please Enter Password"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)passwordEntered:(int)number
{
    if ([password length] == 4) {
        return;
    }
    
    [password appendFormat:@"%d", number];
    switch ([password length]) {
        case 1:
            [pas1 setText:@"*"];
            break;
        case 2:
            [pas2 setText:@"*"];
            break;
        case 3:
            [pas3 setText:@"*"];
            break;
        case 4:
            [pas4 setText:@"*"];
            break;
        default:
            break;
    }
    if (passwordStat == ENTER_PASSWORD) {
        if ([password length] != 4) {
            return;
        }
        if ([password compare:[[Utils getInstance] isPasswardSet]] == NSOrderedSame) {
            [[Utils getInstance] setIsScreenLocked:NO];
            [[Utils getInstance].splitViewController dismissModalViewControllerAnimated:YES];
        }
        else {
            [informationLabel setText:@"Password Error"];
            password = [[NSMutableString alloc] initWithString:@""];
            needConfirmPassword = [[NSMutableString alloc] initWithString:@""];
            [pas1 setText:@""];
            [pas2 setText:@""];
            [pas3 setText:@""];
            [pas4 setText:@""];
        }
        return;
    }
    else if (passwordStat == RESET_CHECK) {
        if ([password length] != 4) {
            return;
        }
        if ([password compare:[[Utils getInstance] isPasswardSet]] == NSOrderedSame) {
            passwordStat = RESET_PASSWORD;
            password = [[NSMutableString alloc] initWithString:@""];
            needConfirmPassword = [[NSMutableString alloc] initWithString:@""];
            [pas1 setText:@""];
            [pas2 setText:@""];
            [pas3 setText:@""];
            [pas4 setText:@""];
            passwordStat = RESET_PASSWORD;
            [informationLabel setText:@"Please Set Password:(0000 to erase password)"];
        }
        else {
            [informationLabel setText:@"Password Error"];
            password = [[NSMutableString alloc] initWithString:@""];
            needConfirmPassword = [[NSMutableString alloc] initWithString:@""];
            [pas1 setText:@""];
            [pas2 setText:@""];
            [pas3 setText:@""];
            [pas4 setText:@""];
        }
        return;
    }
    else if (passwordStat == RESET_PASSWORD)
    {
        if ([password length] != 4) {
            return;
        }
        if ([password compare:@"0000"] == NSOrderedSame) {
            password = nil;
            [self setPasToFile];
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Password erased"];
            [[Utils getInstance] setIsScreenLocked:NO];
            [[Utils getInstance].splitViewController dismissModalViewControllerAnimated:YES];
            return;
        }
        needConfirmPassword = password;
        password = [[NSMutableString alloc] initWithString:@""];
        [pas1 setText:@""];
        [pas2 setText:@""];
        [pas3 setText:@""];
        [pas4 setText:@""];
        passwordStat = RESET_PASSWORD_CONFIRM;
        [informationLabel setText:@"Confirm password"];
    }
    else if (passwordStat == RESET_PASSWORD_CONFIRM)
    {
        if ([password length] != 4) {
            return;
        }
        if ([password compare:needConfirmPassword] == NSOrderedSame) {
            [self setPasToFile];
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Password set finished"];
            [[Utils getInstance] setIsScreenLocked:NO];
            [[Utils getInstance].splitViewController dismissModalViewControllerAnimated:YES];
            return;
        } else {
            [informationLabel setText:@"Password do not same as previous, reenter"];
            passwordStat = RESET_PASSWORD;
            password = [[NSMutableString alloc] initWithString:@""];
            needConfirmPassword = [[NSMutableString alloc] initWithString:@""];
            [pas1 setText:@""];
            [pas2 setText:@""];
            [pas3 setText:@""];
            [pas4 setText:@""];
        }
        return;
    }
}

- (IBAction)buttonClicked:(id)sender {
    UIButton* button = (UIButton*)sender;
    if (button.tag < 10) {
        //number
        [self passwordEntered:button.tag];
        return;
    }
    else if (button.tag == 10)
    {
        //Clear
        password = [[NSMutableString alloc] initWithString:@""];
        [pas1 setText:@""];
        [pas2 setText:@""];
        [pas3 setText:@""];
        [pas4 setText:@""];
        return;
    }
    else if (button.tag == 11)
    {
        //Delete
        if ([password length] == 0) {
            return;
        }
        switch ([password length]) {
            case 1:
                [pas1 setText:@""];
                break;
            case 2:
                [pas2 setText:@""];
                break;
            case 3:
                [pas3 setText:@""];
                break;
            case 4:
                [pas4 setText:@""];
                break;
            default:
                break;
        }
        [password deleteCharactersInRange:NSMakeRange([password length]-1, 1)];
        return;
    }
    else if (button.tag == 12)
    {
        //reset
        if (passwordStat == RESET_PASSWORD || passwordStat == RESET_PASSWORD_CONFIRM) {
            [[Utils getInstance] setIsScreenLocked:NO];
            [[Utils getInstance].splitViewController dismissModalViewControllerAnimated:YES];
            return;
        }
        password = [[NSMutableString alloc] initWithString:@""];
        [pas1 setText:@""];
        [pas2 setText:@""];
        [pas3 setText:@""];
        [pas4 setText:@""];
        if ([[Utils getInstance] isPasswardSet] == nil) {
            // Reset password, no password previously
            passwordStat = RESET_PASSWORD;
            [informationLabel setText:@"Please Set Password:(0000 to erase password)"];
            [resetButton setTitle:@"Exit" forState:UIControlStateNormal];
        } else {
            // Reset password, need check whether authonized
            passwordStat = RESET_CHECK;
            [informationLabel setText:@"Please Enter Original Password"];
        }
        [button setTitle:@"Exit" forState:UIControlStateNormal];
    }
}
@end
