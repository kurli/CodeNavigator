//
//  ChartBoardViewController.m
//  DBTest
//
//  Created by Guozhen Li on 8/6/14.
//  Copyright (c) 2014 Guangzhen Li. All rights reserved.
//

#import "ChartBoardViewController.h"
#import "WeekChartControllerHelper.h"
#import "DayChartControllerHelper.h"
#import "HourChartControllerHelper.h"
//#import <ShareSDK/ShareSDK.h>
#import "Utils.h"
#import <ProjectViewController.h>

@interface ChartBoardViewController () {
    UIView* subView;
}

@property (nonatomic, strong) WeekChartControllerHelper* weekChartController;
@property (nonatomic, strong) DayChartControllerHelper* daysChartController;
@property (nonatomic, strong) HourChartControllerHelper* hoursChartController;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) UIView* weekChartView;
@property (nonatomic, strong) UIView* daysChartView;
@property (nonatomic, strong) UIView* hoursChartView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;

@property (strong, nonatomic) UIPopoverController *projectPopoverController;
@property (strong, nonatomic) NSString* currentProject;

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *projectButton;
@end

@implementation ChartBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.currentProject = nil;
    }
    return self;
}

#define UIColorFromHex(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    [self initWeekChartBoard];
//    [ShareSDK registerApp:@"2a54d22fd462"];
//    [ShareSDK waitAppSettingComplete:^{
//        [self.shareButton setEnabled:YES];
//    }];
    self.view.backgroundColor = UIColorFromHex(0x313131);
    [[Utils getInstance].dbManager appEnded:nil];

    [self initWeekChartBoard];
    
    self.currentProject = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initWeekChartBoard {
    if (self.weekChartView == nil) {
        self.weekChartView = [[UIView alloc] init];
        CGRect frame = self.view.frame;
        frame.origin.y += (self.toolBar.frame.size.height * 2);
        frame.size.height -= frame.origin.y;
        [self.weekChartView setFrame:frame];
        self.weekChartController = [[WeekChartControllerHelper alloc] init];
        [self.weekChartController initView:self.weekChartView andToolHeight:0];
        [self.view addSubview:self.weekChartView];
    }
    [self.daysChartView setHidden:YES];
    [self.hoursChartView setHidden:YES];
    [self.weekChartView setHidden:NO];
    
    [self.daysChartController setHidden:YES];
    [self.hoursChartController setHidden:YES];
    [self.weekChartController setHidden:NO];
}

-(void)initDayCharBoard {
    if (self.daysChartView == nil) {
        self.daysChartView = [[UIView alloc] init];
        CGRect frame = self.view.frame;
        frame.origin.y += (self.toolBar.frame.size.height * 2);
        frame.size.height -= frame.origin.y;
        [self.daysChartView setFrame:frame];
        self.daysChartController = [[DayChartControllerHelper alloc] init];
        [self.daysChartController initView:self.daysChartView andToolHeight:0];
        [self.view addSubview:self.daysChartView];
    }
    [self.hoursChartView setHidden:YES];
    [self.weekChartView setHidden:YES];
    [self.daysChartView setHidden:NO];
    
    [self.weekChartController setHidden:YES];
    [self.hoursChartController setHidden:YES];
    [self.daysChartController setHidden:NO];
}

-(void)initHourCharBoard {
    if (self.hoursChartView == nil) {
        self.hoursChartView = [[UIView alloc] init];
        CGRect frame = self.view.frame;
        frame.origin.y += (self.toolBar.frame.size.height * 2);
        frame.size.height -= frame.origin.y;
        [self.hoursChartView setFrame:frame];
        self.hoursChartController = [[HourChartControllerHelper alloc] init];
        [self.hoursChartController initView:self.hoursChartView andToolHeight:0];
        [self.view addSubview:self.hoursChartView];
    }
    [self.daysChartView setHidden:YES];
    [self.weekChartView setHidden:YES];
    [self.hoursChartView setHidden:NO];
    
    [self.daysChartController setHidden:YES];
    [self.weekChartController setHidden:YES];
    [self.hoursChartController setHidden:NO];
}

