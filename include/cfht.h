/* Copyright (C) 1991,1994    Canada-France-Hawaii Telescope Corp.       */
/* This program is distributed WITHOUT any warranty, and is under the    */
/* terms of the GNU General Public License, see the file COPYING         */
/*****************************************************************************
*
* file: cfht.h
* $Header: /mpgs/cvsroot/gui/include/cfht.h,v 1.1.1.1 1996/12/04 20:47:28 dmills Exp $
* $Locker:  $
*
* This file is the main include file for the generic library.
*
*
* HISTORY
*
* who        when           what
* -------    -----------    ----------------------------------------------
* jab        27 Jan 1988    Original coding
* jab         1 Mar 1988    Added config file stuff
* jab        12 Mar 1988    Added logging stuff
* jk         22 Mar 1988    Added cfht_od()
* jk/jab     24 Mar 1988    Added CFHT_TAPE and CFHT_DISPLAY
* jab         6 Apr 1988    Added puma link device
* jab        29 Apr 1988    Added already included check
* sss        08 May 1988    Added CFHT_NPIPE
* jk         17 May 1988    Modified tape and display because of collision
* jk         06 Oct 1988    added cfht_resetetimer as a define
* sss        17 Mar 1989    added cfht_log() support stuffs
* sss        11 Apr 1989    added real time defines for detectors,etc.
* sss        24 Oct 1989    added CFHT_RELEASE define for .,config access
* sss         3 Jan 1990    added CFHT_*SESSIONHOST defines for env. vars
* jrw        01 Oct 1990    added stuff for cfht_number
* jrw        02 Nov 1990    added CFHT_STR_* defines
* jk         27 Feb 1991    cfht_exec unions not used anymore
* sss        27 Mar 1991    added cfht_basename()
* jrw        09 May 1991    added function definitions (ANSI and crufty flavors)
* jk         29 Aug 1991    changed cfht_errno from BOOLEAN to int
*
* $Log: cfht.h,v $
* Revision 1.1.1.1  1996/12/04 20:47:28  dmills
* MPG gui's initial version
*
 * Revision 1.17  94/12/28  17:06:51  17:06:51  thomas (Jim Thomas)
 * Moved strerror definition for suns here from cfp.h (for cfht_logv)
 * 
 * Revision 1.16  94/12/21  10:35:46  10:35:46  john (John Kerr)
 * add pid_t.
 * 
 * Revision 1.15  94/12/15  10:46:42  10:46:42  john (John Kerr)
 * modified pid in cfht_exec_data to be a pid_t type.
 * 
 * Revision 1.14  94/12/14  10:50:01  10:50:01  thomas (Jim Thomas)
 * Added CFHT_LIBMUSIC, CFHT_VALUE_SIZE, Q macro
 * Deleted BYTE
 * 
 * Revision 1.13  94/09/20  18:40:45  18:40:45  thomas (Jim Thomas)
 * added CFHT_LOGONLY, CFHT_LIBOCS
 * reworked symbols related to cfht_log
 * 
 * Revision 1.12  94/08/14  10:27:17  10:27:17  jwright (Jim Wright)
 * add warning log messages and color messages
 * 
 * Revision 1.11  94/07/11  15:48:53  15:48:53  veran (Jean-Pierre Veran)
 * AAdded net logging capabilities
 * 
 * Revision 1.10  94/02/02  14:08:00  14:08:00  jwright (Jim Wright)
 * remove typedef of FILE_ID form cfp.h and put it in cfht.h.  reason is
 * that cfht_exec() has an argument of type FILE_ID and thus needs to have
 * this type visible so that it can correctly declare an ANSI prototype.
 * it is presumed that any file including cfp.h will first have included
 * cfht.h.
 * 
 * Revision 1.9  94/01/20  20:35:13  20:35:13  jwright (Jim Wright)
 * fix enum
 * 
 * Revision 1.8  94/01/20  04:51:31  04:51:31  jwright (Jim Wright)
 * add enumeration for controller types
 * 
 * Revision 1.7  93/11/26  10:14:09  10:14:09  jwright (Jim Wright)
 * added definitions to retrieve info from net.par
 * 
 * Revision 1.6  93/05/19  08:45:49  08:45:49  steve (Steven Smith)
 * added cfht_logv TIMING define
 * 
 * Revision 1.5  93/02/16  16:21:15  16:21:15  john (John Kerr)
 * added a CFHT_INSTRUMENT_TYPE
 * 
 * Revision 1.4  92/12/01  19:21:47  19:21:47  steve (Steven Smith)
 * added CFHT_ELOGHOST for cfht_log() net based
 * 
 * Revision 1.3  92/11/09  13:11:03  13:11:03  john (John Kerr)
 * added void cfht_goDaemon()
 * 
 * Revision 1.2  91/11/15  10:07:52  10:07:52  jwright (Jim Wright)
 * add macro to handle both ansi and k&r style parameters
 * in function declarations; convert declarations to use macro
 * 
 * Revision 1.1  91/09/24  15:59:31  15:59:31  steve (Steven S Smith)
 * Initial revision
 * 
*
*****************************************************************************/

