\name{tvcm-methods}

\alias{tvcm-methods}
\alias{coef.tvcm}
\alias{coefficients.tvcm}
\alias{depth.tvcm}
\alias{extract}
\alias{extract.tvcm}
\alias{formula.tvcm}
\alias{fitted.tvcm}
\alias{getCall.tvcm}
\alias{logLik.tvcm}
\alias{model.frame.tvcm}
\alias{neglogLik2.tvcm}
\alias{nobs.tvcm}
\alias{predict.tvcm}
\alias{print.tvcm}
\alias{ranef.tvcm}
\alias{resid.tvcm}
\alias{residuals.tvcm}
\alias{splitpath}
\alias{splitpath.tvcm}
\alias{summary.tvcm}
\alias{weights.tvcm}
\alias{width.tvcm}

\title{Methods for \command{\link{tvcm}} objects}

\description{Standard methods for computing on \command{\link{tvcm}}
  objects.} 

\usage{
\method{coef}{tvcm}(object, ...)

\method{depth}{tvcm}(x, root = FALSE, ...)

\method{extract}{tvcm}(object, what = c(
              "control", "model", 
              "nodes", "sctest", "p.value",
              "devgrid", "cv", "selected",
              "coef", "sd", "var"),
        steps = NULL, ...)

\method{neglogLik2}{tvcm}(object, ...)

\method{predict}{tvcm}(object, newdata = NULL,
        type = c("link", "response", "prob", "class",
          "node", "coef", "ranef"),
        ranef = FALSE, na.action = na.pass, ...)

\method{splitpath}{tvcm}(tree, steps = 1L,
         details = FALSE, ...)

\method{summary}{tvcm}(object, ...)

\method{width}{tvcm}(x, ...)
}

\arguments{
  \item{object, tree, x}{an object of class \command{\link{tvcm}}.}
  \item{root}{logical scalar. Should the root count be counted in
    \code{depth}?} 
  \item{steps}{integer vector. The iteration steps from which
    information should be extracted.} 
  \item{newdata}{an optional data frame in which to look for variables 
    with which to predict, if omitted, the fitted values are used.} 
  \item{type}{character string. Denotes for \command{\link{predict}} the
    type of predicted value. See \command{\link{predict.glm}} or
    \command{\link{predict.olmm}}. \code{"response"} and \code{"prob"}
    are identical.}
  \item{na.action}{function determining what should be done with missing
    values for fixed effects in \code{newdata}. The default is to
    predict \code{NA}: see \command{\link{na.pass}}.}
  \item{ranef}{logical scalar or matrix indicating whether prediction
    should be based on random effects. See
    \command{\link{predict.olmm}}. }
  \item{what}{a character specifying the quantities to \code{extract}.}
  \item{details}{logical scalar. Whether detail results like
    coefficient constancy tests or loss minimizing grid search should be 
    shown.}
  \item{...}{Additional arguments passed to the calls.}
}

\details{
  The \command{\link{predict}} function has two additional options for the
  \code{type} argument. The option \code{"node"} calls the node id and
  \code{"coef"} predicts the coefficients corresponding to an
  observation. In cases of multiple \command{\link{vc}} terms for the same
  predictor, the coefficients are summed up.

  The \command{\link{splitpath}} function allows to backtrack the
  partitioning procedure. By default, it shows which split was chosen in
  the first iteration. The interesting iteration(s) can be selected by
  the \code{steps} argument. With \code{details = TRUE} it is also
  possible to backtrack the coefficient constancy tests and/or the loss
  reduction statistics.  

  \command{\link{summary}} computes summary statistics of the fitted model, 
  including the estimated coefficients. The varying coefficient are printed
  by means of a printed decision tree. Notice that in cases there is no split
  for the varying coefficient, the average coefficient will be among the 
  fixed effects.	
  
  Further undocumented, available methods are: \command{\link{fitted}},
  \command{\link{formula}}, \command{\link{getCall}},
  \command{\link{logLik}}, \command{\link{model.frame}},
  \command{\link{nobs}}, \command{\link{print}}, \command{\link{ranef}},
  \command{\link{resid}}, and \command{\link{weights}}. All these
  methods have the same arguments as the corresponding default methods. 
}

