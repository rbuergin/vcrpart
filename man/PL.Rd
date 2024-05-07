\name{PL}

\alias{PL}

\docType{data}

\title{Effect of parental leave policy}

\description{Data to analyze the effect of the 1990 Austrian parental leave
  reform on fertility and postbirth labor market careers. The data originate 
  from the Austrian Social Security Database (ASSD) and where prepared by 
  Lalive and Zweimueller (2009). The sample includes 6'180 women giving a 
  childbirth (the first birth recorded in the ASSD data) between June
  and July 1990 and were eligible to benefit from the parental leave
  program.}   

\usage{data(PL)}

\format{
  A data frame with 6'180 observations on the following variables
  \describe{
    \item{\code{uncb3}}{binary. Additional birth 0-36 months after child birth.}
    \item{\code{uncb10}}{binary. Additional birth 0-120 months after child birth.}
    \item{\code{uncj3}}{binary. Return-to-work 0-36 months after child birth.}
    \item{\code{uncj10}}{numeric. Return-to-work 0-120 months after child birth.}
    \item{\code{pbexp10}}{numeric. Employment (months/yr), 37-120 months
      after child birth.} 
    \item{\code{pbinc_tot10}}{numeric. Earnings (EUR/month), 37-120
      months after child birth.}
    \item{\code{pbexp3}}{numeric. Employment (months/yr), 0-36 months
      after child birth.} 
    \item{\code{pbinc_tot3}}{numeric. Earnings (EUR/month), 0-36 months
      after child birth.} 
    \item{\code{ikar3}}{numeric. Length of parental leave of the first
      year after birth.} 
    \item{\code{ikar4}}{numeric. Length of parental leave of the second
      year after birth.} 
    \item{\code{july}}{binary treatment variable. Indicates whether the child 
      considered (the first recorded in the ASSD data) was born in June 1990
      or in July 1990.}
    \item{\code{bd}}{child's birthday.}
    \item{\code{workExp}}{years in employment prior to birth.}
    \item{\code{unEmpl}}{years in unemployment prior to birth.}
    \item{\code{zeroLabEarn}}{factor. Whether women has earnings at birth.}
    \item{\code{laborEarnings}}{numeric. Earnings at birth.}
    \item{\code{employed}}{factor. Whether the woman was employed in 1989.}
    \item{\code{whiteCollar}}{factor. Whether woman is white collar worker.}
    \item{\code{wage}}{numeric. Daily 1989 earnings.}
    \item{\code{age}}{ordered factor. Age.}
    \item{\code{industry}, \code{industry.SL}}{factor. Industry where woman worked.}	
    \item{\code{region}, \code{region.SL}}{factor. The region where the woman lives.}
  }
}

\details{
  The data are described in Lalive and Zweimueller (2009). 
}

\source{Austrian Social Security Database (ASSD). The data set is also available 
  from \url{https://sites.google.com/site/rafaellalive/research}}  

\references{Lalive, R. and J. Zweimueller (2009). Does Parental Leave
  Affect Fertility and Return-to-Work? Evidence from Two Natural
  Experiments. \emph{The Quarterly Journal of Economics} \bold{124}(3),
  1363--1402.
} 

\keyword{datasets}
