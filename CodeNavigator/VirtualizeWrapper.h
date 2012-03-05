//
//  VirtualizeWrapper.h
//  CodeNavigator
//
//  Created by Guozhen Li on 2/6/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BORDER_WIDTH 3
#define ENTRY_WIDTH 170
#define ENTRY_HEIGHT 40
#define IMAGE_MARGINE 50
#define ENTRYS_MARGINE 50
#define VERSION 1
#define DIVIDER @"\n--lgz--divider--\n"
#define ENTRY_DIVIDER @"\n--lgz--entry--end\n"
#define MAX_IMAGE_SIZE 1536

@class VirtualizeViewController;

typedef enum _NewEntryType
{
    NEW_ENTRY_PARENT,
    NEW_ENTRY_CHILD
} NewEntryType;

typedef enum _DragType
{
    DRAG_TYPE_ADD_CHILD,
    DRAG_TYPE_ADD_PARENT,
    DRAG_TYPE_NONE
} DragType;

@interface Entry : NSObject {
    int line;
}

@property (assign, nonatomic) BOOL _id;
@property (strong, nonatomic) NSString* entryName;
@property (strong, nonatomic) NSString* filePath;
@property (strong, nonatomic) NSMutableArray* childInfo;//name:line
@property (strong, nonatomic) NSMutableArray* parents;//caller | entryhead: 0: most left 1: most top 2: most right 3:most bottom
@property (strong, nonatomic) NSMutableArray* childs;//calls | entryhead: all children sorted by id
@property (assign, nonatomic) CGRect rect;// entryHead: origin stores offset, size stores size

-(void) setLine:(int)l;

-(int) getLine;

@end

@interface VirtualizeWrapper : NSObject
{
    DragType dragType;
    NewEntryType newEntryType;
    CGPoint lastDragPoint;
    BOOL isNeedHighlightChildKeyword;
    BOOL isDirty;
}

@property (strong, nonatomic) NSString* filePath;

@property (strong, nonatomic) Entry* entryHead;

@property (assign, nonatomic) Entry* currentEntry;

@property (assign, nonatomic) Entry* currentDragEntry;

@property (assign, nonatomic) UIImageView* imageView;

@property (assign, nonatomic) UIScrollView* scrollView;

@property (strong, nonatomic) UIImage* storedImage;

@property (assign, nonatomic) VirtualizeViewController* viewController;

@property (assign, nonatomic) BOOL isNeedGetDefinition;

@property (strong, nonatomic) UIImage* entryBackground;

@property (strong, nonatomic) UIImage* entryHBackbround;

- (void) setNeedhighlightChildKeyword:(BOOL)b;

- (BOOL) isNeedHighlightChildKeyword;

- (void) openFile;

- (void) setNewEntryType:(NewEntryType)_type;

- (NewEntryType) getNewEntryType;

- (void) addEntry:(NSString*)entry andFile:(NSString*)file andLine:(int)line;


- (void) drawEntry:(Entry*) entry andHighlighted:(BOOL)highlight;

- (void) touchEvent:(CGPoint)point;

- (void) clearRect:(CGRect)rect;

- (Entry*) checkInChild:(CGPoint)point;

- (void) storeImage;

- (void) restoreImage;

- (void) dragStart:(CGPoint)point;

- (void) dragEnd:(CGPoint)point;

- (void) handleDragEvent:(CGPoint)point;

- (BOOL) calculateImageInfo:(CGRect)rect andPerformDraw:(BOOL)performDraw;

- (void) showEntryButtonsForEntry:(Entry*)entry;

- (void) redrawAllEntrysAndLines;

- (void) drawLine:(CGPoint)start andEnd:(CGPoint)end;

- (void) drawLinesForEntry:(Entry*)entry andForParent:(BOOL)fp;

- (void) drawLineForEntry:(Entry*)parent andChild:(Entry*)child;

- (void) addRoundedRectToPath:(CGContextRef) context andRect: (CGRect) rect andWidth:(float) ovalWidth andHeight:(float) ovalHeight;

- (void) highlightAllChildrenKeyword;

- (BOOL) checkWhetherExistInCurrentEntry:(NSString*)name andLine:(NSString*)line;

- (void) deleteEntry:(Entry*)entry;

- (void) deleteCurrentEntry;

- (void) saveToFile;

- (void) readFromContent:(NSString*)contents;

- (void) releaseAllEntrys;

- (void) deselectHighlighted:(Entry*)entry;

- (BOOL) isDirty;

- (void) startImgDraw;

- (void) endImgDraw;

- (void) addEmptyEntry;

- (void) manuallyAddChild:(Entry*)entry;

- (void) manuallyAddParent:(Entry*)entry;

- (void) drawImg:(UIImage*) image andPoint:(CGPoint)point;

@end
