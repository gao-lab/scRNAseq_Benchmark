#!/bin/bash

set -e

docker build -t cb-gpu -f Dockerfiles/cell_blast/Dockerfile .
docker run -d -p 5000:5000 --restart=always --name registry registry:2 2> /dev/null || docker start registry
docker tag cb-gpu localhost:5000/cb-gpu
docker push localhost:5000/cb-gpu
SINGULARITY_NOHTTPS=1 singularity build -F envs/cb-gpu-0.3.2.simg docker://localhost:5000/cb-gpu:latest
docker stop registry
