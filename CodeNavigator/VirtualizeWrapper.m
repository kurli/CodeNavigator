//
//  VirtualizeWrapper.m
//  CodeNavigator
//
//  Created by Guozhen Li on 2/6/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "VirtualizeWrapper.h"
#import "Utils.h"
#import "VirtualizeViewController.h"
#import "DetailViewController.h"

@implementation Entry

@synthesize entryName;
@synthesize filePath;
@synthesize parents;
@synthesize childs;
@synthesize rect;
@synthesize childInfo;
@synthesize _id;

-(void)setLine:(int)l
{
    line = l;
}

-(int)getLine
{
    return line;
}

- (void) dealloc
{
    [self.childInfo removeAllObjects];
    [self setChildInfo:nil];
    
    [self.childs removeAllObjects];
    [self setChilds:nil];
    
    [self.parents removeAllObjects];
    [self setParents:nil];
    
    [self setEntryName:nil];
    [self setFilePath:nil];
}

@end

@implementation VirtualizeWrapper

@synthesize filePath;
@synthesize entryHead;
@synthesize currentEntry;
@synthesize imageView;
@synthesize storedImage;
@synthesize currentDragEntry;
@synthesize scrollView;
@synthesize viewController;
@synthesize isNeedGetDefinition;
@synthesize entryBackground;
@synthesize entryHBackbround;

- (id)init
{
    id obj = [super init];
    return obj;
}

- (void) dealloc
{
    [self setFilePath:nil];
    [self setStoredImage:nil];
    [self setEntryHead:nil];
    [self setCurrentEntry:nil];
    [self setImageView:nil];
    [self setCurrentEntry:nil];
    [self setScrollView:nil];
    [self setViewController:nil];
    [self releaseAllEntrys];
    [self setEntryBackground:nil];
    [self setEntryHBackbround:nil];
}

- (void) releaseAllEntrys
{
    if (entryHead == nil)
        return;
    Entry* entry = nil;
    for (int i=0; i<[entryHead.childs count]; i++) {
        entry = [entryHead.childs objectAtIndex:i];
        [entry.childInfo removeAllObjects];
        [entry.childs removeAllObjects];
        [entry.parents removeAllObjects];
    }
    [entryHead.childs removeAllObjects];
    [entryHead.parents removeAllObjects];
    [entryHead.childInfo removeAllObjects];
    
    [self setCurrentEntry:nil];
    [self setCurrentDragEntry:nil];
}

- (void) openFile
{
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError* error;
    if (filePath == nil || [filePath length] == 0)
    {
        NSLog(@"VirtualizeWrapper: filePath nil");
        return;
    }
    BOOL isFolder;
    NSString* imgPath = [filePath stringByAppendingPathExtension:@"lgz_vir_img"];
    NSString* dataPath = [filePath stringByAppendingPathExtension:@"lgz_virtualize"];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:imgPath isDirectory:&isFolder];
    if (isExist)
    {
        @autoreleasepool {
        NSData* data = [NSData dataWithContentsOfFile:imgPath];
        UIImage* image = [UIImage imageWithData:data];
        CGRect rect;
        rect.origin.x = 0;
        rect.origin.y = 0;
        rect.size = image.size;
        [imageView setFrame:rect];
        [scrollView setContentSize:rect.size];
        
        UIGraphicsBeginImageContext(imageView.frame.size);
        [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
        [image drawInRect:rect];
        
        // get a UIImage from the image context- enjoy!!!
        UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
        
        [imageView setImage:outputImage];
        // clean up drawing environment
        UIGraphicsEndImageContext();
        }
        
        isExist = [[NSFileManager defaultManager] fileExistsAtPath:dataPath isDirectory:&isFolder];
        if (!isExist)
        {
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"File format error!"];
            return;
        }
        NSString* str = [NSString stringWithContentsOfFile:dataPath usedEncoding: &encoding error:&error];
        [self readFromContent:str];
    }
    else
    {
        CGRect scrollRect = scrollView.frame;
        scrollRect.origin.x = 0;
        scrollRect.origin.y = 0;
        [imageView setFrame:scrollRect];
        [scrollView setContentSize:scrollRect.size];
        [self startImgDraw];
        [self clearRect:scrollRect];
        [self endImgDraw];
    }
}

- (void) setNewEntryType:(NewEntryType)_type
{
    newEntryType =  _type;
}

- (NewEntryType) getNewEntryType
{
    return newEntryType;
}

- (void) checkBorder:(Entry*)entry
{
    if (entryHead == nil) {
        return;
    }
    if (entry == nil)
        return;
    
    if ([entryHead.parents count] == 0)
    {
        [entryHead.parents addObject:entry];
        [entryHead.parents addObject:entry];
        [entryHead.parents addObject:entry];
        [entryHead.parents addObject:entry];
        return;
    }
    
    Entry* tmp;
    //left most
    tmp = [entryHead.parents objectAtIndex:0];
    if (tmp.rect.origin.x > entry.rect.origin.x)
    {
        [entryHead.parents replaceObjectAtIndex:0 withObject:entry];
    }
    
    //top most
    tmp = [entryHead.parents objectAtIndex:1];
    if (tmp.rect.origin.y > entry.rect.origin.y) {
        [entryHead.parents replaceObjectAtIndex:1 withObject:entry];
    }
    
    //right most
    tmp = [entryHead.parents objectAtIndex:2];
    if (tmp.rect.origin.x < entry.rect.origin.x) {
        [entryHead.parents replaceObjectAtIndex:2 withObject:entry];
    }
    
    //bottom most
    tmp = [entryHead.parents objectAtIndex:3];
    if (tmp.rect.origin.y < entry.rect.origin.y) {
        [entryHead.parents replaceObjectAtIndex:3 withObject:entry];
    }
}

