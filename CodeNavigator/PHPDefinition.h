//
//  CSharpDefinition.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/23/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#ifndef CodeNavigator_PHPDefinition_h
#define CodeNavigator_PHPaDefinition_h

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

#define BRACE_START @"{"

#define BRACE_END @"}"

#define KEYWORD_PHP @"__CLASS__ __CLASS__ __DIR__ __FILE__ __FILE__ __FUNCTION__ __FUNCTION__ __LINE__ __LINE__ __METHOD__ __METHOD__ __NAMESPACE__ __TRAIT__ abstract and array as break case catch cfunction class clone const continue declare default die do echo else elseif empty enddeclare endfor endforeach endif endswitch	endwhile eval exception exit extends extends final for foreach function global if implements include include_once interface isset list new or php_user_filter print private protected public require require_once return static switch this throw try unset use var while xor"

#define PREPROCESSOR @"#define",@"#if",@"#ifdef",@"#undef",@"#endif",@"#else",@"#pragma",@"#ifndef", @"#elif", @"#error", @"#region", @"#endregion", nil

#define PREPROCESSOR_HEADER @"#"

#define HEADER_KEYWORD @"include"

#define HEADER_KEYWORD2 @"import"

#define MAGIC_NUMBER @"-&*$|"

#endif
