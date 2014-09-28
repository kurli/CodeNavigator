#import "ErlangParser.h"
#import "FunctionListManager.h"

@implementation ErlangParser

-(id) init
{
    [self setParserConfigName:@"Erlang"];
	if ( (self = [super init])!=nil )
	{
//        //****
//        NSString* keywords = @"after begin catch case cond end fun if let of query receive try when is_atom is_binary is_bitstring is_boolean is_float      is_function is_integer is_list is_number is_pid      is_port is_record is_reference is_tuple      atom binary bitstring boolean function integer list      number pid port record reference tuple abs adler32 adler32_combine alive apply atom_to_binary      atom_to_list binary_to_atom binary_to_existing_atom      binary_to_list binary_to_term bit_size bitstring_to_list      byte_size check_process_code contact_binary crc32      crc32_combine date decode_packet delete_module      disconnect_node element erase exit float float_to_list      garbage_collect get get_keys group_leader halt hd      integer_to_list internal_bif iolist_size iolist_to_binary      is_alive is_atom is_binary is_bitstring is_boolean      is_float is_function is_integer is_list is_number is_pid      is_port is_process_alive is_record is_reference is_tuple      length link list_to_atom list_to_binary list_to_bitstring      list_to_existing_atom list_to_float list_to_integer      list_to_pid list_to_tuple load_module make_ref module_loaded      monitor_node node node_link node_unlink nodes notalive      now open_port pid_to_list port_close port_command      port_connect port_control pre_loaded process_flag      process_info processes purge_module put register      registered round self setelement size spawn spawn_link      spawn_monitor spawn_opt split_binary statistics      term_to_binary time throw tl trunc tuple_size      tuple_to_list unlink unregister whereis";
//        NSArray* keywordsArray = [keywords componentsSeparatedByString:@" "];
//        keywordsArray = [keywordsArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//            NSComparisonResult result = [a compare:b];
//            return result;
//        }];
//        NSMutableString* str = [[NSMutableString alloc] init];
//        for (int i=0; i<[keywordsArray count]; i++) {
//            [str appendFormat:@"%@ ",[keywordsArray objectAtIndex:i]];
//        }
//        NSLog(str);
        //****
	}
	return self;
}

// return YES, if we need to restart parse
// return NO, we do not need to reparse, or no comment found
-(BOOL) checkCommentsLine
{
    // If we r in string, we dont need to parse comment
    if ( isStringNotEnded == YES )
		return NO;
	if ( YES == isCommentsNotEnded )
    {		
		// comments not ended we nned to find "*/"
		// In this case we assume that we have met /* before
		NSRange commentEndRange = [needParseLine rangeOfString: [self getMultiLineCommentsEndStr]];
		// check whether */ exsist
		if ( commentEndRange.location != NSNotFound )
		{
            NSString* commentsRange = [needParseLine substringToIndex: commentEndRange.location + commentEndRange.length];
            [self commentStart];
			[self addString: commentsRange addEnter:NO];
			[self addEnd];
			isCommentsNotEnded = NO;
			NSRange range = {0, commentEndRange.location + commentEndRange.length};
			[needParseLine deleteCharactersInRange: range];
            
            [self bracesEnded:currentParseLine andToken:[self getMultiLineCommentsStartStr]];
			return YES;
		}
		else 
		{
			// */ not exsist we also in comments line here
            [self commentStart];
            [self addString: needParseLine addEnter:NO];
            [self addEnd];
            [needParseLine setString:@""];
			return NO;
		}
    }
	else
    {
		// We need to check whether comments in the beginning
		// check //
		NSRange commentSingleRange = [needParseLine rangeOfString: [self getSingleLineCommentsStr]];
		NSRange commentMultiStartRange = [needParseLine rangeOfString: [self getMultiLineCommentsStartStr]];
		NSRange commentEndRange = [needParseLine rangeOfString: [self getMultiLineCommentsEndStr]];
		if ( commentSingleRange.location == 0 )
        {
			// it's comment line
			[self commentStart];
			[self addString: needParseLine addEnter:NO];
			[self addEnd];
			[needParseLine setString:@""];
			return NO;
        }
		else if( commentMultiStartRange.location == 0 )
        {
            [self bracesStarted:currentParseLine andToken:[self getMultiLineCommentsStartStr]];
			// it's comment multi line
			[self commentStart];
			// check whether comment line is only this line
			if ( commentEndRange.location == NSNotFound )
            {
				// multi line comment
				[self addString: needParseLine addEnter:NO];
                [self addEnd];
				isCommentsNotEnded = YES;
				[needParseLine setString:@""];
				return NO;
            }
			else
            {				
				// single line comment
				NSString* commentsRange = [needParseLine substringToIndex: commentEndRange.location + commentEndRange.length];
				[self addString: commentsRange addEnter:NO];
				[self addEnd];
				NSRange range = {0, commentEndRange.location + commentEndRange.length};
				[needParseLine deleteCharactersInRange: range];
                [self bracesEnded:currentParseLine andToken:[self getMultiLineCommentsStartStr]];

				return YES;
            }
        }
		return NO;
    }
}