-(void) addEntry:(NSString *)entryName andFile:(NSString *)file andLine:(int)line
{
    isDirty = YES;
    CGRect rect;
    if (self.entryHead == nil)
    {
        self.entryHead = [[Entry alloc] init];
        rect.origin.x = IMAGE_MARGINE;
        rect.origin.y = IMAGE_MARGINE;
        rect.size.width = imageView.frame.size.width;
        rect.size.height = imageView.frame.size.height;
        [entryHead setRect:rect];
        self.entryHead.childs = [[NSMutableArray alloc] init];
        self.entryHead.parents = [[NSMutableArray alloc] init];
        
        [self startImgDraw];
        [self clearRect:imageView.frame];
        [self endImgDraw];
    }
    
    if (isNeedGetDefinition == YES)
    {
        // Has finished get result from resultView, so reset it.
        [self.viewController setIsNeedGetResultFromCscope:NO];
        
        // Because if currentEntry changed, the flag will be reseted
        isNeedGetDefinition = NO;
        [currentEntry setFilePath:file];
        [currentEntry setLine:line];
        //TODO if entry name has been changed, we need to delete it's children and parents
        [currentEntry setEntryName:entryName];
        [self startImgDraw];
        [self drawEntry:currentEntry andHighlighted:YES];
        [self endImgDraw];
        return;
    }
    
    Entry* entry = [[Entry alloc]init];
    entry.childInfo = [[NSMutableArray alloc]init];
    entry.childs = [[NSMutableArray alloc] init];
    entry.parents = [[NSMutableArray alloc] init];
    [entryHead.childs addObject:entry];
    
    if (self.currentEntry == nil)
    {
        [entry setEntryName:entryName];
        [entry setFilePath:file];
        [entry setLine:line];
        
        rect.origin.x = 0;
        rect.origin.y = 0;
        rect.size.width = ENTRY_WIDTH;
        rect.size.height = ENTRY_HEIGHT;
        [entry setRect:rect];
        [self startImgDraw];
        [self drawEntry:entry andHighlighted:NO];
        [self endImgDraw];
        [self checkBorder:entry];
    }
    else
    {
        NSString* childInfo;
        Entry* lastEntry;
        NSString* file2;
        switch (newEntryType) {
            case NEW_ENTRY_CHILD:
                //Here we only get the position from the caller, not the definition one
                [entry setEntryName:entryName];
                [entry setFilePath:nil];
                [entry setLine:-1];
                
                //add child info for parent
                file2 = [[Utils getInstance] getPathFromProject:file];
                childInfo = [NSString stringWithFormat:@"%@:%@:%d",file2, entryName, line];
                [currentEntry.childInfo addObject:childInfo];

                //set display rect
                lastEntry = [currentEntry.childs lastObject];
                if (lastEntry == nil)
                {
                    rect.origin.x = currentEntry.rect.origin.x + ENTRYS_MARGINE + ENTRY_WIDTH;
                    rect.origin.y = currentEntry.rect.origin.y;
                }
                else
                {
                    rect.origin.x = lastEntry.rect.origin.x;
                    rect.origin.y = lastEntry.rect.origin.y + lastEntry.rect.size.height + 25;
                }

                rect.size.width = ENTRY_WIDTH;
                rect.size.height = ENTRY_HEIGHT;
                [entry setRect:rect];
                
                //add currentEntry as it's parent
                [entry.parents addObject:currentEntry];
                
                //add it's own as currentEntry's child
                [currentEntry.childs addObject:entry];
                
                [self checkBorder:entry];
                
                //calculate the viewport, it will draw all entrys
                if (![self calculateImageInfo:rect andPerformDraw:YES])
                {
                    [self startImgDraw];
                    [self drawLineForEntry:currentEntry andChild:entry];
                    [self drawEntry:entry andHighlighted:NO];
                    [self endImgDraw];
                }
                break;
            case NEW_ENTRY_PARENT:
                //Here entryName should be the caller name
                //But the line is not, it's the calling line
                [entry setEntryName:entryName];
                [entry setFilePath:file];
                [entry setLine:-1];
                
                file2 = [[Utils getInstance] getPathFromProject:file];
                childInfo = [NSString stringWithFormat:@"%@:%@:%d",file2, currentEntry.entryName, line];
                [entry.childInfo addObject:childInfo];

                //set display rect
                lastEntry = [currentEntry.parents lastObject];
                if (lastEntry == nil)
                {
                    rect.origin.x = currentEntry.rect.origin.x - ENTRYS_MARGINE - ENTRY_WIDTH;
                    rect.origin.y = currentEntry.rect.origin.y;
                }
                else
                {
                    rect.origin.x = lastEntry.rect.origin.x;
                    rect.origin.y = lastEntry.rect.origin.y + lastEntry.rect.size.height + 25;
                }
                rect.size.width = ENTRY_WIDTH;
                rect.size.height = ENTRY_HEIGHT;
                [entry setRect:rect];
                
                //add currentEntry as it's child
                [entry.childs addObject:currentEntry];
                                
                //add it's own as currentEntry's parent
                [currentEntry.parents addObject:entry];
                
                [self checkBorder:entry];
                
                //calculate the viewport, it will draw all entrys
                if (![self calculateImageInfo:rect andPerformDraw:YES])
                {
                    [self startImgDraw];
                    [self drawLineForEntry:entry andChild:currentEntry];
                    [self drawEntry:entry andHighlighted:NO];
                    [self endImgDraw];
                }
                break;
            default:
                break;
        }
    }
}

- (void) addEmptyEntry
{
    Entry* entry = [[Entry alloc]init];
    entry.childInfo = [[NSMutableArray alloc]init];
    entry.childs = [[NSMutableArray alloc] init];
    entry.parents = [[NSMutableArray alloc] init];
    [entryHead.childs addObject:entry];

    [entry setEntryName:nil];
    [entry setFilePath:nil];
    [entry setLine:-1];
    
    CGRect rect;
    rect.size.height = ENTRY_HEIGHT;
    rect.size.width = ENTRY_WIDTH;
    rect.origin.x = (viewController.scrollView.contentOffset.x + 100) - entryHead.rect.origin.x;
    rect.origin.y = viewController.scrollView.contentOffset.y + 60 - entryHead.rect.origin.y;
    
    [entry setRect:rect];
    
    if (currentEntry != nil)
        [self deselectHighlighted:currentEntry];
    
    [self startImgDraw];
    [self drawEntry:entry andHighlighted:NO];
    [self endImgDraw];
}

