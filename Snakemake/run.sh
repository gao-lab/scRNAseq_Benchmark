#!/bin/bash

if [ ! -d .slurm ]; then mkdir .slurm; fi
snakemake -s Snakefile_mkdir -j40 -pr
if [ "${1}" == "cls" ]; then
    snakemake -j500 --cluster-config cluster_cls.json --cluster "sbatch -J {cluster.jobname} -A {cluster.account} -p {cluster.partition} -q {cluster.qos} --no-requeue -N {cluster.n_node} -n {cluster.n_task} -c {cluster.n_cpu} {cluster.gres} -o {cluster.output} -e {cluster.error}" --use-singularity --singularity-args "--nv " -prk
else
    snakemake -j40 --use-singularity --singularity-args "--nv " -prk
fi
