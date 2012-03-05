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

@property (strong, nonatomic) NSString* currentSourcePath;

@property (strong, nonatomic) NSArray* selectionList;

@property (strong, nonatomic) NSString* searchKeyword;

-(void) setSearchItemText:(NSString*)keyword;

@end
