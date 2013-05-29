//
//  HandleURLController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 5/29/13.
//
//

#import <Foundation/Foundation.h>

@class FileFormatResolver;

@interface HandleURLController : NSObject

- (BOOL) checkWhetherSupported:(NSURL*) url;

- (BOOL) isBusy;

- (BOOL) handleFile: (NSString*) path;

@property (strong, nonatomic) FileFormatResolver* fileFormatResolver;

@property (strong, nonatomic) NSString* filePath;

@end
