import os
from sys import argv
from pathlib import Path

import rpy2.robjects as robjects
import numpy as np
import pandas as pd
from sklearn import linear_model
import Cell_BLAST as cb


def select_seurat_gene(DataPath, CV_RDataPath, OutputDir):
    '''
    Script to select seurat genes in the training set of the inputfile.
    Seurat gene list is written to a file.

    Parameters
    ----------
    DataPath : Data file path (.csv), cells-genes matrix with cell unique barcodes
    CV_RDataPath : Cross validation RData file path (.RData), obtained from Cross_Validation.R function.
    OutputDir : Output directory defining the path of the exported file.
    '''

    # read the Rdata file
    robjects.r['load'](CV_RDataPath)

    nfolds = np.array(robjects.r['n_folds'], dtype='int')
    tokeep = np.array(robjects.r['Cells_to_Keep'], dtype='bool')
    train_ind = np.array(robjects.r['Train_Idx'])

    # read the data
    data = cb.data.ExprDataSet.read_table(DataPath, orientation="cg", sep=",", header=0, index_col=0, sparsify=True)
    data = data[tokeep, :]

    for i in range(np.squeeze(nfolds)):
        train_ind_i = np.array(train_ind[i], dtype = 'int') - 1
        train = data[train_ind_i, :]

        seurat_gene, ax = train.find_variable_genes(binning_method="equal_frequency")
        ax.get_figure().savefig(str(OutputDir / Path("seurat_genes"+str(i)+".pdf")))
        seurat_gene = pd.DataFrame(seurat_gene)
        seurat_gene.to_csv(str(OutputDir / Path("seurat_gene" + str(i) + ".csv")), index=False)

select_seurat_gene(argv[1], argv[2], argv[3])
