## This R script reads data:
## The Bro log data from [Secrepo](http://www.secrepo.com/Datasets%20Description/HTML_Bro_log_1/conn.html):
## assigns headers to it and makes a useful subset for data exploration.

## Get the data from the repo
conndata=read.table("https://github.com/dsbristol/dst/raw/master/data/conn_sample.log",as.is=T)
## Assign column names
colnames(conndata)=c('ts','uid','id.orig_h','id.orig_p',
    'id.resp_h','id.resp_p','proto','service','duration',
    'orig_bytes','resp_bytes','conn_state','local_orig',
    'missed_bytes','history','orig_pkts','orig_ip_bytes',
    'resp_pkts','resp_ip_bytes','tunnel_parents')

## Make a version of the data that uses only the top 20 most frequently used ports
topports=names(head(sort(table(conndata[,"id.resp_p"]),decreasing=T),20))
conndata2=conndata[conndata[,"id.resp_p"]%in%topports,]

