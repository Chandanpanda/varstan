% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/model.R
\name{model}
\alias{model}
\alias{model.varstan}
\alias{model.Sarima}
\alias{model.garch}
\alias{model.varma}
\alias{model.Bekk}
\alias{model.SVM}
\title{Print the defined model of a varstan object}
\usage{
model(obj)
}
\arguments{
\item{obj}{a varstan object or one of the defined current defined models in varstan package}

\item{...}{additional values need in print methods}
}
\value{
a  string with the defined time series model
}
\description{
The function returns a string with the users defined model for the given time series data
}
\details{
if \code{obj} is a varstan object the function will print the information of the
defined model inside of the object. If \code{obj} is one of the model classes (like Sarima or garch)
then it will print the model information as well.

For full information of the model with the used priors use the function report or just
print the object
}
\examples{


model1 = Sarima(birth,order = c(0,1,2),seasonal = c(1,1,1))
model(model1)


}
\seealso{
\code{report} \code{print}
}
\author{
Asael Alonzo Matamoros
}
