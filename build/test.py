import numpy as np
import matplotlib.pyplot as plt
import ctypes

if __name__ == "__main__":
    lib=ctypes.cdll.LoadLibrary('libfdtd.so')
    arr1=np.zeros((4,4,4),dtype=np.float32)
    arr2=np.zeros((4,4,4),dtype=np.float32)

    val=0
    for i in range(3):
        for j in range(3):
            for k in range(3):
                arr1[i,j,k]=val
                val+=1

    c_float_p=ctypes.POINTER(ctypes.c_float)
    a=lib.FDTD_new(
            arr1.shape[0],
            arr1.shape[1],
            arr1.shape[2],
            arr1.ctypes.data_as(c_float_p),
            arr2.ctypes.data_as(c_float_p)
            )
    lib.FDTD_run(a)
    print("ran!")
    print("arr1")
    print(arr1)
    print("arr2")
    print(arr2)
    # arr1+=100
    # lib.FDTD_run(a)
    # print("ran!")




