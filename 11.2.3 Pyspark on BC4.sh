#!/bin/sh

## See https://www.tutorialspoint.com/pyspark/pyspark_quick_guide.htm
## And https://spark.apache.org/examples.html

## Setup the pyspark environment
module load languages/anaconda3/3.6.5
pip install pyspark --user


##
rm -rf folder
spark-submit 2.1-SparkInputOutput.py &> 2.1-SparkInputOutput.log
grep -v INFO 2.1-SparkInputOutput.log | grep -v WARN

## Do this for count, filter, collect, broadcast, ...
spark-submit 2.2-SparkCount.py &> 2.2-SparkCount.log
grep -v INFO 2.2-SparkCount.log | grep -v WARN

## Examine the storage type
spark-submit 2.3-SparkStorageLevel.py &> 2.3-SparkStorageLevel.log
grep -v INFO 2.3-SparkStorageLevel.log | grep -v WARN

## Run a python script using pyspark
spark-submit 2.4-ReadAndFilter.py &> 2.4-ReadAndFilter.log
grep "Lines" 2.4-ReadAndFilter.log

## pyspark likes to have psutil installed, though runs without:
# conda install psutil

## Spark isn't happy deleting contents of files due to permissions
rm -rf target/tmp/myCollaborativeFilter
## Run a basic distributed ML algorithm
spark-submit 2.5-MLlibRecommender.py &> 2.5-MLlibRecommender.log
grep -v INFO 2.5-MLlibRecommender.log | grep -v WARN

## Run map-reduce word counting
rm -rf pyspark_wc
spark-submit 2.6-MapReduceWordcount.py &> 2.6-MapReduceWordcount.log
grep -v INFO 2.6-MapReduceWordcount.log | grep -v WARN

##########
## https://towardsdatascience.com/machine-learning-with-pyspark-and-mllib-solving-a-binary-classification-problem-96396065d2aa
spark-submit 2.7-MLpipeline.py &> 2.7-MLpipeline.log
grep -v INFO 2.7-MLpipeline.log | grep -v WARN

