from pyspark import SparkContext
import re
sc = SparkContext("local", "count app")
text_file = sc.textFile("hdfs/books/*.txt")

def linesplit(line):
    line = re.sub(r'[^\w\s]','',line)
    return(line.split(" "))

counts = text_file.flatMap(linesplit) \
             .map(lambda word: (word, 1)) \
             .reduceByKey(lambda a, b: a + b)

counts.saveAsTextFile("hdfs/pyspark_wc")

