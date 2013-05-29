//
//  FileFormatResolver.h
//  CodeNavigator
//
//  Created by Guozhen Li on 5/29/13.
//
//

#import <Foundation/Foundation.h>

@interface FileFormatResolver : NSObject

- (void) perform;

- (void) downloadToPath:(NSString*)path;

- (BOOL) isBusy;

@property (nonatomic, strong) NSString* filePath;

@end
