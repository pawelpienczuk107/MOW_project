# temporaries

library(dmr.claseval)
library(dmr.disc)
library(dmr.regeval)
library(dmr.stats)
library(dmr.trans)
library(dmr.util)
library(rpart)

data(weather, package="dmr.data")
data(weatherc, package="dmr.data")
data(weatherr, package="dmr.data")
data(Vehicle, package="mlbench")
data(Soybean, package="mlbench")
data(BostonHousing, package="mlbench")
set.seed(12)
rv <- runif(nrow(Vehicle))
v.train <- Vehicle[rv>=0.33,]
v.test <- Vehicle[rv<0.33,]
rs <- runif(nrow(Soybean))
s.train <- Soybean[rs>=0.33,]
s.test <- Soybean[rs<0.33,]
rbh <- runif(nrow(BostonHousing))
bh.train <- BostonHousing[rbh>=0.33,]
bh.test <- BostonHousing[rbh<0.33,]

dd.chi2 <- function(a1, a2) 1-chisq.test(a1, a2)$p.value
cd.kruskal <- function(a1, a2) 1-kruskal.test(a1, a2)$p.value
cc.spearman <- function(a1, a2) 1-cor.test(a1, a2, method="spearman")$p.value
## simple statistical attribute selection filter
simple.filter <- function(formula, data, dd=dd.chi2, cd=cd.kruskal, cc=cc.spearman)
{
  attributes <- x.vars(formula, data)
  target <- y.var(formula)
  utility <- function(a)
  {
    unname(switch(attr.type(data[[a]], data[[target]]),
                  dd = dd(data[[a]], data[[target]]),
                  cd = cd(data[[a]], data[[target]]),
                  dc = cd(data[[target]], data[[a]]),
                  cc = cc(data[[a]], data[[target]])))
  }
  sort(sapply(attributes, utility), decreasing=TRUE)
}
# simple filter for the weather data
simple.filter(play~., weather)
simple.filter(play~., weather, dd=symunc)
# simple filter for the weatherc data
simple.filter(play~., weatherc)
simple.filter(play~outlook+wind, weatherc, dd=symunc)
simple.filter(play~temperature+humidity, weatherc,
              cd=function(a1, a2) kruskal.test(a1, a2)$statistic)
# simple filter for the weatherr data
simple.filter(playability~., weatherr)
simple.filter(playability~outlook+wind, weatherr,
              cd=function(a1, a2) kruskal.test(a1, a2)$statistic)
simple.filter(playability~temperature+humidity, weatherr,
              cc=function(a1, a2) cor(a1, a2, method="spearman")^2)
# simple filter for the Vehicle Silhouettes data
v.utl.simple <- simple.filter(Class~., discnm.eqfreq(~., v.train, 7), dd=symunc)
# simple filter for the Soybean data
s.utl.simple <- simple.filter(Class~., Soybean, dd=symunc)
# simple filter for the BostonHousing data
bh.utl.simple <- simple.filter(medv~., discnm.eqfreq(~., bh.train, 7), dd=symunc)
