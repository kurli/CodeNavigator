//
//  CommentWrapper.h
//  CodeNavigator
//
//  Created by Guozhen Li on 5/9/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentItem : NSObject

@property (nonatomic, strong) NSString* userName;

@property (nonatomic, unsafe_unretained) int time;

@property (nonatomic, unsafe_unretained) int line;

@property (nonatomic, strong) NSString* comment;

@end

@interface CommentWrapper : NSObject

@property (nonatomic, strong) NSMutableArray* commentArray;

@property (nonatomic, strong) NSString* filePath;

-(void)readFromFile:(NSString*)path;

-(void)addComment:(int)line andComment:(NSString*)comment;

-(void)saveToFile;

-(NSString*) getCommentByLine:(int)line;

@end
