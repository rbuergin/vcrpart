#ifndef  USE_FC_LEN_T
# define USE_FC_LEN_T
#endif
#include "olmm.h"
#include "utils.h"
#include <Rmath.h>
#include <R_ext/Utils.h>
#include <R_ext/Lapack.h>
#include <R_ext/BLAS.h>
#ifndef FCONE
# define FCONE
#endif

/* set array values to zero */
#define AllocVal(x, n, v) {int _I_, _SZ_ = (n); for(_I_ = 0; _I_ < _SZ_; _I_++) (x)[_I_] = (v);}

/* positions in the dims vector */
enum dimP {
  n_POS = 0,    /* number of observations */
  N_POS,        /* number of subject clusters */
  p_POS,        /* number of fixed effects */ 
  pEta_POS,     /* number of columns of X */
  pInt_POS,     /* number of colums that takes the intercept in X */
  pCe_POS,      /* number of predictor-variable fixef */
  pGe_POS,      /* number of predictor-invariant fixef */
  q_POS,        /* number of random coefficients */
  qEta_POS,     /* number of columns of W */
  qCe_POS,      /* number of predictor-variable ranef */
  qGe_POS,      /* number of predictor-invariant ranef */
  J_POS,        /* number of ordinal response levels */
  nEta_POS,     /* number of predictors = J - 1 */
  nPar_POS,     /* total number of parameters */
  nGHQ_POS,     /* number of quadrature points per dimension */
  nQP_POS,      /* number of quadrature points total */
  fTyp_POS,     /* model family (1 = cumulative, 2 = ...) */
  lTyp_POS,     /* link function (1 = logit, 2 = ...)*/
  verb_POS,     /* verbose */
  numGrad_POS,  /* whether scores are computed numerically */
  numHess_POS   /* whether Hessian is computed numerically */
};

#define X_SLOT(x) REAL(getListElement(x, "X"))
#define W_SLOT(x) REAL(getListElement(x, "W"))
#define WEIGHTS_SLOT(x) REAL(getListElement(x, "weights"))
#define WEIGHTSSBJ_SLOT(x) REAL(getListElement(x, "weights_sbj"))
#define OFFSET_SLOT(x) REAL(getListElement(x, "offset"))
#define DIMS_SLOT(x) INTEGER(getListElement(x, "dims"))
#define FIXEF_SLOT(x) REAL(getListElement(x, "fixef"))
#define RANEFCHOLFAC_SLOT(x) REAL(getListElement(x, "ranefCholFac"))
#define COEFFICIENTS_SLOT(x) REAL(getListElement(x, "coefficients"))
#define ETA_SLOT(x) REAL(getListElement(x, "eta"))
#define U_SLOT(x) REAL(getListElement(x, "u"))
#define LOGLIKOBS_SLOT(x) REAL(getListElement(x, "logLik_obs"))
#define LOGLIKSBJ_SLOT(x) REAL(getListElement(x, "logLik_sbj"))
#define LOGLIK_SLOT(x) REAL(getListElement(x, "logLik"))
#define SCOREOBS_SLOT(x) REAL(getListElement(x, "score_obs"))
#define SCORESBJ_SLOT(x) REAL(getListElement(x, "score_sbj"))
#define SCORE_SLOT(x) REAL(getListElement(x, "score"))xf
#define INFO_SLOT(x) REAL(getListElement(x, "info"))
#define GHX_SLOT(x) REAL(getListElement(x, "ghx"))
#define GHW_SLOT(x) REAL(getListElement(x, "ghw"))
#define RANEFELMAT_SLOT(x) REAL(getListElement(x, "ranefElMat"))

/**
 * ---------------------------------------------------------
 * Utility functions (may relocate them ...)
 * ---------------------------------------------------------
 */

/* set link function */

double olmm_gLink(double x, int link) {
  switch (link) {
  case 1: // logit
    return dlogis(x, 0.0, 1.0, 0.0);
  case 2: // probit
    return dnorm(x, 0.0, 1.0, 0.0);
  case 3: // cauchit
    return dcauchy(x, 0.0, 1.0, 0.0);
  default : // all other
    error("link not recognised\n");
    return NA_REAL;
  }
}

double olmm_GLink(double x, int link) {
  switch (link) {
  case 1: // logit
    return plogis(x, 0.0, 1.0, 1.0, 0.0);
  case 2: // probit
    return pnorm(x, 0.0, 1.0, 1.0, 0.0);
  case 3: // cauchit
    return pcauchy(x, 0.0, 1.0, 1.0, 0.0);
  default : // all other
    error("link not recognised\n");
    return NA_REAL;
  }
}

/**
 * ---------------------------------------------------------
 * Store a new parameter vector in a olmm object
 *
 * @param x a olmm object
 * @param par the new parameter vector to store
 * ---------------------------------------------------------
 */

