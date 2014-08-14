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
//#import <ShareSDK/ShareSDK.h>
#import "Utils.h"

@interface ChartBoardViewController () {
    UIView* subView;
}

@property (nonatomic, strong) WeekChartControllerHelper* weekChartController;
@property (nonatomic, strong) DayChartControllerHelper* daysChartController;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) UIView* weekChartView;
@property (nonatomic, strong) UIView* daysChartView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;
@property (weak, nonatomic) IBOutlet UILabel *codeNavigatorLabel;

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@end

@implementation ChartBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
        [self.weekChartController initView:self.weekChartView andToolHeight:0 andLabel:self.codeNavigatorLabel];
        [self.view addSubview:self.weekChartView];
    }
    [self.daysChartView setHidden:YES];
    [self.weekChartView setHidden:NO];
    [self.daysChartController setHidden:YES];
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
        [self.daysChartController initView:self.daysChartView andToolHeight:0 andLabel:self.codeNavigatorLabel];
        [self.view addSubview:self.daysChartView];
    }
    [self.weekChartView setHidden:YES];
    [self.daysChartView setHidden:NO];
    [self.daysChartController setHidden:NO];
    [self.weekChartController setHidden:YES];
}

-(void)initHourChardBoard {
    
}

- (IBAction)changeCharView:(id)sender {
    UISegmentedControl* controller = (UISegmentedControl*)sender;
    switch (controller.selectedSegmentIndex) {
        case 0:
            [self initWeekChartBoard];
            break;
        case 1:
            [self initDayCharBoard];
            break;
        case 2:
            [self initHourChardBoard];
            break;
        default:
            break;
    }
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