// return YES, if we need to restart parse
// return NO, we do not need to reparse, or no header found
-(BOOL) checkChar
{
	unichar charTemp = [needParseLine characterAtIndex:0];
	if ( charTemp != '\'' )
    {
		return NO;
    }
	// We need to parse char
	int index = 1;
	
	// find char end
	for (; index<[needParseLine length]; index++)
    {
		charTemp = [needParseLine characterAtIndex:index];
		if ( charTemp == '\'' )
        {
			if (index > 0 && [needParseLine characterAtIndex:index-1] == '\\')
            {
                // Check whether this situation "\\"
                if (index-2 >= 0 && [needParseLine characterAtIndex:index-2] == '\\') {
                    break;
                }
				continue;
            }
			else
				break;
        }
    }
	
	// we have go through the line and no string end found
	if ( index == [needParseLine length] )
    {
		[self stringStart];
		[self addString:needParseLine addEnter:NO];
		[self addEnd];
		
		[needParseLine setString:@""];
		// We need to get new line
		return NO;
    }
	
	NSString* content = [needParseLine substringToIndex: index+1];
	[self stringStart];
	[self addString: content addEnter:NO];
	[self addEnd];
	NSRange range;
	range.location = 0;
	range.length = index+1;
	[needParseLine deleteCharactersInRange: range];
	return YES;
}

// return YES, if we need to restart parse
// return NO, we do not need to reparse, or no header found
-(BOOL) checkString
{  
	unichar charTemp = [needParseLine characterAtIndex:0];
	if ( charTemp != '\"' && isStringNotEnded == NO )
    {
		return NO;
    }
	// We need to parse string
	int index;
	if ( isStringNotEnded == YES )
    {
		// we need to check from beginning
		index = 0;
    }
	else
    {
		// we need to check from second char, because first is"
		index = 1;
    }
	
	// find string end
	for (; index<[needParseLine length]; index++)
    {
		charTemp = [needParseLine characterAtIndex:index];
		if ( charTemp == '\"' )
        {
			if (index > 0 && [needParseLine characterAtIndex:index-1] == '\\')
            {
                // Check whether this situation "\\"
                if (index-2 >= 0 && [needParseLine characterAtIndex:index-2] == '\\') {
                    break;
                }
				continue;
            }
			else
				break;
        }      
    }
	
	// we have go through the line and no string end found
	if ( index == [needParseLine length] )
    {
		//if ( isStringNotEnded == NO )
        {
			[self stringStart];
			[self addString:needParseLine addEnter:NO];
			[self addEnd];
        }
		
		if ( [needParseLine characterAtIndex:[needParseLine length]-1] != '\\' )
        {
			[needParseLine setString:@""];
			return NO;
        }
		isStringNotEnded = YES;
		[needParseLine setString:@""];
		// We need to get new line
		return NO;
    }
	
	isStringNotEnded = NO;
	NSString* content = [needParseLine substringToIndex: index+1];
	[self stringStart];
	[self addString: content addEnter:NO];
	[self addEnd];
	NSRange range;
	range.location = 0;
	range.length = index+1;
	[needParseLine deleteCharactersInRange: range];
	return YES;
}

-(BOOL) checkIsNameValidChar: (unichar) character
{
	if ( (int)character >='a' && (int)character <='z' )
		return YES;
	else if ( (int)character == '_' )
		return YES;
	else if( (int)character >= '0' && (int)character <='9' )
		return YES;
	else if ( (int)character >='A' && (int)character <='Z' )
		return YES;
	return NO;
}

