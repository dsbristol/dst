#!/bin/sh

## Remember to get this locally onto your BC4 filesystem with:
## git clone https://github.com/dsbristol/pyspark.git

## You can get this working locally on your laptop too. This is worth it for pyspart but probably not for hadoop. The only real barrier is getting Hadoop to talk to Java...

## Some references and source material:

# http://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html#Standalone_Operation
# https://www.linuxjournal.com/content/introduction-mapreduce-hadoop-linux
# https://examples.javacodegeeks.com/enterprise-java/apache-hadoop/hadoop-streaming-example/
# https://dzone.com/articles/local-hadoop-on-laptop-for-practice

module load Java/1.8.0_92
wget https://www.apache.org/dyn/closer.cgi/hadoop/common/hadoop-3.1.2/hadoop-3.1.2.tar.gz
tar -xzvf hadoop-3.1.2.tar.gz

## To run Map/Reduce locally
./1.1-map.py < data/test.log | sort | ./1.1-reduce.py

#############
rm -rf output/conn_log # Remove the output if it is already created
HDIR=hadoop-3.1.2
$HDIR/bin/hadoop jar \
  $HDIR/share/hadoop/tools/lib/hadoop-streaming-3.1.2.jar \
  -mapper 1.1-map.py -reducer 1.1-reduce.py \
  -input data/test.log -output output/conn_log

#############
## GET SOME DATA
## This is how we obtained the `books` dataset; see ota.ox.ac.uk for details.
# mkdir data/books
# cd data/books
# for i in `seq 5720 5730`; do
#     wget http://ota.ox.ac.uk/text/$i.txt
# done
# cd ../..

rm -rf output/books_wc # Remove the output if it is already created
$HDIR/bin/hadoop jar \
  $HDIR/share/hadoop/tools/lib/hadoop-streaming-3.1.2.jar \
  -mapper 1.2-map_wc.py -reducer 1.2-reduce_wc.py \
  -input data/books/* -output output/books_wc

#############
## Running "real" hadoop

## NOW you have to setup ssh with password less access! See

## test with 
## ssh localhost
## If that works, then you can type "exit" to get back to your regular login.
## Otherwise this should work:
# ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
# cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
# chmod 0600 ~/.ssh/authorized_keys

## Setup HDFS
echo "
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>
" > $HDIR/etc/hadoop/hdfs-site.xml

## Format HDFS and setup a namenode
$HDIR/bin/hdfs namenode -format

## Create a folder on HDFS
$HDIR/bin/hdfs dfs -mkdir hdfs
$HDIR/bin/hdfs dfs -put data/books hdfs/

## See also 
## hdfs dfs -copyToLocal <hdfs_input_file_path> <output_path>

## Rerun the hadoop job, this time specifying 10 reducers

$HDIR/bin/hadoop jar \
  $HDIR/share/hadoop/tools/lib/hadoop-streaming-3.1.2.jar \
  -D mapred.reduce.tasks=10 \     
  -mapper 1.2-map_wc.py -reducer 1.2-reduce_wc.py \
  -input hdfs/books/* -output hdfs/books_wc
