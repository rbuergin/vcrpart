\name{tvcolmm}

\alias{tvcolmm}
\alias{tvcolmm_control}

\title{Tree-based varying coefficient regression based on ordinal and
  nominal two-stage linear mixed models.}

\description{The \command{\link{tvcolmm}} function implements the
  tree-based longitudinal varying coefficient regression algorithm
  proposed in Burgin and Ritschard (2015). The algorithm approximates
  varying fixed coefficients in the cumulative logit mixed model by a
  (multivariate) piecewise constant function using recursive
  partitioning, i.e., it estimates the fixed effect component of the
  model separately for strata of the value space of partitioning
  variables. 
}

\usage{
tvcolmm(formula, data, family = cumulative(), 
        weights, subset, offset, na.action = na.omit, 
        control = tvcolmm_control(), ...)

tvcolmm_control(sctest = TRUE, alpha = 0.05, bonferroni = TRUE,
                minsize = 50, maxnomsplit = 5, maxordsplit = 9,
                maxnumsplit = 9, fast = TRUE,
                trim = 0.1, estfun.args = list(), nimpute = 5,
                seed = NULL, maxstep = 1e3, verbose = FALSE, ...)
}

\arguments{
  \item{formula}{a symbolic description of the model to fit, e.g.,
    
    \code{y ~ -1 + vc(z1, \ldots, zL, by = x1 + \ldots + xP, intercept = TRUE) + re(1|id)}
    
    where \code{vc} term specifies the varying fixed coefficients. Only
    one such \code{vc} term is allowed with
    \command{\link{tvcolmm}} (in contrast to \command{\link{tvcglm}}
    where multiple \code{vc} terms can be specified). The above example 
    formula removes the global intercepts and adds locally varying
    intercepts, by adding a \code{-1} term and specfiying \code{intercept
    = TRUE} in the \code{vc} term. If varying intercepts are desired, we
    recommend to always remove the global intercepts. For more details on
    the formula specification, see \command{\link{olmm}} and
    \command{\link{vcrpart-formula}}.}   
  \item{family}{the model family. An object of class
    \command{\link{family.olmm}}.}    
  \item{data}{a data frame containing the variables in the model.}
  \item{weights}{an optional numeric vector of weights to be used in the 
    fitting process.}
  \item{subset}{an optional logical or integer vector specifying a
    subset of \code{'data'} to be used in the fitting process.}
  \item{offset}{this can be used to specify an a priori known component 
    to be included in the linear predictor during fitting.} 	
  \item{na.action}{a function that indicates what should happen if data 
    contain \code{NA}s. The default \code{na.action = na.omit} is
    listwise deletion, i.e., observations with missings on any variable
    are dropped. See \command{\link{na.action}}.}
  \item{control}{a list with control parameters as returned by
    \command{\link{tvcolmm_control}}, or by \command{\link{tvcm_control}}
    for advanced users.}
  \item{sctest}{logical scalar. Defines whether coefficient constancy
    tests should be used for the variable and node selection in each
    iteration.}
  \item{alpha}{numeric significance threshold between 0 and 1. A node is
    splitted when the smallest (possibly Bonferroni-corrected) \eqn{p}
    value for any coefficient constancy test in the current step falls
    below \code{alpha}.}  
  \item{bonferroni}{logical. Indicates if and how \eqn{p}-values of
    coefficient constancy tests must be Bonferroni
    corrected. See details.}
  \item{minsize}{numeric scalar. The minimum sum of weights in terminal
    nodes.}
  \item{maxnomsplit, maxordsplit, maxnumsplit}{integer scalars for split
    candidate reduction. See \command{\link{tvcm_control}}.}
  \item{fast}{logical scalar. Whether the approximative model should be
    used to search for the next split. See
    \command{\link{tvcm_control}}.}
  \item{trim}{numeric between 0 and 1. Specifies the trimming parameter
    in coefficient constancy tests for continuous partitioning
    variables. See also the argument \code{from} of function
    \code{supLM} in package \pkg{strucchange}.}
  \item{estfun.args}{list of arguments to be passed to
    \command{\link{olmm_gefp}}. See details.}
  \item{nimpute}{a positive integer scalar. The number of times
    coefficient constancy tests should be repeated in each
    iteration. See details.}
  \item{seed}{an integer specifying which seed should be set at the
    beginning.}
  \item{maxstep}{integer. The maximum number of iterations i.e. number
    of splits to be processed.}  
  \item{verbose}{logical. Should information about the fitting process
    be printed to the screen?}
  \item{\ldots}{additional arguments passed to the fitting function
    \code{fit} or to \command{\link{tvcm_control}}.}  
}

