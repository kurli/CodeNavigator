//
//  RubbyDefinition.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/24/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#ifndef CodeNavigator_RubbyDefinition_h
#define CodeNavigator_RubbyDefinition_h

#define COMMENTS_SINGLE @"#"

#define COMMENTS_MULTI @"=begin"

#define COMMENTS_MULTI_END @"=end"

#define KEYWORD_RUBBY @"Array BEGIN Bignum Binding Class Continuation Dir END Exception FalseClass File File::Stat Fixnum Fload Hash IO Integer MatchData Method Module NilClass Numeric Object Proc Range Regexp String Struct::TMS Symbol Thread ThreadGroup Time TrueClass alias and begin break case class def define_method defined do each else elsif end ensure false for if in module new next nil not or raise redo rescue retry return self super then throw true undef unless until when while yield"

#define PREPROCESSOR @"#define",@"#if",@"#ifdef",@"#undef",@"#endif",@"#else",@"#pragma",@"#ifndef", @"#elif", @"#error", nil

#define PREPROCESSOR_HEADER @"&^%$^"

#define HEADER_KEYWORD @"include"

#define HEADER_KEYWORD2 @"import"

#define MAGIC_NUMBER @"-&*$|"

#endif
