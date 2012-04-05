//
//  ObjectiveCDefinition.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/22/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#ifndef CodeNavigator_ObjectiveCDefinition_h
#define CodeNavigator_ObjectiveCDefinition_h


#define COMMENTS_SINGLE @"//"

#define COMMENTS_MULTI @"/*"

#define COMMENTS_MULTI_END @"*/"

#define BRACE_START @"{"

#define BRACE_END @"}"

#define KEYWORD_OBJ @"char bool BOOL double float int long short id void IBAction IBOutlet SEL YES NO readwrite readonly nonatomic retain assign readonly getter setter nil NULL super self copy break case catch class const copy __finally __exception __try const_cast continue private public protected __declspec default delete deprecated dllexport dllimport do dynamic_cast else enum explicit extern if for friend goto inline mutable naked namespace new noinline noreturn nothrow register reinterpret_cast return selectany sizeof static static_cast struct switch template this thread throw true false try typedef typeid typename union using uuid virtual volatile whcar_t while unsigned strong unsafe_unretained"

#define PREPROCESSOR @"#define",@"#if",@"#ifdef",@"#undef",@"#endif",@"#else",@"#pragma",@"#ifndef", @"#elif", @"#error", nil

#define PREPROCESSOR_HEADER @"#"

#define HEADER_KEYWORD @"include"

#define HEADER_KEYWORD2 @"import"

#define MAGIC_NUMBER @"-&*$|"


#endif
