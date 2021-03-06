% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/varma.R
\name{varma}
\alias{varma}
\title{Constructor varma(p,q) object}
\usage{
varma(ts,order = c(1,0))
}
\arguments{
\item{ts}{an multivariate time series}

\item{order}{A specification of the  VARMA model,same as order parameter:  the two
components (p, q) are the AR order,and the  MA order.}

\item{series.name}{an optional string vector with the series names.}
}
\description{
Constructor of the varma(p,q) model for Bayesian estimation in STAN
}
\details{
The function returns  a list with the data for running stan() function of
 rstan package

If \code{sd} option is used to specify an arma model for the mean parameter,
if a varma option is used then the model is equivalent to the varma model class

The default priors used in Bekk are:

\itemize{
 \item{"ar"}{ar ~ normal(0,0.5)}
 \item{"ma"}{ma ~ normal(0,0.5)}
 \item{"mu0"}{mu0 ~ normal(0,1)}
 \item{"sigma0"}{sigma0 ~ t-student(0,1,7)}
 \item{"arch"}{arch ~ normal(0,0.5)}
 \item{"garch"}{garch ~ normal(0,0.5)}
 \item{"mgarch"}{mgarch ~ normal(0,0.5)}
 \item{"dfv"}{dfv ~ gamma(2,0.1)}
}

For changing the default prior use the function \code{set_prior}
}
\examples{
# Declares a varma model for the Astrovan data

model = varma(Astrovan,order = c(1,1))
model


}
\references{
Polasek, Ren(1999).
 A multivariate GARCH-M model for exchange rates in the US,Germany and Japan

 Fonseca,Ferreira, Migon (2008)
 Objective Bayesian analysis for the Student-t regression model
}
\seealso{
\code{\link{garch}} \code{\link{varma}} \code{\link{set_prior}}
}
\author{
Asael Alonzo Matamoros
}