#ifndef CFHTDOTH
#define CFHTDOTH

#ifndef pid_t
#ifdef linux
#include <sys/types.h>
#endif
#include <sys/wait.h>
#endif /* pid_t */


/********************
 * type definitions *
 ********************/

typedef int BOOLEAN;           /* should only contain TRUE, or FALSE */
typedef double ANGLE;          /* floating pt. arc seconds */
typedef double TIME;           /* floating pt. seconds */
typedef double JDATE;          /* julian day number */
typedef char *DATE;            /* ascii string date */
typedef int PASSFAIL;          /* for functions that return PASS, or FAIL */
typedef void (*PFV)();         /* pointer to function that returns void */

enum exp_controller_t {       /* valid detector controller types */
    FAIL = -1,
    CONTROLLER_GENIII,
    CONTROLLER_CC200,
    CONTROLLER_FTS,
    CONTROLLER_RETICON
};

typedef int FILE_ID;              /* used for parse file instance handles */

/*************
 * constants *
 *************/

#define PASS  0           /* function returning with no error */
#define FAIL  -1          /* function returning an error in errno */
			  /* lots of things depend on FAIL being negative!! */

/* #define TRUE  1          
   #define FALSE 0        */

#ifndef NULL              /* make sure it's not already defined */
#define NULL  0           /* used mostly for null string pointers */
#endif  /* NULL */

#define CFHTLOCKS  "/tmp/cfhtlocks"

/********************
 * real time defs   *
 ********************/

#define CFHT_RT_DETECTOR 65    /* about 1/2 */
#define CFHT_RT_MOMMA    75    /* not as fast */
#define CFHT_RT_HANDLER  85    /* slower yet */

/********************
 * exec definitions *
 ********************/

#define CFHT_EXEC_NUM    10    /* number of pending deaths allowed */
#define CFHT_EXEC         1    /* straight exec */
#define CFHT_EXECFG       2    /* wait and return exit code */
#define CFHT_EXECBG       3    /* dont wait and dont ever bother me */
#define CFHT_EXECBGC      4    /* dont wait but deposit exit code when ... */
#define CFHT_EXECBGH      5    /* dont wait but call handler when ... */
                               /* (handler is called with pid and exit code */

#define CFHT_ARGV_NUM   100    /* size of cfht_argv() arg list */
#define CFHT_ARGS_SIZE 1024    /* size of string to make args out of */
#define CFHT_VALUE_SIZE 256    /* max length of a value (as in name=value) */

union cfht_exec_addr {
    int *code;                 /* exit code (-1 -> not yet exited) */
    PFV func;                  /* handler to call */
};

struct cfht_exec_data {
    pid_t pid;                   /* process id (0 -> unused) */
    int type;                  /* CFHT_EXECBGC, or CFHT_EXECBGH (0 -> ignore) */
    void *addr;                /* union not used anymore */
};

extern int cfht_exec_rtprio;

/*********************
 * config file stuff *
 *********************/

#define CFHT_ECONFPATH   "CFHTCONFPATH"                 /* env. for path */
#define CFHT_CONFPATH    "/usr/local/cfht/dev/conf"     /* default path */
#define CFHT_ECONFNAME   "CFHTCONFNAME"                 /* env. for name */
#define CFHT_CONFNAME    "config"                       /* default name */

