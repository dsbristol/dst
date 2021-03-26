from pyspark import SparkContext
sc = SparkContext("local", "count app")
## Distribute data over a spark context
samples = sc.parallelize([
    ("abonsanto@fakemail.com", "Alberto", "Bonsanto"),
    ("mbonsanto@fakemail.com", "Miguel", "Bonsanto"),
    ("stranger@fakemail.com", "Stranger", "Weirdo"),
    ("dbonsanto@fakemail.com", "Dakota", "Bonsanto")
])

## Collect the data (a sequential operation)
print(samples.collect())

## Save the data (a parallel operation)
samples.saveAsTextFile("output/folder/here.txt")
## Load the data (a parallel operation)
read_rdd = sc.textFile("output/folder/here.txt")
## Collect the data again
print(read_rdd.collect())