\value{
  The \command{\link{coef.tvcm}} and \command{\link{coefficients.tvcm}}
  methods return a \command{\link{list}} with model
  coefficients. Slot \code{vc} stores varying coefficients, \code{fe}
  fixed coefficients and \code{re} coefficients on random effects.

  The \command{\link{depth.tvcm}} method returns a integer vector with
  the depth of the trees of every varying
  coefficient. \command{\link{width.tvcm}} returns a integer vector with
  the width of the trees.  

  The \command{\link{extract}} and \command{\link{extract.tvcm}} methods
  allow to extract further information of \code{tvcm} objects, such as
  the underlying regression model. The type of the return value depends
  on the input for argument \code{what}.

  The \command{\link{formula.tvcm}} method extracts the model formula,
  which is an object of class \code{formula}. See also
  \command{\link{formula}}.
    
  The methods \command{\link{fitted.tvcm}} and
  \command{\link{predict.fvcm}} return an object of class \code{numeric}
  or \code{matrix}, depending on the used model or the specification of
  the argument \code{type}.

  The \command{\link{getCall.tvcm}} method extracts the call for fitting
  the model, which is an object of class \code{call}. See also
  \command{\link{call}}. 
  
  The \command{\link{logLik.tvcm}} method returns an object of class
  \code{logLik}, see also \command{\link{logLik}}.
  
  The \command{\link{model.frame.tvcm}} method returns a
  \code{data.frame}. See also \command{\link{model.frame}}.

  The \command{\link{neglogLik2.tvcm}} method returns a single numeric,
  see also \command{\link{neglogLik2}}.
    
  The \command{\link{nobs.tvcm}} method extracts the number of
  observations used to fit the model. See also
  \command{\link{nobs.tvcm}}. 

  The \command{\link{print.tvcm}} and \command{\link{summary.tvcm}}
  methods return \code{NULL}. 

  The \command{\link{ranef.tvcm}} method returns an object of class
  \code{matrix} with values for the random effects. See also
  \command{\link{ranef.olmm}} and \command{\link{ranef}}.

  The \command{\link{resid.tvcm}} and \command{\link{residuals.tvcm}}
  methods return  a \code{numeric} or a \code{matrix}, depending on the
  used model or the type of residuals. See the help of the
  \command{\link{resid}} method of the used model.

  The methods \command{\link{splitpath}} and
  \command{\link{splitpath.tvcm}} return an object of class
  \code{splitpath.tvcm} that contains information on splitting when
  building the tree.

  The \command{\link{weights.tvcm}} method extracts a \code{numeric}
  vector with the model weights. See also \command{\link{weights}}.
}

\author{Reto Burgin}

\seealso{
  \command{\link{tvcm}}, \command{\link{tvcm-assessment}},
  \command{\link{tvcm-plot}}
}

\examples{
## ------------------------------------------------------------------- #
## Dummy example:
##
## Apply various methods on a 'tvcm' object fitted on the 'vcrpart_2'
## data. Cross-validation is omitted to accelerate the computations.
## ------------------------------------------------------------------- #

data(vcrpart_2)

model <- tvcm(y ~ -1 + vc(z1, z2) + vc(z1, z2, by = x1) + x2,
              data = vcrpart_2, family = gaussian(), subset = 1:90,
              control = tvcm_control(cv = FALSE))

coef(model)
extract(model, "selected")
extract(model, "model")
predict(model, newdata = vcrpart_2[91:100,], type = "node")
predict(model, newdata = vcrpart_2[91:100,], type = "response")
splitpath(model, steps = 1)
summary(model, digits = 2)
}
\keyword{methods}