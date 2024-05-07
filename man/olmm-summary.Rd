\name{olmm-summary}

\alias{olmm-summary}
\alias{summary.olmm}
\alias{print.summary.olmm}
\alias{print.olmm}

\title{Printing and summarizing \command{\link{olmm}} objects}

\description{
  Generates summary results of a fitted \command{\link{olmm}} object.
}

\usage{
\method{summary}{olmm}(object, etalab = c("int", "char", "eta"),
        silent = FALSE, ...)

\method{print}{olmm}(x, etalab = c("int", "char", "eta"), ...)
}

\arguments{
  \item{object, x}{a fitted \command{\link{olmm}} object.}
  \item{etalab}{character. Whether category-specific effects should be 
    labeled by integers of categories (default), the labels of the 
    categories or the index of the predictor.}
  \item{silent}{logical: should a warning be reported if the computation 
    of the covariance matrix for the estimated coefficients failed.}
  \item{...}{additional arguments passed to print.}
}

\value{
  The \code{summary} method returns a list of class
  \code{"summary.olmm"}.
}

\seealso{\command{\link{olmm}}, \command{\link{olmm-methods}}}

\author{Reto Burgin}
 
\examples{
## ------------------------------------------------------------------- #
## Dummy example:
##
## Printing the summary of a model on artificially generated data.
## ------------------------------------------------------------------- #

data(vcrpart_1)

model <- olmm(y ~ wave + z4:treat + re(1|id), vcrpart_1, subset = 1:60)

print(model, digits = 2)

summary(model, digits = 2)
}

\keyword{methods}