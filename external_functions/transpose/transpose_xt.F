*
* transpose_xt.F
*
* 
* 
*
* This function sets the second argument to be equal
* to the first one.
*


*
* In this subroutine we provide information about
* the function.  The user configurable information 
* consists of the following:
*
* descr              Text description of the function
*
* num_args           Required number of arguments
*
* axis_inheritance   Type of axis for the result
*                       ( CUSTOM, IMPLIED_BY_ARGS, NORMAL, ABSTRACT )
*                       CUSTOM          - user defined axis
*                       IMPLIED_BY_ARGS - same axis as the incoming argument
*                       NORMAL          - the result is normal to this axis
*                       ABSTRACT        - an axis which only has index values
*
* piecemeal_ok       For memory optimization:
*                       axes where calculation may be performed piecemeal
*                       ( YES, NO )
* 
*
* For each argument we provide the following information:
*
* name               Text name for an argument
*
* unit               Text units for an argument
*
* desc               Text description of an argument
*
* axis_influence     Are this argument's axes the same as the result grid?
*                       ( YES, NO )
*
* axis_extend       How much does Ferret need to extend arg limits relative to result 
*


      SUBROUTINE transpose_xt_init(id)

      INCLUDE 'ferret_cmn/EF_Util.cmn'

      INTEGER id, arg


* **********************************************************************
*                                            USER CONFIGURABLE PORTION |
*                                                                      |
*                                                                      V

      CALL ef_set_desc(id,
     . 'transposes X and T axes of given variable' )

      CALL ef_set_num_args(id, 1)
      CALL ef_set_axis_inheritance(id, ABSTRACT, 
     .     IMPLIED_BY_ARGS, IMPLIED_BY_ARGS, ABSTRACT)
      CALL ef_set_piecemeal_ok(id, NO, NO, NO, NO)

      arg = 1
      CALL ef_set_arg_name(id, arg, 'VAR')
      CALL ef_set_arg_desc(id, arg, 'variable transposed in X and T')
      CALL ef_set_axis_influence(id, arg, YES, YES, YES,YES)

*                                                                      ^
*                                                                      |
*                                            USER CONFIGURABLE PORTION |
* **********************************************************************

      RETURN 
      END


      SUBROUTINE transpose_xt_result_limits(id)

      INCLUDE 'ferret_cmn/EF_Util.cmn'
      INCLUDE 'ferret_cmn/EF_mem_subsc.cmn'

      INTEGER id

* **********************************************************************
*                                           USER CONFIGURABLE PORTION |
*                                                                     |
*                                                                     V
      INTEGER my_lo_x, my_hi_x, my_lo_t, my_hi_t,nx,nt
      CHARACTER*100 errtxt

      INTEGER arg_lo_ss(4,EF_MAX_ARGS), arg_hi_ss(4,EF_MAX_ARGS),
     .     arg_incr(4,EF_MAX_ARGS)

*
*     Use utility functions to get context information about the arguments.
*     Set the abstract X and Y axes.
*

      CALL ef_get_arg_subscripts(id, arg_lo_ss, arg_hi_ss, arg_incr)

      nx = arg_hi_ss(X_AXIS, ARG1) - arg_lo_ss(X_AXIS, ARG1) + 1
      nt = arg_hi_ss(T_AXIS, ARG1) - arg_lo_ss(T_AXIS, ARG1) + 1
      
*     The below has the effect of translating any sub-matrix so that
*     the indices will always begin at 1

      my_lo_x = 1
      my_hi_x = nx
      my_lo_t = 1
      my_hi_t = nt



      CALL ef_set_axis_limits(id, X_AXIS, my_lo_t, my_hi_t)
      CALL ef_set_axis_limits(id, T_AXIS, my_lo_x, my_hi_x)


*                                                                     ^
*                                                                     |
*                                           USER CONFIGURABLE PORTION |
* **********************************************************************

      RETURN 

 999   CONTINUE

       CALL EF_BAIL_OUT(id, errtxt)

      END