- (void) manuallyAddChild:(Entry *)entry
{
    if (entry == nil)
        return;
    if (currentEntry == nil)
        return;
    if (entry == currentEntry)
        return;
    
    for (int i=0; i<[entry.parents count]; i++) {
        Entry* e = [entry.parents objectAtIndex:i];
        if (e == currentEntry) {
            return;
        }
    }
    
    NSString* str = @"nil";
    [currentEntry.childs addObject:entry];
    [currentEntry.childInfo addObject:str];
    [entry.parents addObject:currentEntry];
    [self startImgDraw];
    [self drawLineForEntry:currentEntry andChild:entry];
    if ([entry.parents count] == 1)
        [self drawEntry:entry andHighlighted:NO];
    [self endImgDraw];
}

- (void) manuallyAddParent:(Entry *)entry
{
    if (entry == nil)
        return;
    if (currentEntry == nil)
        return;
    if (entry == currentEntry)
        return;
    
    for (int i=0; i<[entry.childs count]; i++) {
        Entry* e = [entry.childs objectAtIndex:i];
        if (e == currentEntry) {
            return;
        }
    }
    
    NSString* str = @"nil";
    [currentEntry.parents addObject:entry];
    [entry.childs addObject:currentEntry];
    [entry.childInfo addObject:str];
    [self startImgDraw];
    [self drawLineForEntry:entry andChild:currentEntry];
    if ([currentEntry.parents count] == 1)
        [self drawEntry:currentEntry andHighlighted:YES];
    [self endImgDraw];
}

#pragma Draw functions

- (void) startImgDraw
{
    GLuint width = imageView.frame.size.width;
    GLuint height = imageView.frame.size.height;
    UIGraphicsBeginImageContext(imageView.frame.size);
    [imageView.image drawInRect:CGRectMake(0, 0, width, height)];
}

- (void) endImgDraw
{
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void) drawEntry:(Entry *)entry andHighlighted:(BOOL)highlight
{
    @autoreleasepool {
        CGContextRef context = UIGraphicsGetCurrentContext();
    
        CGRect rect = entry.rect;
        // calculate offst in imageview
        rect.origin.x += entryHead.rect.origin.x;
        rect.origin.y += entryHead.rect.origin.y;
        if (!highlight)
        {
            if (entryBackground == nil)
                self.entryBackground = [UIImage imageNamed:@"EntryBg.png"];
            [self drawImg:entryBackground andPoint:rect.origin];
            //CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.8 green:0.8 blue:0 alpha:1] CGColor]);
        }
        else
        {
            if (entryHBackbround == nil)
                self.entryHBackbround = [UIImage imageNamed:@"EntryHBg.png"];
            [self drawImg:entryHBackbround andPoint:rect.origin];
            //CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1] CGColor]);
        }
        //[self addRoundedRectToPath:context andRect:rect andWidth:10.0f andHeight:10.0f];
        //CGContextFillPath(context);
    
        //Draw text
        CGContextSetFillColorWithColor(context, [[UIColor darkTextColor] CGColor]);
        UIGraphicsPushContext(context);
        if (entry.filePath != nil)
        {
            NSString* fileName = [entry.filePath lastPathComponent];
            if ([entry getLine] >= 0)
                fileName = [fileName stringByAppendingFormat:@" : %d", [entry getLine]];
            [fileName drawAtPoint:CGPointMake(rect.origin.x+5, rect.origin.y)
                         forWidth:ENTRY_WIDTH
                         withFont:[UIFont boldSystemFontOfSize:15] 
                         lineBreakMode:UILineBreakModeClip];
        }
        if (entry.entryName != nil)
        {
            [entry.entryName drawAtPoint:CGPointMake(rect.origin.x+5, rect.origin.y+20)
                             forWidth:ENTRY_WIDTH
                             withFont:[UIFont boldSystemFontOfSize:15] 
                             lineBreakMode:UILineBreakModeClip];
        }
        UIGraphicsPopContext();
    
        //Draw caller arrow
        if ([entry.parents count] != 0)
        {
            NSString* arrow = @"➤";
            CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:1 green:1 blue:1 alpha:1] CGColor]);
            [arrow drawAtPoint:CGPointMake(rect.origin.x-10, rect.origin.y+rect.size.height/2-11)
                     forWidth:15
                     withFont:[UIFont boldSystemFontOfSize:18] 
                lineBreakMode:UILineBreakModeClip];
        }
    }
}

//Draw background
- (void) clearRect:(CGRect)rect
{
    @autoreleasepool {

    UIColor* color = nil;
    NSString*  bgcolor = [ThemeManager getDisplayBackgroundColor];
    if ([bgcolor length] != 7)
        bgcolor = @"#303040";
    bgcolor = [bgcolor substringFromIndex:1];
    unsigned int baseValue;
    if ([[NSScanner scannerWithString:bgcolor] scanHexInt:&baseValue])
    {
        color = UIColorFromRGB(baseValue);
    }
    if (color == nil)
    {
        bgcolor = @"#303040";
        if ([[NSScanner scannerWithString:bgcolor] scanHexInt:&baseValue])
        {
            color = UIColorFromRGB(baseValue);
        }
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) {
        return;
    }
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextBeginPath(context);
    CGContextFillRect(context, rect);
    CGContextStrokePath(context);
    }
}

