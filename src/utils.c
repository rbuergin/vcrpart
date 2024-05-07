#include "utils.h"
#include <Rmath.h>


/**
 * ---------------------------------------------------------
 * Duplicate an R object
 *
 * @param x an R object.
 *
 * @return the duplicate of 'x'
 * ---------------------------------------------------------
 */

SEXP vcrpart_duplicate(SEXP x) {
  SEXP rval = PROTECT(duplicate(x));
  UNPROTECT(1);
  return rval;
}

/**
 * ---------------------------------------------------------
 * Get list elements
 *
 * @param list a list.
 * @param str a character string.
 *
 * @return a list element
 * ---------------------------------------------------------
 */

SEXP getListElement(SEXP list, const char *str) {
  SEXP elmt = R_NilValue, names = getAttrib(list, R_NamesSymbol); 
  for (int i = 0; i < length(list); i++)
    if(strcmp(CHAR(STRING_ELT(names, i)), str) == 0) {
      elmt = VECTOR_ELT(list, i);
      break;
    }
  return elmt;
}
