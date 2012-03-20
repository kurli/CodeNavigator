//
//  GitLogViewCongroller.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/18/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GTRepository;

@interface GitLogViewCongroller : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    int selected;
}
@property (nonatomic, strong) GTRepository* repo;
@property (nonatomic, strong) NSArray* commitsArray;

-(void) gitLogForProject:(NSString*)project;

-(void) showModualView;

- (IBAction)backButtonClicked:(id)sender;

@end
