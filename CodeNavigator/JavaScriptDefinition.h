//
//  CSharpDefinition.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/23/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#ifndef CodeNavigator_JavaScriptDefinition_h
#define CodeNavigator_JavaScriptDefinition_h

/*
 *  JavaScriptDefinition.h
 *  CodeNavaigatorAlg
 *
 *  Created by Guozhen Li on 6/26/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#define COMMENTS_SINGLE @"//"

#define COMMENTS_MULTI @"/*"

#define COMMENTS_MULTI_END @"*/"

#define BRACE_START @"{"

#define BRACE_END @"}"

#define KEYWORD_JAVASCRIPT @"abstract boolean break byte case catch char class const continue debugger default delete do double else enum export extends false final finally float for function goto if implements import in instanceof int interface long native new null package private protected public return short static super switch synchronized this throw throws transient true try typeof var void volatile while with"

#define PREPROCESSOR @"#define",@"#if",@"#ifdef",@"#undef",@"#endif",@"#else",@"#pragma",@"#ifndef", @"#elif", @"#error", @"#region", @"#endregion", nil

#define PREPROCESSOR_HEADER @"#"

#define HEADER_KEYWORD @"include"

#define HEADER_KEYWORD2 @"import"

#define MAGIC_NUMBER @"-&*$|"

#endif
