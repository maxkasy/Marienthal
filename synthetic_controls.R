library(Synth)
library(tidyverse)




# The following is reproducing the example by the Synth authors
data("basque")

dataprep.out <-
    dataprep(
        foo = basque
        ,predictors= c("school.illit",
                       "school.prim",
                       "school.med",
                       "school.high",
                       "school.post.high"
                       ,"invest"
        )
        ,predictors.op = c("mean")
        ,dependent     = c("gdpcap")
        ,unit.variable = c("regionno")
        ,time.variable = c("year")
        ,special.predictors = list(
            list("gdpcap",1960:1969,c("mean")),                            
            list("sec.agriculture",seq(1961,1969,2),c("mean")),
            list("sec.energy",seq(1961,1969,2),c("mean")),
            list("sec.industry",seq(1961,1969,2),c("mean")),
            list("sec.construction",seq(1961,1969,2),c("mean")),
            list("sec.services.venta",seq(1961,1969,2),c("mean")),
            list("sec.services.nonventa",seq(1961,1969,2),c("mean")),
            list("popdens",1969,c("mean")))
        ,treatment.identifier  = 17
        ,controls.identifier   = c(2:16,18)
        ,time.predictors.prior = c(1964:1969)
        ,time.optimize.ssr     = c(1960:1969)
        ,unit.names.variable   = c("regionname")
        ,time.plot            = c(1955:1997) 
    )


synth.out <- synth(data.prep.obj = dataprep.out, method = "BFGS")

gaps <- dataprep.out$Y1plot - (dataprep.out$Y0plot %*% synth.out$solution.w)

synth.tables <- synth.tab(dataprep.res = dataprep.out, synth.res = synth.out)


# implemented by running a for loop to implement placebo tests across all control units
# in the sample and collecting information on the gaps.