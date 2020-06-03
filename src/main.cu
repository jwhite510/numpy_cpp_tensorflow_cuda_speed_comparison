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
  int width;
  int height;
  float* data;
  array2d(int width,int height):width(width),height(height){
    cudaMallocManaged(&data,width*height*sizeof(float));
  }
  ~array2d(){
    cudaFree(&data);
  }

};

__global__
void add(array2d arr1, array2d arr2)
// void add(int n,float*x, float*y)
{
  int index=blockIdx.x*blockDim.x+threadIdx.x;
  int stride=blockDim.x*gridDim.x;
  for(int i=index; i < arr1.width*arr1.height; i+=stride){
    // arr1.data[i] = arr1.data[i]+arr2.data[i];
    // arr1.data[i] = blockIdx.x;

    // unravel index
    int row=i/arr1.width;
    int col=i%arr1.width;

    // arr1.data[row*arr1.width+col]=threadIdx.x;
    arr1.data[row*arr1.width+col]+=arr2.data[row*arr1.width+col];
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
    arr2.data[i] = 5.0f;
  }
  // Run kernel on 1M elements on the GPU
  int blockSize=256;
  int numBlocks=(N*N+blockSize-1)/blockSize;
  cout << "numBlocks => " << numBlocks << endl;
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
