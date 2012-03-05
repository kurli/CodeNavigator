//
//  FileManagerController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 2/20/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "FileManagerController.h"
#import "VirtualizeViewController.h"

#define ITEM_WIDTH 300
#define ITEM_MARGINE 60

@implementation FileManagerController

@synthesize viewController;
@synthesize imageView;
@synthesize scrollView;
@synthesize currentProjectFolder;
@synthesize imagesPathList;

- (void) dealloc
{
    [self.imagesPathList removeAllObjects];
    [self setImagesPathList:nil];
    [self setCurrentProjectFolder:nil];
}

-(void) addRoundedRectToPath:(CGContextRef) context andRect: (CGRect) rect andWidth:(float) ovalWidth andHeight:(float) ovalHeight
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) { // 1
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context); // 2
    CGContextTranslateCTM (context, CGRectGetMinX(rect), // 3
                           CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight); // 4
    fw = CGRectGetWidth (rect) / ovalWidth; // 5
    fh = CGRectGetHeight (rect) / ovalHeight; // 6
    CGContextMoveToPoint(context, fw, fh/2); // 7
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1); // 8
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // 9
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // 10
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // 11
    CGContextClosePath(context); // 12
    CGContextRestoreGState(context); // 13
}

-(void) searchVirtualizeFiles
{
    if (currentProjectFolder == nil)
        return;
    
    if (self.imagesPathList != nil)
    {
        [self.imagesPathList removeAllObjects];
        [self setImagesPathList:nil];
    }
    
    self.imagesPathList = [[NSMutableArray alloc] init];
    
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.currentProjectFolder error:&error];
    for (int i=0; i<[contents count]; i++)
    {
        NSString* extention = [contents objectAtIndex:i];
        extention = [extention pathExtension];
        if ([extention compare:@"lgz_vir_img"] == NSOrderedSame)
        {
            NSString *currentPath = [currentProjectFolder stringByAppendingPathComponent:[contents objectAtIndex:i]];
            [self.imagesPathList addObject:currentPath];
        }
    }
}

-(void) displayImage:(int)index
{
    if (index >= [self.imagesPathList count])
        return;
    NSString* imagePath = [self.imagesPathList objectAtIndex:index];
    NSData* data = [NSData dataWithContentsOfFile:imagePath];
    if (data == nil)
        return;
    UIImage* image = [UIImage imageWithData:data];
    float scale = 1.0f;
    CGSize size;
    if (image.size.width > ITEM_WIDTH)
    {
        scale = (ITEM_WIDTH)/(image.size.width);
    }
    size.width = image.size.width * scale;
    size.height = image.size.height * scale;
    image = [UIImage imageWithCGImage:[image CGImage] scale:1/scale orientation:UIImageOrientationUp];
    
    CGRect rect;
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size.width = viewController.tableView.frame.size.width + size.width + 150;
    rect.size.height = size.height+90;
    [imageView setFrame:rect];
    [scrollView setContentSize:rect.size];
    
    UIGraphicsBeginImageContext(imageView.frame.size);
    [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIGraphicsPushContext(context);
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]CGColor]);
    rect.origin.x = viewController.tableView.frame.size.width + 90;
    rect.origin.y = 60;
    rect.size.width = size.width + 30;
    rect.size.height = size.height + 30;
    [self addRoundedRectToPath:context andRect:rect andWidth:10.0f andHeight:10.0f];
    UIGraphicsPopContext();
    CGContextFillPath(context);
    [image drawInRect:CGRectMake(viewController.tableView.frame.size.width+105, 75, size.width, size.height)];
    
    // get a UIImage from the image context- enjoy!!!
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    [imageView setImage:outputImage];
    // clean up drawing environment
    UIGraphicsEndImageContext();
}

-(void) clearScreen
{
    @autoreleasepool {
        int width = imageView.frame.size.width;
        int height = imageView.frame.size.height;
        
        UIGraphicsBeginImageContext(imageView.frame.size);
        [imageView.image drawInRect:CGRectMake(0, 0, width, height)];
                
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
        CGContextBeginPath(context);
        CGContextFillRect(context, CGRectMake(0, 0, width, height));
        CGContextStrokePath(context);
        imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

@end
