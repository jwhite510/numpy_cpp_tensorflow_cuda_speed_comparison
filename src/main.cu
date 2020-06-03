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
struct array2d{
  float* data;
  int width;
  int height;
  array2d(int width,int height):width(width),height(height)
  {
    cudaMallocManaged(&data,width*height*sizeof(float));
  };
  void print(){
    for(int i=0; i < width; i++)
    {
      for(int j=0; j < height; j++){
        cout<<data[width*i+j]<<"  ";
      }cout<<endl;
    }
  }
  ~array2d(){
    cudaFree(data);
  }
};
__global__
// void add(array2d &arr1, array2d &arr2)
void add(int n,float*x, float*y)
{
  // int row=blockIdx.y*blockDim.y+threadIdx.y;
  // int col=blockIdx.x*blockDim.x+threadIdx.x;
  // arr1.data[arr1.width*row+col]+=arr2.data[arr2.width*row+col];

  int index=blockIdx.x*blockDim.x+threadIdx.x;
  int stride=blockDim.x*gridDim.x;
  for(int i=index; i < n; i+=stride){
    x[i] = x[i]+y[i];
  }

}
int main(void)
{
  int N = 10;
  array2d arr1(N,N);
  array2d arr2(N,N);

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
  add<<<numBlocks, blockSize>>>(N,arr1.data, arr2.data);

  // Wait for GPU to finish before accessing on host
  cudaDeviceSynchronize();
  cout<<"arr1:"<<endl;
  arr1.print();
  // cout<<"arr2:"<<endl;
  // arr2.print();
  return 0;
}
