library(xgboost)
library(readr)

cat("initializing data\n")

models <- c()
for (i in 0:1) {
    models <- c(models,paste("clf_A",formatC(i,width=4,flag="0"),".data",sep=""))
}
# for (i in 0:28) {
#     models <- c(models,paste("clf_B",formatC(i,width=4,flag="0"),".data",sep=""))
# }
# for (i in 0:49) {
#     models <- c(models,paste("clf_C",formatC(i,width=4,flag="0"),".data",sep=""))
# }
# for (i in 0:7) {
#     models <- c(models,paste("clf_D",formatC(i,width=4,flag="0"),".data",sep=""))
# }

nModels <- length( models )

load("cleanTestData.data")

test    <- cleanTestData$test
testIDs <- test$ID
test    <- subset(test,select=-c(ID))
dtest   <- data.matrix(test)
nitems  <- nrow(test)

cat("selecting models\n")

scores <- vector( mode="numeric", length=nModels)

i = 0
for ( model in models ) {
  i <- i + 1
  load( model )
  scores[i] <- clf$bestScore
  cat("scoring ",model,"  score: ",clf$bestScore,"  iters: ",clf$bestInd,"\n")
  rm(clf)
  gc()
}

scoreMean <- mean(scores)
scoreSD   <- sd(scores)

cat("mean: ",scoreMean,"  SD: ",scoreSD,"\n")

# selectedModels <- 1:length(models)

selectedModels <- which( scores >= (scoreMean ))
nSelectedModels <- length(selectedModels)

predictions <- matrix(nrow=nitems,ncol=nSelectedModels)

cat("making predictions\n")
i = 0
j = 0
for ( modelIdx in selectedModels ) {
  i <- i + 1
  model <- models[modelIdx]
  load( model )
  cat("predicting ",model,"\n")
  predictions[,i] <- predict(clf,dtest)
  rm(clf)
  gc()
}

avg <- vector(length=nitems)
sd  <- vector(length=nitems)

cat("averaging predictions\n")

for ( i in 1:nitems ) {
  avg[i] <- mean(predictions[i,])
  sd[i]  <- sd(predictions[i,])
}

submission <- data.frame(ID=testIDs)
submission[, "target"] <- avg

cat("saving the predictions\n")
write_csv(submission, "xgb_submission.csv" )
