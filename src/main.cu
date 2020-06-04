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
  float* data;
  array3d(int size_0,int size_1, int size_2)
    :size_0(size_0),size_1(size_1),size_2(size_2)
  {
    length=size_0*size_1*size_2;
    cout<<"calling cudaMallocManaged"<<endl;
    cudaMallocManaged(&data,length*sizeof(float));
  }
  ~array3d(){
    cudaFree(&data);
  }
  void show(){
    for(int _i0=0; _i0 < size_0; _i0++){
      // printing slice
      for(int _i1=0; _i1 < size_1; _i1++){
        for(int _i2=0; _i2 < size_2; _i2++){
          cout<<data[_i0*size_1*size_2 + _i1*size_2 + _i2]<<" ";
        }cout<<endl;
      }cout<<"------"<<endl;
    }
  }

};
__device__
float GetElement(const array3d &arr, int i_0,int i_1,int i_2)
{
  return arr.data[i_0*arr.size_1*arr.size_2 + i_1*arr.size_2 + i_2];
}
__device__ void SetElement(array3d &arr, int i_0, int i_1, int i_2, float value)
{
  arr.data[i_0*arr.size_1*arr.size_2 + i_1*arr.size_2 + i_2]=value;
}

__global__
void add(array3d arr1, array3d arr2)
{
  int index=blockIdx.x*blockDim.x+threadIdx.x;
  int stride=blockDim.x*gridDim.x;
  for(int i=index; i < arr1.length; i+=stride){

    // unravel index
    int _i_ur_0=i/(arr1.size_1*arr1.size_2);
    int _i_ur_1=(i-(arr1.size_1*arr1.size_2*_i_ur_0))/(arr1.size_2);
    int _i_ur_2=i%arr1.size_2;

    float e=GetElement(arr1,_i_ur_0,_i_ur_1,_i_ur_2);

    if(_i_ur_1+1<arr2.size_1)
      SetElement(arr2,_i_ur_0,_i_ur_1+1,_i_ur_2, e);

  }
}
int main(void)
{

  int N = 3;
  array3d arr1(N,N,10);
  array3d arr2(N,N,10);

  // initialize x and y arrays on the host
  int val=0;
  for (int i = 0; i < arr1.length; i++) {
    arr1.data[i] = val++;
    arr2.data[i] = 0.0f;
  }
  // Run kernel on 1M elements on the GPU
  int blockSize=256;
  int numBlocks=(N*N+blockSize-1)/blockSize;
  cout << "numBlocks => " << numBlocks << endl;
  add<<<numBlocks, blockSize>>>(arr1, arr2);

  // Wait for GPU to finish before accessing on host
  cudaDeviceSynchronize();
  cout<<"arr1:"<<endl;
  arr1.show();
  cout<<"arr2:"<<endl;
  arr2.show();
  return 0;
}
