/*
 *  CPlusPlusDefination.h
 *  CodeNavaigatorAlg
 *
 *  Created by Guozhen Li on 6/26/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#define COMMENTS_SINGLE @"//"

#define COMMENTS_MULTI @"/*"

#define COMMENTS_MULTI_END @"*/"

#define KEYWORD_OBJS @"asm",@"auto",@"bool",@"break",@"case",@"catch",@"char",@"class",@"const",@"const_cast",@"continue",@"default",@"delete",@"do",@"double",@"dynamic_cast",@"else",@"enum",@"explicit",@"extern",@"false",@"float",@"for",@"friend",@"goto",@"if",@"inline",@"int",@"long",@"mutable",@"namespace",@"new",@"operator",@"private",@"protected",@"public",@"register",@"reinterpret_cast",@"return",@"short",@"signed",@"sizeof",@"static",@"static_cast",@"struct",@"switch",@"template",@"this",@"throw",@"true",@"try",@"typedef",@"typeid",@"typename",@"union",@"unsigned",@"using",@"virtual",@"void",@"volatile",@"wchar_t",@"while", nil

#define PREPROCESSOR @"#define",@"#if",@"#ifdef",@"#undef",@"#endif",@"#else",@"#pragma",@"#ifndef", nil

#define PREPROCESSOR_HEADER @"#"

#define HEADER_KEYWORD @"include"

#define MAGIC_NUMBER @"-&*$|"

typedef enum _PREPROCESSOR_TYPE{
	PREPROCESSOR_DEFINE = 0,
} PREPROCESSOR_TYPE;