SEXP olmm_setPar(SEXP x, SEXP par) {  

  const void *vmax;
  
  /* list with the results */
  SEXP rvalR = PROTECT(allocVector(VECSXP, 4));

  /* R objects which are not modified */
  int *dims = INTEGER(getListElement(x, "dims"));
  double *newPar = REAL(par);
 
  /* slots of 'x' to modify */
  SEXP fixefR = PROTECT(duplicate(getListElement(x, "fixef"))),
    vecRanefCholFacR =PROTECT(duplicate(getListElement(x, "ranefCholFac"))),
    coefficientsR = PROTECT(duplicate(getListElement(x, "coefficients"))),
    ranefElMatR = PROTECT(duplicate(getListElement(x, "ranefElMat")));
  
  double *fixef = REAL(fixefR), /* used slots */
    *vecRanefCholFac = REAL(vecRanefCholFacR),
    *coefficients = REAL(coefficientsR), 
    *ranefElMat = REAL(ranefElMatR);

  const int p = dims[p_POS], family = dims[fTyp_POS],  
    pCe = dims[pCe_POS], pGe = dims[pGe_POS],
    pEta = dims[pEta_POS], q = dims[q_POS], J = dims[J_POS], 
    nEta = dims[nEta_POS], nPar = dims[nPar_POS],
    lenVecRanefCholFac = q * q, lenVRanefCholFac = q * (q + 1) / 2,
    i1 = 1;

  const double zero = 0.0, one = 1.0; /* for matrix manipulations */
  
  /* overwrite coefficients slot */
  for (int i = 0; i < nPar; i++)
    coefficients[i] = newPar[i];
  
  /* overwrite fixed effect parameter slot */
  for (int i = 0; i < nEta; i++) {
    for (int j = 0; j < pCe; j++) {
      fixef[i * pEta + j] = newPar[i * pCe + j];
    }
    for (int j = 0; j < pGe; j++)
      fixef[i * pEta + pCe + j] = newPar[pCe * nEta + j];
  }

  /* set predictor-invariant fixed effects of adjacent-category model 
     to use the Likelihood of the baseline-category model */
  if (family == 3) {
    for (int i = 0; i < pGe; i++) {
      for (int j = 0; j < nEta; j++) {
	fixef[(pCe + pGe) * j + pCe + i] *=
	  J - j - 1;
      }
    }
  }

  /* overwrite (cholesky decompositioned) random effect parameters */
  vmax = vmaxget();
  double *vRanefCholFac = (double *)
    R_alloc(lenVRanefCholFac, sizeof(double));
  
  for (int i = 0; i < lenVRanefCholFac; i++)
    vRanefCholFac[i] = newPar[p + i];
  
  /* e.g. https://netlib.org/lapack/explore-html/d7/dda/group__gemv_ga4ac1b675072d18f902db8a310784d802.html */
  /* multiply with l. t. elimination matrix */ 
  /* TRANS: "T" > (alpha*A'*x + beta*y) */
  /* M: number of rows of A */
  /* N: number of columns of A */
  /* ALPHA: double precision  */
  /* A */
  /* LDA */
  /* X */
  /* INC */
  /* BETA */
  /* Y */
  /* INCY */
  F77_CALL(dgemv)("T", &lenVRanefCholFac, &lenVecRanefCholFac, &one, ranefElMat,
                  &lenVRanefCholFac, vRanefCholFac, &i1, &zero, vecRanefCholFac, &i1 FCONE);

  /* write updated coefficients into a list */
  SET_VECTOR_ELT(rvalR, 0, fixefR);
  SET_VECTOR_ELT(rvalR, 1, vecRanefCholFacR);
  SET_VECTOR_ELT(rvalR, 2, coefficientsR);
  SET_VECTOR_ELT(rvalR, 3, ranefElMatR);

  UNPROTECT(5);
  vmaxset(vmax);
  return rvalR;
}


/**
 * ---------------------------------------------------------
 * Update marginal log-Likelihood, score and info slots.
 *    
 * @param  x a olmm object
 *
 * @return R_NilValue
 * ---------------------------------------------------------
 */