*
* In this subroutine we compute the result
*
      SUBROUTINE transpose_xt_compute(id, arg_1, result)

      INCLUDE 'ferret_cmn/EF_Util.cmn'
      INCLUDE 'ferret_cmn/EF_mem_subsc.cmn'

	  INTEGER id

      REAL bad_flag(1:EF_MAX_ARGS), bad_flag_result
      REAL arg_1(mem1lox:mem1hix, mem1loy:mem1hiy, 
     .           mem1loz:mem1hiz, mem1lot:mem1hit)
      REAL result(memreslox:memreshix, memresloy:memreshiy,
     .            memresloz:memreshiz, memreslot:memreshit)

* After initialization, the 'res_' arrays contain indexing information 
* for the result axes.  The 'arg_' arrays will contain the indexing 
* information for each variable's axes. 

      INTEGER res_lo_ss(4), res_hi_ss(4), res_incr(4)
      INTEGER arg_lo_ss(4,1:EF_MAX_ARGS), arg_hi_ss(4,1:EF_MAX_ARGS),
     .     arg_incr(4,1:EF_MAX_ARGS)

* **********************************************************************
*                                            USER CONFIGURABLE PORTION |
*                                                                      |
*                                                                      V

      INTEGER i,j,k,l
      INTEGER i1, j1, k1, l1
      CHARACTER*100 errtxt

      CALL ef_get_res_subscripts(id, res_lo_ss, res_hi_ss, res_incr)
      CALL ef_get_arg_subscripts(id, arg_lo_ss, arg_hi_ss, arg_incr)
      CALL ef_get_bad_flags(id, bad_flag, bad_flag_result)


* check to make sure both axis have points to transpose
      IF ((arg_lo_ss(T_AXIS, ARG1) .EQ. ef_unspecified_int4) .OR. 
     .     (arg_hi_ss(T_AXIS, ARG1) .EQ. ef_unspecified_int4)) THEN
         write(errtxt,*) 'T axis cannot be a normal axis'
         GOTO 999
      ELSEIF  ((arg_lo_ss(X_AXIS, ARG1) .EQ. ef_unspecified_int4) .OR. 
     .        (arg_hi_ss(X_AXIS, ARG1) .EQ. ef_unspecified_int4)) THEN
         write(errtxt,*) 'X axis cannot be a normal axis'
         GOTO 999
      ENDIF

      k1 = arg_lo_ss(Z_AXIS, ARG1)
      DO 400 k = res_lo_ss(Z_AXIS), res_hi_ss(Z_AXIS)
         j1 = arg_lo_ss(Y_AXIS, ARG1)
         DO 300 j = res_lo_ss(Y_AXIS), res_hi_ss(Y_AXIS)
            i1 = arg_lo_ss(X_AXIS, ARG1)
            DO 200 l = res_lo_ss(T_AXIS), res_hi_ss(T_AXIS) 
                l1 = arg_lo_ss(T_AXIS, ARG1)
                DO 100 i = res_lo_ss(X_AXIS), res_hi_ss(X_AXIS) 
                   IF (arg_1(i1,j1,k1,l1) .ne. bad_flag(ARG1)) THEN
                      result(i,j,k,l) = arg_1(i1,j1,k1,l1)
                   ELSE
                      result(i,j,k,l) = bad_flag_result
                   ENDIF
                   l1 = l1 + arg_incr(T_AXIS, ARG1)
 100            CONTINUE
                i1 = i1 + arg_incr(X_AXIS, ARG1)
 200         CONTINUE
             j1 = j1 + arg_incr(Y_AXIS, ARG1)
 300      CONTINUE
          k1 = k1 + arg_incr(Z_AXIS, ARG1)
 400   CONTINUE
       RETURN 
       
 999   CONTINUE

       CALL EF_BAIL_OUT(id, errtxt)
      
*                                                                      ^
*                                                                      |
*                                            USER CONFIGURABLE PORTION |
* **********************************************************************

      RETURN 
      END
