#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "FerMem.h"

/*
 * Functions that just forward to the appropriate malloc, realloc, and free functions.
 * This is done to remove differences in code for Ferret and PyFerret in that all the
 * differences should be contained in this files.  This also allows an easy method of 
 * "old-fashioned" debugging (print statements) of memory issues with the appropriate 
 * compiler flag.  Optimization should inline these functions, so the extra layer of 
 * function calls should not cost time in optimized code.
 *
 * A calloc equivalent is intentionally not provided.
 * To replicate calloc: ptr = FerMem_Malloc(size); memset(ptr, 0, size);
 *
 * 07/2017 *KMS* - Initial version
 */

#ifdef MEMORYDEBUG
#define DEBUGFILENAME "memorydebug.txt"
/*
 * Add the debug message to the memorydebug file.
 * For consistency, use format "%016p" to print pointers.
 */
void FerMem_WriteDebugMessage(const char *msg) {
    FILE *debugfile = fopen(DEBUGFILENAME, "a");
    if ( debugfile == NULL ) {
        perror("Unable to open for appending memory debug file " DEBUGFILENAME);
        return;
    }
    fputs(msg, debugfile);
    fclose(debugfile);
}
#endif

/*
 * Allocates memory like malloc.  If (and only if) the compile flag MEMORYDEBUG is defined, 
 * prints a line to memorydebug.txt with the allocation information.  The value of filename 
 * should be __FILE__ and the value of linenumber should be __LINE__ in the source file 
 * calling this routine.
 *
 * So: 
 *     myptr = malloc(mysize);
 * should be turned into: 
 *     myptr = FerMem_Malloc(mysize, __FILE__, __LINE__);
 */
void *FerMem_Malloc(size_t size, char *filename, int linenumber) {
    void *result = malloc(size);

#ifdef MEMORYDEBUG
    char msg[256];

    /* initialize to non-zero junk to catch uninitialized memory usage */
    memset(result, 0x6B, size);
    sprintf(msg, "%016p : 1 : memory malloc allocated for %ld bytes : file %s : line %d\n", result, size, filename, linenumber);
    FerMem_WriteDebugMessage(msg);
#endif

    return result;
}

/*
 * Reallocates memory like realloc.  If (and only if) the compile flag MEMORYDEBUG is defined, 
 * prints a line to memorydebug.txt with the allocation information.  The value of filename 
 * should be __FILE__ and the value of linenumber should be __LINE__ in the source file 
 * calling this routine.
 *
 * So: 
 *     newptr = realloc(myptr, newsize);
 * should be turned into: 
 *     newptr = FerMem_Realloc(myptr, newsize, __FILE__, __LINE__);
 */
void *FerMem_Realloc(void *ptr, size_t size, char *filename, int linenumber) {
    void *newptr;

#ifdef MEMORYDEBUG
    char msg[256];
    sprintf(msg, "%016p : 2 : memory to be realloc freed : file %s : line %d\n", ptr, filename, linenumber);
#endif

    newptr = realloc(ptr, size);

#ifdef MEMORYDEBUG
    sprintf(msg, "%016p : 3 : memory realloc allocated for %ld bytes : file %s : line %d\n", newptr, size, filename, linenumber);
    FerMem_WriteDebugMessage(msg);
#endif

    return newptr;
}

/*
 * Frees memory like free.  If (and only if) the compile flag MEMORYDEBUG is defined, 
 * prints a line to memorydebug.txt with the allocation information.  The value of filename 
 * should be __FILE__ and the value of linenumber should be __LINE__ in the source file 
 * calling this routine.
 *
 * So: 
 *     free(mymem);
 * should be turned into: 
 *     FerMem_Free(mymem, __FILE__, __LINE__);
 */
void FerMem_Free(void *ptr, char *filename, int linenumber) {

#ifdef MEMORYDEBUG
    char msg[256];
    sprintf(msg, "%016p : 4 : memory to be freed : file %s : line %d\n", ptr, filename, linenumber);
    FerMem_WriteDebugMessage(msg);
#endif

    free(ptr);
}

