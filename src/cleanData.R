#
# cleanData.R -- the dirty data from Springleaf and save it

library(readr)
library(xgboost)

set.seed(511)

cat("reading the train and test data\n")

train <- read_csv("../input/train.csv", progress=FALSE)
test  <- read_csv("../input/test.csv",  progress=FALSE)

# names(train)  # 1934 variables

#
cat("removing constant columns\n")
#

train_col_ct  <- sapply(train, function(x) length(unique(x)))
train         <- train[, !names(train) %in% names(train_col_ct[train_col_ct==1])]

test_col_ct   <- sapply(test,  function(x) length(unique(x)))
test          <- test[,  !names(test)  %in% names(test_col_ct[ test_col_ct==1])]

#
cat("changing character data to integer values\n")
#

train_char <- train[, sapply(train, is.character)]
test_char  <- test[,  sapply(test, is.character)]

if (!all(names(train_char) == names(test_char))) {
  stop("train_char != test_char\n")
}


train_char[train_char==-1]   <- NA
train_char[train_char==""]   <- NA
train_char[train_char=="[]"] <- NA


test_char[test_char==-1]   <- NA
test_char[test_char==""]   <- NA
test_char[test_char=="[]"] <- NA

cat("adding time-based features\n")

train_date <- train_char[,grep("\\dJAN\\d|\\dFEB\\d|\\dMAR\\d|\\dAPR\\d|\\dMAY\\d|\\dJUN\\d", train_char, perl=TRUE,ignore.case=TRUE),]
test_date  <- test_char[,grep("\\dJAN\\d|\\dFEB\\d|\\dMAR\\d|\\dAPR\\d|\\dMAY\\d|\\dJUN\\d", test_char, perl=TRUE,ignore.case=TRUE),]

train_char <- train_char[, !colnames(train_char) %in% colnames(train_date)]
test_char  <- test_char[,  !colnames(test_char) %in% colnames(test_date)]

cat("converting strings to dates\n")
train_date <- sapply(train_date, function(x) strptime(x, "%d%B%y:%H:%M:%S"))
train_date <- do.call(cbind.data.frame, train_date)

test_date <- sapply(test_date, function(x) strptime(x, "%d%B%y:%H:%M:%S"))
test_date <- do.call(cbind.data.frame, test_date)

if (!all(names(train_date) == names(test_date))) {
  stop("train_date != test_date\n")
}


for (idx in colnames(train_date)) {
  cat("Procesing training date column: ",idx," ..")

  cat("DOW,")
  idx1 <- paste( idx, "dow",sep="_")
  day_of_week <- train_date[,idx]
  day_of_week <- sapply(day_of_week, function(x) if (!is.na(x)) as.integer(strftime(x, "%u")) else -1)
  train[[idx1]] <- day_of_week

  cat("month,")
  idx1 <- paste( idx, "mon",sep="_")
  month <- train_date[,idx]
  month <- sapply(month, function(x) if (!is.na(x)) as.integer(strftime(x, "%u")) else -1)
  train[[idx1]] <- month

  cat("yr\n")
  idx1 <- paste( idx, "yr",sep="_")
  yr <- train_date[,idx]
  yr <- sapply(yr, function(x) if (!is.na(x)) as.integer(strftime(x, "%y")) else -1)
  train[[idx1]] <- yr


  cat("Procesing testing date column: ",idx," ..")
  cat("DOW,")
  idx1 <- paste( idx, "dow",sep="_")
  day_of_week <- test_date[,idx]
  day_of_week <- sapply(day_of_week, function(x) if (!is.na(x)) as.integer(strftime(x, "%u")) else -1)
  test[[idx1]] <- day_of_week

  cat("month,")
  idx1 <- paste( idx, "mon",sep="_")
  month <- test_date[,idx]
  month <- sapply(month, function(x) if (!is.na(x)) as.integer(strftime(x, "%u")) else -1)
  test[[idx1]] <- month

  cat("yr\n")
  idx1 <- paste( idx, "yr",sep="_")
  yr <- test_date[,idx]
  yr <- sapply(yr, function(x) if (!is.na(x)) as.integer(strftime(x, "%y")) else -1)
  test[[idx1]] <- yr

}

# blow away the old timestamps

train <- train[, !colnames(train) %in% colnames(train_date)]
test  <- test[, !colnames(test) %in% colnames(test_date)]

for (f in names(train_char)) {
  levels <- unique(c(train[[f]], test[[f]]))
  train[[f]] <- as.integer(factor(train[[f]], levels=levels))
  test[[f]]  <- as.integer(factor(test[[f]], levels=levels))
}

cat("replacing missing values with -1\n")
for (idx in 1:ncol(train)) { train[is.na(train[,idx]),idx] <- -1 }

for (idx in 1:ncol(test)) { test[is.na(test[,idx]),idx] <- -1 }


cat("saving training and test data\n")

cleanTrainData               <- list()
cleanTrainData[["train"]]    <- train

save(cleanTrainData, file="cleanTrainData.data")

cleanTestData               <- list()
cleanTestData[["test"]]     <- test

save(cleanTestData, file="cleanTestData.data")
