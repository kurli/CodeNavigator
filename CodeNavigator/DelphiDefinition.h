//
//  DelphiDefinition.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/23/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#ifndef CodeNavigator_DelphiDefinition_h
#define CodeNavigator_DelphiDefinition_h

#define COMMENTS_SINGLE @"//"

#define COMMENTS_MULTI @"(*"

#define COMMENTS_MULTI_END @"*)"

#define BRACE_START @"{"

#define BRACE_END @"}"

#define KEYWORD_DELPHI @"abs addr and ansichar ansistring array as asm begin boolean byte cardinal case char class comp const constructor currency destructor div do double downto else end except exports extended false file finalization finally for function goto if implementation in inherited int64 initialization integer interface is label library longint longword mod nil not object of on or packed pansichar pansistring pchar pcurrency pdatetime pextended pint64 pointer private procedure program property pshortstring pstring pvariant pwidechar pwidestring protected public published raise real real48 record repeat set shl shortint shortstring shr single smallint string then threadvar to true try type unit until uses val var varirnt while widechar widestring with word write writeln xor"

#define PREPROCESSOR nil

#define PREPROCESSOR_HEADER @"#"

#define HEADER_KEYWORD @"include"

#define HEADER_KEYWORD2 @"import"

#define MAGIC_NUMBER @"-&*$|"

#endif