- (IBAction)changeCharView:(id)sender {
    UISegmentedControl* controller = (UISegmentedControl*)sender;
    switch (controller.selectedSegmentIndex) {
        case 0:
            [self initWeekChartBoard];
            if (self.weekChartController.currentProject != self.currentProject) {
                if (self.weekChartController.currentProject == nil ||
                    [self.weekChartController.currentProject compare:self.currentProject] != NSOrderedSame) {
                    [self.weekChartController reloadData:self.currentProject];
                }
            }
            break;
        case 1:
            [self initDayCharBoard];
            if (self.daysChartController.currentProject != self.currentProject) {
                if (self.daysChartController.currentProject == nil ||
                    [self.daysChartController.currentProject compare:self.currentProject] != NSOrderedSame) {
                    [self.daysChartController reloadData:self.currentProject];
                }
            }
            break;
        case 2:
            [self initHourCharBoard];
            if (self.hoursChartController.currentProject != self.currentProject) {
                if (self.hoursChartController.currentProject == nil ||
                    [self.hoursChartController.currentProject compare:self.currentProject] != NSOrderedSame) {
                    [self.hoursChartController reloadData:self.currentProject];
                }
            }
            break;
        default:
            break;
    }
}

-(void) projectSelectedDone:(NSString*)proj {
    [self.projectPopoverController dismissPopoverAnimated:NO];
    self.projectPopoverController = nil;
    
    self.currentProject = proj;
    
    switch (self.segmentController.selectedSegmentIndex) {
        case 0:
            [self.weekChartController reloadData:proj];
            break;
        case 1:
            [self.daysChartController reloadData:proj];
            break;
        case 2:
            [self.hoursChartController reloadData:proj];
            break;
        default:
            break;
    }

    if (proj == nil) {
        proj = @"All";
    }
    [self.projectButton setTitle:proj forState:UIControlStateNormal];
}

- (IBAction)projectSelected:(id)sender {
    ProjectViewController* viewController = [[ProjectViewController alloc] init];
    [viewController setViewController2:self];
    [viewController setCurrentProject:self.currentProject];
#ifdef IPHONE_VERSION
    error
#else
    self.projectPopoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
#endif
    self.projectPopoverController.popoverContentSize = viewController.view.frame.size;
    [self.projectPopoverController presentPopoverFromRect:self.projectButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)shareButtonClicked:(id)sender {
    UIImage* image;
    switch (self.segmentController.selectedSegmentIndex) {
        case 0:
            image = [self.weekChartController screenshot];
            break;
        case 1:
            image = [self.daysChartController screenshot];
            break;
        case 2:
            image = [self.hoursChartController screenshot];
            break;
        default:
            break;
    }
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    [[Utils getInstance] alertWithTitle:@"Done" andMessage:@"Check your photo album.\nShare with your friends there. :-)"];
    
//    NSString* path = [self.daysChartController screenshot];
//    
//    id<ISSContainer> container = [ShareSDK container];
//    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
//    
//    id<ISSContent> publishContent = [ShareSDK content:@"分享内容"
//                                       defaultContent:@"默认分享内容，没内容时显示"
//                                                image:[ShareSDK imageWithPath:path]
//                                                title:@"CodeNavigator"
//                                                  url:@"http://guangzhen.cublog.cn"
//                                          description:@""
//                                            mediaType:SSPublishContentMediaTypeNews];
//    
//    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
//                                                         allowCallback:YES
//                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
//                                                          viewDelegate:nil
//                                               authManagerViewDelegate:nil];
//    
//    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
//                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
//                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
//                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"CodeNavigator"],
//                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
//                                    nil]];
//    
//    [ShareSDK showShareActionSheet:container
//                         shareList:nil
//                           content:publishContent
//                     statusBarTips:YES
//                       authOptions:authOptions
//                      shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
//                                                          oneKeyShareList:[NSArray defaultOneKeyShareList]
//                                                           qqButtonHidden:NO
//                                                    wxSessionButtonHidden:NO
//                                                   wxTimelineButtonHidden:NO
//                                                     showKeyboardOnAppear:NO
//                                                        shareViewDelegate:nil
//                                                      friendsViewDelegate:nil
//                                                    picViewerViewDelegate:nil]
//                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
//                                if (state == SSResponseStateSuccess)
//                                {
//                                    NSLog(@"分享成功");
//                                }
//                                else if (state == SSResponseStateFail)
//                                {
//                                    NSLog(@"分享失败,错误码:,错误描述:");
//                                }
//                            }];
}

@end
