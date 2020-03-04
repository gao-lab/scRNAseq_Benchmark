import os
from sys import argv

import rpy2.robjects as robjects
import numpy as np
import pandas as pd
from sklearn import linear_model
import matplotlib.backends.backend_pdf
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
    index_mapping = {item: i for i, item in enumerate(data.var_names)}
    seurat_gene_name_list, seurat_gene_idx_list = [], []
    pdf = matplotlib.backends.backend_pdf.PdfPages(os.path.join(OutputDir, "seurat_genes.pdf"))

    for i in range(np.squeeze(nfolds)):
        train_ind_i = np.array(train_ind[i], dtype = 'int') - 1
        train = data[train_ind_i, :]

        seurat_gene, ax = train.find_variable_genes(binning_method="equal_frequency")
        pdf.savefig(ax.get_figure())
        seurat_gene_name_list.append(seurat_gene)
        seurat_gene_idx_list.append([index_mapping[item] for item in seurat_gene])

    pdf.close()
    pd.DataFrame(seurat_gene_name_list).T.to_csv(os.path.join(OutputDir, "seurat_gene_name.csv"), index=False)
    pd.DataFrame(seurat_gene_idx_list).T.to_csv(os.path.join(OutputDir, "seurat_gene_idx.csv"), index=False)

select_seurat_gene(argv[1], argv[2], argv[3])