SEXP olmm_update_marg(SEXP x, SEXP par) {

  const void *vmax;
  
  /* list with the results (the modified slots) */
  SEXP rvalR = PROTECT(allocVector(VECSXP, 11));
  
  /* get subject slot */  
  int *subject =
    INTEGER(coerceVector(getListElement(x, "subject"), INTSXP));
  
  /* integer valued slots */
  int *dims = DIMS_SLOT(x);

  /* numeric valued objects */
  double *X = X_SLOT(x),
    *W = W_SLOT(x),
    *weights_obs = WEIGHTS_SLOT(x),
    *weights_sbj = WEIGHTSSBJ_SLOT(x),
    *offset = OFFSET_SLOT(x), 
    *ghw = GHW_SLOT(x), 
    *ghx = GHX_SLOT(x);

  /* copy slots to be modified */
  SEXP etaR = PROTECT(duplicate(getListElement(x, "eta"))),
    logLik_sbjR = PROTECT(duplicate(getListElement(x, "logLik_sbj"))), 
    logLikR = PROTECT(duplicate(getListElement(x, "logLik"))), 
    score_obsR = PROTECT(duplicate(getListElement(x, "score_obs"))), 
    score_sbjR = PROTECT(duplicate(getListElement(x, "score_sbj"))), 
    scoreR = PROTECT(duplicate(getListElement(x, "score"))), 
    infoR = PROTECT(duplicate(getListElement(x, "info")));

  /* create pointers to slots to be modified */
  double *eta = REAL(etaR),
    *logLik_sbj = REAL(logLik_sbjR),
    *logLik = REAL(logLikR),
    *score_obs = REAL(score_obsR),
    *score_sbj = REAL(score_sbjR),
    *score = REAL(scoreR),
    *info = REAL(infoR);
      
  /* set constants (dimensions of vectors etc.) */
  const int n = dims[n_POS], N = dims[N_POS], 
    p = dims[p_POS], pEta = dims[pEta_POS],
    pCe = dims[pCe_POS], pGe = dims[pGe_POS], 
    q = dims[q_POS], qEta = dims[qEta_POS], 
    qCe = dims[qCe_POS], qGe = dims[qGe_POS],
    J = dims[J_POS], nPar = dims[nPar_POS], 
    nEta = dims[nEta_POS], nQP = dims[nQP_POS], 
    family = dims[fTyp_POS], link = dims[lTyp_POS], 
    numGrad = dims[numGrad_POS],
    numHess = dims[numHess_POS],
    lenVecRanefCholFac = q * q, lenVRanefCholFac = q * (q + 1) / 2;
  
  /* get response variable */
  int *yI = INTEGER(coerceVector(getListElement(x, "y"), INTSXP));
  
  /* variables for matrix operations etc. */
  int i1 = 1, tmpJ, subsTmp; 
  double one = 1.0, zero = 0.0, 
    gq_weight = 1, scoreCondInv = 0.0, 
    logLikCond_modified;
      
  /* define internal objects */
  vmax = vmaxget();
  double *etaCLM = (double*) NULL,
    *etaRanefCLM = (double*) NULL,
    *sumBL = (double*) NULL,
    *etaRanef = Calloc(n * nEta, double),
    *gq_nodes = (double *) R_alloc(q, sizeof(double)),
    *ranefVec = (double *) R_alloc(q, sizeof(double)),
    *ranef = (double *) R_alloc(qEta * nEta, sizeof(double)),
    *logLikCond_obs = Calloc(n, double),
    *logLikCond_sbj = Calloc(N, double),
    *scoreCondVar = (double *) R_alloc(family == 1 ? 2 : nEta,
				       sizeof(double)),
    *vecRanefTerm = (double *) R_alloc(lenVecRanefCholFac, sizeof(double)),
    *vRanefTerm = (double *) R_alloc(lenVRanefCholFac, sizeof(double)),
    *etaTmp = (double *) R_alloc(nEta, sizeof(double)),
    *scoreCond_obs = (double*) NULL,
    *scoreCond_sbj = (double*) NULL;

  if (numGrad == 0) {
    scoreCond_obs = Calloc(n * nPar, double);
    scoreCond_sbj = Calloc(N * nPar, double);
  }

  AllocVal(etaRanef, n * nEta, zero);

  /* update parameters */
  SEXP newParList = PROTECT(olmm_setPar(x, par));
  
  double *fixef = REAL(VECTOR_ELT(newParList, 0)),
    *ranefCholFac = REAL(VECTOR_ELT(newParList, 1)),
    *ranefElMat = REAL(VECTOR_ELT(newParList, 3));
  
  /* initialize eta = offset */
  for (int i = 0; i < (n * nEta); i++) eta[i] = offset[i];
  
  /* update eta = offset + Xb */
  if (pEta > 0L)
    F77_CALL(dgemm)("N", "N", &n, &nEta, &pEta, &one, X, &n, fixef, 
		    &pEta, &one, eta, &n FCONE FCONE);
  
  switch (family) {
  case 1: 
    etaCLM = Calloc(n * 2 , double);
    etaRanefCLM = Calloc(n * 2 , double);
    for (int i = 0; i < n; i++) {
      etaCLM[i] /* lower */
	= yI[i] > 1 ? eta[n * (yI[i] - 2) + i] : -DBL_MAX;  
      etaCLM[i + n] = /* upper */
	yI[i] < J ? eta[n * (yI[i] - 1) + i] : DBL_MAX;
    }
    break;
  case 2: case 3:
    sumBL = Calloc(n, double);
    break;
  }
  
  /* initializations */
  logLik[0] = 0;
  AllocVal(logLik_sbj, N, zero);

  if (numGrad == 0) {

    AllocVal(score, nPar, zero);
    AllocVal(score_sbj, N * nPar, zero);
    AllocVal(score_obs, n * nPar, zero);
  }
  
  /* Gauss-Hermite quadrature */

  for (int k = 0; k < nQP; k++) {
    
    /* clear temporary objects */
    AllocVal(logLikCond_obs, n, zero);
    AllocVal(logLikCond_sbj, N, zero);

    if (numGrad == 0) {
      AllocVal(scoreCond_obs, n * nPar, zero);
      AllocVal(scoreCond_sbj, N * nPar, zero);
    }

    if ((family == 2) | (family == 3)) AllocVal(sumBL, n, zero);

    /* prepare integration nodes and weights */
    for (int i = 0; i < q; i++) {
      gq_nodes[i] = ghx[nQP * i + k];
      gq_weight *= ghw[nQP * i + k];
    }
    gq_weight = log(gq_weight);

    /* multiply ranefCholFac with actual nodes */
    F77_CALL(dgemv)("N", &q, &q, &one, ranefCholFac, &q, 
		    gq_nodes, &i1, &zero, ranefVec, &i1 FCONE);

    /* ranefVec (vector) to ranef (matrix) */
    for (int i = 0; i < nEta; i++) {
      for (int j = 0; j < qCe; j++) 
      	ranef[i * qEta + j] = ranefVec[i * qCe + j];
      for (int j = 0; j < qGe; j++) 
	ranef[i * qEta + qCe + j] = ranefVec[qCe * nEta + j];
    }

    /* set predictor-invariant random effects of adjacent-category models 
       to use the Likelihood of the baseline-category model */
    if (family == 3) {
      for (int i = 0; i < qGe; i++) {
	for (int j = 0; j < nEta; j++) {
	  ranef[(qCe + qGe) * j + qCe + i] *=
	    J - j - 1; 
	}
      }
    }

    /* compute contribution of random effects to linear predictor */
    F77_CALL(dgemm)("N", "N", &n, &nEta, &qEta, &one, W, &n, 
		    ranef, &qEta, &zero, etaRanef, &n FCONE FCONE);    

    /* use etaRanefCLM to accelerate computations */
    if (family == 1) {
      for (int i = 0; i < n; i++) {
	etaRanefCLM[i] /* lower */
	  = yI[i] > 1 ? etaRanef[n * (yI[i] - 2) + i] : -DBL_MAX; 
	etaRanefCLM[n + i] = /* upper */
	  yI[i] < J ? etaRanef[n * (yI[i] - 1) + i] : DBL_MAX;
      }
    }

    /* approximate marginal log Likelihood ................. */

    for (int i = 0; i < n; i++) {     
      
      switch (family) {
      case 1: /* cumulative link model */
	logLikCond_obs[i] =
	  log(olmm_GLink(etaCLM[n + i] + etaRanefCLM[n + i], link) - 
	      olmm_GLink(etaCLM[i] + etaRanefCLM[i], link));
	logLikCond_sbj[subject[i]-1] += logLikCond_obs[i];
	break;
      case 2: case 3: /* baseline-category logit model Likelihood */
	for (int j = 0; j < nEta; j++)
	  sumBL[i] += exp(eta[n * j + i] + etaRanef[n * j + i]);
	logLikCond_obs[i] = -log(1.0 + sumBL[i]);
	if (yI[i] < J)
	  logLikCond_obs[i] += eta[n * (yI[i] - 1) + i] + 
	    etaRanef[n * (yI[i] - 1) + i];
	logLikCond_sbj[subject[i]-1] += logLikCond_obs[i];
	break;
      }
    }
      
    for (int i = 0; i < N; i++) {
      logLik_sbj[i] += exp(logLikCond_sbj[i] + gq_weight);
    }
    
    if (numGrad == 0) {
      
      /* approximate score function ........................ */
      
      for (int i = 0; i < n; i++) {

	for (int j = 0; j < nEta; j++)
	  etaTmp[j] = eta[n * j + i] + etaRanef[n * j + i];

	/* hack to avoid numeric problems with DBL_MIN, DBL_MAX */
	logLikCond_modified = 
	  ((fabs(exp(logLikCond_obs[i])) < 1E-6) & (gq_weight < 1E-6)) ?
	  DBL_MAX : logLikCond_obs[i];
	
	/* calculate the Kronecker product of u_i and w_it */
	for (int j = 0; j < q; j++) {
	  for (int l = 0; l < nEta; l++) {
	    for (int m = 0; m < qCe; m++) {
	      vecRanefTerm[q * j + l * qCe + m] = 
		gq_nodes[j] * W[n * m + i];
	    }
	  }
	  for (int l = 0; l < qGe; l++) {
	    vecRanefTerm[q * j + nEta * qCe + l] = 
	      gq_nodes[j] * W[n * (qCe + l) + i];
	  }
	}
	
	/* get vRanefTerm */
	F77_CALL(dgemv)("N", &lenVRanefCholFac, &lenVecRanefCholFac, 
			&one, ranefElMat, 
			&lenVRanefCholFac, vecRanefTerm, &i1, 
			&zero, vRanefTerm, &i1 FCONE);
	
	/* fixed effect scores ........................ */
	
	/* predictor-variable fixed effects scores .... */
      
	switch (family) {
	case 1: 
	  if (yI[i] < J) { /* score on upper concerned effects */
	    scoreCondVar[1] = 
	      olmm_gLink(etaCLM[n + i] + etaRanefCLM[n + i], link) / 
	      exp(logLikCond_modified);

	    for (int j = 0; j < pCe; j++)
	      scoreCond_obs[n * (pCe*(yI[i]-1) + j) + i] +=
		scoreCondVar[1] * X[n * j + i];
	  }	    
	  if (yI[i] > 1) { /* score on lower effects */
	    scoreCondVar[0] = 
	      -olmm_gLink(etaCLM[i] + etaRanefCLM[i], link) / 
	      exp(logLikCond_modified);

	    for (int j = 0; j < pCe; j++) {
	      scoreCond_obs[n * (pCe * (yI[i]-2) + j) + i] +=
		scoreCondVar[0] * X[n * j + i];
	    }
	  }
	  break;
	case 2: case 3:
	  
	  for (int j = 0; j < nEta; j++) {
	    scoreCondVar[j] = 
	      (yI[i]-1 == j ? 1.0 : 0.0) -
	      exp(etaTmp[j]) / (1.0 + sumBL[i]);

	    for (int l = 0; l < pCe; l++) {
	      scoreCond_obs[n * (pCe * j + l) + i] = 
		scoreCondVar[j] * X[n * l + i];
	    }
	  }
	  break;
	}

	/* predictor-invariant fixed effect scores .... */
	
	switch (family) {
	case 1:
	  scoreCondInv = /* will be used also for random effect scores */
	    (olmm_gLink(etaCLM[i + n] + etaRanefCLM[i + n], link) -
	     olmm_gLink(etaCLM[i] + etaRanefCLM[i], link)) / 
	    exp(logLikCond_modified);

	  for (int j = 0; j < pGe; j++) {
	    scoreCond_obs[n * (nEta * pCe + j) + i] =
	      scoreCondInv * X[n * (pCe + j) + i];
	  }
	  break;
	case 2: /* baseline-category model */
	  scoreCondInv = 
	    (yI[i] < J ? 1.0 : 0.0) -
	    sumBL[i] / (1.0 + sumBL[i]);

	  for (int j = 0; j < pGe; j++) {
	    scoreCond_obs[n * (nEta * pCe + j) + i] =
	      scoreCondInv * X[n * (pCe + j) + i];	      
	  }
	  break;
	case 3: /* adjacent-categories model */
	  scoreCondInv = 
	    (yI[i] < J ? 1.0 : 0.0) -
	      sumBL[i] / (1.0 + sumBL[i]);

	  for (int j = 0; j < pGe; j++) {
	    for (int l = 0; l < nEta; l++) {
	      scoreCond_obs[n * (nEta * pCe + j) + i] +=
		scoreCondVar[l] * (J - l - 1) * X[n * (j + pCe) + i];
	    }
	  }
	  break;
	}
    
	/* random effect scores ....................... */

	for (int j = 0; j < q; j++) { /* columns of RanefCholFac */
	  
	  for (int l = j; l < q; l++) { /* rows of RanefCholFac */
	    
	    subsTmp = j * q - j * (j + 1) / 2 + l;

	    if (l < qCe * nEta) {
	      
	      /* predictor-variable random effect scores */
	      
	      tmpJ = (int)(floor(l / qCe));
	      
	      switch (family) {
	      case 1: 
		if ((yI[i] < J) & (yI[i] == tmpJ)) {
		  scoreCond_obs[n * (p + subsTmp) + i] +=
		    scoreCondVar[1] * vRanefTerm[subsTmp];
		}
		if ((yI[i] > 1) & (yI[i] == tmpJ)) {
		  scoreCond_obs[n * (p + subsTmp) + i] += 
		    scoreCondVar[0] * vRanefTerm[subsTmp];
		}
		break;
	      case 2: case 3: 
		scoreCond_obs[n * (p + subsTmp) + i] = 
		  scoreCondVar[tmpJ] * vRanefTerm[subsTmp];
		break;
	      }

	    } else {
	      
	      /* predictor-invariant random effect scores */
	      
	      switch (family) {
	      case 1:
		scoreCond_obs[n * (p + subsTmp) + i] =
		  scoreCondInv * vRanefTerm[subsTmp];
		break;
	      case 2:
		scoreCond_obs[n * (p + subsTmp) + i] =
		  scoreCondInv * vRanefTerm[subsTmp];
		break;
	      case 3:
		for (int m = 0; m < nEta; m++) {
		  scoreCond_obs[n * (p + subsTmp) + i] += 
		    scoreCondVar[m] * (J - m - 1) * vRanefTerm[subsTmp];
		}
		break;
	      }
	    }
	  }
	}
      }
      
      /* add terms to score_obs */      
      for (int i = 0; i < n; i++)
	for (int j = 0; j < nPar; j++)	
	  score_obs[n * j + i] += scoreCond_obs[n * j + i] * 
	    exp(logLikCond_sbj[subject[i]-1] + gq_weight);

    }
 
    gq_weight = 1; /* reset integration weight */
  }

  Free(etaRanef);
  Free(logLikCond_obs);
  Free(logLikCond_sbj);
  if (family == 1) Free(etaCLM);
  if (family == 1) Free(etaRanefCLM);
  if ((family == 2) | (family == 3)) Free(sumBL);
  Free(scoreCond_obs);
  Free(scoreCond_sbj);

  /* add up score_obs to score_sbj (before computing info matrix!) */

  if (numGrad == 0) {

    for (int i = 0; i < n; i++)
      for (int j = 0; j < nPar; j++) {
	score_sbj[N * j + subject[i]-1] += score_obs[n * j + i];
      }
  }

  /* compute information matrix ................ */
  
  if (numHess == 0) {
 
    AllocVal(info, nPar * nPar, zero); /* reset info matrix*/
    double *hDerVec = (double *) R_alloc(nPar, sizeof(double)),
      hInv2;
    
    for (int i = 0; i < N; i++) {    
      hInv2 = - weights_sbj[i] / (logLik_sbj[i] * logLik_sbj[i]);
      for (int j = 0; j < nPar; j++) hDerVec[j] = score_sbj[i + N * j];
      F77_CALL(dgemm)("N", "T", &nPar, &nPar, &i1, &hInv2, hDerVec,
		      &nPar, hDerVec, &nPar, &one, info, &nPar FCONE FCONE);
    }
  }

  /* finish score function calculations ........ */
    
  if (numGrad == 0) {

    for (int i = 0; i < n; i++)
      for (int j = 0; j < nPar; j++)
	score_obs[n * j + i] *= weights_obs[i] / logLik_sbj[subject[i]-1];

    for (int i = 0; i < N; i++) {
      for (int j = 0; j < nPar; j++) {
	score_sbj[N * j + i] *= weights_sbj[i] / logLik_sbj[i];
	score[j] += score_sbj[N * j + i];
      }
    }
  }

  /* finish Likelihood function calculations ..... */
  
  for (int i = 0; i < N; i++) {
    logLik_sbj[i] = weights_sbj[i] * log(logLik_sbj[i]);
    logLik[0] += logLik_sbj[i];
  }

  /* write updated coefficients into a list */
  SET_VECTOR_ELT(rvalR, 0, VECTOR_ELT(newParList, 0));
  SET_VECTOR_ELT(rvalR, 1, VECTOR_ELT(newParList, 1));
  SET_VECTOR_ELT(rvalR, 2, VECTOR_ELT(newParList, 2));
  SET_VECTOR_ELT(rvalR, 3, VECTOR_ELT(newParList, 3));
  SET_VECTOR_ELT(rvalR, 4, etaR);
  SET_VECTOR_ELT(rvalR, 5, logLik_sbjR);
  SET_VECTOR_ELT(rvalR, 6, logLikR);
  SET_VECTOR_ELT(rvalR, 7, score_obsR);
  SET_VECTOR_ELT(rvalR, 8, score_sbjR);
  SET_VECTOR_ELT(rvalR, 9, scoreR);
  SET_VECTOR_ELT(rvalR, 10, infoR);
  
  /* set names of list */
  SEXP names = PROTECT(allocVector(STRSXP, 11));
  SET_STRING_ELT(names, 0, mkChar("fixef"));
  SET_STRING_ELT(names, 1, mkChar("ranefCholFac"));
  SET_STRING_ELT(names, 2, mkChar("coefficients"));
  SET_STRING_ELT(names, 3, mkChar("ranefElMat"));
  SET_STRING_ELT(names, 4, mkChar("eta"));
  SET_STRING_ELT(names, 5, mkChar("logLik_sbj"));
  SET_STRING_ELT(names, 6, mkChar("logLik"));
  SET_STRING_ELT(names, 7, mkChar("score_obs"));
  SET_STRING_ELT(names, 8, mkChar("score_sbj"));
  SET_STRING_ELT(names, 9, mkChar("score"));
  SET_STRING_ELT(names, 10, mkChar("info"));
  setAttrib(rvalR, R_NamesSymbol, names);
    
  UNPROTECT(10);
  vmaxset(vmax);
  return rvalR;
}

