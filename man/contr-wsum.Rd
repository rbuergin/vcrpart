\name{contr.wsum}

\alias{contr.wsum}

\title{Contrast matrices}

\description{
  Returns a category-weighted contrast matrix
}

\usage{
contr.wsum(x, weights = rep.int(1.0, length(x)), sparse = FALSE)
}

\arguments{
  \item{x}{a factor vector}
  \item{weights}{a vector of weights with the same length as \code{x}.}
  \item{sparse}{ogical indicating if the result should be sparse (of class \code{dgCMatrix}), using package \pkg{Matrix}.}
}

\details{
  Computes a contrast matrix similar to \command{\link{contr.sum}}. The
  reference category is however weighted by the sum of weights of the
  other categories.
}

\value{A matrix with \code{nlevels(x)} rows and \code{nlevels(x)- 1}
  columns.}
\author{Reto Burgin}

\seealso{\command{\link{contr.sum}}}

\examples{
x <- factor(rep(LETTERS[1:3], c(10, 20, 30)))
contr.wsum(x) # standard call
contr.wsum(x, sparse = TRUE) # using a sparse matrix
}