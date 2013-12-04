//
//  HighLightWordController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 1/11/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DetailViewController;

@interface HighLightWordController : UIViewController<UISearchBarDelegate>

@property (strong, nonatomic) DetailViewController* detailViewController;
@property (unsafe_unretained, nonatomic) IBOutlet UISearchBar *searchBarUI;

#ifdef IPHONE_VERSION
- (IBAction)searchButtonClicked:(id)sender;

- (IBAction)cancelButtonClicked:(id)sender;
#endif

- (IBAction)gotoHighlight:(id)sender;

-(void) doSearch: (BOOL)doScroll;

@end
