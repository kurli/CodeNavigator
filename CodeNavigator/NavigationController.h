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
    int selectedItem;
}

@property (unsafe_unretained, nonatomic) IBOutlet UISearchBar *searchBar;

@property (retain, nonatomic) NSString* currentSearchProject;

@property (retain, nonatomic) NSArray* selectionList;

@property (retain, nonatomic) NSString* searchKeyword;

-(void) setSearchItemText:(NSString*)keyword;

@end
