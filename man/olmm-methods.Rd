\name{olmm-methods}

\alias{olmm-methods}
\alias{anova.olmm}
\alias{coefficients.olmm}
\alias{coef.olmm}
\alias{deviance.olmm}
\alias{formula.olmm}
\alias{fixef}
\alias{fixef.glm}
\alias{fixef.olmm}
\alias{getCall.olmm}
\alias{logLik.olmm}
\alias{model.frame.olmm}
\alias{model.matrix.olmm}
\alias{neglogLik2}
\alias{neglogLik2.olmm}
\alias{ranef}
\alias{ranef.olmm}
\alias{ranefCov}
\alias{ranefCov.olmm}
\alias{resid.olmm}
\alias{residuals.olmm}
\alias{simulate.olmm}
\alias{terms.olmm}
\alias{update.olmm}
\alias{VarCorr}
\alias{VarCorr.olmm}
\alias{print.VarCorr.olmm}
\alias{vcov.olmm}
\alias{weights.olmm}

\title{Methods for \command{\link{olmm}} objects}

\description{Standard methods for computing on \command{\link{olmm}}
  objects.} 

\usage{
\method{anova}{olmm}(object, ...)

\method{coef}{olmm}(object, which = c("all", "fe"), ...)

\method{fixef}{olmm}(object, which = c("all", "ce", "ge"), ...)

\method{model.matrix}{olmm}(object, which = c("fe", "fe-ce", "fe-ge",
             "re", "re-ce", "re-ge"), ...)

\method{neglogLik2}{olmm}(object, ...)

\method{ranef}{olmm}(object, norm = FALSE, ...)

\method{ranefCov}{olmm}(object, ...) 

\method{simulate}{olmm}(object, nsim = 1, seed = NULL,
         newdata = NULL, ranef = TRUE, ...)

\method{terms}{olmm}(x, which = c("fe-ce", "fe-ge", "re-ce", "re-ge"), ...)

\method{VarCorr}{olmm}(x, sigma = 1., ...)

\method{weights}{olmm}(object, level = c("observation", "subject"), ...)
}

\arguments{
  \item{object, x}{an \command{\link{olmm}} object.}
  \item{which}{optional character string. For  \command{\link{coef}} and
    \command{\link{fixef}}, it indicates whether \code{"all"}
    coefficients, the fixed effects \code{"fe"}, the category-specific
    fixed effects \code{"ce"} (i.e. non-proportional odds) or the global
    fixed effects \code{"ge"} (i.e. proportional odds) should be
    extracted. For \code{model.matrix} it indicates whether the model
    matrix of the fixed- (\code{"fe"}) or the random effects (\code{"re"})
    should be extracted.} 
  \item{level}{character string. Whether the results should be on the
    observation level (\code{level = "observation"}) or on the subject
    level (\code{level = "subject"}).} 
  \item{norm}{logical. Whether residuals should be divided by their
    standard deviation.}
  \item{nsim}{number of response vectors to simulate.  Defaults to 1.}
  \item{seed}{an object specifying if and how the random number
    generator should be initialized. See \command{\link{simulate}}}
  \item{newdata}{a data frame with predictor variables.}
  \item{ranef}{either a logical or a matrix (see
    \command{\link{predict.olmm}}). Whether the simulated responses should
    be conditional on random effects. If \code{TRUE}, the \code{newdata}
    data frame must contain the subject identification
    variable. Further, if all subjects in \code{newdata} are in
    \code{object}, the simulation will be based on the estimated random
    effects as obtained with \command{\link{ranef}}. If any subject in
    \code{newdata} is not in \code{object} the random effects are
    simulated.}
  \item{sigma}{ignored but obligatory argument from original generic.} 
  \item{...}{potential further arguments passed to methods.}
}

\details{
  \command{\link{anova}} implements log-likelihood ratio tests for model  
  comparisons, based on the marginal likelihood. At the time being, 
  at least two models must be assigned.
  
  \command{\link{neglogLik2}} returns the marginal maximum likelihood of the
  fitted model times minus 2. 

  \command{\link{ranefCov}} extracts the variance-covariance matrix of
  the random effects. Similarly, \command{\link{VarCorr}} extracts the
  estimated variances, standard deviations and correlations of the
  random effects.  

  \command{\link{resid}} extracts the residuals of Li and Sheperd
  (2012). By default, the marginal outcome distribution is used to
  compute these residuals. The conditional residuals can be computed by
  assigning \code{ranef = TRUE} as a supplementary argument.   

  \command{\link{simulate}} simulates ordinal responses based on the
  input model. 
  
  Further, undocumented methods are \command{\link{deviance}},
  \command{\link{extractAIC}}, \command{\link{fitted}},
  \command{\link{formula}}, \command{\link{getCall}},
  \command{\link{logLik}}, \command{\link{model.frame}},
  \command{\link{nobs}}, \command{\link{update}}, \command{\link{vcov}}.  

  The \command{\link{anova}} implementation is based on codes of the 
  \pkg{lme4} package. The authors are grateful for these codes. 
}

