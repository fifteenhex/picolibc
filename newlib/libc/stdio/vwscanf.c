/*-
 * Code created by modifying scanf.c which has following copyright.
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * and/or other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */
/* Doc in vfwscanf.c */
 
#define _DEFAULT_SOURCE
#include <stdio.h>
#include <wchar.h>
#include <stdarg.h>
#include "local.h"

int
vwscanf (const wchar_t *__restrict fmt, va_list ap)
{
  return _svfwscanf ( stdin, fmt, ap);
}
