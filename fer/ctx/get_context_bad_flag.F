	SUBROUTINE GET_CONTEXT_BAD_FLAG ( cx )

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
* insert bad data flag into context for variable

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program
* written for VAX computer under VMS operating system
*
* revision 0.0 - 4/1/87

* V510 5/00 *sh* - user variables with settable bad flags
*       *acm* 3/12 cleanup ifdefs and unnecessary include files
* V680 5/12 *acm* 6D Ferret, changes for DEFINE DATA/AGGREGATE
* V698 3/16 *sh* added logic for cat_ef_time2d (ACTS_LIKE_FVAR)

        IMPLICIT NONE
	include	'tmap_dims.parm'
	include	'xdset_info.cmn_text'
	external xdset_info_data
	include	'ferret.parm'
	include	'xcontext.cmn'
	include	'xvariables.cmn'

	LOGICAL ACTS_LIKE_FVAR
	INTEGER cx


	IF     ( ACTS_LIKE_FVAR(cx_category(cx)) ) THEN

	   cx_bad_data( cx ) = ds_bad_flag( cx_variable( cx ) )

	ELSEIF     ( cx_category( cx ) .EQ. cat_user_var ) THEN

	   cx_bad_data( cx ) = uvar_bad_data( cx_variable( cx ) )

	ELSE

	   cx_bad_data( cx ) = bad_val4

	ENDIF

	RETURN
	END