\details{
  The \command{\link{tvcolmm}} function iterates the following steps:

  \enumerate{
    \item Fit the current mixed model

    \code{y ~ Node:x1 + \ldots + Node:xP + re(1 + w1 + \ldots |id)}
    
    with \command{\link{olmm}}, where \code{Node} is a categorical
    variable with terminal node labels \code{1}, \ldots, \code{M}. 

    \item Test the constancy of the fixed effects \code{Node:x1,
    \ldots}, separately for each moderator \code{z1}, \ldots, \code{zL}
    in each node \code{1}, \ldots, \code{M}. This yields \code{L} times
    \code{M} (possibly Bonferroni corrected) \eqn{p}-values for
    rejecting coefficient constancy.

    \item If the minimum \eqn{p}-value is smaller than \code{alpha},
    then select the node and the variable corresponding to the minimum
    \eqn{p}-value. Search and incorporate the optimal
    among the candidate splits in the selected node and variable by
    exhaustive likelihood search.
    
    \item Else if minimum \eqn{p}-value is larger than \code{alpha},
    stop the algorithm and return the current model.
  }

  The implemented coefficient constancy tests used for node and variable
  selection (step 2) are based on the M-fluctuation tests of Zeileis and
  Hornik (2007), using the observation scores of the fitted mixed
  model. The observation scores can be extracted by
  \command{\link{olmm_estfun}} for models fitted with
  \command{\link{olmm}}. To deal with intra-individual correlations
  between such observation scores, the \command{\link{olmm_estfun}}
  function decorrelates the observation scores. In cases of unbalanced
  data, the pre-decorrelation method requires imputation. \code{nimpute}
  gives the number of times the coefficient constancy tests are repeated
  in each iteration. The final \eqn{p}-values are then the averages of
  the repetations.

  The algorithm combines the splitting technique of Zeileis (2008) with
  the technique of Hajjem et. al (2011) and Sela and Simonoff (2012) to
  incorporate regression trees into mixed models.

  For the exhaustive search, the algorithm implements a number of split
  point reduction methods to decrease the computational complexity. See
  the arguments \code{maxnomsplit}, \code{maxordsplit} and
  \code{maxnumsplit}. By default, the algorithm also uses the
  approximative search model approach proposed in Burgin and Ritschard
  (2017). To disable this option to use the original algorithm, set
  \code{fast = FALSE} in \command{\link{tvcolmm_control}}.

  Special attention is given to varying intercepts, i.e. the terms that
  account for the direct effects of the moderators. A common
  specification is 

  \code{y ~ -1 + vc(z1, \ldots, zL, by = x1 + \ldots + xP, intercept = TRUE) + re(1 + w1 + \ldots |id)}

  Doing so replaces the globale intercept by local intercepts. As
  mentioned, if a varying intercepts are desired, we recommend to always
  remove the global intercept. 
 }

\value{An object of class \command{\link{tvcm}}
}

\references{
  Zeileis, A., T. Hothorn, and K. Hornik (2008). Model-Based
  Recursive Partitioning. \emph{Journal of Computational and Graphical
    Statistics}, \bold{17}(2), 492--514. 

  Zeileis A., Hornik K. (2007), Generalized M-Fluctuation Tests for
  Parameter Instability, \emph{Statistica Neerlandica}, \bold{61}(4),
  488--508.
  
  Burgin R. and Ritschard G. (2015), Tree-Based Varying Coefficient 
  Regression for Longitudinal Ordinal Responses. \emph{Computational
    Statistics & Data Analysis}, \bold{86}, 65--80.

  Burgin, R. and G. Ritschard (2017), Coefficient-Wise Tree-Based
  Varying Coefficient Regression with vcrpart. \emph{Journal of
  Statistical Software}, \bold{80}(6), 1--33.

  Sela R. and J. S. Simonoff (2012). RE-EM trees: A Data Mining
  Approach for Longitudinal and Clustered data, \emph{Machine Learning}
  \bold{86}(2), 169--207. 
  
  A. Hajjem, F. Bellavance and D. Larocque (2011), Mixed Effects
  Regression Trees for Clustered Data, \emph{Statistics & Probability
    Letters} \bold{81}(4), 451--459.
}

\seealso{\command{\link{tvcm_control}}, \command{\link{tvcm-methods}},
  \command{\link{tvcm-plot}}, \command{\link{fvcolmm}},
  \command{\link{olmm}}} 

\examples{
## ------------------------------------------------------------------- # 
## Example: Moderated effect effect of unemployment
##
## Here we fit a varying coefficient ordinal linear mixed on the 
## synthetic ordinal longitudinal data 'unemp'. The interest is whether 
## the effect of unemployment 'UNEMP' on happiness 'GHQL' is moderated 
## by 'AGE', 'FISIT', 'GENDER' and 'UEREGION'. 'FISIT' is the only true  
## moderator. For the the partitioning we coefficient constancy tests,
## as described in Burgin and Ritschard (2015)
## ------------------------------------------------------------------- #

data(unemp)

## fit the model
model.UE <-
  tvcolmm(GHQL ~ -1 + 
          vc(AGE, FISIT, GENDER, UEREGION, by = UNEMP, intercept = TRUE) +
          re(1|PID), data = unemp)

## diagnosis
plot(model.UE, "coef")
summary(model.UE)
splitpath(model.UE, steps = 1, details = TRUE)
}

\author{Reto Burgin}

\keyword{tree}