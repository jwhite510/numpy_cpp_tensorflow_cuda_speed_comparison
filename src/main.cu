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
  void CopyToHost(){
    cudaMemcpy(h_data,d_data,length*sizeof(float),cudaMemcpyDeviceToHost);
  }
  void CopyToDevice(){
    cudaMemcpy(d_data,h_data,length*sizeof(float),cudaMemcpyHostToDevice);
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
void construct(array3d &arr, int size_0,int size_1, int size_2)
{
  arr.size_0=size_0;
  arr.size_1=size_1;
  arr.size_2=size_2;
  arr.length=size_0*size_1*size_2;
  // allocate memory on device
  cudaMalloc(&arr.d_data,arr.length*sizeof(float));
  // allocate memory on host
  arr.h_data = new float[arr.length];
}
void ToDevice(array3d &arr){
  cudaMemcpy(arr.d_data,arr.h_data,arr.length*sizeof(float),cudaMemcpyHostToDevice);
}
void ToHost(array3d &arr){
  cudaMemcpy(arr.h_data,arr.d_data,arr.length*sizeof(float),cudaMemcpyDeviceToHost);
}
void destruct(array3d &arr){
  delete [] arr.h_data;
  cudaFree(arr.d_data);
}
__device__
float GetElement(const array3d arr, int i_0,int i_1,int i_2)
{
  return arr.d_data[i_0*arr.size_1*arr.size_2 + i_1*arr.size_2 + i_2];
}
__device__ void SetElement(array3d arr, int i_0, int i_1, int i_2, float value)
{
  arr.d_data[i_0*arr.size_1*arr.size_2 + i_1*arr.size_2 + i_2]=value;
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
    // SetElement(arr2,_i_ur_0,_i_ur_1,_i_ur_2, i);

  }
}

struct FDTD{
  array3d arr1;
  array3d arr2;
  FDTD(){
    int N = 3;
    construct(arr1, N,N,10);
    construct(arr2, N,N,10);

    // initialize x and y arrays on the host
    int val=0;
    for (int i = 0; i < arr1.length; i++) {
      arr1.h_data[i] = val++;
      arr2.h_data[i] = 0.0f;
    }
  }
  void run(){
    arr1.CopyToDevice();
    arr2.CopyToDevice();

    int blockSize=256;
    int numBlocks=(arr1.length+blockSize-1)/blockSize;
    cout << "numBlocks => " << numBlocks << endl;
    add<<<numBlocks, blockSize>>>(arr1, arr2);
    arr1.CopyToHost();
    arr2.CopyToHost();

    // Wait for GPU to finish before accessing on host
    cout<<"arr1:"<<endl;
    arr1.show();
    cout<<"arr2:"<<endl;
    arr2.show();
  }
  ~FDTD(){
    destruct(arr1);
    destruct(arr2);
  }
};
int main(void)
{
  FDTD fdtd;
  fdtd.run();

  return 0;
}
