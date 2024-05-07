\name{vcrpart-formula}

\alias{vcrpart-formula}
\alias{fe}
\alias{vc}
\alias{re}
\alias{ce}
\alias{ge}

\title{Special terms for formulas.}

\description{Special terms for formulas assigned to \command{\link{tvcm}},
  \command{\link{fvcm}} and \command{\link{olmm}}.   
}

\usage{
fe(formula, intercept = TRUE)
re(formula, intercept = TRUE)
vc(..., by, intercept = missing(by), nuisance = character())
ce(formula)
ge(formula)
}

\arguments{
  \item{formula}{a symbolic description for the corresponding component
    of the formula component. See examples.}
  \item{intercept}{logical or character vector. \code{intercept = TRUE}
    (default) indicates that an intercept is incorporated.
    \code{intercept = FALSE} removes the random intercept from the
    formula. Note that the sometimes allowed \code{-1}
    term is ignored. The character strings \code{"ce"}
    (category-specific random intercepts) and \code{"ge"}
    (category-global random intercepts) may be used in connection with
    \command{\link{olmm}}. Intercepts have specific interpretations for
    \code{fe}, \code{re} and \code{vc}, see the details.}  
  \item{\ldots}{the names of variables that moderate (i.e. modify) the
    effects of the variables specified in \code{by}, separated by
    commas. It is also possibly to assign a vector that contains the
    variable names as characters. Note that operators like
    \code{factor(x)} are not allowed.}  
  \item{by}{a formula of predictors the effects of which are moderated
    by the variables in \code{\ldots}. See \command{\link{tvcm}} and the
    examples below. Note that the \code{by} variable must be numeric and
    factor variables must be recoded to dummy variables by hand.}
  \item{nuisance}{character vector of variables in \code{by} which have
    to be estimated separately for each partition but the algorithm should
    not focus on this variable when searching for splits.} 
}

\value{
  a list used by \command{\link{tvcm}}, \command{\link{fvcm}} and
  \command{\link{olmm}} for constructing the model matrices.
}

\details{
  Special formula terms to define fixed effects \command{\link{fe}},
  varying coefficients \command{\link{vc}} and random effects
  \command{\link{re}}. The use of these formula terms ensures that
  the functions \command{\link{fvcm}}, \command{\link{tvcm}} and
  \command{\link{olmm}} fit the intended model. Some examples are given
  below and on the documentation pages of the fitting functions.
  
  For all of \command{\link{fvcm}}, \command{\link{tvcm}} and
  \command{\link{olmm}}, variables which are not defined with one of
  \command{\link{fe}}, \command{\link{vc}} and \command{\link{re}} are
  treated as fixed effects. Intercepts can be dropped from the model by
  the \code{intercept} argument. The terms \command{\link{ce}}
  (category-specific effects) and \command{\link{ge}} (global effect or
  proportional odds effect) are designed for the function
  \command{\link{olmm}}. Notice that \command{\link{tvcm}} may changes,
  for internal reasons, the order of the terms in the specified
  formula. Note that you can put multiple terms within
  \command{\link{fe}}, \command{\link{ge}} and \command{\link{ce}} terms
  (e.g., \code{fe(ce(x1 + x2 + ge(x3 + x4))}).

  At present, the term \code{"."}, which is often use to extract all
  variables of the data, is ignored. As an alternative,
  \command{\link{vc}} interprets character vectors, assigned as unnamed
  arguments, as lists of variables of moderators to be extracted from
  \code{data}. See the examples below.

  Default for intercepts in \command{\link{fe}} terms is \code{intercept
    = TRUE}, or \code{intercept = "ce"} for models fitted with
  \command{\link{olmm}}. This means that an intercept is automatically
  attached. Alternatives are \code{intercept = FALSE}, which is equal to
  \code{intercept = "none"}, and \code{intercept = "ge"}, which yields a
  global-effect intercept for models fitted with \command{\link{olmm}}.
  
  Default for intercepts in \command{\link{vc}} is to introduce an
  intercept if the \code{by} argument is ignored, otherwise no intercept
  is introduced. Specifically, if input is specified for the \code{by}
  argument, then  \code{intercept = TRUE}, or \code{intercept = "ce"}
  for models fitted by \command{\link{olmm}}. Alternatives are
  \code{intercept = FALSE}, which is equal to \code{intercept = "none"},
  and \code{intercept = "ge"}, which yields a global-effect varying
  intercept. 

  Default for intercepts in \command{\link{re}} is \code{intercept =
  TRUE}, which is equal to \code{intercept = "ge"}. \code{intercept =
  FALSE} is equal to \code{intercept = "none"}. For category-specific
  random intercepts, use \code{intercept = "ge"}. See
  \command{\link{olmm}}. 
}

\seealso{\command{\link{tvcm}}, \command{\link{fvcm}},
  \command{\link{olmm}}} 

\examples{
## Formula for a model with 2 fixed effects (x1 and x2) and a random
## intercept. The 're' terms indicates that an intercept is fitted for
## each level of 'id'.

formula <- y ~ fe(x1 + x2) + re(1|id)

## Formula for a model with one fixed effect and one varying coefficient
## term with 2 moderators and 2 varying coefficient predictors. 'tvcm'
## will fit one partition to model the effects of 'x2' and 'x3' as
## functions of 'z1' and 'z2'.

formula <- y ~ x1 + vc(z1, z2, by = x2 + x3, intercept = TRUE)

## Similar formula as above, but the predictors 'x2' and 'x3' have
## separate 'vc' terms. 'tvcm' will fit a separate partition for each of
## 'x2' and 'x3' to model their effects as functions of 'z1' and 'z2'.

formula <- y ~ x1 + vc(z1, z2, by = x2) + vc(z1, z2, by = x3)

## As an alternative to '.' you can define variables in a vector
vars <- c("x1", "x2", "x3")
formula <- y ~ x1 + vc(vars, by = x2) + vc(vars, by = x3)
}

\author{Reto Burgin}