#!/bin/bash

git clone https://github.com/loretoparisi/darknet 
wget http://vision.stanford.edu/aditya86/ImageNetDogs/images.tar 
wget http://vision.stanford.edu/aditya86/ImageNetDogs/annotation.tar 
tar -xvf images.tar
tar -xvf annotation.tar

# Process data
git clone https://github.com/ldavila07/gpu-test