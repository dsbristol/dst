#!/bin/sh

## Remember to get this locally onto your BC4 filesystem with:
## git clone https://github.com/dsbristol/pyspark.git

## You can get this working locally on your laptop too. This is worth it for pyspart but probably not for hadoop. The only real barrier is getting Hadoop to talk to Java...

## Some references and source material:

# http://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html#Standalone_Operation
# https://www.linuxjournal.com/content/introduction-mapreduce-hadoop-linux
# https://examples.javacodegeeks.com/enterprise-java/apache-hadoop/hadoop-streaming-example/
# https://dzone.com/articles/local-hadoop-on-laptop-for-practice

## To run Map/Reduce locally
./1.1-map.py < data/test.log | sort | ./1.1-reduce.py
## It is important to examine the mapper and reducer to understand what they do.

## To install a working Java/Hadoop pairing: note that I recommend upgrading to the most recent version
module load Java/1.8.0_92
wget https://archive.apache.org/dist/hadoop/common/hadoop-3.1.2/hadoop-3.1.2.tar.gz
tar -xzvf hadoop-3.1.2.tar.gz

#############
## Now we'll un Hadoop Map Reduce.
## It will produce a lot of chatter to the screen, as the whole Hadoop backend is fired up.

rm -rf output/conn_log # Remove the output if it is already created
HDIR=hadoop-3.1.2
$HDIR/bin/hadoop jar \
  $HDIR/share/hadoop/tools/lib/hadoop-streaming-3.1.2.jar \
  -mapper 1.1-map.py -reducer 1.1-reduce.py \
  -input data/test.log -output output/conn_log
## Examine the output:
cat output/conn_log/part-00* # There is only part-00000, meaning that only ONE reducer was used.
## Hopefully this looks the same as we say in the local Map/Reduce...

#############
## GET SOME DATA
## This is how we obtained the included `books` dataset; see ota.ox.ac.uk for details.
# mkdir data/books
# cd data/books
# for i in `seq 5720 5730`; do
#     wget http://ota.ox.ac.uk/text/$i.txt
# done
# cd ../..

## First some exploration of the data:
wc data/books/*
head data/books/5720.txt

## Now we will run a scalable Map/Reduce on these books. This is a whole-corpus word count; see the mapper and reducer for details.

rm -rf output/books_wc # Remove the output if it is already created
$HDIR/bin/hadoop jar \
  $HDIR/share/hadoop/tools/lib/hadoop-streaming-3.1.2.jar \
  -mapper 1.2-map_wc.py -reducer 1.2-reduce_wc.py \
  -input data/books/* -output output/books_wc

## Examine the output:
wc output/books_wc/part-00*
tail output/books_wc/part-00000

#############
## Running "real" hadoop
## The above is a toy example in the sense that the data are not living on the distributed file system. It can therefore only parallelise across a single compute node.
## Setting up HDFS allows Hadoop and Map/Reduce to operate seamlessly on an almost unlimited scale.
## Naturally this has some challenges. One is that there must be network communication... soL:

## NOW you have to setup ssh with password less access! See e.g. [here](https://linuxize.com/post/how-to-setup-passwordless-ssh-login/) (this is everywhere).

## If you have it configured, you can test with:
# ssh localhost
## If that works, then you can type "exit" to get back to your regular login.

## Otherwise this should work:
# ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
# cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
# chmod 0600 ~/.ssh/authorized_keys


## Setup HDFS
## We now have to tell HDFS how the data should be configured. This is a minimal setup.
## Note: if you copy/paste this into a terminal, the line endings may go wrong. If you paste it into a text editor, e.g. `nano $HDIR/etc/hadoop/hdfs-site.xml` this should not happen.
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
## You can see this on /tmp/hadoop-madjl/dfs/name

## Create a folder on HDFS
$HDIR/bin/hdfs dfs -mkdir hdfs
$HDIR/bin/hdfs dfs -put data/books hdfs/

## Check what is going on:
ls hdfs/books/ # Do we see the files?
$HDIR/bin/hdfs dfs -ls books # Do we see the files?
mount # What does this show? 
ls /run/user # Virtual file system
## So we learn that HDFS is using a virtual file system (which is hosted using a system called fuse)
## This allows it to be simultaneously "just some files on a disk" as well as distributed.
## However:
## HDFS providing such transparant access to files leads to difficulty checking whether we are using it correctly...
## Remember that on BC4, HDFS is a toy only, because there is no real distributed file system (all data is stored on a shared network drive)
##

## See also 
## hdfs dfs -copyToLocal <hdfs_input_file_path> <output_path>

##
## Rerun the hadoop job, this time specifying 10 reducers

$HDIR/bin/hadoop jar \
  $HDIR/share/hadoop/tools/lib/hadoop-streaming-3.1.2.jar \
  -D mapred.reduce.tasks=10 \     
  -mapper 1.2-map_wc.py -reducer 1.2-reduce_wc.py \
  -input hdfs/books/* -output hdfs/books_wc

## A final eamination of the output is worthwhile!
wc hdfs/books_wc/part-00*
## Check that all reducer keys were unique
cat hdfs/books_wc/part-00* | sort| cut -f1 | uniq -c | awk '{if($1>1){print($2);}}'

## Finally we have a successful usage of Hadoop on HDFS.

## Next up: [11.2.2 on Pyspark in Jupyter](11.2.2 Pyspark from Jupyter.ipynb)

