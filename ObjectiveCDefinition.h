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

#define KEYWORD_OBJ @"BOOL IBAction IBOutlet NO NULL SEL YES __declspec __exception __finally __try assign bool break case catch char class const const_cast continue copy copy default delete deprecated dllexport dllimport do double dynamic_cast else enum explicit extern false float for friend getter goto id if inline int long mutable naked namespace new nil noinline nonatomic noreturn nothrow private protected public readonly readonly readwrite register reinterpret_cast retain return selectany self setter short sizeof static static_cast strong struct super switch template this thread throw true try typedef typeid typename union unsafe_unretained unsigned using uuid virtual void volatile whcar_t while"

#define PREPROCESSOR @"#define",@"#if",@"#ifdef",@"#undef",@"#endif",@"#else",@"#pragma",@"#ifndef", @"#elif", @"#error", nil

#define PREPROCESSOR_HEADER @"#"

#define HEADER_KEYWORD @"include"

#define HEADER_KEYWORD2 @"import"

#define MAGIC_NUMBER @"-&*$|"


#endif
