\name{movie}

\alias{movie}

\docType{data}

\title{Movie critics}

\description{Movie critics of the Variety magazine. The data were
  previously used to fit adjacent-categories mixed models by Hartzl et
  al. (2001)}

\usage{data(movie)}

\format{
  A data frame with 372 observations on 93 movies. Three vectors contain
  information on 
  \describe{
    \item{\code{movie}}{movie ID.}
    \item{\code{critic}}{ordinal response on a 3 category scale, "Con" <
      "Mixed" < "Pro".} 
    \item{\code{review}}{critics, "Medved", "Ebert", "Siskel" and
      "Medved".} 
  }
}

\source{The data are tabulated in Hartzel et al. (2001).}

\references{
  Hartzel, J., A. Agresti and B. Caffo (2001). Multinomial Logit Random
  Effect Models, \emph{Statistical Modelling} \bold{1}(2), 81--102.
}  

\keyword{datasets}
