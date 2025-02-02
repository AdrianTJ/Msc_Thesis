install.packages(c("BASS", "lhs", 'MASS', 'mcreplicate'))

library(BASS)
library(lhs)
library(MASS)
library(mcreplicate)

f <- function(x1,x2) {
  y1 <- x1 * 15
  y2 <- x2 * 20 - 5
  a <- 1
  b <- 5.1 / (4 * pi ^2)
  c <- 5 / pi
  r <- 6
  s <- 10
  t <- 1 / (8 * pi)
  return(a * (y2 - b * y1^2 + c * y1 - r)^2 + s * (1-t) * cos(y1) + s)
}

get_bass_2d <- function(max_iterations = 100){
  n0 <- 10
  dims <- 2
  XX <- maximinLHS(n0, dims)
  Y <- f(XX[,1], XX[,2])
  
  for (iteration in 1:max_iterations) {
    
    fit <- bass(
      xx = XX,
      y = Y,
      degree = 1,
      verbose = F,
      #thin = 10
    )
    
    x_new <- maximinLHS(1000,dims)
    pred <- predict(fit, newdata = data.frame(x = x_new))
    mu <- apply(pred,2,mean)
    
    kappa <- 1 # tunable
    sigma <- apply(pred,2,sd)
    lower_confidence_bound <- mu - kappa * sigma
    
    XX <- rbind(XX, x_new[which.min(lower_confidence_bound),])
    Y <- append(Y, f(x_new[which.min(lower_confidence_bound),][1],x_new[which.min(lower_confidence_bound),][2]))
    print(iteration)
  }
  return(Y)
}

results <- mc_replicate(n=100, get_bass_2d(max_iterations = 100), mc.cores = 6)

write.matrix(results,file="Branin-Hoo_Results_BASS.txt")


