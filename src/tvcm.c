#include "tvcm.h"

/**
 * ---------------------------------------------------------
 * Computes the split matrix for nominal variables for
 * the 'tvcm' algorithm.
 *
 * @param nLevs total number of categories.
 * @param xdlev integer vector levels observed have a 
      1 and the other a 0
 * @param nCuts number of possible splits with the categories
 *    observed in the current node.
 *
 * @return an integer vector of length nCuts x nLevs to be used
 *    to construct the split matrix.
 * ---------------------------------------------------------
 */

SEXP tvcm_nomsplits(SEXP zdlev) {
  zdlev = PROTECT(coerceVector(zdlev, INTSXP));
  int *rzdlev = INTEGER(zdlev);
  int nLevs = length(zdlev), nLevsD = 0, nCuts = 1;
  for (int l = 0; l < nLevs; l++) nLevsD += rzdlev[l];
  for (int l = 0; l < (nLevsD - 1); l++) nCuts *= 2;
  nCuts = nCuts - 1;
  SEXP indz = PROTECT(allocMatrix(INTSXP, nCuts, nLevs));
  int *rindz = INTEGER(indz);
  for (int i = 0; i < (nLevs * nCuts); i++) rindz[i] = 0;
  int ii = 0;
  if (nCuts > 0) {
    for (int i = 0; i < nCuts; i++) {
      ii = i + 1;
      for (int l = 0; l < nLevs; l++) {
	if (rzdlev[l] > 0) {
	  rindz[i + nCuts * l] = ii % 2;
	  ii = ii / 2;
	}
      }
    }
  }
  UNPROTECT(2);
  return indz;
}
