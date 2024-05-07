#include "olmm.h"
#include "utils.h"
#include "tvcm.h"
#include <R_ext/Rdynload.h>

#define CALLDEF(name, n)  {#name, (DL_FUNC) &name, n}

static R_CallMethodDef CallEntries[] = {
  CALLDEF(olmm_setPar, 2),
  CALLDEF(olmm_update_marg, 2),
  CALLDEF(olmm_update_u, 1),
  CALLDEF(olmm_pred_marg, 5),
  CALLDEF(olmm_pred_margNew, 6),
  CALLDEF(vcrpart_duplicate, 1),
  CALLDEF(tvcm_nomsplits, 1),
  {NULL, NULL, 0}
};

void R_init_vcrpart(DllInfo *dll) 
{
  /* registering the functions */
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
