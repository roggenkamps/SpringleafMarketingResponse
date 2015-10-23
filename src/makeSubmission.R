library(readr)
library(xgboost)

set.seed(808)

load("cleanTestData.data")

test <- cleanTestData$test

cat("creating submission predictions\n" )

submission <- data.frame(ID=test$ID)
submission$target <- NA

test <- subset(test,select=-c(ID))
dtest <-data.matrix(test)

cat("created data matrix\n")

load("clf.data")

submission[, "target"] <- predict(clf, dtest )

cat("saving the submission file\n")
write_csv(submission, "submission.csv")

