//
//  LocalFileControllerDelegate.h
//  CodeNavigator
//
//  Created by Guozhen Li on 4/7/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalFileControllerDelegate : NSObject
{
    BOOL isProjectFolder;
    int depth;
}

@property (nonatomic, strong) NSMutableArray* currentDirectories;
@property (nonatomic, strong) NSMutableArray* currentFiles;
@property (nonatomic, strong) NSString* currentLocation;
@property (nonatomic, unsafe_unretained) UITableView* localTableView;
@property (nonatomic, unsafe_unretained) UILabel* titleLabel;
@property (nonatomic, unsafe_unretained) UIButton* refreshButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *backButton;

- (void) backButtonClicked;

- (void) reloadData;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@end
