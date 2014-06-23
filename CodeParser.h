#import <Foundation/Foundation.h>

#define MAX_CHAR_IN_LINE 80
#define BREAK_STR @"lgz_BR_lgz"
#define BUILDIN_PARSER_PATH @"/Documents/.settings/BuildInParser"

typedef void (^ParseFinishedCallback)();

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
    BOOL withHeaderAndEnder;
}

@property (nonatomic, strong) NSDictionary* parserConfig;

@property (nonatomic, strong) NSString* parserConfigName;

@property (strong, atomic) NSArray* tagsArray;

@property (strong, atomic) NSString* filePath;

-(void) setFile:(NSString*) name andProjectBase:(NSString*) base;

-(void) setContent:(NSString*) content andProjectBase:(NSString*) base;

-(void) setMaxLineCount:(int)max;

-(BOOL) isStringOrCommentsEnded;

-(BOOL) startParse:(ParseFinishedCallback)onParseFinished;

-(BOOL) parseToHtml;

-(BOOL) startParseAndWait;

-(BOOL) isProjectDefinedWord:(NSString*) word;

-(void) setWithHeaderAndEnder:(BOOL)enable;

// ---------------- Parser related interface -------------------
-(BOOL) checkCommentsLine;

-(BOOL) checkPreprocessor:(int) lineNumber;

-(void) parseLine: (NSString*) line lineNum:(int)lineNumber;

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

-(void) addRawHtml:(NSString*) html;

// ---------------- HTML Components End ----------------------

// ---------------- Common Components ------------------------

-(int) getNextSpaceIndex:(NSMutableString*) content;

// ---------------- Common Components  END -------------------

// ----------------- Parser Config ---------------------------
//-(NSDictionary*) getParserByName:(NSString *)name;

-(NSString*) getExtentionsStr;

-(NSString*) getSingleLineCommentsStr;

-(NSString*) getMultiLineCommentsStartStr;

-(NSString*) getMultiLineCommentsEndStr;

-(NSString*) getKeywordsStr;

-(NSString*) getParserName;
// ----------------- Parser Config END -----------------------

@end
