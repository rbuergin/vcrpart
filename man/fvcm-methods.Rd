\name{fvcm-methods}

\alias{fvcm-methods}
\alias{fitted.fvcm}
\alias{print.fvcm}
\alias{oobloss.fvcm}
\alias{plot.fvcm}
\alias{predict.fvcm}
\alias{ranef.fvcm}

\title{Methods for \command{\link{fvcm}} objects}

\description{Standard methods for computing on \command{\link{fvcm}}
  objects.} 

\usage{
\method{oobloss}{fvcm}(object, fun = NULL, ranef = FALSE, ...)

\method{plot}{fvcm}(x, type = c("default", "coef", 
           "simple", "partdep"),
     tree = NULL, ask = NULL, ...)

\method{predict}{fvcm}(object, newdata = NULL,
        type = c("link", "response", "prob", "class", "coef", "ranef"),
        ranef = FALSE, na.action = na.pass, verbose = FALSE, ...)
}

\arguments{
  \item{object, x}{an object of class \command{\link{fvcm}}.} 
  \item{fun}{the loss function. The default loss function is defined 
    as the sum of the deviance residuals. For a user defined function
    \command{fun}, see the examples of 
    \command{\link{oobloss.tvcm}}.} 
  \item{newdata}{an optional data frame in which to look for variables
    with which to predict. If omitted, the training data are used.} 
  \item{type}{character string indicating the type of plot or
    prediction. See \command{\link{plot.tvcm}} or
    \command{\link{predict.tvcm}}. \code{"response"} and \code{"prob"}
    are identical.} 
  \item{tree}{integer vector. Which trees should be plotted.}
  \item{ask}{logical. Whether an input should be asked before printing
    the next panel.} 
  \item{ranef}{logical scalar or matrix indicating whether predictions
    should be based on random effects. See
    \command{\link{predict.olmm}}.} 
  \item{na.action}{function determining what should be done with missing
    values for fixed effects in \code{newdata}. The default is to
    predict \code{NA}: see \command{\link{na.pass}}.} 
  \item{verbose}{logical scalar. If \code{TRUE} verbose output is
    generated during the validation.}
  \item{...}{further arguments passed to other methods.}
}

\details{
  \command{\link{oobloss.fvcm}} estimates the out-of-bag loss based on
  predictions of the model that aggregates only those trees in which the
  observation didn't appear (cf. Hastie et al, 2001, sec. 15). The
  prediction error is computed as the sum of prediction errors obtained
  with \code{fun}, which are the deviance residuals by default. 

  The plot and the prediction methods are analogous to
  \command{\link{plot.tvcm}} resp. \command{\link{predict.tvcm}}. Note
  that the plot options \code{mean} and \code{conf.int} for
  \code{type ="coef"} are not available (and internally set to
  \code{FALSE}).  

  Further undocumented, available methods are \command{\link{fitted}},
  \command{\link{print}} and \command{\link{ranef}}. All these latter
  methods have the same arguments as the corresponding default methods. 
}

\value{The methods \command{\link{fitted.fvcm}} and
  \command{\link{predict.fvcm}} return an object of class \code{numeric}
  or \code{matrix}, depending on the used model or the specification of
  the argument \code{type}. See also \command{\link{fitted.tvcm}}. 
  
  The \command{\link{oobloss.fvcm}} method returns the output of the
  loss function defined by \code{fun}. This is a single numeric by
  default. See also \command{\link{oobloss}}.

  The \command{\link{plot.fvcm}} method returns \code{NULL}.

  The \command{\link{ranef.fvcm}} method returns an object of class
  \code{matrix} with values for the random effects. See also
  \command{\link{ranef.olmm}} and \command{\link{ranef}}.
}

\author{Reto Burgin}

\references{
  Breiman, L. (1996). Bagging Predictors. \emph{Machine Learning},
  \bold{24}(2), 123--140.
  
  Breiman, L. (2001). Random Forests. \emph{Machine Learning},
  \bold{45}(1), 5--32.

  Hastie, T., R. Tibshirani and J. Friedman (2001). \emph{The Elements
    of Statistical Learning} (2 ed.). New York, USA: Springer-Verlag.
}

\seealso{\command{\link{fvcm}}, \command{\link{tvcm-methods}}}

\examples{

## ------------------------------------------------------------------- #
## Dummy example 1:
##
## Fitting a random forest tvcm on artificially generated ordinal
## longitudinal data. The parameters 'maxstep = 1' and 'K = 2' are     
## chosen to restrict the computations.
## ------------------------------------------------------------------- # 

## load the data

data(vcrpart_1)

## fit and analyse the model

control <-
  fvcolmm_control(mtry = 2, maxstep = 1, 
                  folds = folds_control(type = "subsampling", K = 2, prob = 0.75))

model.1 <-
  fvcolmm(y ~ -1 + wave + vc(z3, z4, by = treat, intercept = TRUE) + re(1|id),
          family = cumulative(), subset = 1:100,
          data = vcrpart_1, control = control)

## estimating the out of bag loss
suppressWarnings(oobloss(model.1))

## predicting responses and varying coefficients for subject '27'
subs <- vcrpart_1$id == "27"

## predict coefficients
predict(model.1, newdata = vcrpart_1[subs,], type = "coef")

## marginal response prediction
predict(model.1, vcrpart_1[subs,], "response", ranef = FALSE)

## conditional response prediction
re <- matrix(5, 1, 1, dimnames = list("27", "(Intercept)"))
predict(model.1, vcrpart_1[subs,], "response", ranef = re)
predict(model.1, vcrpart_1[subs,], "response", ranef = 0 * re)

## predicting in-sample random effects
head(predict(model.1, type = "ranef"))

## fitted responses (marginal and conditional prediction)
head(predict(model.1, type = "response", ranef = FALSE))
head(predict(model.1, type = "response", ranef = TRUE))


## ------------------------------------------------------------------- #
## Dummy example 2:
##
## Fitting a random forest tvcm on artificially generated normally
## distributed data. The parameters 'maxstep = 3' and 'K = 3' are
## chosen to restrict the computations and 'minsize = 5' to obtain at
## least a few splits given the small sample size.
## ------------------------------------------------------------------- #

data(vcrpart_2)

## fit and analyse the model

control <- fvcm_control(mtry = 1L, minsize = 5, maxstep = 3,
                        folds_control("subsampling", K = 3, 0.75))

model.2 <- fvcglm(y ~ -1  + vc(z1, z2, by = x1, intercept = TRUE) + x2,
                  data = vcrpart_2,
                  family = gaussian(), subset = 1:50,control = control)

## estimating the out of bag loss
suppressWarnings(oobloss(model.2))

## predict the coefficient for individual cases
predict(model.2, vcrpart_2[91:100, ], "coef")
}

\keyword{methods}
\keyword{hplot}