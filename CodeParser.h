#import <Foundation/Foundation.h>

@interface CodeParser : NSObject
{
	NSString* fileContent;
	NSMutableString* htmlContent;
    NSString* projectBase;
}

-(void) setFile:(NSString*) name andProjectBase:(NSString*) base;

-(BOOL) startParse;

-(BOOL) isProjectDefinedWord:(NSString*) word;

// ---------------- HTML Components ------------------- 

-(void) parseLine: (NSString*) line lineNum:(int)lineNumber;

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
                                                       
-(void) lineStart: (int)num;
                                                      
-(void) lineEnd;
                            
-(void) addEnd;

// ---------------- HTML Components End ------------------- 

// ---------------- Common Components ------------------- 

-(int) getNextSpaceIndex:(NSMutableString*) content;

// ---------------- Common Components  END ------------------- 

@end
