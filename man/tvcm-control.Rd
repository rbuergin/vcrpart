\name{tvcm-control}

\alias{tvcm-control}
\alias{tvcm_control}

\title{Control parameters for \command{\link{tvcm}}.} 

\description{
  Various parameters that control aspects for \command{\link{tvcm}}.  
}

\usage{
tvcm_control(minsize = 30, mindev = ifelse(sctest, 0.0, 2.0),
             sctest = FALSE, alpha = 0.05, bonferroni = TRUE,
             trim = 0.1, estfun.args = list(), nimpute = 5, 
             maxnomsplit = 5, maxordsplit = 9, maxnumsplit = 9,
             maxstep = 1e3, maxwidth = Inf, maxdepth = Inf,
             lossfun = neglogLik2, ooblossfun = NULL, fast = TRUE,
             cp = 0.0, dfpar = 0.0, dfsplit = 1.0,
             cv = !sctest, folds = folds_control("kfold", 5),
             prune = cv, papply = mclapply, papply.args = list(),
             center = fast, seed = NULL, verbose = FALSE, ...)
}

\arguments{
  \item{alpha, bonferroni, trim, estfun.args, nimpute}{See
    \command{\link{tvcolmm_control}}} 
  \item{mindev, cv, folds, prune, center}{See
    \command{\link{tvcglm_control}}}
  \item{minsize}{numeric (vector). The minimum sum of weights in
    terminal nodes.}
  \item{sctest}{logical scalar. Defines whether coefficient constancy
    tests should be used for the variable and node selection in each
    iteration.}
  \item{maxnomsplit}{integer. For nominal partitioning variables with
    more the \code{maxnomsplit} the categories are ordered an treated as
    ordinal.}
  \item{maxordsplit}{integer. The maximum number of splits of ordered
    partitioning variables to be evaluated.}
  \item{maxnumsplit}{integer. The maximum number of splits of numeric
    partitioning variables to be evaluated.}
  \item{maxstep}{integer. The maximum number of iterations i.e. number
    of splits to be processed.}  
  \item{maxwidth}{integer (vector). The maximum width of the partition(s).}  
  \item{maxdepth}{integer (vector). The maximum depth of the partition(s).} 
  \item{lossfun}{a function to extract the training error, typically
    minus two times the negative log likelihood of the fitted model (see
    \command{\link{neglogLik2}}). Is currently ignored if a \code{glm}
    model is fitted and \code{fast = TRUE}.}  
  \item{ooblossfun}{a loss function that defines how to compute the
    validation error during cross-validation. The function will be
    assigned to the \code{fun} argument of \command{\link{oobloss}}.}
  \item{fast}{logical scalar. Whether the approximative model should be
    used to search for the next split. The approximative search model
    uses only the observations of the node to split and incorporates the
    fitted values of the current model as offsets. Therewith the
    estimation is reduces to the coefficients of the added split. If
    \code{FALSE}, the accurate search model is used.}
  \item{cp}{numeric scalar. The penalty to be multiplied with the
    complexity of the model during partitioning. The complexity of the
    model is defined as the number of coefficients times \code{dfpar}
    plus the number of splits times \code{dfsplit}. By default, \code{cp
      = 0} (no penalization during partitioning) and \code{dfpar = 0} and
    \code{dfsplit = 1} (the complexity is measured as the total number
    of splits). \code{cp} also presents the minimum evaluated value at
    cross-validation.}
  \item{dfpar}{numeric scalar. The degree of freedom per model
    coefficient. Is used to compute the complexity of the model, see
    \code{cp}.}  
  \item{dfsplit}{a numeric scalar. The degree of freedom per split. Is
    used to compute the complexity of the model, see \code{cp}.}   
  \item{papply}{(parallel) apply function, defaults to
    \code{\link[parallel]{mclapply}}. The function will parallelize the 
    partition stage and the evaluation of the cross-validation folds as
    well as the final pruning stage.}
  \item{papply.args}{a list of arguments to be passed to \code{papply}.}
  \item{seed}{an integer specifying which seed should be set at the
    beginning.}
  \item{verbose}{logical. Should information about the fitting process
    be printed to the screen?}
  \item{\ldots}{further, undocumented arguments to be passed.} 
}

\value{
  A list of class \code{tvcm_control} containing
  the control parameters for \command{\link{tvcm}}.
}

\author{Reto Burgin}

\seealso{\command{\link{tvcolmm_control}},
  \command{\link{tvcglm_control}}, \command{\link{tvcm}},
  \command{\link{fvcm}}}

\examples{
tvcm_control(minsize = 100)
}