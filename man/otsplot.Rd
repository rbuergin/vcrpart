\name{otsplot}

\alias{otsplot}
\alias{otsplot.default}
\alias{otsplot_control}
\alias{otsplot_filter}

\title{Time-series plot for longitudinal ordinal data}

\description{Plots multiple ordinal sequences in a \eqn{x} (usually
  time) versus \eqn{y} (response variable) scatterplot. The sequences 
  are displayed by jittered frequency-weighted parallel lines.}

\usage{

\method{otsplot}{default}(x, y, subject, weights, groups,
        control = otsplot_control(), filter = NULL, 
        main, xlab, ylab, xlim, ylim, ...)

otsplot_control(cex = 1, lwd = 1/4, col = NULL,
                hide.col = grey(0.8), seed = NULL,
                lorder = c("background", "foreground") ,
                lcourse = c("upwards", "downwards"),
                grid.scale = 1/5, grid.lwd = 1/2,
                grid.fill =  grey(0.95), grid.col = grey(0.6),          
                layout = NULL, margins = c(5.1, 4.1, 4.1, 3.1),
                strip.fontsize = 12, strip.fill =  grey(0.9),
                pop = TRUE, newpage = TRUE, maxit = 500L)

otsplot_filter(method = c("minfreq", "cumfreq", "linear"), level = NULL) 
}

\arguments{
  \item{x}{a \code{numeric} or \code{factor} vector for the \code{x}
    axis, e.g. time.}  
  \item{y}{an \code{ordered} factor vector for the \code{y} axis.} 
  \item{subject}{a \code{factor} vector that identifies the subject,
    i.e., allocates elements in \code{x} and \code{y} to the subject
    i.e. observation unit.} 
  \item{weights}{a numeric vector of weights of length equal the number
    of subjects.}
  \item{groups}{a \code{numeric} or \code{factor} vector of group
    memberships of length equal the number of subjects. When specified,
    one panel is generated for each distinct membership value.}
  \item{control}{control parameters produced by \code{otsplot_control},
    such as line colors or the scale of translation zones.}
  \item{filter}{an \command{\link{otsplot_filter}} object which defines line 
    coloring options. See details.} 
  \item{main, xlab, ylab}{title and axis labels for the plot.}
  \item{xlim, ylim}{the x limits \code{c(x1, x2)} resp. y limits
    \code{(y1,y2)}.}
  \item{\ldots}{additional undocumented arguments.}
  \item{cex}{expansion factor for the squared symbols.}
  \item{lwd}{expansion factor for line widths. The expansion is
    relative to the size of the squared symbols.}
  \item{col}{color palette vector for line coloring.}
  \item{hide.col}{Color for ordinal time-series filtered-out by the
    \code{filter} specification in \code{otsplot}.}
  \item{seed}{an integer specifying which seed should be set at the
    beginning.}
  \item{lorder}{line ordering. Either \code{"background"} or
    \code{"foreground"}.}
  \item{lcourse}{Method to connect simultaneous elements with the
    preceding and following ones. Either \code{"upwards"} (default) or
    \code{"downwards"}.}
  \item{grid.scale}{expansion factor for the translation zones.}
  \item{grid.lwd}{expansion factor for the borders of translation
    zones.}
  \item{grid.fill}{the fill color for translation zones.}
  \item{grid.col}{the border color for translation zones.}
  \item{strip.fontsize}{fontsize of titles in stripes that appear
    when a \code{groups} vector is assigned.}
  \item{strip.fill}{color of strips that appear when a \code{groups}
    vector is assigned.}
  \item{layout}{an integer vector \code{c(nr, nc)} specifying the
    number of rows and columns of the panel arrangement when the
    \code{groups} argument is used.} 
  \item{margins}{a numeric vector \code{c(bottom, left, top, right)}
    specifying the space on the margins of the plot. See also
    the argument \code{mar} in \command{\link{par}}.}
  \item{pop}{logical scalar. Whether the viewport tree should be popped
    before return.}
  \item{newpage}{logical scalar. Whether \code{grid.newpage()} should be
    called previous to the plot.}
  \item{maxit}{maximal number of iteration for the algorithm that
    computes the translation arrangement.}
   \item{method}{character string. Defines the filtering
     function. Available are \code{"minfreq"}, \code{"cumfreq"} and
     \code{"linear"}.} 
   \item{level}{numeric scalar between 0 and 1. The frequency threshold
     for the filtering methods \code{"minfreq"} and \code{"cumfreq"}.} 
}

\details{
  The function is a scaled down version of the \code{seqpcplot}
  function of the \pkg{TraMineR} package, implemented in the \pkg{grid}
  graphics environment.

  The \code{filter} argument serves to specify filters to fade out less 
  interesting patterns. The filtered-out patterns are displayed in the
  \code{hide.col} color. The \code{filter} argument expects an object 
  produced by \command{\link{otsplot_filter}}.

  \code{otsplot_filter("minfreq", level = 0.05)} colors patterns with a 
  support of at least 5\% (within a
  group). \code{otsplot_filter("cumfreq", level = 0.75)} 
  highlight the 75\% most frequent patterns (within
  group). \code{otsplot_filter("linear")}  
  linearly greys out patterns with low support.

  The implementation adopts a color palette which was originally
  generated by the \pkg{colorspace} package (Ihaka et al., 2013). The
  authors are grateful for these codes.  
}

\value{\command{\link{otsplot}} returns an object of class
  \code{otsplot}.

  \command{\link{otsplot_control}} returns an object of class
  \code{otsplot_control} and \command{\link{otsplot_filter}} an object
  of class \code{otsplot_filter}. Both these object types are
  specifically designed as input arguments of \command{\link{otsplot}}.
  
}

\author{Reto Burgin and Gilbert Ritschard}

\references{
  Burgin, R. and G. Ritschard (2014). A Decorated Parallel Coordinate 
  Plot for Categorical Longitudinal Data, \emph{The American
  Statistician} \bold{68}(2), 98--103. 

  Ihaka, R., P. Murrell, K. Hornik, J. C. Fisher and A. Zeileis (2013).
  colorspace: Color Space Manipulation. R package version 1.2-4. URL
  \url{https://CRAN.R-project.org/package=colorspace}.
}

\examples{
## ------------------------------------------------------------------- #
## Dummy example: 
##
## Plotting artificially generated ordinal longitudinal data
## ------------------------------------------------------------------- #

## load the data
data(vcrpart_1)
vcrpart_1 <- vcrpart_1[1:40,]

## plot the data
otsplot(x = vcrpart_1$wave, y = vcrpart_1$y, subject = vcrpart_1$id)

## using 'groups'
groups <- rep(c("A", "B"), each = nrow(vcrpart_1) / 2L)
otsplot(x = vcrpart_1$wave, y = vcrpart_1$y, subject = vcrpart_1$id,
        groups = groups)

## color series with supports over 30%
otsplot(x = vcrpart_1$wave, y = vcrpart_1$y, subject = vcrpart_1$id,
        filter = otsplot_filter("minfreq", level = 0.3))

## highlight the 50% most frequent series
otsplot(x = vcrpart_1$wave, y = vcrpart_1$y, subject = vcrpart_1$id,
        filter = otsplot_filter("cumfreq", level = 0.5))

## linearly grey out series with low support 
otsplot(x = vcrpart_1$wave, y = vcrpart_1$y, subject = vcrpart_1$id,
        filter = otsplot_filter("linear"))

## subject-wise plot 
otsplot(x = vcrpart_1$wave, y = vcrpart_1$y,
        subject = vcrpart_1$id, groups = vcrpart_1$id)
}

\keyword{hplot}