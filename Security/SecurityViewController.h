//
//  SecurityViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 4/30/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _PASSWORD_STAT
{
    ENTER_PASSWORD,
    RESET_CHECK,
    RESET_PASSWORD,
    RESET_PASSWORD_CONFIRM
} PASSWORD_STAT;

@interface SecurityViewController : UIViewController
{
    PASSWORD_STAT passwordStat;
}

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *informationLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *pas1;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *pas2;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *pas3;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *pas4;

@property (strong, nonatomic) NSMutableString* password;

@property (strong, nonatomic) NSMutableString* needConfirmPassword;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *resetButton;

- (IBAction)buttonClicked:(id)sender;
@end