- (void) drawHighlighted:(Entry *)entry
{
    UIImage* addChildImg = [UIImage imageNamed:@"ManuallAddChild.png"];
    UIImage* addParentImg = [UIImage imageNamed:@"manuallAddParent.png"];
    CGPoint parentPoint = entry.rect.origin;
    parentPoint.x += entryHead.rect.origin.x;
    parentPoint.y += entryHead.rect.origin.y;
    parentPoint.x -= addChildImg.size.width/2;
    parentPoint.y += entry.rect.size.height;
    CGPoint childPoint = entry.rect.origin;
    childPoint.x += entryHead.rect.origin.x;
    childPoint.y += entryHead.rect.origin.y;
    childPoint.x += (entry.rect.size.width-addParentImg.size.width/2);
    childPoint.y += entry.rect.size.height;
    [self startImgDraw];
    [self drawEntry:entry andHighlighted:YES];
    [self drawImg:addChildImg andPoint:childPoint];
    [self drawImg:addParentImg andPoint:parentPoint];
    [self endImgDraw];
}

-(void) deselectHighlighted:(Entry*)entry
{
    if (currentEntry != nil)
    {
        [self startImgDraw];
        [self drawEntry:currentEntry andHighlighted:NO];
        CGRect rect;
        rect.origin.x = entryHead.rect.origin.x + currentEntry.rect.origin.x - 35/2;
        rect.origin.y = entryHead.rect.origin.y + currentEntry.rect.origin.y + currentEntry.rect.size.height;
        rect.size.height = 22;
        rect.size.width = 35;
        [self clearRect:rect];
        rect.origin.x = entryHead.rect.origin.x + currentEntry.rect.origin.x + currentEntry.rect.size.width - 35/2;
        [self clearRect:rect];
        [self drawLinesForEntry:currentEntry andForParent:YES];
        [self endImgDraw];
    }
}

#pragma Touch event handlers
//Single touch
-(void) touchEvent:(CGPoint)point
{
    @autoreleasepool {
    Entry* entry = [self checkInChild:point];
    if (entry != currentEntry)
    {
        // currentEntry has been changed, so need to rest it
        [self.viewController setIsNeedGetResultFromCscope:NO];
        isNeedGetDefinition = NO;
    }
    if (entry != nil)
    {
        [self deselectHighlighted:currentEntry];
        [self drawHighlighted:entry];
        currentEntry = entry;
        [self showEntryButtonsForEntry:entry];
        
        if (entry.entryName!=nil && [entry getLine]!=-1)
        {
            NSString* line = [NSString stringWithFormat:@"%d", [entry getLine]];
            NSString* currentDisplayFile = [[Utils getInstance].detailViewController getCurrentDisplayFile];
            NSString* displayFile = [[Utils getInstance] getDisplayFileBySourceFile:entry.filePath];
            //highlight all children keyword after view loaded
            isNeedHighlightChildKeyword = YES;
            if ([currentDisplayFile compare:displayFile] == NSOrderedSame)
            {
                [[Utils getInstance].detailViewController gotoFile:entry.filePath andLine:line andKeyword:entry.entryName];
                [self highlightAllChildrenKeyword];
            }
            else
                [[Utils getInstance].detailViewController gotoFile:entry.filePath andLine:line andKeyword:entry.entryName];
        }
        else
        {
            if (entry.entryName != nil)
            {
                // we need to find the definition
                isNeedGetDefinition = YES;
                [self.viewController setIsNeedGetResultFromCscope:YES];
                NSString* name = entry.entryName;
                NSString* project = [[Utils getInstance] getProjectFolder:filePath];
                [[Utils getInstance] cscopeSearch:name andPath:entry.filePath andProject:project andType:FIND_GLOBAL_DEFINITION andFromVir:YES];
                return;
            }
            // it's a empty entry, we need to get it from source view by user click
            return;
        }
    }
    else
    {   
        if (currentEntry != nil)
        {
            [self deselectHighlighted:currentEntry];
            [viewController hideEntryButtons];
            currentEntry = nil;
        }
    }
    }
}

- (void) highlightAllChildrenKeyword
{
    if (currentEntry == nil)
        return;
    @autoreleasepool {

    NSString* childInfo;
    NSArray* array;
    for (int i=0; i<[currentEntry.childInfo count]; i++) {
        childInfo = [currentEntry.childInfo objectAtIndex:i];
        array = [childInfo componentsSeparatedByString:@":"];
        if ([array count] != 3)
            continue;
        NSString* name = [array objectAtIndex:1];
        NSString* line = [array objectAtIndex:2];
        NSString* js = [NSString stringWithFormat:@"highlight_this_line_keyword('L%@', '%@');", line, name];
        [[Utils getInstance].detailViewController.activeWebView stringByEvaluatingJavaScriptFromString:js];
    }
    isNeedHighlightChildKeyword = NO;
    }
}

- (void) storeImage
{
    UIImage* image = [imageView.image copy];
    [self setStoredImage:image];
}

- (void) restoreImage
{
    if (storedImage == nil)
        return;
    [imageView setImage:storedImage];
}

- (void) dragStart:(CGPoint)point
{
    Entry* e = [self checkInChild:point];
    dragType = DRAG_TYPE_NONE;
    if (e == nil)
    {
        currentDragEntry = nil;
        
        // check whether pressed button for manually add child/parent
        if (currentEntry != nil)
        {
            CGRect rect;
            rect.origin.x = entryHead.rect.origin.x + currentEntry.rect.origin.x - 35/2;
            rect.origin.y = entryHead.rect.origin.y + currentEntry.rect.origin.y + currentEntry.rect.size.height;
            rect.size.height = 30;
            rect.size.width = 35;
            
            if (CGRectContainsPoint(rect, point))
            {
                // manually add parent clicked
                dragType = DRAG_TYPE_ADD_PARENT;
                CGPoint p = rect.origin;
                p.y += 15;
                p.x +=5;
                lastDragPoint = p;
                [self storeImage];
            }
            else
            {
                rect.origin.x = entryHead.rect.origin.x + currentEntry.rect.origin.x + currentEntry.rect.size.width - 35/2;
                if (CGRectContainsPoint(rect, point)) {
                    // manually add child clicked
                    dragType = DRAG_TYPE_ADD_CHILD;
                    CGPoint p = rect.origin;
                    p.y += 15;
                    p.x += 30;
                    lastDragPoint = p;
                    [self storeImage];
                }
            }
            
        }
        return;
    }
    isDirty = YES;
    currentDragEntry = e;
    if (currentDragEntry == currentEntry)
    {
        [viewController hideEntryButtons];
    }
    else
    {
        [self startImgDraw];
        [self drawEntry:currentDragEntry andHighlighted:YES];
        [self endImgDraw];
    }
    [self storeImage];
    lastDragPoint = point;
}

