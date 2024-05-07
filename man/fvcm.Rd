\name{fvcm}

\alias{fvcm}
\alias{fvcm_control}
\alias{fvcolmm}
\alias{fvcolmm_control}
\alias{fvcglm}
\alias{fvcglm_control}

\title{Bagging and Random Forests based on \command{\link{tvcm}}}

\description{
  Bagging (Breiman, 1996) and Random Forest (Breiman, 2001) ensemble
  algorithms for \command{\link{tvcm}}.
}

\usage{

fvcm(..., control = fvcm_control())

fvcm_control(maxstep = 10, minsize = 10,
             folds = folds_control("subsampling", K = 100),
             mtry = 5, sctest = FALSE, alpha = 1.0,
             mindev = 0.0, verbose = TRUE, ...)

fvcolmm(..., family = cumulative(), control = fvcolmm_control())

fvcolmm_control(maxstep = 10, minsize = 20, 
                folds = folds_control("subsampling", K = 100),
                mtry = 5, sctest = TRUE, alpha = 1.0,  
                nimpute = 1, verbose = TRUE, ...)

fvcglm(..., family, control = fvcglm_control())

fvcglm_control(maxstep = 10, minsize = 10,
               folds = folds_control("subsampling", K = 100),
               mtry = 5, mindev = 0,
               verbose = TRUE, ...)
}

\arguments{
  \item{\ldots}{for \command{\link{fvcm}}, \command{\link{fvcolmm}} and
    \command{\link{fvcglm}} arguments to be passed to
    \command{\link{tvcm}}. This includes at least the arguments
    \code{formula}, \code{data} and \code{family}, see examples below. For
    \command{\link{fvcm_control}} further control arguments to be passed
    to \command{\link{tvcm_control}}. For
    \command{\link{fvcolmm_control}} and
    \command{\link{fvcglm_control}} further control arguments to be passed
    to \command{\link{fvcm_control}}}.       
  \item{control}{a list of control parameters as produced by
    \command{\link{fvcm_control}}.} 
  \item{family}{the model family, e.g., \command{\link{binomial}} or 
    \command{\link{cumulative}}.} 
  \item{maxstep}{integer. The maximum number of steps for when growing
    individual trees.}
  \item{folds}{a list of parameters to control the extraction of subsets, 
    as created by \command{\link{folds_control}}.}
  \item{mtry}{positive integer scalar. The number of combinations of
    partitions, nodes and variables to be randomly sampled as candidates
    in each iteration.}
  \item{sctest}{logical scalar. Defines whether coefficient constancy
    tests should be used for the variable and node selection in each
    iteration.}
  \item{mindev, alpha}{these parameters are merely specified to
    disable the default stopping rules for \command{\link{tvcm}}. See
    also \command{\link{tvcm_control}} for details.}
  \item{minsize, nimpute}{special parameter settings for
    \command{\link{fvcolmm}}. The minimum node size is set to the
    default of \command{\link{tvcolmm}}. The default \code{nimpute}
    deactivates the imputation procedure in cases of unbalanced data.}
  \item{verbose}{logical. Should information about the fitting process
    be printed to the screen?}
}

\details{
  Implements the \emph{Bagging} (Breiman, 1996) and \emph{Random
  Forests} (Breiman, 2001) ensemble algorithms for
  \command{\link{tvcm}}. The method consist in growing multiple trees by
  using \command{\link{tvcm}} and aggregating the fitted coefficient
  functions in the scale of the predictor function. To enable bagging,
  use \code{mtry = Inf} in \command{\link{fvcm_control}}.    

  \command{\link{fvcolmm}} and \command{\link{fvcglm}} are the
  extensions for \command{\link{tvcolmm}} and
  \command{\link{tvcglm}}.

  \command{\link{fvcm_control}} is a wrapper of
  \command{\link{tvcm_control}} and the arguments indicated specify
  modified defaults and parameters for randomizing split
  selections. Notice that, relative to \command{\link{tvcm_control}},
  also the \code{cv} \code{prune} arguments are internally disabled. The
  default arguments for \code{alpha} and \code{maxoverstep} essentially
  disable the stopping rules of \command{\link{tvcm}}, where the
  argument \code{maxstep} (the number of iterations i.e. the maximum
  number of splits) fully controls the stopping. The parameter
  \code{mtry} controls the randomization for selecting combinations of
  partitions, nodes and variables for splitting. The default of
  \code{mtry = 5} is arbitrary.
}

\value{An object of class \code{fvcm}.}

\author{Reto Burgin}

\references{
  Breiman, L. (1996). Bagging Predictors. \emph{Machine Learning},
  \bold{24}(2), 123--140.
  
  Breiman, L. (2001). Random Forests. \emph{Machine Learning},
  \bold{45}(1), 5--32.

  Hastie, T., R. Tibshirani and J. Friedman (2001). \emph{The Elements
    of Statistical Learning} (2 ed.). New York, USA: Springer-Verlag.

  Burgin, R. A. (2015). Tree-based methods for moderated regression
  with application to longitudinal data. PhD thesis. University of
  Geneva. 
}

\seealso{\command{\link{fvcm-methods}}, \command{\link{tvcm}}, 
  \command{\link{glm}}, \command{\link{olmm}}}

\examples{
## ------------------------------------------------------------------- #
## Dummy example:
##
## Bagging 'tvcm' on the artificially generated data 'vcrpart_3'. The 
## true coefficient function is a sinus curve between -pi/2 and pi/2. 
## The parameters 'maxstep = 3' and 'K = 5' are chosen to restrict the 
## computations.
## ------------------------------------------------------------------- #

## simulated data
data(vcrpart_3)

## setting parameters
control <-
  fvcm_control(maxstep = 3, 
               folds = folds_control("subsampling", K = 5, 0.5, seed = 3))

## fitting the forest
model <- fvcm(y ~ vc(z1, by = x1), data = vcrpart_3, 
              family = gaussian(), control = control)

## plot the first two trees
plot(model, "coef", 1:2)

## plotting the partial dependency of the coefficient for 'x1'
plot(model, "partdep")
}

\keyword{models}