//
//  RemoteFileControllerDelegate.h
//  CodeNavigator
//
//  Created by Guozhen Li on 4/7/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBRestClient;
@class DBMetadata;

@interface SelectionItem : NSObject
@property (nonatomic, strong) NSString* path;
@property (nonatomic, strong) NSString* fileName;
@end

@interface RemoteFileControllerDelegate : NSObject
{
    int depth;
}

@property (nonatomic, strong) NSMutableArray* currentDirectories;
@property (nonatomic, strong) NSMutableArray* currentFiles;
@property (nonatomic, strong) NSString* currentLocation;
@property (nonatomic, strong) NSMutableArray* selectedArray;
@property (nonatomic, unsafe_unretained) UITableView* remoteTableView;
@property (nonatomic, unsafe_unretained) UILabel* titleLabel;
@property (nonatomic, unsafe_unretained) UIButton* refreshButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *backButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *remoteIndicator;
@property (nonatomic, strong) DBRestClient* restClient;
@property (nonatomic, strong) DBMetadata* metaData;

- (void) reloadWithMetaData:(DBMetadata*) _metaData;

- (void) backButtonClicked;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (IBAction)checkBoxButtonClicked:(id)sender;

@end
