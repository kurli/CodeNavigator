//
//  cscope.c
//  SingleView
//
//  Created by Guozhen Li on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
 *	main functions
 */

#include "global.h"

#include "build.h"
#include "vp.h"
#include "version.h"	/* FILEVERSION and FIXVERSION */
#include "scanner.h" 
#include "alloc.h"

#include <stdlib.h>	/* atoi */
#if defined(USE_NCURSES) && !defined(RENAMED_NCURSES)
//kurry #include <ncurses.h>
#else
//kurry #include <curses.h>
#endif
#include <sys/types.h>	/* needed by stat.h */
#include <sys/stat.h>	/* stat */
#include <signal.h>

#include "cscope.h"

/* defaults for unset environment variables */
#define	EDITOR	"vi"
#define HOME	"/"	/* no $HOME --> use root directory */
#define	SHELL	"sh"
#define LINEFLAG "+%s"	/* default: used by vi and emacs */
#define TMPDIR	"/tmp"
#ifndef DFLT_INCDIR
#define DFLT_INCDIR "/usr/include"
#endif

/* note: these digraph character frequencies were calculated from possible 
 printable digraphs in the cross-reference for the C compiler */
char	dichar1[] = " teisaprnl(of)=c";	/* 16 most frequent first chars */
char	dichar2[] = " tnerpla";		/* 8 most frequent second chars 
                                     using the above as first chars */
char	dicode1[256];		/* digraph first character code */
char	dicode2[256];		/* digraph second character code */

char	*editor, *shell, *lineflag;	/* environment variables */
char	*home;			/* Home directory */
BOOL	lineflagafterfile;
char	*argv0;			/* command name */
BOOL	compress = YES;		/* compress the characters in the crossref */
BOOL	dbtruncated;		/* database symbols are truncated to 8 chars */
int	dispcomponents = 1;	/* file path components to display */
#if CCS
BOOL	displayversion;		/* display the C Compilation System version */
#endif
BOOL	editallprompt = YES;	/* prompt between editing files */
unsigned int fileargc;		/* file argument count */
char	**fileargv;		/* file argument values */
int	fileversion;		/* cross-reference file version */
BOOL	incurses = NO;		/* in curses */
BOOL	invertedindex;		/* the database has an inverted index */
BOOL	isuptodate;		/* consider the crossref up-to-date */
//kurry
//BOOL	kernelmode;		/* don't use DFLT_INCDIR - bad for kernels */
BOOL	linemode = NO;		/* use line oriented user interface */
BOOL	verbosemode = NO;	/* print extra information on line mode */
BOOL	recurse_dir = NO;	/* recurse dirs when searching for src files */
char	*namefile;		/* file of file names */
BOOL	ogs;			/* display OGS book and subsystem names */
char	*prependpath;		/* prepend path to file names */
FILE	*refsfound;		/* references found file */
char	temp1[PATHLEN + 1];	/* temporary file name */
char	temp2[PATHLEN + 1];	/* temporary file name */
char	tempdirpv[PATHLEN + 1];	/* private temp directory */
long	totalterms;		/* total inverted index terms */
BOOL	trun_syms;		/* truncate symbols to 8 characters */
char	tempstring[TEMPSTRING_LEN + 1]; /* use this as a buffer, instead of 'yytext', 
                                         * which had better be left alone */
char	*tmpdir;		/* temporary directory */

//kurry
char    *basedir;       /* base dir for iOS bundle */

/* Internal prototypes: */
static	void	initcompress(void);
static	void	longusage(void);
static	void	skiplist(FILE *oldrefs);
static	void	usage(void);


void cscope_build(const char*, const char*);
int addstr(const char*);
void refresh();

#ifdef HAVE_FIXKEYPAD
void	fixkeypad();
#endif

#if defined(KEY_RESIZE) && !defined(__DJGPP__)
void 
sigwinch_handler(int sig, siginfo_t *info, void *unused)
{
    (void) sig;
    (void) info;
    (void) unused;
    if(incurses == YES)
        ungetch(KEY_RESIZE);
}
#endif

