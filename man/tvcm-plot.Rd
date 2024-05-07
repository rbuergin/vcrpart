\name{tvcm-plot}

\alias{tvcm-plot}
\alias{plot.tvcm}
\alias{panel_coef}
\alias{panel_partdep}

\title{\code{plot} method for \command{\link{tvcm}} objects.}

\description{
  \code{plot} method and panel functions for \command{\link{tvcm}} objects. 
}

\usage{
\method{plot}{tvcm}(x, type = c("default", "coef", 
        "simple", "partdep", "cv"),
     main, part = NULL, drop_terminal = TRUE,
     tnex, newpage = TRUE, ask = NULL,
     pop = TRUE, gp = gpar(), ...)

panel_partdep(object, parm = NULL,
              var = NULL, ask = NULL,
              prob = NULL, neval = 50, add = FALSE,
              etalab = c("int", "char", "eta"), ...)

panel_coef(object, parm = NULL, 
           id = TRUE, nobs = TRUE,
           exp = FALSE,
           plot_gp = list(),
           margins, yadj = 0.1,
           mean = FALSE, mean_gp = list(),
           conf.int = FALSE, conf.int_gp = list(),
           abbreviate = TRUE, etalab = c("int", "char", "eta"), ...)
}

\arguments{
  \item{x, object}{An object of class \command{\link{tvcm}}.}
  \item{type}{the type of the plot. Available types are
    \code{"default"}, \code{"simple"}, \code{"coef"},
    \code{"partdep"} and \code{"cv"}.}   
  \item{main}{character. A main title for the plot.}
  \item{drop_terminal}{a logical indicating whether all terminal nodes
    should be plotted at the bottom. See also
    \command{\link{plot.party}}.} 
  \item{tnex}{a numeric value giving the terminal node extension in
    relation to the inner nodes. By default the value is computed
    adaptively to the tree size.}
  \item{newpage}{a logical indicating whether \code{grid.newpage()}
    should be called.}
  \item{pop}{a logical whether the viewport tree should be popped before
    return.}
  \item{gp}{graphical parameters. See \command{\link{gpar}}.}
  \item{part}{integer or letter. The partition i.e. varying 
    coefficient component to be plotted.} 
  \item{parm}{character vector (\command{\link{panel_partdep}} and
    \command{\link{panel_coef}}) or list of character vectors
    (\command{\link{panel_coef}}) with names of model
    coefficients corresponding to the chosen component. Indicates which 
    coefficients should be visualized. If \code{parm} is a list, a
    separate panel is allocated for each list component.}  
  \item{var}{character vector. Indicates the partitioning variables
    to be visualized.}
  \item{ask}{logical. Whether an input should be asked before printing
    the next panel.}
  \item{prob}{a probability between 0 and 1. Gives the size of the
    random subsample over which the coefficients are averaged. May be
    smaller than 1 if the sample is large.}
  \item{neval}{the maximal number of distinct values of the variable to
    be evaluated.}
  \item{add}{logical. Whether the panel is to be added into an active
    plot.} 
  \item{id}{logical. Whether the node id should be displayed.}
  \item{nobs}{logical. Whether the number of observations in each node
    should be displayed.}
  \item{exp}{logical. Whether the labels in the y-axes should be the
    exponential of coefficients.}
  \item{plot_gp}{a list of graphical parameters for the panels. Includes
    components \code{xlim}, \code{ylim}, \code{pch}, \code{ylab},
    \code{type} (the type of symbols, e.g. \code{"b"}), \code{label}
    (characters for ticks at the x axis), \code{height}, \code{width},
    \code{gp} (a list produced by \command{\link{gpar}}). If \code{parm} 
    is a list, \code{plot_gp} may be a nested list specifying the
    graphical parameters for each list component of \code{parm}. See
    examples.} 
  \item{margins}{a numeric vector \code{c(bottom, left, top, right)}
    specifying the space on the margins for each panel. By default
    the values are computed adaptively to the tree size.}
  \item{yadj}{a numeric scalar larger than zero that increases the
    margin above the panel. May be useful if the edge labels are covered
    by the coefficient panels.} 
  \item{mean}{logical. Whether the average coefficients over the
    population should be visualized.}
  \item{mean_gp}{list with graphical parameters for plotting the mean
    coefficients. Includes a component \code{gp = gpar(...)} and a
    component \code{pch}. See examples.}
  \item{conf.int}{logical. Whether confidence intervals should be
    visualized. These are indicative values only. They do not account
    for the uncertainty of model selection procedure.} 
  \item{conf.int_gp}{a list of graphical parameters for the confidence
    intervals applied to \command{\link{arrow}}. Includes \code{angle},
    \code{length}, \code{ends} and \code{type}. See examples.}
  \item{abbreviate}{logical scalar. Whether labels of coefficients should
    be abbreviated.}		
  \item{etalab}{character. Whether category-specific effects should be
    labeled by integers of categories (default), the labels of the
    categories (\code{"char"}) or the index of the predictor
    (\code{"eta"}).} 
  \item{\ldots}{additional arguments passed to
    \command{\link{panel_partdep}} or \command{\link{panel_coef}} or
  other methods.}
}

