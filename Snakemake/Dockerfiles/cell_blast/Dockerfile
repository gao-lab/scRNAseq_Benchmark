FROM nvidia/cuda:9.0-base

# Install conda
RUN apt-get update && apt-get install --no-install-recommends --yes wget bzip2
RUN wget -q https://repo.continuum.io/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh && \
    sh Miniconda3-4.6.14-Linux-x86_64.sh -b -p /opt/conda

ENV PATH="/opt/conda/bin:${PATH}"

# Build environment
RUN conda install -c default -c bioconda -c r -c plotly -c conda-forge -y \
    python=3.6.9 conda=4.6.14 numpy=1.14.6 numba=0.43.1 scipy=1.2.1 joblib=0.13.2 \
    tqdm=4.31.1 scikit-learn=0.19.2 pandas=0.24.2 h5py=2.9.0 statsmodels=0.9.0 seaborn=0.9.0 \
    r=3.6.0 rpy2=3.1.0 python-igraph=0.7.1.post7 umap-learn=0.3.8 loompy=2.0.17 \
    pronto=0.12.2 anndata=0.6.19 plotly=3.9.0 && \
    conda install -c default tensorflow-gpu=1.9.0 && \
    pip install Cell-BLAST==0.2.14 --no-deps

# Clean up
RUN apt-get purge --yes wget bzip2 && \
    apt-get autoremove --yes && \
    apt-get clean && \
    conda clean -a -y && \
    rm -rf Miniconda3-4.6.14-Linux-x86_64.sh && \
    rm -rf /var/lib/apt/lists/*

COPY Scripts/run_Cell_BLAST.py /Scripts/

