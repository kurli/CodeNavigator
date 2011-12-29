/*===========================================================================
 Copyright (c) 1998-2000, The Santa Cruz Operation 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 *Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.

 *Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 *Neither name of The Santa Cruz Operation nor the names of its contributors
 may be used to endorse or promote products derived from this software
 without specific prior written permission. 

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS
 IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 DAMAGE. 
 =========================================================================*/

/*	cscope - interactive C symbol or text cross-reference
 *
 *	command functions
 */

#include "global.h"
#include "build.h"		/* for rebuild() */
#include "alloc.h"

#include <stdlib.h>
#if defined(USE_NCURSES) && !defined(RENAMED_NCURSES)
//kurry #include <ncurses.h>
#else
//kurry #include <curses.h>
#endif
#include <ctype.h>

static char const rcsid[] = "$Id: command.c,v 1.33 2009/04/10 13:39:23 broeker Exp $";


int	selecting;
unsigned int   curdispline = 0;

BOOL	caseless;		/* ignore letter case when searching */
BOOL	*change;		/* change this line */
BOOL	changing;		/* changing text */
char	newpat[PATLEN + 1];	/* new pattern */
/* HBB 20040430: renamed to avoid lots of clashes with function arguments
 * also named 'pattern' */
char	Pattern[PATLEN + 1];	/* symbol or text pattern */

/* HBB FIXME 20060419: these should almost certainly be const */
static	char	appendprompt[] = "Append to file: ";
static	char	pipeprompt[] = "Pipe to shell command: ";
static	char	readprompt[] = "Read from file: ";
static	char	toprompt[] = "To: ";


/* Internal prototypes: */
static	BOOL	changestring(void);
static	void	clearprompt(void);
static	void	mark(unsigned int i);
static	void	scrollbar(MOUSE *p);


/* execute the command */
BOOL
command(int commandc)
{
    //kurry;
    return YES;
}

/* clear the prompt line */

static void
clearprompt(void)
{
	//kurry
}

/* read references from a file */

BOOL
readrefs(char *filename)
{
//kurry
	return(YES);
}

/* change one text string to another */

static BOOL
changestring(void)
{
    //kurry
    return YES;
}

/* mark/unmark this displayed line to be changed */
static void
mark(unsigned int i)
{
    //kurry
}


/* scrollbar actions */
static void
scrollbar(MOUSE *p)
{
    //kurry
}


/* count the references found */
void
countrefs(void)
{
}
