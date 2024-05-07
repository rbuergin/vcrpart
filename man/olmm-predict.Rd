\name{olmm-predict}

\alias{olmm-predict}
\alias{fitted.olmm}
\alias{predict.olmm}

\title{Predict outcome probabilities and responses for
  \command{\link{olmm}} objects} 

\description{\code{fitted} and \code{predict} method for
  \command{\link{olmm}} objects. The function implements mainly the 
  prediction methods of Skrondal and Rabe-Hesketh (2009).} 

\usage{
\method{fitted}{olmm}(object, ...)

\method{predict}{olmm}(object, newdata = NULL,
        type = c("link", "response", "prob", "class", "ranef"),
        ranef = FALSE, na.action = na.pass, ...)
}

\arguments{
  \item{object}{a fitted \command{\link{olmm}} object.}
  \item{newdata}{data frame for which to evaluate predictions.}
  \item{type}{character string. \code{type = "response"} and 
    \code{type = "prob"} yield response probabilities, 
    \code{type = "class"} the response category with highest 
    probability and \code{type = "link"} the linear predictor
    matrix. \code{type = "ranef"} yields the predicted random effects,
    see \command{\link{ranef.olmm}}.}
  \item{ranef}{logical or numeric matrix. See details.} 
  \item{na.action}{function determining what should be done with missing
    values for fixed effects in \code{newdata}. The default is to
    predict \code{NA}: see \command{\link{na.pass}}.} 
  \item{...}{optional additional parameters. Includes \code{offset} and
    \code{subset}.} 
}

\details{If \code{type = "link"} and \code{ranef = FALSE}, the fixed 
  effects components are computed. The random effect components are ignored.

  If \code{type = "link"} and \code{ranef = TRUE}, the fixed effect components 
  plus the random effect components are computed. The function will look for 
  whether random coefficients are available for the subjects (i.e. clusters) 
  in \code{newdata}. If so, it extracts the corresponding random effects as
  obtained by \command{\link{ranef}}. For new subjects in \code{newdata} the 
  random effects are set to zero. If \code{newdata} does not contain a subject
  vector, the random effects are set to zero.

  If \code{type = "link"} and \code{ranef} is a matrix, the fixed effect 
  components plus the random effect components with the random coefficients 
  from the assigned matrix are computed. Notice that \code{newdata} should 
  contain a subject vector to assign the random coefficients. This prediction 
  method is, amongst others, proposed in Skrondal and Rabe-Hesketh (2009), 
  Sec. 7.1. 

  The two options \code{type = "response"} and \code{type = "prob"} are 
  identical and \code{type = "class"} extracts the response category 
  with the highest probability. Hence, the prediction mechanism is the 
  same for all three options.
  
  Given \code{newdata} contains a subject vector, \code{type = "response"} 
  combined with \code{ranef = FALSE} yields for new subjects the 
  population-averaged response probabilities (Skrondal and Rabe-Hesketh, Sec. 7.2) 
  and for existing subjects the cluster-averaged prediction (Skrondal and 
  Rabe-Hesketh 2009, Sec. 7.3). If no subject vector is assigned the function 
  assumes that all subjects are new and therefore yields the population-averaged 
  response probabilities (Skrondal and Rabe-Hesketh 2009, Sec. 7.2).

  The option \code{type = "response"} combined with \code{ranef = TRUE} 
  works equivalent to \code{type = "link"} combined with \code{ranef = TRUE}. 

  If the model does not contain random effects, the argument \code{ranef} is 
  ignored.
}

\value{
  A matrix or a vector of predicted values or response probabilities. 
}

\note{
  The method can not yet handle new categories in categorical predictors
  and will return an error. 
}

\author{Reto Burgin}

\references{
  Skrondal, A., S. Rabe-Hesketh (2009). Prediction in Multilevel
  Generalized Linear Models. \emph{Journal of the Royal Statistical
  Society A}, \bold{172}(3), 659--687.   
}

\seealso{\command{\link{olmm}}, \command{\link{olmm-methods}}}

\examples{
## ------------------------------------------------------------------- #
## Example: Schizophrenia
## ------------------------------------------------------------------- #

data(schizo)

## omit subject 1103 and the last observations of 1104 and 1105 
subs <- c(1:4, 8, 11)

dat.train <- schizo[-subs, ] # training data
dat.valid <- schizo[ subs, ] # test data

## fit the model
model <- olmm(imps79o ~ tx + sqrt(week) + tx:sqrt(week) + re(1|id), dat.train)

## prediction on the predictor scale
## ---------------------------------

## random effects are set equal zero
predict(model, newdata = dat.valid, type = "link", ranef = FALSE)

## .. or equally with self-defined random effects
ranef <- matrix(0, 3, 1)
rownames(ranef) <- c("1103", "1104", "1105")
predict(model, newdata = dat.valid, type = "link", ranef = ranef)

## use random effects for the subjects 1104 and 1105. 
predict(model, newdata = dat.valid, type = "link", ranef = TRUE)

## prediction on the response scale
## --------------------------------

## use random effects for the subjects 1104 and 1105. 
predict(model, newdata = dat.valid, type = "response", ranef = FALSE)
predict(model, newdata = dat.valid, type = "prob", ranef = FALSE) # .. or, equally
predict(model, newdata = dat.valid, type = "class", ranef = FALSE)

## treat all individuals as new (subject vector is deleted)
predict(model, newdata = dat.valid[,-1], type = "response", ranef = FALSE)

## use random effects for the subjects 1104 and 1105. 
predict(model, newdata = dat.valid, type = "response", ranef = TRUE)

## use self defined random effects
ranef <- matrix(0, 3, 1)
rownames(ranef) <- c("1103", "1104", "1105")
predict(model, newdata = dat.valid, type = "response", ranef = ranef)

## predict random effects
## ----------------------

head(predict(model, type = "ranef"))
head(ranef(model)) # .. or, equally
}
\keyword{methods}