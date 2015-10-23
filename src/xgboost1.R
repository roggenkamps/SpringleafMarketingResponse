library(xgboost)
library(readr)

cat("initializing data\n")

set.seed(808)

load("cleanTrainData.data")

nComp     <- 100   # number of principle components to use
nRounds   <- 200   # number of rounds 
earlyStop <-  20   # nummer of rounds to go beyond a maximum
trainPct  <- 0.7   # percentage of training instances
maxDepth  <-  25   # depth of the tree
verbosity <-   0   # amount of messages generated

rawData <- cleanTrainData$train

ntrain <- nrow(rawData)

trainSz <- 0.7 * ntrain
evalSz  <- ntrain - trainSz

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

cat("training...\n")
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

set.seed(101)
clf <- xgb.train(   params              = param,
                    data                = dtrain,
                    nrounds             = nRounds,
                    verbose             = verbosity,
                    early.stop.round    = earlyStop,
                    watchlist           = watchlist,
                    maximize            = TRUE)

save(clf, file="clf.data")
