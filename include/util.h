/* This file is part of opag, an option parser generator.
   Copyright (C) 2002, 2004 Martin Dickopp

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
   USA.  */

#ifndef HDR_UTIL
#define HDR_UTIL 1


/* Declarations missing in the standard headers.  */
#if !HAVE_DECL_STRCHR
extern char *strchr (), *strrchr ();
#endif

#if !HAVE_DECL_STRERROR
extern char *strerror ();
#endif


/* Number of elements in an array.  */
#define numof(a) (sizeof (a) / sizeof *(a))


/* Name under which the program has been invoked.  */
extern const char *invocation_name;


/* malloc and realloc wrappers.  Terminate the program if memory allocation fails.  */
extern void *xmalloc (size_t size) gcc_attr_malloc;
extern void *xrealloc (void *ptr, size_t size);

/* Report a failure to allocate memory and terminate the program.  */
extern void mem_alloc_failed (void) gcc_attr_noreturn;

/* Test if a string is a valid C identifier.  */
extern int c_identifier (const char *s) gcc_attr_pure gcc_attr_nonnull (());

/* Test if a string is a valid C++ identifier (possibly scope qualified).  */
extern int cxx_scoped_identifier (const char *s) gcc_attr_pure gcc_attr_nonnull (());


#endif