void
cannotopen(char *file)
{
    printf("Cannot open file %s", file);
}

/* FIXME MTE - should use postfatal here */
void
cannotwrite(char *file)
{
    char	msg[MSGLEN + 1];
    
    snprintf(msg, sizeof(msg), "Removed file %s because write failed", file);
    
    myperror(msg);	/* display the reason */
    
    unlink(file);
    myexit(1);	/* calls exit(2), which closes files */
}

void refresh()
{
}

int addstr(const char* str)
{
    return 0;
}

static void
longusage(void)
{
}

static void
usage(void)
{
}

/* set up the digraph character tables for text compression */
static void
initcompress(void)
{
    int	i;
	
    if (compress == YES) {
        for (i = 0; i < 16; ++i) {
            dicode1[(unsigned char) (dichar1[i])] = i * 8 + 1;
        }
        for (i = 0; i < 8; ++i) {
            dicode2[(unsigned char) (dichar2[i])] = i + 1;
        }
    }
}

static void
skiplist(FILE *oldrefs)
{
    int	i;
	
    if (fscanf(oldrefs, "%d", &i) != 1) {
        postfatal("cscope: cannot read list size from file %s\n", reffile);
        /* NOTREACHED */
    }
    while (--i >= 0) {
        if (fscanf(oldrefs, "%*s") != 0) {
            postfatal("cscope: cannot read list name from file %s\n", reffile);
            /* NOTREACHED */
        }
    }
}

char	*kur_getcwd(char *name, size_t size)
{
    strcpy(name, basedir);
    return basedir;
}

void cscope_set_base_dir(const char* dir)
{
    if (basedir != NULL) {
        free(basedir);
    }
    basedir = malloc(sizeof(const char)*(strlen(dir)+1));
    strcpy(basedir, dir);
}

void cscope_build(const char* out_file_name, const char* file_list_f)
{
    pid_t pid;
    struct stat	stat_buf;
#if defined(KEY_RESIZE) && !defined(__DJGPP__)
    struct sigaction winch_action;
#endif
    mode_t orig_umask;
	
    yyin = stdin;
    yyout = stdout;
    /* save the command name for messages */
    argv0 = "cscope";
    
    namefile = file_list_f;

    buildonly = YES;
    linemode  = YES;
    //TODO we do not support sort, so ignore quick sort
    //invertedindex = YES;

    /* read the environment */
    editor = mygetenv("EDITOR", EDITOR);
    editor = mygetenv("VIEWER", editor); /* use viewer if set */
    editor = mygetenv("CSCOPE_EDITOR", editor);	/* has last word */
    home = mygetenv("HOME", HOME);
    shell = mygetenv("SHELL", SHELL);
    lineflag = mygetenv("CSCOPE_LINEFLAG", LINEFLAG);
    lineflagafterfile = getenv("CSCOPE_LINEFLAG_AFTER_FILE") ? 1 : 0;
    tmpdir = mygetenv("TMPDIR", TMPDIR);
    
    /* make sure that tmpdir exists */
    if (lstat (tmpdir, &stat_buf)) {
        fprintf (stderr, "\
                 cscope: Temporary directory %s does not exist or cannot be accessed\n", 
                 tmpdir);
        fprintf (stderr, "\
                 cscope: Please create the directory or set the environment variable\n\
                 cscope: TMPDIR to a valid directory\n");
        myexit(1);
    }
    
    /* create the temporary file names */
    orig_umask = umask(S_IRWXG|S_IRWXO);
    pid = getpid();
    snprintf(tempdirpv, sizeof(tempdirpv), "%s/cscope.%d", tmpdir, pid);
    if(mkdir(tempdirpv,S_IRWXU)) {
        fprintf(stderr, "\
                cscope: Could not create private temp dir %s\n",
                tempdirpv);
        myexit(1);
    }
    umask(orig_umask);
    
    snprintf(temp1, sizeof(temp1), "%s/cscope.1", tempdirpv);
    snprintf(temp2, sizeof(temp2), "%s/cscope.2", tempdirpv);
    
    /* if running in the foreground */
    if (signal(SIGINT, SIG_IGN) != SIG_IGN) {
        /* cleanup on the interrupt and quit signals */
        signal(SIGINT, myexit);
        signal(SIGQUIT, myexit);
    }
    /* cleanup on the hangup signal */
    signal(SIGHUP, myexit);
    
    /* ditto the TERM signal */
    signal(SIGTERM, myexit);

    /* if the cross-reference is to be considered up-to-date */
    if (isuptodate == NO){
        /* save the file arguments */
        fileargc = 0;
        fileargv = NULL;
        
        /* make the source file list */
        srcfiles = mymalloc(msrcfiles * sizeof(char *));
        makefilelist();
        if (nsrcfiles == 0) {
            postfatal("cscope: no source files found\n");
            /* NOTREACHED */
        }

        
        /* initialize the C keyword table */
        initsymtab();
        
        /* Tell build.c about the filenames to create: */
        reffile = out_file_name;
        setup_build_filenames(reffile);
        
        /* build the cross-reference */
        initcompress();	    
        build();
    }
    myexit(0);
}

