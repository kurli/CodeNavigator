//
//  DiffInfoListViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 4/4/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GitDiffViewController;

@interface DiffInfoListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray* diffAnalyzeList;

@property (nonatomic, strong) GitDiffViewController* gitDiffViewController;

@end
