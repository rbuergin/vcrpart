#ifndef VCRPART_UTILS_H
#define VCRPART_UTILS_H

#include <R.h>
#include <Rdefines.h>

SEXP vcrpart_duplicate(SEXP x);
SEXP getListElement(SEXP list, const char *str);

#endif
