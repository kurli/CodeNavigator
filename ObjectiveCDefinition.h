//
//  ObjectiveCDefinition.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/22/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#ifndef CodeNavigator_ObjectiveCDefinition_h
#define CodeNavigator_ObjectiveCDefinition_h

#define BRACE_START @"{"

#define BRACE_END @"}"

#define PREPROCESSOR @"#define",@"#if",@"#ifdef",@"#undef",@"#endif",@"#else",@"#pragma",@"#ifndef", @"#elif", @"#error", nil

#define PREPROCESSOR_HEADER @"#"

#define HEADER_KEYWORD @"include"

#define HEADER_KEYWORD2 @"import"

#define MAGIC_NUMBER @"-&*$|"


#endif
