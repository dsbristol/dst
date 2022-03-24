from pyspark.sql import SparkSession
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt

## See https://towardsdatascience.com/machine-learning-with-pyspark-and-mllib-solving-a-binary-classification-problem-96396065d2aa

## Interactive session

spark = SparkSession.builder.appName('ml-bank').getOrCreate()
df = spark.read.csv('data/bank.csv', header = True, inferSchema = True)
df.printSchema()

## Converting to pandas
pd.DataFrame(df.take(5), columns=df.columns).transpose()

## Using the spark RDS describe
numeric_features = [t[0] for t in df.dtypes if t[1] == 'int']
df.select(numeric_features).describe().toPandas().transpose()

## Two ways to sample 1000 random points
## The recommended way, though you have to specify two limits (the fraction, here 0.5, and the number, here 1000, if needed)
## This way creates a spark RDD
numeric_data1=df.sample(False, 0.5, seed=0).limit(1000)
## This way does a "collect", which can be slow in larger datasets, but is more natural
numeric_data2=df.rdd.takeSample(False, 1000, seed=0)

numeric_data = numeric_data1.toPandas()

## Plotting to a file
matplotlib.use('Agg')
axs = pd.plotting.scatter_matrix(numeric_data, figsize=(8, 8));

# n = len(numeric_data.columns)
# for i in range(n):
#     v = axs[i, 0]
#     v.yaxis.label.set_rotation(0)
#     v.yaxis.label.set_ha('right')
#     v.set_yticks(())
#     h = axs[n-1, i]
#     h.xaxis.label.set_rotation(90)
#     h.set_xticks(())
plt.savefig('output/banks.png')
plt.close()

## Getting rid of useless columns
df = df.select('age', 'job', 'marital', 'education', 'default', 'balance', 'housing', 'loan', 'contact', 'duration', 'campaign', 'pdays', 'previous', 'poutcome', 'deposit')
cols = df.columns
df.printSchema()

#######################
## Preparing the data
from pyspark.ml.feature import OneHotEncoder, StringIndexer, VectorAssembler

categoricalColumns = ['job', 'marital', 'education', 'default', 'housing', 'loan', 'contact', 'poutcome']
stages = []

for categoricalCol in categoricalColumns:
    stringIndexer = StringIndexer(inputCol = categoricalCol, outputCol = categoricalCol + 'Index')
    encoder = OneHotEncoder(inputCols=[stringIndexer.getOutputCol()],
                                outputCols=[categoricalCol + "classVec"])
    stages += [stringIndexer, encoder]

label_stringIdx = StringIndexer(inputCol = 'deposit', outputCol = 'label')
stages += [label_stringIdx]

numericCols = ['age', 'balance', 'duration', 'campaign', 'pdays', 'previous']
assemblerInputs = [c + "classVec" for c in categoricalColumns] + numericCols
assembler = VectorAssembler(inputCols=assemblerInputs, outputCol="features")
stages += [assembler]

#######################
## Making a "data processing pipeline"

from pyspark.ml import Pipeline
pipeline = Pipeline(stages = stages)
pipelineModel = pipeline.fit(df)
df = pipelineModel.transform(df)
selectedCols = ['label', 'features'] + cols
df = df.select(selectedCols)
df.printSchema()

#######################
## Look at a couple of rows
pd.DataFrame(df.take(5), columns=df.columns).transpose()

#######################
## Do a standard training/ testing split
train, test = df.randomSplit([0.7, 0.3], seed = 2018)
print("Training Dataset Count: " + str(train.count()))
print("Test Dataset Count: " + str(test.count()))


#######################
## Fit a logistic regression
from pyspark.ml.classification import LogisticRegression
lr = LogisticRegression(featuresCol = 'features', labelCol = 'label', maxIter=10)
lrModel = lr.fit(train)
predictions = lrModel.transform(test)

#######################
## Plot the results
import numpy as np

beta = np.sort(lrModel.coefficients)

plt.plot(beta)
plt.ylabel('Beta Coefficients')
plt.savefig('output/bank_betas.png')
plt.close()

######################
## ROC curves

trainingSummary = lrModel.summary

predpandas=predictions.select(['label','probability']).toPandas()
predpandas['probability']=[x[1] for x in predpandas['probability']]
from sklearn.metrics import roc_curve
testrocarray = roc_curve(predpandas['label'], predpandas['probability'])
testroc = pd.DataFrame.from_records(testrocarray).transpose()
testroc.columns=['FPR','TPR','Thresh']

trainroc = trainingSummary.roc.toPandas()

plt.plot(trainroc['FPR'],trainroc['TPR'],label='Training')
plt.plot(testroc['FPR'],testroc['TPR'],label='Test')
plt.ylabel('False Positive Rate')
plt.xlabel('True Positive Rate')
plt.title('ROC Curve')
plt.legend()
plt.savefig('output/banks_roc.png')
plt.close()

print('Training set areaUnderROC: ' + str(trainingSummary.areaUnderROC))