/* identifiers within config file */
#define CFHT_DETECTOR    "detector"                     /* e.g. th1 */
#define CFHT_RELEASE     "release"                      /* e.g. 901231 */
#define CFHT_INSTRUMENT  "instrument"                   /* 'who am i' */
#define CFHT_INSTRUMENT_TYPE  "instrument_type"         /* e.g. FTS */
#define CFHT_HANDLERS    "handlers"                     /* e.g. tcsh, ccdh */
#define CFHT_FOCUS       "focus"                        /* e.g. prime */
#define CFHT_DISPLAY     "display_guy"                  /* display handler */
#define CFHT_TAPE        "tape_guy"                     /* tape handler */
#define CFHT_SESSION     "session"                      /* e.g. ccd, focam */

/*****************
 * net.par stuff *
 *****************/

#define CFHT_CCDSERVER	"ccdserver"
#define CFHT_F4SERVER	"f4server"
#define CFHT_FOCAMSERVER "focamserver"
#define CFHT_GENSERVER	"genserver"
#define CFHT_LOGSERVER	"logserver"
#define CFHT_RFSERVER	"rfserver"
#define CFHT_TCSSERVER	"tcsserver"
#define CFHT_TRAFFIC	"traffic"

/**********************
 * session host stuff *
 **********************/

#define CFHT_ESESSIONHOST    "SESSIONHOST"    /* used in xstart files */
#define CFHT_SESSIONHOST     "moe"            /* perhaps hostname()? */

/*****************
 * logging stuff *
 *****************/

/* JT mod 940916 per SPR ??? change logging of DEBUG, add LOGONLY, LIBOCS */
/* JT mod 941128 per SPR nnn -- add LIBMUSIC */

/* environment variables */

/*
 * The following are viewed as boolean flags.  For each, the indicated setting
 * has the described effect (e.g., "setenv CFHTERROR off" will cause error
 * messages not to appear in the feedback window), and the inverse setting or
 * no setting has the opposite effect (e.g., otherwise error messages appear
 * in the feedback window).
 */
#define CFHT_EERROR     "CFHTERROR"     /* Off -> no error messages to
					 * feedback window */
#define CFHT_EWARN      "CFHTWARN"      /* Off -> no warning messages to
					 * feedback window */
#define CFHT_ENODISP    "CFHTNODISP"    /* On -> no START/STATUS/DONE messages
					 * to feedback window */
#define CFHT_EDEBUG     "CFHTDEBUG"     /* On -> CFHT_MAIN debug messages to
					 * log file */
#define CFHT_ELIB       "CFHTLIB"       /* On -> unknown lib debug messages to
					 * log file */
#define CFHT_ELIBCAMAC  "CFHTLIBCAMAC"  /* On -> libcamac debug to log file */
#define CFHT_ELIBCCD    "CFHTLIBCCD"    /* On -> libccd debug to log file */
#define CFHT_ELIBCFHT   "CFHTLIBCFHT"   /* On -> libcfht debug to log file */
#define CFHT_ELIBCFP    "CFHTLIBCFP"    /* On -> libcfp debug to log file */
#define CFHT_ELIBFF     "CFHTLIBFF"     /* On -> libff debug to log file */
#define CFHT_ELIBHH     "CFHTLIBHH"     /* On -> libhh debug to log file */
#define CFHT_ELIBMUSIC  "CFHTLIBMUSIC"  /* On -> libmusic debug to log file */
#define CFHT_ELIBOCS    "CFHTLIBOCS"    /* On -> libocs debug to log file */
#define CFHT_ELIBRET    "CFHTLIBRET"    /* On -> libret debug to log file */
#define CFHT_ECOLORLOG	"CFHTCOLORLOG" 	/* Off -> no color on user log */

#define CFHT_LOGU       "CFHTLOGU"      /* user log messages file name */
#define CFHT_LOGS       "CFHTLOGS"      /* system log messages file name */
#define CFHT_ELOGHOST	"CFHTLOGHOST" 	/* host for netbased logging */

/* who */
typedef enum {
    CFHT_MAIN = 0,		  /* caller is end user */
    CFHT_LIB,			  /* caller is undefined library */
    CFHT_LIBCAMAC,		  /* caller is CAMAC library */
    CFHT_LIBCCD,		  /* caller is ccd library */
    CFHT_LIBCFHT,		  /* caller is CFHT library */
    CFHT_LIBCFP,		  /* caller is CFP library */
    CFHT_LIBFF,			  /* caller is FITS library */
    CFHT_LIBHH,			  /* caller is high level HPIB library */
    CFHT_LIBMUSIC,		  /* caller is music library */
    CFHT_LIBOCS,		  /* caller is OCS library */
    CFHT_LIBRET			  /* caller is reticon library */
} cfht_log_who;