- (void) dragEnd:(CGPoint)point
{
    // Here we are in manually add child/parent mode
    if (dragType != DRAG_TYPE_NONE)
    {
        Entry *entry = [self checkInChild:point];
        if (dragType == DRAG_TYPE_ADD_CHILD) {
            [self restoreImage];
            [self manuallyAddChild:entry];
        }
        else if (dragType == DRAG_TYPE_ADD_PARENT) {
            [self restoreImage];
            [self manuallyAddParent:entry];
        }
        dragType = DRAG_TYPE_NONE;
        return;
    }
    
    if (currentDragEntry == nil)
        return;
    
    [self checkBorder:currentDragEntry];
    if (![self calculateImageInfo:currentDragEntry.rect andPerformDraw:YES])
    {
        [self redrawAllEntrysAndLines];
    }
    currentDragEntry = nil;
}

- (void) handleDragEvent:(CGPoint)point
{
    if (dragType != DRAG_TYPE_NONE) {
        [self restoreImage];
        [self startImgDraw];
        if (dragType == DRAG_TYPE_ADD_CHILD) {
            [self drawLine:lastDragPoint andEnd:point];
        }
        else if (dragType == DRAG_TYPE_ADD_PARENT)
        {
            [self drawLine:point andEnd:lastDragPoint];
        }
        [self endImgDraw];
        return;
    }
    
    if (currentDragEntry == nil)
        return;
    [self restoreImage];
    CGRect rect = currentDragEntry.rect;
    rect.origin.x += (point.x - lastDragPoint.x);
    rect.origin.y += (point.y - lastDragPoint.y);
    currentDragEntry.rect = rect;
    [self startImgDraw];
    [self drawEntry:currentDragEntry andHighlighted:NO];
    [self endImgDraw];
    lastDragPoint = point;
}

#pragma Utils algorithms
-(Entry*) checkInChild:(CGPoint)point
{
    if (entryHead == nil)
        return nil;
    if (entryHead.childs == nil || [entryHead.childs count] == 0)
        return nil;
    for (int i = 0; i < entryHead.childs.count; i++)
    {
        Entry* e = [entryHead.childs objectAtIndex:i];
        CGRect rect = e.rect;
        rect.origin.x += entryHead.rect.origin.x;
        rect.origin.y += entryHead.rect.origin.y;
        if (CGRectContainsPoint(rect, point))
            return e;
    }
    return nil;
}

- (BOOL) calculateImageInfo:(CGRect)rect andPerformDraw:(BOOL)performDraw
{
    if (entryHead == nil)
    {
        NSLog(@"Error: calculateImageInfo");
    }
    else
    {
        CGRect originRect = entryHead.rect;
        float temp1 = 0;
        float temp2 = 0;
        BOOL needRedraw = NO;
        Entry* tmp;
        if (originRect.origin.x + rect.origin.x < IMAGE_MARGINE)
        {
            tmp = [entryHead.parents objectAtIndex:0];
            originRect.origin.x = IMAGE_MARGINE - tmp.rect.origin.x;
            needRedraw = YES;
        }
        if (originRect.origin.y + rect.origin.y < IMAGE_MARGINE)
        {
            tmp = [entryHead.parents objectAtIndex:1];
            originRect.origin.y = IMAGE_MARGINE - tmp.rect.origin.y;
            needRedraw = YES;
        }
        tmp = [entryHead.parents objectAtIndex:2];
        if (originRect.origin.x + tmp.rect.origin.x + tmp.rect.size.width + IMAGE_MARGINE > originRect.size.width)
        {
            temp1 = (originRect.origin.x + tmp.rect.origin.x + tmp.rect.size.width + IMAGE_MARGINE)/originRect.size.width;
        }
        tmp = [entryHead.parents objectAtIndex:3];
        if (originRect.origin.y + tmp.rect.origin.y + tmp.rect.size.height + IMAGE_MARGINE > originRect.size.height)
        {
            temp2 = (originRect.origin.y + tmp.rect.origin.y + tmp.rect.size.height + IMAGE_MARGINE)/originRect.size.height;
        }
        if (temp1>0 || temp2>0)
        {
            GLuint width = originRect.size.width;
            GLuint height = originRect.size.height;
            if (temp1>0)
                width = width * temp1;
            if (temp2>0)
                height = height * temp2;
            if ((width > MAX_IMAGE_SIZE && temp1>0) || (height > MAX_IMAGE_SIZE && temp2>0))
            {
                [[Utils getInstance] alertWithTitle:@"Warning!!" andMessage:@"Image size approaching the maximum size!"];
            }
            originRect.size.width = width;
            originRect.size.height = height;
            [entryHead setRect:originRect];
            CGRect tempRect = {0, 0, 0, 0};
            tempRect.size = originRect.size;
            [imageView setFrame:tempRect];
            [scrollView setContentSize:tempRect.size];
            if (performDraw)
                [self redrawAllEntrysAndLines];
            return YES;
        }
        if (needRedraw)
        {
            [entryHead setRect:originRect];
            if (performDraw)
                [self redrawAllEntrysAndLines];
            return YES;
        }
    }
    return NO;
}

