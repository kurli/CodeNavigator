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

/*	cscope - interactive C symbol cross-reference
 *
 *	terminal input functions
 */

#include "global.h"
#if defined(USE_NCURSES) && !defined(RENAMED_NCURSES)
//kurry #include <ncurses.h>
#else
//kurry #include <curses.h>
#endif
#include <setjmp.h>	/* jmp_buf */
#include <stdlib.h>
#include <errno.h>
#if HAVE_SYS_TERMIOS_H
#include <sys/termios.h>
#endif

static char const rcsid[] = "$Id: input.c,v 1.15 2006/08/20 15:00:34 broeker Exp $";

static	jmp_buf	env;		/* setjmp/longjmp buffer */
static	int	prevchar;	/* previous, ungotten character */

/* Internal prototypes: */
static RETSIGTYPE catchint(int sig);

/* catch the interrupt signal */

/*ARGSUSED*/
static RETSIGTYPE
catchint(int sig)
{
 	(void) sig;		/* 'use' it, to avoid a warning */

	signal(SIGINT, catchint);
	longjmp(env, 1);
}

/* unget a character */
void
myungetch(int c)
{
	prevchar = c;
}

/* get a character from the terminal */
int
mygetch(void)
{
// kurry
}


/* get a line from the terminal in non-canonical mode */
int
mygetline(char p[], char s[], unsigned size, int firstchar, BOOL iscaseless)
{
    // kurry
    return 0;
}

/* ask user to enter a character after reading the message */

void
askforchar(void)
{
    addstr("Type any character to continue: ");
    mygetch();
}

/* ask user to press the RETURN key after reading the message */

void
askforreturn(void)
{
    fprintf(stderr, "Press the RETURN key to continue: ");
    getchar();
    /* HBB 20060419: message probably messed up the screen --- redraw */
    if (incurses == YES) {
	//kurry
    }
}

/* expand the ~ and $ shell meta characters in a path */

void
shellpath(char *out, int limit, char *in) 
{
    char	*lastchar;
    char	*s, *v;

    /* skip leading white space */
    while (isspace((unsigned char)*in)) {
	++in;
    }
    lastchar = out + limit - 1;

    /* a tilde (~) by itself represents $HOME; followed by a name it
       represents the $LOGDIR of that login name */
    if (*in == '~') {
	*out++ = *in++;	/* copy the ~ because it may not be expanded */

	/* get the login name */
	s = out;
	while (s < lastchar && *in != '/' && *in != '\0' && !isspace((unsigned char)*in)) {
	    *s++ = *in++;
	}
	*s = '\0';

	/* if the login name is null, then use $HOME */
	if (*out == '\0') {
	    v = getenv("HOME");
	} else {	/* get the home directory of the login name */
	    v = logdir(out);
	}
	/* copy the directory name if it isn't too big */
	if (v != NULL && strlen(v) < (lastchar - out)) {
	    strcpy(out - 1, v);
	    out += strlen(v) - 1;
	} else {
	    /* login not found, so ~ must be part of the file name */
	    out += strlen(out);
	}
    }
    /* get the rest of the path */
    while (out < lastchar && *in != '\0' && !isspace((unsigned char)*in)) {

	/* look for an environment variable */
	if (*in == '$') {
	    *out++ = *in++;	/* copy the $ because it may not be expanded */

	    /* get the variable name */
	    s = out;
	    while (s < lastchar && *in != '/' && *in != '\0' &&
		   !isspace((unsigned char)*in)) {
		*s++ = *in++;
	    }
	    *s = '\0';
	
	    /* get its value, but only it isn't too big */
	    if ((v = getenv(out)) != NULL && strlen(v) < (lastchar - out)) {
		strcpy(out - 1, v);
		out += strlen(v) - 1;
	    } else {
		/* var not found, or too big, so assume $ must be part of the
		 * file name */
		out += strlen(out);
	    }
	}
	else {	/* ordinary character */
	    *out++ = *in++;
	}
    }
    *out = '\0';
}
