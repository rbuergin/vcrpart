\name{vcrpart-demo}

\alias{vcrpart-demo}
\alias{vcrpart_1}
\alias{vcrpart_2}
\alias{vcrpart_3}
\alias{unemp}

\docType{data}

\title{Synthetic data sets}

\description{Synthetic data for illustrations.} 

\usage{
data(vcrpart_1)
data(vcrpart_2)
data(vcrpart_3)
data(unemp)
}

\format{
  \describe{
    \item{\code{y}}{ordered factor. The response variable}
    \item{\code{id, PID}}{factor. The subject identification vector.}
    \item{\code{wave}}{numeric. The wave identification vector.}
    \item{\code{treat}}{a dummy variable. The treatment effect.}
    \item{\code{x1, x2}}{numeric predictor variables.}
    \item{\code{z1, z2, z3, z2}}{moderator (partitioning) variables.}
    \item{\code{GHQL}}{self rated general happiness.}
    \item{\code{YEAR}}{survey year.}
    \item{\code{UNEMP}}{unemployed or not.}
    \item{\code{AGE}}{age.}
    \item{\code{FISIT}}{self-reported financial situation.}
    \item{\code{GENDER}}{gender.}
    \item{\code{UEREGION}}{regional unemployment.}
  }
}

\seealso{\command{\link{olmm}}, \command{\link{otsplot}},
  \command{\link{tvcm}}} 

\examples{
## --------------------------------------------------------- #
## generating 'vcrpart_1'
## --------------------------------------------------------- #

## create skeletton
set.seed(1)
vcrpart_1 <- data.frame(id = factor(rep(1:50, each = 4)),
                        wave = rep(1:4, 50),
                        treat = sample(0:1, 200, TRUE))

## add partitioning variables
vcrpart_1$z1 <- rnorm(50)[vcrpart_1$id]
vcrpart_1$z2 <- rnorm(200)
vcrpart_1$z3 <- factor(sample(1:2, 50, TRUE)[vcrpart_1$id])
vcrpart_1$z4 <- factor(sample(1:2, 200, TRUE))

## simulate response
eta <- 2 * vcrpart_1$treat * (vcrpart_1$z4 == "1")
eta <- eta + rnorm(50)[vcrpart_1$id] + rlogis(200)
vcrpart_1$y <- cut(-eta, c(-Inf, -1, 1, Inf), 1:3,
                   ordered_result = TRUE)


## --------------------------------------------------------- #
## generating 'vcrpart_2'
## --------------------------------------------------------- #

set.seed(1)
vcrpart_2 <- data.frame(x1 = rnorm(100),
                        x2 = rnorm(100),
                        z1 = factor(sample(1:3, 100, TRUE)),
                        z2 = factor(sample(1:3, 100, TRUE)))
vcrpart_2$y <- vcrpart_2$x1 * (vcrpart_2$z1 == "2") +
  2 * vcrpart_2$x1 * (vcrpart_2$z1 == "3")
vcrpart_2$y <- vcrpart_2$y + rnorm(100)

## --------------------------------------------------------- #
## generating 'vcrpart_3'
## --------------------------------------------------------- #

set.seed(1)
vcrpart_3 <- data.frame(x1 = rnorm(100),
                        z1 = runif(100, -pi/2, pi/2))
vcrpart_3$y <- vcrpart_3$x1 * sin(vcrpart_3$z1) + rnorm(100)

## --------------------------------------------------------- #
## generating 'unemp'
## --------------------------------------------------------- #

## create skeletton
set.seed(1)
unemp <- data.frame(PID = factor(rep(1:50, each = 4)),
                    UNEMP = rep(c(0, 0, 1, 1), 50),
               	    YEAR = rep(2001:2004, 50))

## add partitioning variables
unemp$AGE <- runif(50, 25, 60)[unemp$PID] + unemp$YEAR - 2000
unemp$FISIT <- ordered(sample(1:5, 200, replace = TRUE))
unemp$GENDER <- factor(sample(c("female", "male"), 50, replace = TRUE)[unemp$PID])
unemp$UEREGION <- runif(50, 0.02, 0.1)[unemp$PID]

## simulate response
eta <- 2 * unemp$UNEMP * (unemp$FISIT == "1" | unemp$FISIT == "2")
eta <- eta + rnorm(50)[unemp$PID] + rlogis(200)
unemp$GHQL <- cut(-eta, c(-Inf, -1, 0, 1, Inf), 1:4,
                  ordered_result = TRUE)

}

\keyword{datasets}