-(void) showEntryButtonsForEntry:(Entry *)entry
{
    if (entry == nil)
        return;
    CGPoint point = entry.rect.origin;
    point.x += entryHead.rect.origin.x;
    point.y += entryHead.rect.origin.y;
    [viewController showEntryButtons:point];
}

-(void) redrawAllEntrysAndLines
{
    int count = [entryHead.childs count];
    Entry* entry;
    [self startImgDraw];
    [self clearRect:imageView.frame];
    for (int i=0; i<count; i++)
    {
        entry = [entryHead.childs objectAtIndex:i];
        [self drawEntry:entry andHighlighted:NO];
        [self drawLinesForEntry:entry andForParent:NO];
    }
    [self endImgDraw];
    
    if (currentEntry == nil)
        return;
    [self drawHighlighted:currentEntry];
    [self showEntryButtonsForEntry:currentEntry];
}

-(void) drawLinesForEntry:(Entry *)entry andForParent:(BOOL)fp
{
    if (entry == nil)
        return;
    int count = [entry.childs count];
    Entry* child;
    for (int i=0; i<count; i++)
    {
        child = [entry.childs objectAtIndex:i];
        [self drawLineForEntry:entry andChild:child];
    }
    if (fp == YES)
    {
        count = [entry.parents count];
        Entry* parent;
        for (int i=0; i<count; i++) {
            parent = [entry.parents objectAtIndex:i];
            [self drawLineForEntry:parent andChild:entry];
        }
    }
}

-(void) drawLineForEntry:(Entry *)parent andChild:(Entry *)child
{
    CGPoint start, end;
    start.x = parent.rect.origin.x+parent.rect.size.width+entryHead.rect.origin.x;
    start.y = parent.rect.origin.y+parent.rect.size.height/2+entryHead.rect.origin.y;
    end.x = child.rect.origin.x+entryHead.rect.origin.x;
    end.y = child.rect.origin.y+child.rect.size.height/2+entryHead.rect.origin.y;
    [self drawLine:start andEnd:end];
}

-(void) drawLine:(CGPoint)start andEnd:(CGPoint)end
{
    @autoreleasepool {
    int extension = 30;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, BORDER_WIDTH);
    
    if (start.x > end.x)
        extension = 30+(start.x-end.x)/5;
    
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:1 green:1 blue:1 alpha:1] CGColor]);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context,start.x,start.y);
    CGContextAddCurveToPoint(context, start.x, start.y, start.x+extension, start.y, (start.x+end.x)/2, (start.y+end.y)/2);
    CGContextAddCurveToPoint(context, (start.x+end.x)/2, (start.y+end.y)/2, end.x-extension, end.y, end.x, end.y);
    CGContextDrawPath(context,kCGPathStroke);
    }
}