/* type */
typedef enum {
    CFHT_LOG_ID = 0,		  /* client side initialization msg type */
    CFHT_START,			  /* program is starting */
    CFHT_STATUS,		  /* something interesting to the user */
    CFHT_ERROR,			  /* error */
    CFHT_FATAL = CFHT_ERROR,	  /* obsolete - about to exit due to error */
    CFHT_ERRNO,			  /* do not use - error with errno message */
    CFHT_WARN,			  /* warning - something's wrong */
    CFHT_DONE,			  /* about to exit normally */
    CFHT_LOGONLY,		  /* operational diagnositc info */
    CFHT_DEBUG,			  /* program trace info */
    CFHT_TIMING,		  /* print elapsed + delta times */
    CFHT_FEEDINIT,		  /* init a feedback type output sink */
    CFHT_FEEDQUIT,		  /* free up fd's, etc for feedback sinks */
    CFHT_ROLLINIT,		  /* start up another roll type output sink */
    CFHT_ROLLQUIT,		  /* shut down roll type output sinks */
    CFHT_SHOWSINKS,		  /* used by developer to debug...  */
    CFHT_SERVINIT		  /* re-init da logserver without killing it */
} cfht_log_type;

#define CFHT_DATE_SIZE 29	  /* size needed for cfht_date result */
#define CFHT_TIME_SIZE 12	  /* size needed for cfht_time result */

/* end mod 941128 per SPR nnn -- add LIBMUSIC */
/* end mod 940916 per SPR ??? - change logging of DEBUG, add LOGONLY, LIBOCS */

/***********************
 * parsing definitions *
 ***********************/

struct cfht_rng_double {
    double min;
    double max;
    BOOLEAN min_inclusive;
    BOOLEAN max_inclusive;
};
struct cfht_rng_int {
    int min;
    int max;
    BOOLEAN min_inclusive;
    BOOLEAN max_inclusive;
};
struct cfht_rng_string {
    char **string_array;
};
struct cfht_rng_char {
    char *list_of_chars;
};
union cfht_ranges {
    struct cfht_rng_double cfht_double_range;
    struct cfht_rng_int cfht_int_range;
    struct cfht_rng_string cfht_string_range;
    struct cfht_rng_char cfht_char_range;
};

typedef union cfht_ranges *cfht_range_t;

#define CFHT_STR_MATCH     1  /* check if input matches one of set of strings */
#define CFHT_STR_INCLUDE   2  /* only pass through characters mentioned */
#define CFHT_STR_EXCLUDE   3  /* only pass through characters not mentioned */
#define CFHT_STR_NOWHITE   4  /* remove all white space from string */
#define CFHT_STR_NOTRAIL   5  /* remove all trailing white space */
#define CFHT_STR_ESCAPE    6  /* convert non-printing chars to escape codes */
#define CFHT_STR_UNESCAPE  7  /* convert escape codes to chars */

/**************************
 * cfht_errno definitions *
 **************************/

#define CHECK_ERRNO   -1       /* check unix(tm) errno variable for reason */
#define NO_ERROR       0       /* success */
#define NOT_A_TTY      1       /* for historical uses, and general laziness */
#define PARSE_FAILED   2       /* unable to cope with input */
#define TOO_BIG        3       /* input exceeds hardware limit */
#define OUT_OF_RANGE   4       /* input exceeds software restriction */
#define TYPE_ERROR     5       /* incompatible or unexpected type */
#define UNIMPLEMENTED  6       /* feature not yet implemented */
#define BAD_OPTION     7       /* option passed in to routine was invalid */
#define INVALID_RANGE  8       /* range structure was malformed or illegal */

/*************************
 * structure definitions *
 *************************/

/*********************
 * global references *
 *********************/

extern BOOLEAN cfht_debug;
extern BOOLEAN cfht_error;
extern BOOLEAN cfht_lib;
extern BOOLEAN cfht_nodisp;
extern int cfht_errno;

extern union cfht_ranges *CFHT_RNG_RA;
extern union cfht_ranges *CFHT_RNG_DEC;

