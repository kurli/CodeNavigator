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

@property (nonatomic, unsafe_unretained) NSInteger line;

@property (nonatomic, strong) NSString* comment;

@property (nonatomic, strong) NSString* group;

@end

@interface CommentWrapper : NSObject

@property (nonatomic, strong) NSMutableArray* commentArray;

@property (nonatomic, strong) NSString* filePath;

@property (nonatomic, strong) NSMutableArray* groups;

-(void)readFromFile:(NSString*)path;

-(void)addComment:(NSInteger)line andComment:(NSString*)comment andGroup:(NSString*)group;

-(void)saveToFile;

-(NSString*) getCommentByLine:(NSInteger)line;

-(BOOL) isCommentExistsByGroup:(NSString*) group;

-(NSArray*) getCommentsByGroup:(NSString*) group;

-(NSString*) getCommentGroupByLine:(NSInteger)line;

-(BOOL) removeGroup:(NSInteger) index;

-(BOOL) removeFile:(NSInteger) index;

-(BOOL) removeComment:(NSInteger)index;

@end
