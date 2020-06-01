#!/bin/bash
nvcc -ccbin g++-6 main.cu -O3 -o add_cuda
