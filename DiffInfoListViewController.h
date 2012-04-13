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

@property (nonatomic, unsafe_unretained) NSMutableArray* diffAnalyzeList;

@property (nonatomic, unsafe_unretained) GitDiffViewController* gitDiffViewController;

@end
