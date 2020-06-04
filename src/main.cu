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
struct array3d{
  int size_0;
  int size_1;
  int size_2;
  int length;
  float* h_data;
  float* d_data;
  array3d(int size_0,int size_1, int size_2)
    :size_0(size_0),size_1(size_1),size_2(size_2)
  {
    length=size_0*size_1*size_2;
    // allocate memory on device
    cudaMalloc(&d_data,length*sizeof(float));
    // allocate memory on host
    h_data = new float[length];
    // cudaMallocManaged(&data,length*sizeof(float));
  }
  void CopyToHost(){
    cudaMemcpy(h_data,d_data,length*sizeof(float),cudaMemcpyDeviceToHost);
  }
  void CopyToDevice(){
    cudaMemcpy(d_data,h_data,length*sizeof(float),cudaMemcpyHostToDevice);
  }
  ~array3d(){
    delete [] h_data;
    cudaFree(d_data);
  }
  void show(){
    for(int _i0=0; _i0 < size_0; _i0++){
      // printing slice
      for(int _i1=0; _i1 < size_1; _i1++){
        for(int _i2=0; _i2 < size_2; _i2++){
          cout<<h_data[_i0*size_1*size_2 + _i1*size_2 + _i2]<<" ";
        }cout<<endl;
      }cout<<"------"<<endl;
    }
  }

};
__device__
float GetElement(const array3d &arr, int i_0,int i_1,int i_2)
{
  return arr.d_data[i_0*arr.size_1*arr.size_2 + i_1*arr.size_2 + i_2];
}
__device__ void SetElement(array3d &arr, int i_0, int i_1, int i_2, float value)
{
  arr.d_data[i_0*arr.size_1*arr.size_2 + i_1*arr.size_2 + i_2]=value;
}

__global__
void add(int N,float* d_array)
{
  int index=blockIdx.x*blockDim.x+threadIdx.x;
  int stride=blockDim.x*gridDim.x;
  for(int i=index; i < N; i+=stride){
    d_array[i]=2*d_array[i];
  }
}
int main(void)
{

  int N=100;
  float* h_array= new float[N];
  float* d_array;
  cudaMalloc(&d_array,N*sizeof(float));

  int val=0;
  for(int i=0; i < N; i++){
    h_array[i]=val++;
  }

  // HOST TO DEVICE
  cudaMemcpy(d_array,h_array,N*sizeof(float),cudaMemcpyHostToDevice);

  int blockSize=256;
  int numBlocks=(N+blockSize-1)/blockSize;
  add<<<numBlocks, blockSize>>>(N,d_array);

  // DEVICE TO HOST
  cudaMemcpy(h_array,d_array,N*sizeof(float),cudaMemcpyDeviceToHost);

  for(int i=0; i < 10; i++){
    cout<<h_array[i]<<" ";
  }cout<<endl;

  return 0;
}
