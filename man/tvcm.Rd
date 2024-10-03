\name{tvcm}

\alias{tvcm}

\title{Tree-based varying coefficient regression models}

\description{
  \command{\link{tvcm}} is the general implementation for tree-based 
  varying coefficient regression. It may be used to combine the two
  different algorithms \command{\link{tvcolmm}} and
  \command{\link{tvcglm}}. 
}

\usage{
tvcm(formula, data, fit, family,
     weights, subset, offset, na.action = na.omit,
     control = tvcm_control(), fitargs, ...)
}

\arguments{
  \item{formula}{a symbolic description of the model to fit, e.g.,

    \code{y ~ vc(z1, z2) + vc(z1, z2, by = x)}
    
    where \code{vc} specifies the varying coefficients. See 
    \code{\link{vcrpart-formula}}.}
  \item{fit}{a character string or a function that specifies the fitting
    function, e.g., \command{\link{olmm}} or \command{\link{glm}}.}  
  \item{family}{the model family, e.g., an object of class 
    \command{\link{family.olmm}} or \command{\link{family}}.} 
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
    \command{\link{tvcm_control}}.}
  \item{fitargs}{additional arguments passed to the fitting function
    \code{fit}.} 
  \item{\ldots}{additional arguments passed to the fitting function
    \code{fit}. Note that using the \code{fitargs} argument is the
    preferred way to for this.}  
}

\details{ 
  TVCM partitioning works as follows: In each iteration we fit the
  current model and select a binary split for one of the current
  terminal nodes. The selection requires 4 decisions: the \code{vc}
  term, the node, the variable and the cutpoint in the selected
  variable. The algorithm starts with \eqn{M_k = 1} node for each of the
  \eqn{K} \command{\link{vc}} terms and iterates until the criteria
  defined by \code{control} are reached, see
  \command{\link{tvcm_control}}. For the specific criteria for the split
  selection, see \command{\link{tvcolmm}} and \command{\link{tvcglm}}.

  Alternative tree-based algorithm to \command{\link{tvcm}} are the
  MOB (Zeileis et al., 2008) and the PartReg (Wang and Hastie, 2014)
  algorithms. The MOB algorithm is implemented by the \command{mob}
  function in the packages \pkg{party} and \pkg{partykit}. For smoothing
  splines and kernel regression approaches to varying coefficients, see
  the packages \pkg{mgcv}, \pkg{svcm},\pkg{mboost} or \pkg{np}. 

  The \command{\link{tvcm}} function builds on the software
  infrastructure of the \pkg{partykit} package. The authors are grateful
  for these codes. 
}

\value{An object of class \command{\link{tvcm}}. The
    \command{\link{tvcm}} class itself is based on the
    \command{\link[partykit]{party}} class of the \pkg{partykit} package. The most
    important slots are:

    \item{node}{an object of class \command{\link[partykit]{partynode}}.}
    \item{data}{a \command{\link{data.frame}}. The model frame with all
      variables for partitioning.}
    \item{fitted}{an optional \command{\link{data.frame}} containing at
      least the fitted terminal node identifiers as element
      \code{(fitted)}. In addition, weights may be contained as element
      \code{(weights)} and responses as \code{(response)}.} 
    \item{info}{additional information including \code{control},
      \code{model} and \code{data} (all untransformed data, without
      missings).} 
}

\references{
  Zeileis, A., T. Hothorn, and K. Hornik (2008). Model-Based
  Recursive Partitioning. \emph{Journal of Computational and Graphical
    Statistics}, \bold{17}(2), 492--514.

  Wang, J. C. and T. Hastie (2014), Boosted Varying-Coefficient
  Regression Models for Product Demand Prediction, \emph{Journal of
    Computational and Graphical Statistics}, \bold{23}(2), 361--382.
  
  Hothorn, T. and A. Zeileis (2014). partykit: A Modular Toolkit
  for Recursive Partytioning in R. In \emph{Working Papers in Economics
  and Statistics, Research Platform Empirical and Experimental
  Economics}, Number 2014-10. Universitaet Innsbruck.

  Burgin R. and Ritschard G. (2015), Tree-Based Varying Coefficient 
  Regression for Longitudinal Ordinal Responses. \emph{Computational
    Statistics & Data Analysis}, \bold{86}, 65--80.

  Burgin, R. A. (2015b). Tree-based methods for moderated regression
  with application to longitudinal data. PhD thesis. University of
  Geneva. 
  
  Burgin, R. and G. Ritschard (2017), Coefficient-Wise Tree-Based
  Varying Coefficient Regression with vcrpart. \emph{Journal of
  Statistical Software}, \bold{80}(6), 1--33.
}

\seealso{\command{\link{tvcolmm}}, \command{\link{tvcglm}},
  \command{\link{tvcm_control}}, \command{\link{tvcm-methods}},
  \command{\link{tvcm-plot}}, \command{\link{tvcm-assessment}}}

\examples{

## ------------------------------------------------------------------- #  
## Example 1: Moderated effect of education on poverty
##
## See the help of 'tvcglm'.
## ------------------------------------------------------------------- #

data(poverty)
poverty$EduHigh <- 1 * (poverty$Edu == "high")

## fit the model
model.Pov <-
  tvcm(Poor ~ -1 +  vc(CivStat) + vc(CivStat, by = EduHigh) + NChild, 
         family = binomial(), data = poverty, subset = 1:200,
         control = tvcm_control(verbose = TRUE, papply = "lapply",
           folds = folds_control(K = 1, type = "subsampling", seed = 7)))

## diagnosis
plot(model.Pov, "cv")
plot(model.Pov, "coef")
summary(model.Pov)
splitpath(model.Pov, steps = 1:3)
prunepath(model.Pov, steps = 1)


## ------------------------------------------------------------------- # 
## Example 2: Moderated effect effect of unemployment
##
## See the help of 'tvcolmm'.
## ------------------------------------------------------------------- #

data(unemp)

## fit the model
model.UE <-
  tvcm(GHQL ~ -1 + 
          vc(AGE, FISIT, GENDER, UEREGION, by = UNEMP, intercept = TRUE) +
          re(1|PID),
       data = unemp, control = tvcm_control(sctest = TRUE),
       family = cumulative())

## diagnosis (no cross-validation was performed since 'sctest = TRUE')
plot(model.UE, "coef")
summary(model.UE)
splitpath(model.UE, steps = 1, details = TRUE)


}

\author{Reto Burgin}

\keyword{tree}