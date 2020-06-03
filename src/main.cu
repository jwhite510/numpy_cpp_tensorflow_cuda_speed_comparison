#include <iostream>
#include<chrono>
#include <math.h>

using namespace std;
using namespace std::chrono;

void print10(float* s){
  for(int i=0; i < 10; i++){
    cout<<s[i]<<" ";
  }cout<<endl;
}
// Kernel function to add the elements of two arrays
typedef struct{
  int width;
  int height;
  float* data;
} array2d;

__global__
void add(array2d arr1, array2d arr2)
// void add(int n,float*x, float*y)
{
  // int row=blockIdx.y*blockDim.y+threadIdx.y;
  // int col=blockIdx.x*blockDim.x+threadIdx.x;
  // arr1.data[arr1.width*row+col]+=arr2.data[arr2.width*row+col];

  int index=blockIdx.x*blockDim.x+threadIdx.x;
  int stride=blockDim.x*gridDim.x;
  for(int i=index; i < arr1.width; i+=stride){
    arr1.data[i] = arr1.data[i]+arr2.data[i];
  }

}
int main(void)
{
  int N = 10;
  array2d arr1;
  arr1.width=N;
  arr1.height=N;

  array2d arr2;
  arr2.width=N;
  arr2.height=N;

  cudaMallocManaged(&arr1.data,N*N*sizeof(float));
  cudaMallocManaged(&arr2.data,N*N*sizeof(float));

  // initialize x and y arrays on the host
  for (int i = 0; i < N*N; i++) {
    arr1.data[i] = 3.0f;
    arr2.data[i] = 3.0f;
  }
  // Run kernel on 1M elements on the GPU
  int blockSize=256;
  int numBlocks=(N+blockSize-1)/blockSize;
  cout << "numBlocks => " << numBlocks << endl;
  // dim3 dimBlock(blockSize,blockSize);
  // dim3 dimGrid(arr1.width/dimBlock.x,arr1.height/dimBlock.y);
  // add<<<dimGrid, dimBlock>>>(arr1.data, arr2.data);
  add<<<numBlocks, blockSize>>>(arr1, arr2);

  // Wait for GPU to finish before accessing on host
  cudaDeviceSynchronize();
  cout<<"arr1:"<<endl;
  // arr1.print();
  for(int i=0; i < N; i++){
    for(int j=0; j < N; j++){
      cout<<arr1.data[i*arr1.width+j]<<"  ";
    }cout<<endl;
  }
  // cout<<"arr2:"<<endl;
  // arr2.print();
  return 0;
}