\details{
  The plot functions allow the diagnosis of fitted \command{\link{tvcm}}
  objects. \code{type = "default"}, \code{type = "coef"} and
  \code{type = "simple"} show the tree structure and coefficients in
  each node. \code{type = "partdep"} plots partial dependency plots, see
  Hastie et al. (2001), section 10.13.2. Finally, \code{type = "cv"}
  shows, if available, the results from cross-validation. 

  The functions \command{\link{panel_partdep}} and
  \command{\link{panel_coef}} are exported to show the additional
  arguments that can be passed to \code{\ldots} of a
  \command{\link{plot}} call.  

  Notice that user-defined plots can be generated by the use of the
  \command{\link{plot.party}} function, see \pkg{partykit}.
}

\value{
  The \command{\link{plot.fvcm}} method returns \code{NULL}.
}

\author{Reto Burgin}

\references{
  Hastie, T., R. Tibshirani and J. Friedman (2001). \emph{The Elements
    of Statistical Learning} (2 ed.). New York, USA: Springer-Verlag.
}

\examples{
## ------------------------------------------------------------------- #
## Dummy example:
##
## Plotting the types "coef" and "partdep" for a 'tvcm' object fitted 
## on the artificial data 'vcrpart_2'.
## ------------------------------------------------------------------- # 

data(vcrpart_2)

## fit the model
model <- tvcglm(y ~ vc(z1, z2, by = x1, intercept = TRUE) + x2,
                data = vcrpart_2, family = gaussian(),
                control = tvcm_control(maxwidth = 3, minbucket = 5L))

## plot type "coef"
plot(model, "coef")

## add various (stupid) plot parameters
plot(model, "coef",
     plot_gp = list(type = "p", pch = 2, ylim = c(-4, 4),
       label = c("par1", "par2"), gp = gpar(col = "blue")),
     conf.int_gp = list(angle = 45, length = unit(2, "mm"),
       ends = "last", type = "closed"),
     mean_gp = list(pch = 16,
       gp = gpar(fontsize = 16, cex = 2, col = "red")))

## separate plots with separate plot parameters
plot(model, "coef", parm = list("(Intercept)", "x1"), tnex = 2,
     plot_gp = list(list(gp = gpar(col = "red")),
                    list(gp = gpar(col = "blue"))),
     mean_gp = list(list(gp = gpar(col = "green")),
                    list(gp = gpar(col = "yellow"))))

## plot type "partdep"
par(mfrow = c(1, 2))
plot(model, "partdep", var = "z1", ask = FALSE)
}

\seealso{\command{\link{tvcm}}, \command{\link{tvcm-methods}}}

\keyword{hplot}