\value{
  The \command{\link{anova.olmm}} method returns an object of class
  \code{anova}, see also \command{\link{anova}}.

  The \command{\link{coef.olmm}}, \command{\link{coefficients.olmm}},
  \command{\link{fixef}}, \command{\link{fixef.glm}} and
  \command{\link{fixef.olmm}} methods return named \code{numeric}
  vectors. See also \command{\link{coef}} and
  \command{\link{coefficients}}. 

  The \command{\link{deviance.olmm}} method returns a single numeric,
  see also \command{\link{deviance}}.

  The \command{\link{formula.olmm}} method extracts the model formula,
  which is an object of class \code{formula}. See also
  \command{\link{formula}}. 

  The \command{\link{getCall.olmm}} method extracts the call for fitting
  the model, which is an object of class \code{call}. See also
  \command{\link{call}}. 
  
  The \command{\link{logLik.olmm}} method returns an object of class
  \code{logLik}, which is a single numeric with a few attributes. See
  also \command{\link{logLik}}.

  The \command{\link{neglogLik2}} and \command{\link{neglogLik2.olmm}}
  methods return a single numeric.  

  The \command{\link{model.frame.olmm}} and
  \command{\link{model.matrix.olmm}} methods return the model frame and
  the model matrix of the \code{olmm} object. See also
  \command{\link{model.frame}} and \command{\link{model.matrix}}.

  The \command{\link{ranef}} and \command{\link{ranef.olmm}} methods
  return a matrix with the estimated random effects.

  The \command{\link{ranefCov}} and \command{\link{ranefCov.olmm}}
  methods return an object of class \code{matrix}. The
  \command{\link{VarCorr}} and \command{\link{VarCorr.olmm}} methods
  return an object of class
  \code{VarCorr.olmm}. \command{\link{print.VarCorr.olmm}} returns an
  object of class \code{VarCorr.olmm}.
  
  The \command{\link{resid.olmm}} and \command{\link{residuals.olmm}}
  methods return a numeric vector.

  The \command{\link{simulate.olmm}} method returns a \code{data.frame}
  including simulated responses based on the input model.

  The \command{\link{terms.olmm}} method returns an object of class
  \code{terms}. See also \command{\link{terms}}.

  The \command{\link{update.olmm}} method will update and (by default)
  re-fit a model. It returns an object of class \code{olmm}. See also
  \command{\link{update}}. 

  The \command{\link{vcov.olmm}} method extracts a \code{matrix} with
  the variances and covariances of the fixed effects of the model. See
  also \command{\link{vcov}}.

  The \command{\link{weights.olmm}} method extracts a \code{numeric}
  vector with the model weights. See also \command{\link{weights}}.
}

\author{Reto Burgin}

\references{
  Agresti, A. (2010). \emph{Analysis of Ordinal Categorical Data} (2
  ed.). New Jersey, USA: John Wiley & Sons.

  Tutz, G. (2012). \emph{Regression for Categorical Data}. New York,
  USA: Cambridge Series in Statistical and Probabilistic Mathematics. 
  
  Li, C. and B. E. Sheperd (2012). A New Residual for Ordinal
  Outcomes, \emph{Biometrika}, \bold{99}(2), 437--480.

  Bates, D., M. Maechler, B. M. Bolker and S. Walker (2015). Fitting
  Linear Mixed-Effects Models Using lme4, \emph{Journal of Statistical
  Software}, \bold{67}(1), 1--48.
}

\seealso{\command{\link{olmm}}, \command{\link{predict.olmm}},
  \command{\link{olmm_gefp}}} 

\examples{
## --------------------------------------------------------- #
## Example: Schizophrenia (see also example of 'olmm')
## --------------------------------------------------------- #

data(schizo)

schizo <- schizo[1:181,]
schizo$id <- droplevels(schizo$id)

## anova comparison
## ----------------

## fit two alternative models for the 'schizo' data
model.0 <- olmm(imps79o ~ tx + sqrt(week) + re(1|id), schizo)
model.1 <- olmm(imps79o ~ tx + sqrt(week)+tx*sqrt(week)+re(1|id),schizo)
anova(model.0, model.1)

## simulate responses
## ------------------

## simulate responses based on estimated random effects
simulate(model.0, newdata = schizo[1, ], ranef = TRUE, seed = 1)
simulate(model.0, newdata = schizo[1, ], seed = 1,
         ranef = ranef(model.0)[schizo[1, "id"],,drop=FALSE])
## simulate responses based on simulated random effects
newdata <- schizo[1, ]
newdata$id <- factor("123456789")
simulate(model.0, newdata = newdata, ranef = TRUE)

## other methods
## -------------

coef(model.1)
fixef(model.1)
head(model.matrix(model.1, "fe-ge"))
head(weights(model.1))
ranefCov(model.1)
head(resid(model.1))
terms(model.1, "fe-ge")
VarCorr(model.1)
head(weights(model.1, "subject"))
}

\keyword{methods}