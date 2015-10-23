# SpringleafMarketingResponse
R code used to generate my entries in Kaggle's Springleaf Marketing
Response contest.  I ended up comming in 277th out of 2225 entries in
my first contest.

I ran this code on a 16 GB, 8 core AMD system.  I ran into
memory swapping issues when I attempted to do everything in a single
process due to the large size of the data sets, even with 16 GB of RAM
available.  Thus, I broke the process into several R scripts that I
could run independently.  It also helped to reduce turnaround time
when I made a typo or other error in the latter stages.  Turnaround
time became crucial as I learned more about the XGBoost library and
made experiments on the data, so I needed to reduce it as much as
possible.  Swapping is *very* slow; avoid it.

I used three stages:

1. preprocess the data
2. create trained values
3. generate a submission based on the test data

Preprocessing the data consisted of eliminating duplicate features,
creating additional features based on timestamps, and mapping
character strings to integer values.  This process resulted in two
data files used in the subsequent stages.

I actually did very little feature engineering and next time I will
spend more time on it.  So many features, so little time...

`cleanData.R` reads both the training and the test data and applies
some simple transformations.  It determines which columns represent
character data; translates several apparent null character data values
to NA; creates month, day of week and year columns for each column
containing time data; sets character data to a common set of
encodings; and sets NA values to -1.  Once all data have been cleaned,
it creates two new data files, `cleanTrainData.data` and
`cleanTestData.data`. 

Two paths are available to create submissions, performing a single
run, or making multiple training runs and averaging them together for
the submission.  All of the multiple runs scored better than the
single submissions, thus that is what I used for my final submissions.

`xgboost1.R` and `makeSubmission.R` provide the single run path to
making a submission.

`xgboostMulti,R` and `makeMultiSubmission.R` create a submission based
on sampling the training data to create multiple training data sets.
The `make MultiSubmission.R` then makes predictions using an ensemble
of the training data.  This approach boosted my score more than
anything else.  My public leaderboard scores were much higher than the
highest scores I achieved in an individual run.  One more for the
*wisdom of the crowd*.
