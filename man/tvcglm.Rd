\name{tvcglm}

\alias{tvcglm}
\alias{tvcglm_control}

\title{Coefficient-wise tree-based varying coefficient regression based
  on generalized linear models}

\description{The \command{\link{tvcglm}} function implements the
  tree-based varying coefficient regression algorithm for generalized
  linear models introduced by Burgin and Ritschard (2017). The
  algorithm approximates varying coefficients by piecewise constant
  functions using recursive partitioning, i.e., it estimates the
  selected coefficients individually by strata of the value space of
  partitioning variables. The special feature of the provided algorithm
  is that it allows building for each varying coefficient an individual
  partition, which enhances the possibilities for model specification
  and to select partitioning variables individually by coefficient.
}

\usage{
tvcglm(formula, data, family, 
       weights, subset, offset, na.action = na.omit, 
       control = tvcglm_control(), ...)

tvcglm_control(minsize = 30, mindev = 2.0,
               maxnomsplit = 5, maxordsplit = 9, maxnumsplit = 9,
               cv = TRUE, folds = folds_control("kfold", 5),
               prune = cv, fast = TRUE, center = fast,
	       maxstep = 1e3, verbose = FALSE, ...)
}

\arguments{
  \item{formula}{a symbolic description of the model to fit, e.g.,

    \code{y ~ vc(z1, z2, z3) + vc(z1, z2, by = x1) + vc(z2, z3, by = x2)}
    
    where the \code{vc} terms specify the varying fixed
    coefficients. The unnamed arguments within \code{vc} terms are
    interpreted as partitioning variables (i.e., moderators). The
    \code{by} argument specifies the associated predictor variable. If
    no such predictor variable is specified (e.g., see the first term in
    the above example formula), the \code{vc} term is interpreted as a
    varying intercept, i.e., an nonparametric estimate of the direct
    effect of the partitioning variables. For details, see
    \command{\link{vcrpart-formula}}. Note that the global intercept may
    be removed by a \code{-1} term, according to the desired
    interpretation of the model.} 
  \item{family}{the model family. An object of class
    \command{\link{family}}.}   
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
    \command{\link{tvcglm_control}}, or by \command{\link{tvcm_control}}
    for advanced users.}
  \item{minsize}{numeric (vector). The minimum sum of weights in
    terminal nodes.}
  \item{mindev}{numeric scalar. The minimum permitted training error 
    reduction a split must exhibit to be considered of a new split.
    The main role of this parameter is to save computing time by early
    stopping. May be set lower for very few partitioning variables
    resp. higher for many partitioning variables. }
  \item{maxnomsplit, maxordsplit, maxnumsplit}{integer scalars for split
    candidate reduction. See \command{\link{tvcm_control}}}
  \item{cv}{logical scalar. Whether or not the \code{cp} parameter
    should be cross-validated. If \code{TRUE} \command{\link{cvloss}} is
    called.} 
  \item{folds}{a list of parameters to create folds as produced by 
    \command{\link{folds_control}}. Is used for cross-validation.}
  \item{prune}{logical scalar. Whether or not the initial tree should be
    pruned by the estimated \code{cp} parameter from
    cross-validation. Cannot be \code{TRUE} if \code{cv = FALSE}.}
  \item{fast}{logical scalar. Whether the approximative model should be
    used to search for the next split. The approximative search model
    uses only the observations of the node to split and incorporates the
    fitted values of the current model as offsets. Therewith the
    estimation is reduces to the coefficients of the added split. If
    \code{FALSE}, the accurate search model is used.}
  \item{center}{logical integer. Whether the predictor variables of
    update models during the grid search should be centered. Note that
    \code{TRUE} will not modify the predictors of the fitted model.}
  \item{maxstep}{integer. The maximum number of iterations i.e. number
    of splits to be processed.}  
  \item{verbose}{logical. Should information about the fitting process
    be printed to the screen?}
  \item{\ldots}{additional arguments passed to the fitting function
    \code{fit} or to \command{\link{tvcm_control}}.}  
}