static short shouldStartWrite(char c)
{
    static char* projects = "/.Projects/";
    static int foundIndex = 0;
    if (projects[foundIndex] == c)
    {
        if (foundIndex == 9)
        {
            foundIndex = 0;
            return 1;
        }
        foundIndex++;
    }
    else
    {
        foundIndex = 0;
    }
    return 0;
}

static char* cscope_find(int type, const char* symble_name, const char* out_file_name, 
                        const char* file_list_f){
    FILE *names;                        /* name file pointer */
    pid_t pid;
    struct stat	stat_buf;
#if defined(KEY_RESIZE) && !defined(__DJGPP__)
    struct sigaction winch_action;
#endif
    mode_t orig_umask;
    int c;
    FILE *oldrefs;        /* old cross-reference file */
    int        oldnum;                        /* number in old cross-ref */
    char path[PATHLEN + 1];        /* file path */
    char *s;
    unsigned int i;

    linemode = YES;
    
    yyin = stdin;
    yyout = stdout;
    
    argv0 = "cscope";    
    namefile = file_list_f;
    
    field = type;
    
    //Do not need to rebuild database
    isuptodate = YES;
    
    strcpy(Pattern, symble_name);
    
    int out_size = 10240;
    char *out=malloc(out_size*sizeof(char));
    if (out == NULL)
        return NULL;
    else
        memset(out, 0, out_size*sizeof(char));

    /* read the environment */
    editor = mygetenv("EDITOR", EDITOR);
    editor = mygetenv("VIEWER", editor); /* use viewer if set */
    editor = mygetenv("CSCOPE_EDITOR", editor);	/* has last word */
    home = mygetenv("HOME", HOME);
    shell = mygetenv("SHELL", SHELL);
    lineflag = mygetenv("CSCOPE_LINEFLAG", LINEFLAG);
    lineflagafterfile = getenv("CSCOPE_LINEFLAG_AFTER_FILE") ? 1 : 0;
    tmpdir = mygetenv("TMPDIR", TMPDIR);
    
    /* make sure that tmpdir exists */
    if (lstat (tmpdir, &stat_buf)) {
        fprintf (stderr, "\
                 cscope: Temporary directory %s does not exist or cannot be accessed\n", 
                 tmpdir);
        fprintf (stderr, "\
                 cscope: Please create the directory or set the environment variable\n\
                 cscope: TMPDIR to a valid directory\n");
        myexit(1);
    }
    
    /* create the temporary file names */
    orig_umask = umask(S_IRWXG|S_IRWXO);
    pid = getpid();
    snprintf(tempdirpv, sizeof(tempdirpv), "%s/cscope.%d", tmpdir, pid);
    if(mkdir(tempdirpv,S_IRWXU)) {
        fprintf(stderr, "\
                cscope: Could not create private temp dir %s\n",
                tempdirpv);
        myexit(1);
    }
    umask(orig_umask);
    
    snprintf(temp1, sizeof(temp1), "%s/cscope.1", tempdirpv);
    snprintf(temp2, sizeof(temp2), "%s/cscope.2", tempdirpv);
    
    /* if running in the foreground */
    if (signal(SIGINT, SIG_IGN) != SIG_IGN) {
        /* cleanup on the interrupt and quit signals */
        signal(SIGINT, myexit);
        signal(SIGQUIT, myexit);
    }
    /* cleanup on the hangup signal */
    signal(SIGHUP, myexit);
    
    /* ditto the TERM signal */
    signal(SIGTERM, myexit);
    
    /* Tell build.c about the filenames to create: */
    reffile = out_file_name;
    
    if ((oldrefs = vpfopen(reffile, "rb")) == NULL) {
        postfatal("cscope: cannot open file %s\n", reffile);
        /* NOTREACHED */
    }
    /* get the crossref file version but skip the current directory */
    if (fscanf(oldrefs, "cscope %d %*s", &fileversion) != 1) {
        postfatal("cscope: cannot read file version from file %s\n",
                  reffile);
        /* NOTREACHED */
    }
    
    if (fileversion >= 8) {
        
        /* override these command line options */
        compress = YES;
        invertedindex = NO;
        
        /* see if there are options in the database */
        for (;;) {
            getc(oldrefs);        /* skip the blank */
            if ((c = getc(oldrefs)) != '-') {
                ungetc(c, oldrefs);
                break;
            }
            switch (c = getc(oldrefs)) {
                case 'c':        /* ASCII characters only */
                    compress = NO;
                    break;
                case 'q':        /* quick search */
                    invertedindex = YES;
                    fscanf(oldrefs, "%ld", &totalterms);
                    break;
                case 'T':        /* truncate symbols to 8 characters */
                    dbtruncated = YES;
                    trun_syms = YES;
                    break;
            }
        }
        initcompress();
        seek_to_trailer(oldrefs);
    }
    
    /* skip the source and include directory lists */
    skiplist(oldrefs);
    skiplist(oldrefs);
    
    /* get the number of source files */
    if (fscanf(oldrefs, "%lu", &nsrcfiles) != 1) {
        postfatal("\
                  cscope: cannot read source file size from file %s\n", reffile);
        /* NOTREACHED */
    }
    /* get the source file list */
    srcfiles = mymalloc(nsrcfiles * sizeof(char *));
    
    if (fileversion >= 9) {
        
        /* allocate the string space */
        if (fscanf(oldrefs, "%d", &oldnum) != 1) {
            postfatal("\
                      cscope: cannot read string space size from file %s\n", reffile);
            /* NOTREACHED */
        }
        s = mymalloc(oldnum);
        getc(oldrefs);        /* skip the newline */
        
        /* read the strings */
        if (fread(s, oldnum, 1, oldrefs) != 1) {
            postfatal("\
                      cscope: cannot read source file names from file %s\n", reffile);
            /* NOTREACHED */
        }
        /* change newlines to nulls */
        for (i = 0; i < nsrcfiles; ++i) {
            srcfiles[i] = s;
            for (++s; *s != '\n'; ++s) {
                ;
            }
            *s = '\0';
            ++s;
        }
        /* if there is a file of source file names */
        if ((namefile != NULL && (names = vpfopen(namefile, "r")) != NULL)
            || (names = vpfopen(NAMEFILE, "r")) != NULL) {
            
            /* read any -p option from it */
            while (fgets(path, sizeof(path), names) != NULL && *path == '-') {
                i = path[1];
                s = path + 2;                /* for "-Ipath" */
                if (*s == '\0') {        /* if "-I path" */
                    fgets(path, sizeof(path), names);
                    s = path;
                }
                switch (i) {
                    case 'p':        /* file path components to display */
                        if (*s < '0' || *s > '9') {
                            posterr("cscope: -p option in file %s: missing or invalid numeric value\n",                                                                 namefile);
                            
                        }
                        dispcomponents = atoi(s);
                }
            }
            fclose(names);
        }
    } else {
        for (i = 0; i < nsrcfiles; ++i) {
            if (!fgets(path, sizeof(path), oldrefs) ) {
                postfatal("\
                          cscope: cannot read source file name from file %s\n",
                          reffile);
                /* NOTREACHED */
            }
            srcfiles[i] = my_strdup(path);
        }
    }
    fclose(oldrefs);
    
    opendatabase();
    
    int result_size = 0;
    if (search() == YES) {
		/* print the total number of lines in
		 * verbose mode */
		if (verbosemode == YES)
		    printf("cscope: %d lines\n",
                   totallines);
        
        short _shouldWrite = 0;
		while ((c = getc(refsfound)) != EOF)
        {
            if (out_size < result_size+2)
            {
                break;
            }
            if (_shouldWrite == 0)
            {
                if (shouldStartWrite(c) == 1)
                    _shouldWrite = 1;
                continue;
            }
		    out[result_size++] = c;
            if (c == '\n')
                _shouldWrite = 0;
        }
    }
    out[result_size] = '\0';
    myexit(0);
    if (result_size == 0)
        return out;
    return out;
}

