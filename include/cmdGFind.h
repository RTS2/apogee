/* Copyright (C) 1991    Canada-France-Hawaii Telescope Corp.            */
/* This program is distributed WITHOUT any warranty, and is under the    */
/* terms of the GNU General Public License, see the file COPYING    */
/*!****************************************************************************
* FILE
* getgsc.h
* $Header: /mpgs/cvsroot/gui/include/cmdGFind.h,v 1.1.1.1 1996/12/04 20:47:30 dmills Exp $
* $Locker:  $
*    This file is the main (and only) include file for the getgsc prog
*
* ROUTINES
*
*    INVOKED
*
*    PARAMETERS IN
*
*    PARAMETERS OUT
*
*    FUNCTION RETURNS
*
*    GLOBALS
*
* HISTORY
* who          when            what
* ---------    ------------    ----------------------------------------------
* bg           19 Sep 1990     Original coding
*
* $Log: cmdGFind.h,v $
* Revision 1.1.1.1  1996/12/04 20:47:30  dmills
* MPG gui's initial version
*
 * Revision 1.3  93/06/29  22:14:57  22:14:57  bernt (Bernt Grundseth)
 * *** empty log message ***
 * 
 * Revision 1.2  92/08/17  19:24:53  19:24:53  bernt (Bernt Grundseth)
 * added NSTARS
 * 
 * Revision 1.1  91/09/27  14:30:53  14:30:53  jwright ()
 * Original checkin
 * 
*
****************************************************************************!*/

/*************
 * defines *
 *************/
#define DEG2RAD (M_PI/180.)
#define FITSRECSIZE 2880
#define NSTARS        50000
#define DEC_LOWER_LIMIT  -89.9   
#define DEC_UPPER_LIMIT  90.0

/*************
 * constants *
 *************/

/**************
 * characters *
**************/
    char buf[80] ; 
    char secstr[80] ; 
    char fname[80] ; 
    char *path;

/*************************
 * structure definitions *
 *************************/


struct gscparin
    {
    double ra0;            /* ra center */
    double dec0;        /* dec center */
    float vm1;          /* lower visual magnitude  */
    float vm2;         /* upper visual magnitude  */
    double radius;      /* radius to search */
    double xlim;      /* x limit */
    double ylim;      /* y limit */
    double vig;      /* vignette radius  */
    double scale;      /* scale deg/mm */
    char mode[8];       /* mode = guide or center  */
    };

    /* par returned   */
struct gscparout
    {
    double rar;            /* ra of closest to ra0  */
    double decr;    /* dec of closest to dec0  */
    float vm;       /* visual magnitud */
    int class;      /* class 0=star, >0 non star */
    double dist;    /* distance to 0,0 */
    double x;    /* distance to 0 */
    double y;    /* distance to 0 */
    char   id[16];
    };

/*********************
 * global references *
 *********************/

