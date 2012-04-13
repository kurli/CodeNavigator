//
//  DiffFileListController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 4/2/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GitDiffViewController;

@interface DiffFileListController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, unsafe_unretained) NSMutableArray* diffFileArray;

@property (nonatomic, unsafe_unretained) GitDiffViewController* gitDiffViewController;

@end
