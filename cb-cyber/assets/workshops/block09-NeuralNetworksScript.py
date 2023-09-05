from keras.models import Sequential
from keras.layers import Dense
import numpy as np
# fix random seed for reproducibility
np.random.seed(7)

############
## Extra step: if you are not going to request a whole node (16 cores) you should limit the use
## Here we restrict to 4 cores
ncores=4
import tensorflow as tf
tf.config.threading.set_intra_op_parallelism_threads(ncores) 
tf.config.threading.set_inter_op_parallelism_threads(ncores)
#############

import pandas as pd
df=pd.read_csv('../data/merged_5s.csv', sep=',')

np.random.seed(7)
from sklearn.model_selection import KFold
kf = KFold(n_splits=10,shuffle=True)
kfsplit=kf.split(df)
## We're going to extract out the "test" dataset from the first fold, to do our testing on
# kf.split returns an iterator, i.e. it creates a function that creates a test/split
# which we can either loop over or get the first using next
ninefolds,onefold=next(kfsplit)
mydata=df.loc[ninefolds]
mytestdata=df.loc[onefold]


## This function is useful for establishing which elements in an array are true
def which(self):
    try:
        self = list(iter(self))
    except TypeError as e:
        raise Exception("""'which' method can only be applied to iterables.
        {}""".format(str(e)))
    indices = [i for i, x in enumerate(self) if bool(x) == True]
    return(indices)

## Extract out the columns for which we'll do learning
torcols=which(mydata.apply(pd.Series.nunique) != 1)
# list(range(0,mydata.shape[1]-1)) # We need to remove: IP addresses, and constant columns
torcols.pop(2) # Remove Dest IP
torcols.pop(0) # Remove Source IP
torcols.pop()  # Remove Tor/NonTor label

traindata = mydata[mydata.columns[torcols]].copy()
testdata  = mytestdata[mytestdata.columns[torcols]].copy()


## Extract the labels:
def myextractY(data):
    ## Extract the Tor/nonTor data as 0/1 values
    TorYfactor=pd.factorize(data)
    TorY=TorYfactor[0] # Keep ToyYfactor around to know which is which
    return(TorY,TorYfactor[1])

TorY,TorYnames=myextractY(mydata.values[:,mydata.shape[1]-1])
testTorY,testTorYnames=myextractY(mytestdata.values[:,mytestdata.shape[1]-1])


from sklearn import preprocessing
## Extract the feature data
from sklearn.preprocessing import StandardScaler

def mypreprocess(data,scaling=None):
    data=data.astype(np.float)
    data[np.where(data >= np.finfo(np.float32).max)] = np.finfo(np.float32).max
    data[np.where(data <= np.finfo(np.float32).min)] = np.finfo(np.float32).min
    np.nan_to_num(data)
    if(scaling == None):
        scaling = StandardScaler()
        datat=scaling.fit_transform(data)
    else:
        datat=scaling.transform(data)
    datat[np.where(datat > 10)]=10
    datat[np.where(datat < -10)]=-10
    return(datat,scaling)

traindata=traindata.fillna(0)
## Scale the training data
TorXscaled, scaling = mypreprocess(traindata.values)
TorY,TorYnames=myextractY(mydata.values[:,mydata.shape[1]-1])

testdata=testdata.fillna(0)
## Scale the test data
testTorXscaled, testscaling = mypreprocess(testdata.values,scaling)
testTorY,testTorYnames=myextractY(testdata.values[:,testdata.shape[1]-1])


scaledtormodel = Sequential()
scaledtormodel.add(Dense(24, input_dim=TorXscaled.shape[1], activation='relu'))
scaledtormodel.add(Dense(TorXscaled.shape[1], activation='relu'))
scaledtormodel.add(Dense(1, activation='sigmoid'))
scaledtormodel.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])

epochs=list()
trainacc=list()
testacc=list()
deltaepochs=5
eon=0
for i in range(0,10) :
        print("epoch : " + str(eon))
        scaledtormodel.fit(TorXscaled, TorY, epochs=deltaepochs, batch_size=100)
        scaledtorscores = scaledtormodel.evaluate(TorXscaled, TorY)
        testscaledtorscores = scaledtormodel.evaluate(testTorXscaled, testTorY)
        eon+=deltaepochs
        epochs.append(eon)
        trainacc.append(scaledtorscores[1])
        testacc.append(testscaledtorscores[1])
results=[epochs,
        trainacc,
        testacc]

scaledtormodel.save('model1.keras')
import pickle
pickle.dump(results, open( "model1.pkl", "wb" ) )
## load with:
results1=pickle.load(open( "model1.pkl","rb"))
