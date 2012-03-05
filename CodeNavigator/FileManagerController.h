//
//  FileManagerController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 2/20/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VirtualizeViewController;

@interface FileManagerController : NSObject

@property (assign, nonatomic) VirtualizeViewController* viewController;

@property (assign, nonatomic) UIImageView* imageView;

@property (assign, nonatomic) UIScrollView* scrollView;

@property (strong, nonatomic) NSString* currentProjectFolder;

@property (strong, nonatomic) NSMutableArray* imagesPathList;

-(void) addRoundedRectToPath:(CGContextRef) context andRect: (CGRect) rect andWidth:(float) ovalWidth andHeight:(float) ovalHeight;

-(void) searchVirtualizeFiles;

-(void) displayImage:(int)index;

-(void) clearScreen;

@end
