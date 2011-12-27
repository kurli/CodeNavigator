//
//  NavigationController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DetailViewController.h"
#import "ResultViewController.h"

@interface NavigationController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
    NSArray* selectionList;
    int selectedItem;
}

@property (retain, nonatomic) DetailViewController* detailViewController;

@property (unsafe_unretained, nonatomic) IBOutlet UISearchBar *searchBar;

@property (retain, nonatomic) NSString* currentSearchProject;

-(void) cscopeSearch: (NSString*)text;

-(void) setSearchKeyword:(NSString*)keyword;

@end