/**
 * ---------------------------------------------------------
 * Expected random effects given fixed effects.
 *    
 * @param  x a olmm object
 *
 * @return R_NilValue
 * ---------------------------------------------------------
 */

SEXP olmm_update_u(SEXP x) {

  const void *vmax;
  
  /* get subject slot */  
  int *subject =
    INTEGER(coerceVector(getListElement(x, "subject"), INTSXP));
  
  /* integer valued slots */
  int *dims = DIMS_SLOT(x);

  /* numeric valued objects */
  double *W = W_SLOT(x), 
    *eta = ETA_SLOT(x), 
    *ranefCholFac = RANEFCHOLFAC_SLOT(x), 
    *logLik_sbj = LOGLIKSBJ_SLOT(x), 
    *ghw = GHW_SLOT(x), *ghx = GHX_SLOT(x);

  /* copy random effect slot to be modified */
  SEXP uR = PROTECT(duplicate(getListElement(x, "u")));

  /* create a pointer to copy of random effect slot */
  double *u = REAL(uR);
    
  /* set constants (dimensions of vectors etc.) */
  const int n = dims[n_POS], N = dims[N_POS], 
    q = dims[q_POS], qEta = dims[qEta_POS], 
    qCe = dims[qCe_POS], qGe = dims[qGe_POS],
    J = dims[J_POS], nEta = dims[nEta_POS],
    nQP = dims[nQP_POS], 
    family = dims[fTyp_POS], link = dims[lTyp_POS];

  /* get response variable */
  int *yI = INTEGER(coerceVector(getListElement(x, "y"), INTSXP));

  /* variables for matrix operations */
  int i1 = 1; 
  double one = 1.0, zero = 0.0;
  
  /* define internal vectors */
  vmax = vmaxget();
  double *etaCLM = (double*) NULL,
    *etaRanefCLM = (double*) NULL,
    *sumBL = (double*) NULL,
    *etaRanef = Calloc(n * nEta, double),
    *ranefVec = (double*) R_alloc(q, sizeof(double));
    
  AllocVal(etaRanef, n * nEta, zero);

  switch (family) {
  case 1: 
    etaCLM = Calloc(n * 2 , double);
    etaRanefCLM = Calloc(n * 2 , double);
    for (int i = 0; i < n; i++) {
      etaCLM[i] /* lower */
	= yI[i] > 1 ? eta[n * (yI[i] - 2) + i] : -DBL_MAX; 
      etaCLM[n + i] = /* upper */
	yI[i] < J ? eta[n * (yI[i] - 1) + i] : DBL_MAX;
    }
    break;
  case 2: case 3:
    sumBL = Calloc(n, double);
    break;
  }

  AllocVal(u, N * q, zero);
    
  /* Gauss-Hermite quadrature */

  double *gq_nodes = (double *) R_alloc(q, sizeof(double)),
    gq_weight = 1,
    *ranef = (double *) R_alloc(qEta * nEta, sizeof(double)), 
    *logLikCond_obs = Calloc(n, double),
    *logLikCond_sbj = Calloc(N, double);
    
  for (int k = 0; k < nQP; k++) {

    /* clear temporary objects */
    AllocVal(logLikCond_obs, n, zero);
    AllocVal(logLikCond_sbj, N, zero);
    if ((family == 2) | (family == 3)) AllocVal(sumBL, n, zero);

    /* prepare integration nodes and weights */    
    for (int i = 0; i < q; i++) {
      gq_nodes[i] = ghx[nQP * i + k];
      gq_weight *= ghw[nQP * i + k];
    }
    gq_weight = log(gq_weight);
    
    /* multiply ranefCholFac with actual nodes */
    F77_CALL(dgemv)("N", &q, &q, &one, ranefCholFac, &q, 
		    gq_nodes, &i1, &zero, ranefVec, &i1 FCONE);
    
    /* ranefVec (vector) to ranef (matrix) */
    for (int i = 0; i < nEta; i++) {
      for (int j = 0; j < qCe; j++) {
	if (i * qEta + j >= qEta * nEta) error("overflow"); //
      	if (i * qCe + j >= q) error("overflow"); //
      	ranef[i * qEta + j] = ranefVec[i * qCe + j];
      }
      for (int j = 0; j < qGe; j++) {
	if (i * qEta + qCe + j >= qEta * nEta) error("overflow"); //
	if (qCe * nEta + j > q) error("overflow"); //
      	ranef[i * qEta + qCe + j] = ranefVec[qCe * nEta + j];
      }
    }

    /* set predictor-invariant random effects of adjacent-category model 
       to use the Likelihood of the baseline-category model */
    if (family == 3) {
      for (int i = 0; i < qGe; i++) {
	for (int j = 0; j < nEta; j++) {
	  ranef[j * (qCe + qGe) + qCe + i] *=
	    J - j - 1; 
	}
      }
    }

    /* compute contribution of random effects to linear predictor */
    F77_CALL(dgemm)("N", "N", &n, &nEta, &qEta, &one, W, &n, 
		    ranef, &qEta, &zero, etaRanef, &n FCONE FCONE);

    /* use etaRanefCLM to accelerate computations */
    if (family == 1) {
      for (int i = 0; i < n; i++) {
	etaRanefCLM[i] /* lower */
	  = yI[i] > 1 ? etaRanef[n * (yI[i] - 2) + i] : -DBL_MAX; 
	etaRanefCLM[i + n] = /* upper */
	  yI[i] < J ? etaRanef[n * (yI[i] - 1) + i] : DBL_MAX;
      }
    }

    for (int i = 0; i < n; i++) {     

      /* approximate log-Likelihood */

      switch (family) {
      case 1: /* cumulative link model */
	logLikCond_obs[i] = 
	  log(olmm_GLink(etaCLM[i + n] + etaRanefCLM[i + n], link) - 
	      olmm_GLink(etaCLM[i] + etaRanefCLM[i], link));
	logLikCond_sbj[subject[i]-1] += logLikCond_obs[i];
	break;
      case 2: case 3: /* baseline-category logit model Likelihood */
	for (int j = 0; j < nEta; j++)
	  sumBL[i] += exp(eta[i + j * n] + etaRanef[i + j * n]);
	logLikCond_obs[i] = -log(1.0 + sumBL[i]);
	if (yI[i] < J)
	  logLikCond_obs[i] += eta[i + n * (yI[i] - 1)] +
	    etaRanef[i + n * (yI[i] - 1)];
	logLikCond_sbj[subject[i]-1] += logLikCond_obs[i];
	break;
      }
    }
    
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < q; j++) {
	u[i + j * N] += gq_nodes[j] * exp(logLikCond_sbj[i] + gq_weight);
      }
    }

    gq_weight = 1; /* reset integration weight */
  }

  /* divide u by marginal Likelihood ............. */

  for (int i = 0; i < N; i++) {
    for (int j = 0; j < q; j++) {
      u[i + j * N] /= exp(logLik_sbj[i]);
    }
  }


  Free(etaRanef);
  Free(logLikCond_obs);
  Free(logLikCond_sbj);
  if (family == 1) Free(etaCLM);
  if (family == 1) Free(etaRanefCLM);
  if ((family == 2) | (family == 3)) Free(sumBL);
  UNPROTECT(1);
  vmaxset(vmax);
  return uR;
}


