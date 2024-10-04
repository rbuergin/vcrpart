\name{poverty}

\alias{poverty}

\docType{data}

\title{Poverty in Switzerland}

\description{Poverty measurements of elderly people (older than the
  Swiss legal retirement age) in Switzerland. The data are the
  (complete) subsample of participants of the canton Valais of the
  Vivre-Leben-Vivere (VLV) survey data.}  

\usage{data(poverty)}

\format{
  A data frame with 576 observations on the following variables
  \describe{
    \item{\code{Poor}}{binary response variable on whether the person
      is considered as poor or not. 0 = no and 1 = yes.}
    \item{\code{Canton}}{the canton where the person lives. All
      individuals origin from the canton Wallis.}
    \item{\code{Gender}}{whether person is a male or a female.}
    \item{\code{AgeGroup}}{to which age group the person belongs to.}
    \item{\code{Edu}}{ordered 3-category measurement on the persons
      education.} 
    \item{\code{CivStat}}{civil status.}
    \item{\code{NChild}}{number of children.}
    \item{\code{Working}}{whether the person is still working (even
      though all persons are in the legal retirement age).}
    \item{\code{FirstJob}}{5-category classification of the person's
      first job.}
    \item{\code{LastJob}}{5-category classification of the person's
      last job.}
    \item{\code{Origin}}{whether the person origins from Switzerland or
      a foreign country.}
    \item{\code{SocMob}}{whether and how the person has changed his
      social status over the life span.}
    \item{\code{RetirTiming}}{timing of the retirement relative to the
      legal retirement age.}
    \item{\code{ProfCar}}{4-category classification of the professional
      carrier. Possible are \code{"full employment"},
      \code{"missing / early retirement"}, \code{"start and stop"} and
      \code{"stop and restart"}. The classification was retrieved from a
      longitudinal cluster analysis on the professional carriers in
      Gabriel et. al. (2014).} 
    \item{\code{Pension}}{5-category classification of the pension
      plan. Number refer to the Swiss pension three-pillar system.}
    \item{\code{TimFirstChild}}{timing of first child relative to the
      average timing of the first child of the same age group.}
  }
}

\details{
  Poverty is defined by a threshold of 2400 Swiss francs per person in
  the household. Specifically, the \code{poverty} variable was retrieved
  from a self-rated ordinal variable with nine categories on household 
  income and was adjusted by the OECD equivalence scales methodology to
  account for the household size.  

  The variables \code{Canton}, \code{Gender} and \code{AgeGroup}
  represent the stratification variables of the survey design. 

  The data include a significant number of missings, in particular for
  \code{Poor} and \code{RetirTiming}. The authors are grateful to
  Rainer Gabriel, Michel Oris and the \emph{Centre interfacultaire de
    gerontologie et d'etudes des vulnerabilites} (CIGEV) at the
  University of Geneva for providing the prepared data set.
}

\source{VLV survey}

\references{Ludwig, C., S. Cavalli and M. Oris
  \sQuote{Vivre/Leben/Vivere}: An interdisciplinary survey addressing
  progress and inequalities of ageing over the past 30 years in
  Switzerland. \emph{Archives of Gerontology and Geriatrics}.  
  
  Gabriel, R., M. Oris, M. Studer and M. Baeriswyl (2015). The
  Persistance of Social Stratification? \emph{Swiss Journal of
  Sociology}, \bold{41}(3), 465--487.
} 

\keyword{datasets}
