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

@end