/**
 * ---------------------------------------------------------
 * Marginal predicition.
 *    
 * @param  x the 'olmm' object
 * @param  eta the linear predictor of the values to predict
 * @param  W the random coefficients design matrix of the
 *    the values to predict
 * @param  n the number of observations to predict
 * @param  pred the prediction matrix
 *
 * @return R_NilValue
 * ---------------------------------------------------------
 */

SEXP olmm_pred_marg(SEXP x, SEXP eta, SEXP W, SEXP n, SEXP pred) {

  const void *vmax;
   
  /* duplicate input matrix */
  SEXP rvalR = PROTECT(duplicate(pred));
  double *rval = REAL(rvalR);
  
  double *reta = REAL(eta), *rW = REAL(W);
  const int rn = INTEGER(n)[0];

  /* integer valued slots and pointer to factor valued slots */
  int *dims = DIMS_SLOT(x);

  /* numeric valued objects */
  double *ranefCholFac = RANEFCHOLFAC_SLOT(x),
    *ghw = GHW_SLOT(x), *ghx = GHX_SLOT(x);

  /* set constants (dimensions of vectors etc.) */
  const int q = dims[q_POS], qEta = dims[qEta_POS], 
    qCe = dims[qCe_POS], qGe = dims[qGe_POS],
    J = dims[J_POS], 
    nEta = dims[nEta_POS], nQP = dims[nQP_POS], 
    family = dims[fTyp_POS], link = dims[lTyp_POS];

  /* variables for matrix operations etc. */
  int i1 = 1;
  double one = 1.0, zero = 0.0, 
    gq_weight = 1, sumBL = 0.0;

  /* define internal objects */
  vmax = vmaxget();
  double *etaRanef = Calloc(rn * nEta, double),
    *gq_nodes = (double *) R_alloc(q, sizeof(double)),
    *predCond = Calloc(rn * J, double),
    *ranefVec = (double *) R_alloc(q, sizeof(double)),
    *ranef = (double *) R_alloc(qEta * nEta, sizeof(double));
  
  AllocVal(rval, rn * J, zero);

  for (int k = 0; k < nQP; k++) {

    AllocVal(predCond, rn * J, zero);

    /* prepare integration nodes and weights */    
    for (int i = 0; i < q; i++) {
      gq_nodes[i] = ghx[nQP * i + k];
      gq_weight *= ghw[nQP * i + k];
    }
    gq_weight = log(gq_weight);

    /* multiply ranefCholFac with actual nodes */
    F77_CALL(dgemv)("N", &q, &q, &one, ranefCholFac, &q, 
		    gq_nodes, &i1, &zero, ranefVec, &i1 FCONE);

    /* ranefVec (vector) to ranef (matrix) */
    for (int i = 0; i < nEta; i++) {
      for (int j = 0; j < qCe; j++)
      	ranef[i * qEta + j] = ranefVec[i * qCe + j];
      for (int j = 0; j < qGe; j++)
      	ranef[i * qEta + qCe + j] = ranefVec[qCe * nEta + j];
    }

    /* set predictor-invariant random effects of adjacent-category models 
       to use the Likelihood of the baseline-category model */
    if (family == 3) {
      for (int i = 0; i < qGe; i++) {
	for (int j = 0; j < nEta; j++) {
	  ranef[(qCe + qGe) * j + qCe + i] *=
	    J - j - 1; 
	}
      }
    }

    /* compute contribution of random effects to linear predictor */
    F77_CALL(dgemm)("N", "N", &rn, &nEta, &qEta, &one, rW, &rn, 
		    ranef, &qEta, &zero, etaRanef, &rn FCONE FCONE);

    /* approximate marginal probabilities .................. */
    
    for (int i = 0; i < rn; i++) { 
      for (int j = 0; j < J; j++) {

	switch (family) {
	case 1: /* cumulative link model */
	    predCond[rn * j + i] = 
	      log(olmm_GLink(j < (J - 1) ? reta[rn * j + i] + etaRanef[rn * j + i] : DBL_MAX, link) - olmm_GLink(j > 0 ? reta[rn * (j - 1) + i] + etaRanef[rn * (j - 1) + i] : -DBL_MAX, link));
	  break;
	case 2: case 3: /* baseline-category logit model Likelihood */
	  sumBL = 0;
	  for (int l = 0; l < nEta; l++)
	    sumBL += exp(reta[rn * l + i] + etaRanef[rn * l + i]);
	  predCond[rn * j + i] = -log(1.0 + sumBL);
	  if (j < (J - 1))
	    predCond[rn * j + i] += reta[rn * j + i] + etaRanef[rn * j + i];
	  break;
	}
      }
    }
    
    for (int i = 0; i < rn; i++) {
      for (int j = 0; j < J; j++) {
	rval[rn * j + i] += exp(predCond[rn * j + i] + gq_weight);
      }
    }
    
    gq_weight = 1; /* reset integration weight */
  }
  
  Free(etaRanef);
  Free(predCond);
  UNPROTECT(1);
  vmaxset(vmax);
  return rvalR;
}