#define cfht_resetetimer() cfht_etimer(TRUE)

/******************************************************************
 * macro to declare prototypes for ansi, but still works with k&r *
 *                                                                *
 * define prototype like                                          *
 *        int foo P((int a, char c))                              *
 *                                                                *
 * note that the space before the P and the doubled parentheses   *
 *      are needed                                                *
 ******************************************************************/

#ifndef P
#ifdef __STDC__
#define P(args) args
#else
#define P(args) ()
#endif
#endif

/********************************************************************
 * macro to declare routine parameters for ansi that works with k&r *
 *                                                                  *
 * define actual routine like                                       *
 *        int foo Q((int a, char c), (a, c), int a; char c;) {      *
 *                                                                  *
 * note that inner parentheses are needed on the ansi parameters    *
 *                                 needed on the K&R parameters     *
 *                             and must not be there on the K&R     *
 *                                          type definition         *
 *           there must be a space before the Q                     *
 *           the arguments to Q can be on separate lines like       *
 *                         int foo Q((int a, char c),               *
 *                                   (a, c),                        *
 *                                   int a; char c;)                *
 *                         {                                        *
 ********************************************************************/

#ifndef Q
#ifdef __STDC__
#define Q(ansi, karparm, kartype) ansi
#else
#define Q(ansi, karparm, kartype) karparm kartype
#endif
#endif

/*********************************************
 * complete (?) list of all cfht_* functions *
 *********************************************/

void	cfht_awake P((double when_from_now, double how_often));
char	*cfht_basename P((char *dest, char *filename, char *suffix));
char	*cfht_date P((long *clockp));
void	cfht_delay P((long millisec));
char	*cfht_doupper P((char *str));
double	cfht_dtime P((void));
char	*cfht_fre P((unsigned char *src, unsigned char *dest, int *dsize));
char	*cfht_toe P((unsigned char *src, unsigned char *dest, int ssize));
double	cfht_etimer P((BOOLEAN reset));
int	cfht_exec P((FILE_ID id, char *string, int type, void *addr));
char	*cfht_frs P((char *dest, double val, int scale, int prec));
void	cfht_genh P((int argc, char **argv, char **envp));
void	usage P((char **msg));
void	getcurdeath P((char *what));
double	cfht_julian P((int year, int month, int day, int hour, int minute, double sec));
void	cfht_fromjulian P((int *year, int *month, int *day, int *hour, int *minute, double jd, double *sec));
BOOLEAN	cfht_checksem P((int semid));
int	cfht_initsem P((char *path, char id));
PASSFAIL cfht_setsem P((int semid));
PASSFAIL cfht_setsemwait P((int semid, BOOLEAN sigign));
PASSFAIL cfht_relsem P((int semid));
PASSFAIL cfht_waitsemrel P((int semid, BOOLEAN sigign));
PASSFAIL cfht_waitsemset P((int semid, BOOLEAN sigign));
BOOLEAN cfht_checklock P((int fd));
int	cfht_initlock P((char *path, char id));
PASSFAIL cfht_setlock P((int fd));
PASSFAIL cfht_setlockwait P((int fd, BOOLEAN sigign));
PASSFAIL cfht_rellock P((int fd));
PASSFAIL cfht_waitlockrel P((int fd, BOOLEAN sigign));
PASSFAIL cfht_waitlockset P((int fd, BOOLEAN sigign));
void	cfht_logv P((int who, int type, char *fmt, ...));
void	cfht_log P((int who, int type, char *mess));
PASSFAIL cfht_int P((char *in_str, int *out_addr, cfht_range_t rangeinfo));
PASSFAIL cfht_double P((char *in_str, double *out_addr, cfht_range_t rangeinfo));
long	cfht_od P((void));
#ifdef sun
int	prealloc P((int fildes, unsigned size));
#endif /* sun */
int	cfht_sleep P((int msec, int igsig));
char	*cfht_string P((char *in_str, int operation, cfht_range_t rangeinfo));
char	*cfht_time P((long *clockp));
BOOLEAN	cfht_tob P((char *string));
char	*cfht_tok P((char *string, char *sep, char **tail));
void	cfht_goDaemon P((void));

#ifdef sun
char *strerror P((int ErrorNo));
#endif

#endif /* CFHTDOTH */
