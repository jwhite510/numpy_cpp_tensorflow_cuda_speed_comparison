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
    data=new float[length];
  }
  ~array3d(){
    delete [] data;
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

  array3d arr(3,5,5);
  for(int i=0; i < arr.length; i++){
    arr.data[i]=0.0;
  }

  int _i0=2;
  int _i1=2;
  int _i2=3;
  arr.data[_i0*arr.size_1*arr.size_2 + _i1*arr.size_2 + _i2]=99;

  int raveled_index=_i0*arr.size_1*arr.size_2 + _i1*arr.size_2 + _i2;
  cout << "raveled_index => " << raveled_index << endl;
  arr.show();
  cout<<" -- "<<endl;
  // unravel index
  int _i_ur_0=raveled_index/(arr.size_1*arr.size_2);
  int _i_ur_1=(raveled_index-(arr.size_1*arr.size_2*_i_ur_0))/(arr.size_2);
  int _i_ur_2=raveled_index%arr.size_2;
  cout << "_i_ur_0 => " << _i_ur_0 << endl;
  cout << "_i_ur_1 => " << _i_ur_1 << endl;
  cout << "_i_ur_2 => " << _i_ur_2 << endl;

  exit(0);
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
