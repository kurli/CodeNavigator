//
//  FunctionListManager.h
//  CodeNavigator
//
//  Created by Guozhen Li on 10/21/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"

typedef enum _FunctionItemType{
    FUNCTION_ITEM_,
} FunctionItemType;

@interface FunctionItem : NSObject

//@property (assign, nonatomic) FunctionItemType type;

@property (strong, nonatomic) NSString* name;

@property (assign, nonatomic) int line;

@property (strong, nonatomic) NSString* type;

@end

@interface FunctionListManager : NSObject

@property (strong, nonatomic) GetFunctionListCallback callback;

@property (nonatomic, strong) NSThread* ctagsThread;

@property (strong, atomic) NSString* path;

-(void) getFunctionListForFile:(NSString*)path andCallback:(GetFunctionListCallback)cb;

@end