char* cscope_find_this_symble(const char* symble_name, const char* out_file_name, 
                             const char* file_list_f)
{
    return cscope_find(FIND_SYMBLE, symble_name, out_file_name, file_list_f);
}

char* cscope_find_global(const char* symble_name, const char* out_file_name, 
                        const char* file_list_f)
{
    return cscope_find(FIND_GLOBAL, symble_name, out_file_name, file_list_f);
}

char* cscope_find_called_functions(const char* symble_name, const char* out_file_name, 
                                  const char* file_list_f)
{
    return cscope_find(FIND_CALLED_FUNCTIONS, symble_name, out_file_name, file_list_f);
}

char* cscope_find_functions_calling_a_function(const char* symble_name, const char* out_file_name, 
                                              const char* file_list_f)
{
    return cscope_find(FIND_FUNCTIONS_CALLING_A_FUNCTION, symble_name, out_file_name, file_list_f);
}

char* cscope_find_text_string(const char* symble_name, const char* out_file_name, 
                                              const char* file_list_f)
{
    return cscope_find(FIND_TEXT_STRING, symble_name, out_file_name, file_list_f);
}

char* cscope_find_a_file(const char* symble_name, const char* out_file_name, 
                        const char* file_list_f)
{
    return cscope_find(FIND_A_FILE, symble_name, out_file_name, file_list_f);
}

char* cscope_find_files_including_a_file(const char* symble_name, const char* out_file_name, 
                                        const char* file_list_f)
{
    return cscope_find(FIND_FILES_INCLUDING_A_FILE, symble_name, out_file_name, file_list_f);
}

/* cleanup and exit */

void
myexit(int sig)
{
    close(symrefs);
    if (invertedindex == YES) {
        invclose(&invcontrol);
        nsrcoffset = 0;
        npostings = 0;
    }

    /* HBB 20010313; close file before unlinking it. Unix may not care
	 * about that, but DOS absolutely needs it */
	if (refsfound != NULL)
		fclose(refsfound);
	
	/* remove any temporary files */
	if (temp1[0] != '\0') {
		unlink(temp1);
		unlink(temp2);
		rmdir(tempdirpv);		
	}
    //Reset to update database
	/* restore the terminal to its original mode */
//	if (incurses == YES) {
//		exitcurses();
//	}
	/* dump core for debugging on the quit signal */
	if (sig == SIGQUIT) {
		abort();
	}
	/* HBB 20000421: be nice: free allocated data */
	freefilelist();
	freeinclist();
	freesrclist();
	freecrossref();
	free_newbuildfiles();
    isuptodate = NO;
	//exit(sig);
}