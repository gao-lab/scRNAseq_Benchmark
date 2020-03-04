import os
from sys import argv
from pathlib import Path

import numpy as np
import pandas as pd
import time as tm
from sklearn.svm import LinearSVC
import rpy2.robjects as robjects


def run_SVM(DataPath, LabelsPath, CV_RDataPath, OutputDir, GeneOrderPath = "", NumGenes = 0):
    '''
    run baseline classifier: SVM
    Wrapper script to run an SVM classifier with a linear kernel on a benchmark dataset with 5-fold cross validation,
    outputs lists of true and predicted cell labels as csv files, as well as computation time.

    Parameters
    ----------
    DataPath : Data file path (.csv), cells-genes matrix with cell unique barcodes
    as row names and gene names as column names.
    LabelsPath : Cell population annotations file path (.csv).
    CV_RDataPath : Cross validation RData file path (.RData), obtained from Cross_Validation.R function.
    OutputDir : Output directory defining the path of the exported file.
    GeneOrderPath : Gene order file path (.csv) obtained from feature selection,
    defining the genes order for each cross validation fold, default is NULL.
    NumGenes : Number of genes used in case of feature selection (integer), default is 0.
    '''

    # read the Rdata file
    robjects.r['load'](CV_RDataPath)

    nfolds = np.array(robjects.r['n_folds'], dtype = 'int')
    tokeep = np.array(robjects.r['Cells_to_Keep'], dtype = 'bool')
    col = np.array(robjects.r['col_Index'], dtype = 'int')
    col = col - 1
    test_ind = np.array(robjects.r['Test_Idx'])
    train_ind = np.array(robjects.r['Train_Idx'])

    # read the data
    data = pd.read_csv(DataPath,index_col=0,sep=',')
    labels = pd.read_csv(LabelsPath, header=0,index_col=None, sep=',', usecols = col)

    labels = labels.iloc[tokeep]
    data = data.iloc[tokeep]

    # read the feature file
    # if (NumGenes > 0):
    features = pd.read_csv(GeneOrderPath,header=0,index_col=None, sep=',')

    # normalize data
    data = np.log1p(data)

    Classifier = LinearSVC()

    tr_time=[]
    ts_time=[]
    truelab = []
    pred = []

    for i in range(np.squeeze(nfolds)):
        test_ind_i = np.array(test_ind[i], dtype = 'int') - 1
        train_ind_i = np.array(train_ind[i], dtype = 'int') - 1

        train=data.iloc[train_ind_i]
        test=data.iloc[test_ind_i]
        y_train=labels.iloc[train_ind_i]
        y_test=labels.iloc[test_ind_i]

        if (NumGenes > 0):
            feat_to_use = features.iloc[0:NumGenes,i].dropna()
        else:
            feat_to_use = features.iloc[:,i].dropna()
        train = train.iloc[:,feat_to_use]
        test = test.iloc[:,feat_to_use]

        start=tm.time()
        Classifier.fit(train, y_train)
        tr_time.append(tm.time()-start)

        start=tm.time()
        predicted = Classifier.predict(test)
        ts_time.append(tm.time()-start)

        truelab.extend(y_test.values)
        pred.extend(predicted)

    truelab = pd.DataFrame(truelab)
    pred = pd.DataFrame(pred)

    tr_time = pd.DataFrame(tr_time)
    ts_time = pd.DataFrame(ts_time)

    OutputDir = Path(OutputDir)
    method_name = "SVM"
    if "seurat_gene" in GeneOrderPath:
        method_name += "_seurat"
    truelab.to_csv(str(OutputDir / Path("%s_true.csv" % method_name)),
                   index = False)
    pred.to_csv(str(OutputDir / Path("%s_pred.csv" % method_name)),
                index = False)
    tr_time.to_csv(str(OutputDir / Path("%s_training_time.csv" % method_name)),
                   index = False)
    ts_time.to_csv(str(OutputDir / Path("%s_test_time.csv" % method_name)),
                   index = False)

run_SVM(argv[1], argv[2], argv[3], argv[4], argv[5], int(argv[6]))
