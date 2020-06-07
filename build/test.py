import numpy as np
import matplotlib.pyplot as plt
import ctypes

if __name__ == "__main__":
    lib=ctypes.cdll.LoadLibrary('libfdtd.so')
    a=lib.FDTD_new()
    lib.FDTD_run(a)


