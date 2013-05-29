//
//  ZipFileResolver.h
//  CodeNavigator
//
//  Created by Guozhen Li on 5/29/13.
//
//

#import "FileFormatResolver.h"

@interface ZipFileResolver : FileFormatResolver

@property (strong, nonatomic) NSThread* worker;

@property (strong, nonatomic) UIAlertView* alertView;

@end
