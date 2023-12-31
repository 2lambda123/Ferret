	SUBROUTINE SAVE_FRAME( filename, format, status )

*
*
*  This software was developed by the Thermal Modeling and Analysis
*  Project(TMAP) of the National Oceanographic and Atmospheric
*  Administration's (NOAA) Pacific Marine Environmental Lab(PMEL),
*  hereafter referred to as NOAA/PMEL/TMAP.
*
*  Access and use of this software shall impose the following
*  obligations and understandings on the user. The user is granted the
*  right, without any fee or cost, to use, copy, modify, alter, enhance
*  and distribute this software, and any derivative works thereof, and
*  its supporting documentation for any purpose whatsoever, provided
*  that this entire notice appears in all copies of the software,
*  derivative works and supporting documentation.  Further, the user
*  agrees to credit NOAA/PMEL/TMAP in any publications that result from
*  the use of this software or in any product that includes this
*  software. The names TMAP, NOAA and/or PMEL, however, may not be used
*  in any advertising or publicity to endorse or promote any products
*  or commercial entity unless specific written permission is obtained
*  from NOAA/PMEL/TMAP. The user also understands that NOAA/PMEL/TMAP
*  is not obligated to provide the user with any support, consulting,
*  training or assistance of any kind with regard to the use, operation
*  and performance of this software nor to provide the user with any
*  updates, revisions, new versions or "bug fixes".
*
*  THIS SOFTWARE IS PROVIDED BY NOAA/PMEL/TMAP "AS IS" AND ANY EXPRESS
*  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
*  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
*  ARE DISCLAIMED. IN NO EVENT SHALL NOAA/PMEL/TMAP BE LIABLE FOR ANY SPECIAL,
*  INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
*  RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
*  CONTRACT, NEGLIGENCE OR OTHER TORTUOUS ACTION, ARISING OUT OF OR IN
*  CONNECTION WITH THE ACCESS, USE OR PERFORMANCE OF THIS SOFTWARE. 
*
*
* make a movie or GIF frame of the current output graphics

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program
* written for VAX computer under VMS operating system
*
* V200:  11/14/89 - based on XEQ_FRAME
* V320: 5/94 - array "memory" as a calling argument
*	8/94 - filename added as calling argument
*	1/95 - major revamp using entirely X code instead of GKS (much faster)
*		and incorporating GIF output
*       9/97 - now supports batch mode
* V500: 4/99 *sh* increased filename string length from 128 to 255
* 1/03 *kob* g77 port - requires use of risc_buff for concats
*
* V6.2  *jli* 5/08 pass background color and transparent to put_frame_batch()
*       *acm* 3/12 6D Ferret (common uses nferdims in tmap_dims.parm)
* V6.8 *acm* 7/9/2012 For batch graphics on RHEL6, change ITS_BATCH_GRAPHICS
*                     from logical to integer, then batch = ITS_BATCH_GRAPHICS().NE.0

        IMPLICIT NONE
* calling argument declarations:
	INTEGER		status
	CHARACTER*(*)	filename, format

* internal variable declarations:
	INTEGER		TM_LENSTR1, ITS_BATCH_GRAPHICS, 
     .			i, elen, flen, wsid, clen
        REAL            red, green, blue
	CHARACTER	errstr*128

	include 'errmsg.parm'
	include 'movies.parm'
	include 'tmap_dims.parm'
	include 'xprog_state.cmn'
	include 'xplot_state.cmn'
	include 'xrisc_buff.cmn'

        INTEGER slen
        PARAMETER  ( slen = 255 )

* declarations for C-calling machinery
#ifdef sun
        BYTE      fnmhol(slen), errhol(slen), fmthol(5),colorhol(slen) ! c Hollerith strings
#else
        INTEGER*1 fnmhol(slen), errhol(slen), fmthol(5),colorhol(slen) ! cHollerith strings
#endif

* translate to null-terminated c-type strings
        flen = TM_LENSTR1(filename)
        CALL TM_FTOC_STRNG( filename(:flen), fnmhol, slen )
        clen = TM_LENSTR1(transparent_color)
        CALL TM_FTOC_STRNG( transparent_color(:clen), colorhol, slen )
        CALL TM_FTOC_STRNG( format, fmthol, 5 )

* determine the current output window (GKS wkstn ID, that is)
	DO wsid = 1, max_windows
	   IF ( wn_active(wsid) ) GOTO 110
	end do

* blank out the error message return buffer (a C string)
 110	DO i = 1, slen
	   errhol(i) = 0	   
	end do

* if running in batch mode, take care of metafiles rather than
* dumping window
	if (ITS_BATCH_GRAPHICS().NE.0) then
           CALL GET_BACKGROUND_COLOR (red, green, blue)
           call put_frame_batch(wsid, fnmhol, fmthol, transparent, 
     .        red, green, blue, errhol, status)
	else
* capture the bitmap (C routine)
	   CALL PUT_FRAME( wsid, fnmhol, errhol, fmthol, status )
	end if

* illegal filename errors in status, bitmap capture errors in errstr
	IF ( status .LT. 0 ) THEN
	   GOTO 5200
	ELSEIF ( errhol(1) .NE. 0 ) THEN
	   CALL TM_CTOF_STRNG( errhol, errstr, slen )
	   elen = TM_LENSTR1(errstr)
	   GOTO 5300
	ENDIF

* successful completion
	status = ferr_ok
	RETURN

* error exit
 5000	RETURN
 5200	risc_buff = filename(:flen)
	CALL ERRMSG( ferr_erreq, status, 'Unable to open GIF file: '
     .		     //risc_buff, *5000 )
 5300	CALL ERRMSG( ferr_invalid_command, status,
     .               errstr(:elen), *5000 )

	END

