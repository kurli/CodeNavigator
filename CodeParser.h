#import <Foundation/Foundation.h>

#define MAX_CHAR_IN_LINE 80
#define BREAK_STR @"lgz_BR_lgz"

@interface CodeParser : NSObject
{
	NSString* fileContent;
	NSMutableString* htmlContent;
    NSString* projectBase;
    
    // Parse related
    BOOL isCommentsNotEnded;
	NSMutableString* needParseLine;
    BOOL isStringNotEnded;
    NSArray* keywordsArray;
    NSArray* preprocessorArray;
    
    //Braces ralated
    NSMutableArray* bracesArray;
    
    //current parse line
    int currentParseLine;
    
    int maxLineCount;
}

-(void) setFile:(NSString*) name andProjectBase:(NSString*) base;

-(void) setContent:(NSString*) content andProjectBase:(NSString*) base;

-(void) setMaxLineCount:(int)max;

-(BOOL) startParse;

-(BOOL) isProjectDefinedWord:(NSString*) word;

// ---------------- Parser related interface -------------------
-(BOOL) checkCommentsLine;

-(BOOL) checkPreprocessor:(int) lineNumber;

-(void) parseLine: (NSString*) line lineNum:(int)lineNumber;

-(BOOL) checkCommentsLine;

-(BOOL) checkPreprocessor:(int) lineNumber;

-(BOOL) checkString;

-(BOOL) checkChar;

-(BOOL) checkOthers: (int)lineNumber;

-(void) bracesStarted:(int)lineNumber andToken:(NSString*)token;

-(void) bracesEnded:(int)lineNumber andToken:(NSString*)token;

-(BOOL) checkIsKeyword: (NSString*) word;

// end

// ---------------- HTML Components ------------------- 

-(void) commentStart;

-(void) headerStart;

-(void) stringStart;

-(void) keywordStart;

-(void) otherWordStart;

-(void) addHead;

-(void) addBlankLine;

-(NSString*) getHtml;

-(void) addLink:(NSString*) name type:(NSString*) type;

-(void) addLinkEnd;

-(void) addString: (NSString*)content addEnter: (BOOL)addEnter;

-(void) addUnknownLine: (NSString*)content;
                                                       
-(void) lineStart: (int)num andContent:(NSString*)lineContent;
                                                      
-(void) lineEnd;

-(void) addImage:(NSString*)imgPath;

-(void) addEnd;

-(void) systemStart;

-(void) numberStart;

// ---------------- HTML Components End ------------------- 

// ---------------- Common Components ------------------- 

-(int) getNextSpaceIndex:(NSMutableString*) content;

// ---------------- Common Components  END ------------------- 

@end