// return YES, if we need to restart parse
// return NO, we do not need to reparse, or no header found
-(BOOL) checkOthers: (int) lineNumber
{
	// Get string before space
	NSRange range = [needParseLine rangeOfString: @" "];
	NSString* word;
	if ( range.location == NSNotFound )
    {
		word = [needParseLine substringToIndex:[needParseLine length]];
		range.location = [needParseLine length];
    }
	else
		word = [needParseLine substringToIndex: range.location];
	
	// get word index
	int index;
	unichar temp;
	for (index=0; index<[word length]; index++)
    {
		temp = [word characterAtIndex: index];
		if ([self checkIsNameValidChar: temp] == NO)
        {
			break;
        }
    }
	
	// If first letter is not name valid char
    // It's a operator
	if ( index == 0 )
    {
		// it should be a operator
		word = [needParseLine substringToIndex: 1];
		[self addString: word addEnter:NO];
		[needParseLine deleteCharactersInRange: NSMakeRange(0, 1)];
        
        //fold support
        if ([word compare:BRACE_START] == NSOrderedSame) {
            [self bracesStarted:lineNumber andToken:BRACE_START];
        }
        else if ([word compare:BRACE_END] == NSOrderedSame)
        {
            [self bracesEnded:lineNumber andToken:BRACE_START];
        }
		return YES;
    }
	
	// if other syntax after keyword, delete these
	word = [needParseLine substringToIndex:index];
	
	// check whether keyword
	if ( [self checkIsKeyword:word] == YES )
    {
		[self keywordStart];
		[self addString:word addEnter:NO];
		[self addEnd];
		[needParseLine deleteCharactersInRange: NSMakeRange(0, index)];
		return YES;
    }
    else
    {
        // check whether is a number
        if ([word rangeOfString:@"0x"].location == 0) {
            for (index=2; index<[word length]; index++)
            {
                temp = [word characterAtIndex: index];
                if ((temp >='0' && temp <='9') ||
                    (temp >='A' && temp <= 'Z') ||
                    (temp >= 'a' && temp <= 'z'))
                {
                    continue;
                }
                break;
            }
            word = [word substringToIndex:index];
            [self numberStart];
            [self addString:word addEnter:NO];
            [self addEnd];
            [needParseLine deleteCharactersInRange: NSMakeRange(0, index)];
            return YES;
        }
        BOOL foundNumber = NO;
        int index2=0;
        for (index2=0; index2<[word length]; index2++)
        {
            temp = [word characterAtIndex: index2];
            if ((temp >='0' && temp <='9'))
            {
                foundNumber = YES;
                continue;
            }
            break;
        }
        if ( foundNumber == YES ) {
            word = [word substringToIndex:index2];
            [self numberStart];
            [self addString:word addEnter:NO];
            [self addEnd];
            [needParseLine deleteCharactersInRange: NSMakeRange(0, index2)];
            return YES;
        }
        //end
        
        [self parseOtherWord:lineNumber andWord:word];

        [needParseLine deleteCharactersInRange: NSMakeRange(0, index)];
        return YES;
    }
	return YES;
}

-(void) parseOtherWord:(int) lineNumber andWord:(NSString*)word {
    NSNumber* number = [[NSNumber alloc] initWithInt:lineNumber+1];
    FunctionItem* item = [self.tagsDict objectForKey:number];
    if (item == nil) {
        [self otherWordStart];
        [self addString:word addEnter:NO];
        [self addEnd];
        return;
    }
    NSString* key = item.keyword;
    if ([key length] > 1 && [key characterAtIndex:0] == '~') {
        key = [key substringFromIndex:1];
    }
    
    if ([word compare:key] == NSOrderedSame) {
        [self functionStart];
    } else {
        [self otherWordStart];
    }
    [self addString:word addEnter:NO];
    [self addEnd];
}

-(void) newLineStarted {
    if ([needParseLine length] <= 0) {
        return;
    }
    
    unichar firstChar = [needParseLine characterAtIndex:0];
    if (firstChar == '-') {
        NSRange range = [needParseLine rangeOfString:@"("];
        if (range.location != NSNotFound) {
            NSString* subStr = [needParseLine substringToIndex:range.location];
            [self headerStart];
            [self addString:subStr addEnter:NO];
            [self addEnd];
            range.length = range.location;
            range.location = 0;
            [needParseLine deleteCharactersInRange:range];
        }
    }
}

@end