\details{
  \command{\link{tvcglm}} processes two stages. The first stage, called 
  partitioning stage, builds overly fine partitions for each \code{vc}
  term; the second stage, called pruning stage, selects the best-sized
  partitions by collapsing inner nodes. For details on the pruning
  stage, see \command{\link{tvcm-assessment}}. The partitioning stage
  iterates the following steps: 

  \enumerate{
    \item Fit the current generalized linear model

    \code{y ~ NodeA:x1 + \ldots + NodeK:xK}
    
    with \command{\link{glm}}, where \code{Nodek} is a categorical
    variable with terminal node labels for the \eqn{k}-th varying
    coefficient. 

    \item Search the globally best split among the candidate splits by
    an exhaustive -2 likelihood training error search that cycles
    through all possible splits.

    \item If the -2 likelihood training error reduction of the best
    split is smaller than \code{mindev} or there is no candidate split
    satisfying the minimum node size \code{minsize}, stop the
    algorithm. 

    \item Else incorporate the best split and repeat the procedure.
  }

  The partitioning stage selects, in each iteration, the split that
  maximizes the -2 likelihood training error reduction, compared to the
  current model. The default stopping parameters are \code{minsize = 30}
  (a minimum node size of 30) and \code{mindev = 2} (the training error
  reduction of the best split must be larger than two to continue).

  The algorithm implements a number of split point reduction methods to
  decrease the computational complexity. See the arguments
  \code{maxnomsplit}, \code{maxordsplit} and \code{maxnumsplit}.

  The algorithm can be seen as an extension of CART (Breiman et. al.,
  1984) and PartReg (Wang and Hastie, 2014), with the new feature that
  partitioning can be processed coefficient-wise.
 }

\value{An object of class \command{\link{tvcm}}
}

\references{
  Breiman, L., J. H. Friedman, R. A. Olshen and C.J. Stone (1984).  
  \emph{Classification and Regression Trees}. New York, USA: Wadsworth. 
  
  Wang, J. C., Hastie, T. (2014), Boosted Varying-Coefficient
  Regression Models for Product Demand Prediction, \emph{Journal of
    Computational and Graphical Statistics}, \bold{23}(2), 361-382. 

  Burgin, R. and G. Ritschard (2017), Coefficient-Wise Tree-Based
  Varying Coefficient Regression with vcrpart. \emph{Journal of
    Statistical Software}, \bold{80}(6), 1--33.
}

\seealso{\command{\link{tvcm_control}}, \command{\link{tvcm-methods}},
  \command{\link{tvcm-plot}}, \command{\link{tvcm-plot}},
  \command{\link{tvcm-assessment}}, \command{\link{fvcglm}},
  \command{\link{glm}}} 

\examples{
## ------------------------------------------------------------------- #  
## Example: Moderated effect of education on poverty
##
## The algorithm is used to find out whether the effect of high
## education 'EduHigh' on poverty 'Poor' is moderated by the civil
## status 'CivStat'. We specify two 'vc' terms in the logistic
## regression model for 'Poor': a first that accounts for the direct
## effect of 'CivStat' and a second that accounts for the moderation of
## 'CivStat' on the relation between 'EduHigh' and 'Poor'. We use here
## the 2-stage procedure with a partitioning- and a pruning stage as
## described in Burgin and Ritschard (2017). 
## ------------------------------------------------------------------- #

data(poverty)
poverty$EduHigh <- 1 * (poverty$Edu == "high")

## fit the model
model.Pov <-
  tvcglm(Poor ~ -1 +  vc(CivStat) + vc(CivStat, by = EduHigh) + NChild, 
         family = binomial(), data = poverty, subset = 1:200,
         control = tvcm_control(verbose = TRUE, papply = lapply,
           folds = folds_control(K = 1, type = "subsampling", seed = 7)))

## diagnosis
plot(model.Pov, "cv")
plot(model.Pov, "coef")
summary(model.Pov)
splitpath(model.Pov, steps = 1:3)
prunepath(model.Pov, steps = 1)
}

\author{Reto Burgin}

\keyword{tree}