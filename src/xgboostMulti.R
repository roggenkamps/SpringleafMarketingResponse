library(xgboost)

cat("initializing data\n")

load("cleanTrainData.data")

seedVal   <- 1021   # random seed, change to a unique value for each run 
                    # to insure the run does not repeat an earlier one
seriesVal <-  "A"   # designator for the series
nModels   <-    2   # number of models to run
nRounds   <-   50   # number of rounds 
earlyStop <-   10   # nummer of rounds to go beyond a maximum
trainPct  <-  0.7   # percentage of training instances
maxDepth  <-   25   # depth of the tree
verbosity <-    1   # amount of messages generated

rawData <- cleanTrainData$train
ntrain  <- nrow(rawData)

trainSz <- trainPct * ntrain
evalSz  <- ntrain - trainSz

rm(cleanTrainData)
gc()

cat("created test data matrix\n")

iter <- 0

set.seed(seedVal)

param <- list(  objective           = "binary:logistic",
                # booster           = "gblinear",
                eta                 = 0.1,
                gamma               = 0.01,
                max_depth           = maxDepth,  # changed from default of 6
                subsample           = 1,
                colsample_bytree    = 1,
                eval_metric         = "auc"
                # alpha = 0.0001,
                # lambda = 0.5,
                # alpha  = 0.5
             )


for (i in 1:nModels) {
  iterStr <- paste(seriesVal,formatC(iter,width=4,flag="0"),sep="")
  cat("Iteration ",iterStr,"  start\n")

  trainSamples <- sample(1:ntrain, trainSz)
  evalSamples  <- setdiff(1:ntrain, trainSamples)

  train  <- rawData[trainSamples,]
  ytrain <- train$target

  eval   <- rawData[evalSamples,]
  yeval  <- eval$target
  train  <- subset(train,select=-c(ID,target))
  eval   <- subset(eval,select=-c(ID,target))

  dtrain <- xgb.DMatrix(data.matrix(train), label=ytrain)
  dval   <- xgb.DMatrix(data.matrix(eval),  label=yeval)

  watchlist <- list(eval = dval, train = dtrain)

  cat("  training\n")
  clf <- xgb.train(   params              = param,
                      data                = dtrain,
                      nrounds             = nRounds,
                      verbose             = verbosity,
                      early.stop.round    = earlyStop,
                      watchlist           = watchlist,
                      maximize            = TRUE)

  save(clf, file=paste("clf_",iterStr,".data",sep=""))

  cat("  cleaning up\n")
  rm(trainSamples,evalSamples)
  rm(train,ytrain)
  rm(eval,yeval)
  rm(dtrain,dval)
  gc()

  iter <- iter + 1
}
       
