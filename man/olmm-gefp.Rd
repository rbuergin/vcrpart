\name{olmm-gefp}

\alias{olmm-gefp}
\alias{olmm_gefp}
\alias{predecor_control}
\alias{olmm_estfun}

\title{Methods for score processes of \command{\link{olmm}} objects}  

\description{Methods to extract and pre-decorrelate the (negative)
  marginal maximum likelihood observation scores and compute the
  standardized cumulative score processes of a fitted
  \command{\link{olmm}} object.
} 

\usage{
olmm_estfun(x, predecor = FALSE, control = predecor_control(),
            nuisance = NULL, ...)

predecor_control(impute = TRUE, seed = NULL, 
                 symmetric = TRUE, center = FALSE,
                 reltol = 1e-6,
                 maxit = 250L, minsize = 1L,
                 include = c("observed", "all"),
                 verbose = FALSE, silent = FALSE)

olmm_gefp(object, scores = NULL, order.by = NULL, subset = NULL,
          predecor = TRUE, parm = NULL, center = TRUE, drop = TRUE,
          silent = FALSE, ...)
}

\arguments{
  \item{x, object}{a fitted \command{\link{olmm}} object.}
  \item{predecor}{logical scalar. Indicates whether the within-subject
    correlation of the estimating equations should be removed by a linear
    transformation. See details.}
  \item{control}{a list of control parameter as produced by
    \command{\link{predecor_control}}.}
  \item{nuisance}{integer vector. Defines the coefficients which are
    regarded as nuisance and therefore omitted from the transformation.}
  \item{impute}{logical scalar. Whether missing values should be
    replaced using imputation.}
  \item{seed}{an integer scalar. Specifies the random number used for
    the \code{set.seed} call before the imputation. If set to
    \code{NULL}, \code{set.seed} is not processed.}
  \item{symmetric}{logical scalar. Whether the transformation matrix
    should be symmetric.} 
  \item{minsize}{integer scalar. The minimum number of observations for
    which entries in the transformation should be computed. Higher
    values will lead to lower accuracy but stabilize the computation.}
  \item{reltol}{convergence tolerance used to compute the transformation
    matrix.} 
  \item{maxit}{the maximum number of iterations used to compute the
    transformation matrix.}
  \item{silent}{logical scalar. Should the report of warnings be
    suppressed?}
  \item{include}{logical scalar. Whether the transformation matrix
    should be computed based on the scores corresponding to observations
    (option \code{"observed"}) or on all scores (option \code{"all"}),
    including the imputed values.}
  \item{verbose}{logical scalar. Produces messages.}
  \item{scores}{a function or a matrix. Function to extract the
    estimating equations from \code{object} or a matrix representing the
    estimating equations. If \code{NULL} (default), the
    \command{\link{olmm_estfun}} function will be used with
    argument \code{predecor} and additional arguments from \code{...}.} 
  \item{order.by}{a numeric or factor vector. The explanatory variable
    to be used to order the entries in the estimating equations. If set
    to \code{NULL} (the default) the observations are assumed to be
    ordered.}
  \item{subset}{logical vector. For extracts the subset of the
    estimating equations to be used.}
  \item{parm}{integer, logical or a character vector. Extracts the
    columns of the estimating equations.}
  \item{center}{logical scalar. \code{TRUE} subtracts, if necessary, the 
    column means of the estimating equations.}
  \item{drop}{logical. Whether singularities should be handled
    automatically (otherwise singularities yield an error).}
  \item{...}{arguments passed to other
    functions. \command{\link{olmm_gefp}} passes these arguments to
    \code{scores} if \code{scores} is a function.}
}

\value{
  \command{\link{predecor_control}} returns a list of control parameters
  for computing the pre-decorrelation transformation
  matrix. \command{\link{olmm_estfun}} returns a \command{\link{matrix}}
  with the estimating equations and \command{\link{olmm_gefp}} a list of
  class class \code{"gefp"}.  
}

\details{
  Complements the \command{estfun} method of the package \pkg{sandwich}
  and the \command{gefp} function of the package \pkg{strucchange} for
  \command{\link{olmm}} objects. \command{\link{olmm_estfun}} allows to
  pre-decorrelate the intra-individual correlation of observation
  scores, see the argument \code{predecor}. The value returned by
  \command{olmm_gefp} may be used for testing coefficient constancy
  regarding an explanatory variable \code{order.by} by the
  \command{sctest} function of package \pkg{strucchange}, see the
  examples below. 

  If \code{predecor = TRUE} in \command{\link{olmm_estfun}}, a linear
  within-subject transformation is applied that removes (approximately) 
  the intra-subject correlation from the scores. Backgrounds are
  provided by Burgin and Ritschard (2014a).
  
  Given a score matrix produced by \command{\link{olmm_estfun}}, the
  empirical fluctuation process can be computed by
  \command{\link{olmm_gefp}}. See Zeileis and Hornik
  (2007). \command{\link{olmm_gefp}} provides with \code{subset} and
  \code{parm} arguments specifically designed for nodewise tests in the
  \command{\link{tvcm}} algorithm. Using \code{subset} extracts the
  partial fluctuation process of the selected subset. Further,
  \code{center = TRUE} makes sure that the partial fluctuation process
  (starts and) ends with zero.   
}

\references{
  Zeileis A., Hornik K. (2007), Generalized M-Fluctuation Tests for
  Parameter Instability, \emph{Statistica Neerlandica}, \bold{61}(4),
  488--508. 

  Burgin R. and Ritschard G. (2015), Tree-Based Varying Coefficient 
  Regression for Longitudinal Ordinal Responses. \emph{Computational
    Statistics & Data Analysis}, \bold{86}, 65--80.
}

\author{Reto Burgin}

\seealso{\command{\link{olmm}}}

\examples{
## ------------------------------------------------------------------- #
## Dummy example :
##
## Testing coefficient constancy on 'z4' of the 'vcrpart_1' data.
## ------------------------------------------------------------------- #

data(vcrpart_1)

## extract a unbalanced subset to show to the full functionality of estfun
vcrpart_1 <- vcrpart_1[-seq(1, 100, 4),]
subset <- vcrpart_1$wave != 1L ## obs. to keep for fluctuation tests
table(table(vcrpart_1$id))

## fit the model
model <- olmm(y ~ treat + re(1|id), data = vcrpart_1)

## extract and pre-decorrelate the scores
scores <- olmm_estfun(
  model, predecor = TRUE,
  control = predecor_control(verbose = TRUE))
attr(scores, "T") # transformation matrix

## compute the empirical fluctuation process
fp <- olmm_gefp(model, scores, order.by = vcrpart_1$z4)

## process a fluctuation test
library(strucchange)
sctest(fp, functional = catL2BB(fp))
}

\keyword{methods}