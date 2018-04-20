#!/bin/bash
#
# Darkenet GPU Run Script
# @author Loreto Parisi (loretoparisi at gmail dot com)
# v1.0.0
# @2016 Loreto Parisi (loretoparisi at gmail dot com)
#
IMAGE=darknet_gpu
if [ $1="train" ]; then
CMD=sudo ./train.sh
else
CMD=bash
fi
docker  run --runtime=nvidia -it $IMAGE $CMD