SEXP olmm_pred_margNew(SEXP x, SEXP etaNew, SEXP WNew, SEXP subjectNew, 
		       SEXP nNew, SEXP pred) {

  const void *vmax;
  
  /* duplicate input matrix */
  SEXP rvalR = PROTECT(duplicate(pred));
  double *rval = REAL(rvalR);
  
  double *retaNew = REAL(etaNew), *rWNew = REAL(WNew);
  int *rsubjectNew = INTEGER(subjectNew);
  const int rnNew = INTEGER(nNew)[0];
  
  /* get subject slot */
  int *subject =
    INTEGER(coerceVector(getListElement(x, "subject"), INTSXP));
  
  /* integer valued slots */
  int *dims = DIMS_SLOT(x);

  /* numeric valued objects */
  double *ranefCholFac = RANEFCHOLFAC_SLOT(x),
    *ghw = GHW_SLOT(x), *ghx = GHX_SLOT(x), *eta = ETA_SLOT(x),
    *W = W_SLOT(x), *logLik_sbj = LOGLIKSBJ_SLOT(x);

  /* set constants (dimensions of vectors etc.) */
  const int q = dims[q_POS], qEta = dims[qEta_POS], 
    qCe = dims[qCe_POS], qGe = dims[qGe_POS],
    J = dims[J_POS], N = dims[N_POS], n = dims[n_POS], 
    nEta = dims[nEta_POS], nQP = dims[nQP_POS], 
    family = dims[fTyp_POS], link = dims[lTyp_POS];
  
  /* get response variable */
  int *yI = INTEGER(coerceVector(getListElement(x, "y"), INTSXP));

  /* variables for matrix operations etc. */
  int i1 = 1;
  double one = 1.0, zero = 0.0, 
    gq_weight = 1, sumBL = 0.0,
    logLikCond_obs, lTmp;
  
  /* define internal objects */
  vmax = vmaxget();
  double *etaRanefNew = Calloc(rnNew * nEta, double),
    *etaRanef = Calloc(n * nEta, double),
    *logLikCond_sbj = Calloc(rnNew, double),
    *gq_nodes = (double *) R_alloc(q, sizeof(double)),
    *predCond = Calloc(rnNew * J, double),
    *ranefVec = (double *) R_alloc(q, sizeof(double)),
    *ranef = (double *) R_alloc(qEta * nEta, sizeof(double));
  
  AllocVal(rval, rnNew * J, zero);

  for (int k = 0; k < nQP; k++) {
    
    AllocVal(predCond, rnNew * J, zero);
    AllocVal(logLikCond_sbj, rnNew, zero);

    /* prepare integration nodes and weights */    
    for (int i = 0; i < q; i++) {
      gq_nodes[i] = ghx[nQP * i + k];
      gq_weight *= ghw[nQP * i + k];
    }
    gq_weight = log(gq_weight);

    /* multiply ranefCholFac with actual nodes */
    F77_CALL(dgemv)("N", &q, &q, &one, ranefCholFac, &q, 
		    gq_nodes, &i1, &zero, ranefVec, &i1 FCONE);

    /* ranefVec (vector) to ranef (matrix) */
    for (int i = 0; i < nEta; i++) {
      for (int j = 0; j < qCe; j++)
      	ranef[i * qEta + j] = ranefVec[i * qCe + j];
      for (int j = 0; j < qGe; j++)
      	ranef[i * qEta + qCe + j] = ranefVec[qCe * nEta + j];
    }


    /* set predictor-invariant random effects of adjacent-category models 
       to use the Likelihood of the baseline-category model */
    if (family == 3) {
      for (int i = 0; i < qGe; i++) {
	for (int j = 0; j < nEta; j++) {
	  ranef[(qCe + qGe) * j + qCe + i] *=
	    J - j - 1; 
	}
      }
    }

    /* compute contribution of random effects to linear predictor */

    /* observation in model */
    F77_CALL(dgemm)("N", "N", &n, &nEta, &qEta, &one, W, &n, 
		    ranef, &qEta, &zero, etaRanef, &n FCONE FCONE);
    /* new observations */
    F77_CALL(dgemm)("N", "N", &rnNew, &nEta, &qEta, &one, rWNew, &rnNew, 
		    ranef, &qEta, &zero, etaRanefNew, &rnNew FCONE FCONE);

    /* approximate marginal probabilities .................. */

    for (int i = 0; i < rnNew; i++) {

      /* compute conditional probability */
      
      for (int i2 = 0; i2 < n; i2++) {
	
	logLikCond_obs = 0;	 	  
	if (subject[i2] == rsubjectNew[i]) {	  

	  switch (family) {
	  case 1: 
	    for (int j = 0; j < J; j++) {
	      if (yI[i2] - 1 == j) {
		logLikCond_obs = log(olmm_GLink(j < (J - 1) ? eta[n * j + i2] + etaRanef[n * j + i2] : DBL_MAX, link) - olmm_GLink(j > 0 ? eta[n * (j - 1) + i2] + etaRanef[n * (j - 1) + i2] : -DBL_MAX, link));
		logLikCond_sbj[i] += logLikCond_obs;
	      }
	    }
	    break;
	  case 2: case 3:
	    sumBL = 0;
	    for (int j = 0; j < nEta; j++)
	      sumBL += exp(eta[n * j + i2] + etaRanef[n * j + i2]);
	    logLikCond_obs = -log(1.0 + sumBL);
	    if (yI[i2] < J)
	      logLikCond_obs += eta[n * (yI[i2] - 1) + i2] + 
		etaRanef[n * (yI[i2] - 1) + i2];
	    logLikCond_sbj[i] += logLikCond_obs;
	    break;
	  }
	}
      }
      
      for (int j = 0; j < J; j++) {
	
	/* compute conditional prediction */
	switch (family) {
	case 1:
	  predCond[rnNew * j + i] = 
	    log(olmm_GLink(j < (J - 1) ? retaNew[rnNew * j + i] + etaRanefNew[rnNew * j + i] : DBL_MAX, link) - olmm_GLink(j > 0 ? retaNew[rnNew * (j - 1) + i] + etaRanefNew[rnNew * (j - 1) + i] : -DBL_MAX, link));
	  break;
	case 2: case 3:
	  sumBL = 0;
	  for (int l = 0; l < nEta; l++)
	    sumBL += exp(retaNew[rnNew * l + i] + etaRanefNew[rnNew * l + i]);
	  predCond[rnNew * j + i] = -log(1.0 + sumBL);
	  if (j < (J - 1))
	    predCond[rnNew * j + i] += 
	      retaNew[rnNew * j + i] + etaRanefNew[rnNew * j + i];
	  break;
	}
      }
    }
    
    for (int i = 0; i < rnNew; i++) {
      for (int j = 0; j < J; j++) {
	lTmp = rsubjectNew[i] < N ? logLik_sbj[rsubjectNew[i] - 1] : 0;
	rval[rnNew * j + i] += 
	  exp(predCond[rnNew * j + i] + gq_weight + logLikCond_sbj[i] - lTmp);
      }
    }

    gq_weight = 1; /* reset integration weight */
    
  }

  Free(logLikCond_sbj);
  Free(etaRanef);
  Free(etaRanefNew);
  Free(predCond);
  UNPROTECT(1);
  vmaxset(vmax);
  return rvalR;
}