- (void) drawImg:(UIImage *)image andPoint:(CGPoint)point
{
    @autoreleasepool {
        [image drawInRect:CGRectMake(point.x, point.y, image.size.width, image.size.height)];
    }
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

- (void) setNeedhighlightChildKeyword:(BOOL)b
{
    isNeedHighlightChildKeyword = b;
}

- (BOOL) isNeedHighlightChildKeyword
{
    return isNeedHighlightChildKeyword;
}

- (BOOL) checkWhetherExistInCurrentEntry:(NSString *)name andLine:(NSString*)line
{
    @autoreleasepool {

    if (isNeedGetDefinition == YES)
        return NO;
    
    // we need to get entry head first for new file
    if (entryHead == nil)
        return NO;
        
    //For exception
    if (currentEntry == nil)
        return YES;
    
    if (newEntryType == NEW_ENTRY_CHILD)
    {
        for (int i=0; i<[currentEntry.childInfo count]; i++)
        {
            NSString* childInfo = [currentEntry.childInfo objectAtIndex:i];
            NSArray* array = [childInfo componentsSeparatedByString:@":"];
            if ([name compare:[array objectAtIndex:1]] == NSOrderedSame &&
                [line compare:[array objectAtIndex:2]] == NSOrderedSame)
                return YES;
        }
    }
    else if (newEntryType == NEW_ENTRY_PARENT)
    {
        for (int j=0; j<[currentEntry.parents count]; j++)
        {
            Entry* entry = [currentEntry.parents objectAtIndex:j];
            for (int i=0; i<[entry.childInfo count]; i++)
            {
                NSString* childInfo = [entry.childInfo objectAtIndex:i];
                NSArray* array = [childInfo componentsSeparatedByString:@":"];
                if ([name compare:[array objectAtIndex:1]] == NSOrderedSame &&
                    [line compare:[array objectAtIndex:2]] == NSOrderedSame)
                    return YES;
            }
        }
    }
    }
    return NO;
}

- (void)deleteCurrentEntry
{
    if (currentEntry != nil)
        [self deleteEntry:currentEntry];
}

- (void)deleteEntry:(Entry *)entry
{
    isDirty = YES;
    
    Entry* child;
    // delete it's own from child's parent array
    for (int i=0; i<[entry.childs count]; i++)
    {
        child = [entry.childs objectAtIndex:i];
        [child.parents removeObject:entry];
    }
    [entry.childs removeAllObjects];
    [entry.childInfo removeAllObjects];
    
    // delete parents info
    Entry* parent;
    for (int i=0; i<[entry.parents count]; i++)
    {
        parent = [entry.parents objectAtIndex:i];
        for (int j=0; j<[parent.childs count]; j++)
        {
            if ([parent.childs objectAtIndex:j] == entry)
            {
                [parent.childs removeObjectAtIndex:j];
                [parent.childInfo removeObjectAtIndex:j];
                break;
            }
        }
    }
    [entry.parents removeAllObjects];
        
    // remove from entryHead
    [entryHead.childs removeObject:entry];
    [self setCurrentEntry:nil];
    
    [viewController hideEntryButtons];
    [self redrawAllEntrysAndLines];
}

- (void)saveToFile
{
    @autoreleasepool {
    
    [self deselectHighlighted:currentEntry];
    [viewController hideEntryButtons];
    currentEntry = nil;
    isDirty = NO;
        
    //format all entrys
    for (int i=0; i<[entryHead.childs count]; i++)
    {
        Entry* entry = [entryHead.childs objectAtIndex:i];
        [entry set_id:i];
    }
    
    /*
     ViewPort;;size
     Version;;1
     ----
     id;;**
     entryName;;***
     filePath;;***
     childInfo;;**:**;-;**:**
     parents;;*,*,*
     childs;;*,*,*
     rect;;
     line::**
     */
    
    NSMutableString* contents = [[NSMutableString alloc] init];
    NSError *error;
    
    //add version
    [contents appendFormat:@"Version;;%d",VERSION];
    [contents appendString:ENTRY_DIVIDER];
    
    //add Viewport size
    [contents appendFormat:@"ViewPort;;%f,%f,%f,%f", entryHead.rect.origin.x, entryHead.rect.origin.y, entryHead.rect.size.width, entryHead.rect.size.height];
    [contents appendString:ENTRY_DIVIDER];
    
    //add entrys
    for (int i=0; i<[entryHead.childs count]; i++)
    {
        Entry* entry = [entryHead.childs objectAtIndex:i];
        // id
        [contents appendFormat:@"id;;%d", entry._id];
        [contents appendString:DIVIDER];
        
        //entryName
        [contents appendFormat:@"entryName;;%@", entry.entryName];
        [contents appendString:DIVIDER];
        
        //filePath
        [contents appendFormat:@"filePath;;%@", [[Utils getInstance] getPathFromProject:entry.filePath]];
        [contents appendString:DIVIDER];
        
        //childInfo
        [contents appendString:@"childInfo;;"];
        for (int j=0; j<[entry.childInfo count]; j++)
        {
            [contents appendString:[entry.childInfo objectAtIndex:j]];
            [contents appendString:@";-;"];
        }
        [contents appendString:DIVIDER];
        
        //parents
        [contents appendString:@"parents;;"];
        for (int j=0; j<[entry.parents count]; j++)
        {
            Entry* e = [entry.parents objectAtIndex:j];
            [contents appendFormat:@"%d,",e._id];
        }
        [contents appendString:DIVIDER];
        
        //childs
        [contents appendString:@"childs;;"];
        for (int j=0; j<[entry.childs count]; j++)
        {
            Entry* e = [entry.childs objectAtIndex:j];
            [contents appendFormat:@"%d,",e._id];
        }
        [contents appendString:DIVIDER];
        
        //rect
        [contents appendFormat:@"rect;;%f,%f,%f,%f", entry.rect.origin.x, entry.rect.origin.y, entry.rect.size.width, entry.rect.size.height];
        [contents appendString:DIVIDER];
        
        //line
        [contents appendFormat:@"line;;%d", [entry getLine]];
        
        [contents appendString:ENTRY_DIVIDER];
    }
    
    [contents writeToFile:[filePath stringByAppendingPathExtension:@"lgz_virtualize"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSData* data = UIImageJPEGRepresentation(imageView.image, 1.0);
    NSString* imageFile = [[filePath stringByDeletingPathExtension] stringByAppendingString:@".lgz_vir_img"];
    [data writeToFile:imageFile atomically:YES];
        imageFile = nil;
        data = nil;
    }
    [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Save completed"];
}

- (void) readFromContent:(NSString *)contents
{
    @autoreleasepool {

    NSArray* array = [contents componentsSeparatedByString:ENTRY_DIVIDER];
    if ([array count] < 2)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"File format error"];
        return;
    }
    
    NSArray* tmpArray;
    NSString* tmpContent;
    CGRect rect;

    //Version
    tmpContent = [array objectAtIndex:0];
    tmpArray = [tmpContent componentsSeparatedByString:@";;"];
    if ([tmpArray count] != 2 || [(NSString*)[tmpArray objectAtIndex:0] compare:@"Version"] != NSOrderedSame)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"File format error"];
        return;
    }
    tmpContent = [tmpArray objectAtIndex:1];
    if ([tmpContent intValue] != VERSION)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"File version error"];
        return;
    }
    
    //viewPort
    tmpContent = [array objectAtIndex:1];
    tmpArray = [tmpContent componentsSeparatedByString:@";;"];
    if ([tmpArray count] != 2 || [(NSString*)[tmpArray objectAtIndex:0] compare:@"ViewPort"] != NSOrderedSame)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"File format error"];
        return;
    }
    tmpContent = [tmpArray objectAtIndex:1];
    tmpArray = [tmpContent componentsSeparatedByString:@","];
    if ([tmpArray count] != 4)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"File format error"];
        return;
    }
    entryHead = [[Entry alloc] init];
    rect.origin.x = [(NSString*)[tmpArray objectAtIndex:0] floatValue];
    rect.origin.y = [(NSString*)[tmpArray objectAtIndex:1] floatValue];
    rect.size.width = [(NSString*)[tmpArray objectAtIndex:2] floatValue];
    rect.size.height = [(NSString*)[tmpArray objectAtIndex:3] floatValue];
    entryHead.rect = rect;
    self.entryHead.childs = [[NSMutableArray alloc] init];
    self.entryHead.parents = [[NSMutableArray alloc] init];
    [self setCurrentEntry:nil];
    [self setCurrentDragEntry:nil];
    [self setStoredImage:nil];
    isNeedHighlightChildKeyword = NO;
        
    // entrys
    NSString* tmp;
    NSArray* tmpArray2;
    for (int i=2; i<[array count]; i++)
    {
        Entry* entry = [[Entry alloc] init];
        entry.childs = [[NSMutableArray alloc] init];
        entry.parents = [[NSMutableArray alloc] init];
        entry.childInfo = [[NSMutableArray alloc] init];
        tmpContent = [array objectAtIndex:i];
        tmpArray = [tmpContent componentsSeparatedByString:DIVIDER];
        if ([tmpArray count] < 8)
            continue;

        //id
        tmp = [tmpArray objectAtIndex:0];
        tmpArray2 = [tmp componentsSeparatedByString:@";;"];
        if ([tmpArray2 count] != 2)
            continue;
        if ([(NSString*)[tmpArray2 objectAtIndex:0] compare:@"id"] != NSOrderedSame)
            continue;
        [entry set_id:[(NSString*)[tmpArray2 objectAtIndex:1] intValue]];
        
        //entryName
        tmp = [tmpArray objectAtIndex:1];
        tmpArray2 = [tmp componentsSeparatedByString:@";;"];
        if ([tmpArray2 count] != 2)
            continue;
        if ([(NSString*)[tmpArray2 objectAtIndex:0] compare:@"entryName"] != NSOrderedSame)
            continue;
        [entry setEntryName:[tmpArray2 objectAtIndex:1]];
         
        //filePath
        tmp = [tmpArray objectAtIndex:2];
        tmpArray2 = [tmp componentsSeparatedByString:@";;"];
        if ([tmpArray2 count] != 2)
            continue;
        if ([(NSString*)[tmpArray2 objectAtIndex:0] compare:@"filePath"] != NSOrderedSame)
            continue;
        tmp = [tmpArray2 objectAtIndex:1];
        if (!(tmp == nil || [tmp length] == 0))
        {
            tmp = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/Projects"];
            tmp = [tmp stringByAppendingPathComponent:[tmpArray2 objectAtIndex:1]];
            [entry setFilePath:tmp];
        }
        else
            [entry setFilePath:nil];
        
        //childInfo
        tmp = [tmpArray objectAtIndex:3];
        tmpArray2 = [tmp componentsSeparatedByString:@";;"];
        if ([tmpArray2 count] != 2)
            continue;
        if ([(NSString*)[tmpArray2 objectAtIndex:0] compare:@"childInfo"] != NSOrderedSame)
            continue;
        NSString* tmp2 = [tmpArray2 objectAtIndex:1];
        NSArray* tmpArray3 = [tmp2 componentsSeparatedByString:@";-;"];
        for (int j=0; j<[tmpArray3 count]; j++)
        {
            NSString* str = [tmpArray3 objectAtIndex:j];
            if (str == nil || [str length] == 0)
                continue;
            [entry.childInfo addObject:str];
        }
        
        //parents
        tmp = [tmpArray objectAtIndex:4];
        tmpArray2 = [tmp componentsSeparatedByString:@";;"];
        if ([tmpArray2 count] != 2)
            continue;
        if ([(NSString*)[tmpArray2 objectAtIndex:0] compare:@"parents"] != NSOrderedSame)
            continue;
        tmp2 = [tmpArray2 objectAtIndex:1];
        tmpArray3 = [tmp2 componentsSeparatedByString:@","];
        for (int j=0; j<[tmpArray3 count]; j++)
        {
            NSString* str = [tmpArray3 objectAtIndex:j];
            if (str == nil || [str length] == 0)
                continue;
            [entry.parents addObject:str];
        }
        
        //childs
        tmp = [tmpArray objectAtIndex:5];
        tmpArray2 = [tmp componentsSeparatedByString:@";;"];
        if ([tmpArray2 count] != 2)
            continue;
        if ([(NSString*)[tmpArray2 objectAtIndex:0] compare:@"childs"] != NSOrderedSame)
            continue;
        tmp2 = [tmpArray2 objectAtIndex:1];
        tmpArray3 = [tmp2 componentsSeparatedByString:@","];
        for (int j=0; j<[tmpArray3 count]; j++)
        {
            NSString* str = [tmpArray3 objectAtIndex:j];
            if (str == nil || [str length] == 0)
                continue;
            [entry.childs addObject:str];
        }
        
        //rect
        tmp = [tmpArray objectAtIndex:6];
        tmpArray2 = [tmp componentsSeparatedByString:@";;"];
        if ([tmpArray2 count] != 2)
            continue;
        if ([(NSString*)[tmpArray2 objectAtIndex:0] compare:@"rect"] != NSOrderedSame)
            continue;
        tmp2 = [tmpArray2 objectAtIndex:1];
        tmpArray3 = [tmp2 componentsSeparatedByString:@","];
        rect.origin.x = [[tmpArray3 objectAtIndex:0] floatValue];
        rect.origin.y = [[tmpArray3 objectAtIndex:1] floatValue];
        rect.size.width = [[tmpArray3 objectAtIndex:2] floatValue];
        rect.size.height = [[tmpArray3 objectAtIndex:3] floatValue];
        [entry setRect:rect];
        
        tmp = [tmpArray objectAtIndex:7];
        tmpArray2 = [tmp componentsSeparatedByString:@";;"];
        if ([tmpArray2 count] != 2)
            continue;
        if ([(NSString*)[tmpArray2 objectAtIndex:0] compare:@"line"] != NSOrderedSame)
            continue;
        tmp2 = [tmpArray2 objectAtIndex:1];
        [entry setLine:[tmp2 intValue]];
        
        [entryHead.childs addObject:entry];
    }
    
    for (int i=0; i<[entryHead.childs count]; i++)
    {
        Entry* entry = [entryHead.childs objectAtIndex:i];
        [self checkBorder:entry];
        NSMutableArray* childs = [[NSMutableArray alloc] init];
        for (int j=0; j<[entry.childs count]; j++)
        {
            int index = [[entry.childs objectAtIndex:j] intValue];
            [childs addObject:[entryHead.childs objectAtIndex:index]];
        }
        [entry setChilds:childs];
        
        NSMutableArray* parents = [[NSMutableArray alloc] init];
        for (int k=0; k<[entry.parents count]; k++)
        {
            int index = [[entry.parents objectAtIndex:k] intValue];
            [parents addObject:[entryHead.childs objectAtIndex:index]];
        }
        [entry setParents:parents];
    }
    }
}

- (BOOL) isDirty
{
    return isDirty;
}

@end


