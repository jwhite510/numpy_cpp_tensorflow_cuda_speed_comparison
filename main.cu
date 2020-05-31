#include <iostream>
#include<chrono>
#include <math.h>

using namespace std;
using namespace std::chrono;

// Kernel function to add the elements of two arrays
__global__
void add(int n, float *x, float *y)
{
  int index=blockIdx.x*blockDim.x+threadIdx.x;
  int stride=blockDim.x*gridDim.x;

  // y[index]=1.0;
  // x[index]=stride;

  for (int i = index; i < n; i+=stride)
    y[i] = x[i] + y[i];
}

void cpu_add(int n,float *x, float*y){

  for(int i=0; i<n; i++) {
    y[i]=x[i]+y[i];
  }
}

int main(void)
{
  int N = 1<<20;
  float *x, *y;

  // Allocate Unified Memory – accessible from CPU or GPU
  cudaMallocManaged(&x, N*sizeof(float));
  cudaMallocManaged(&y, N*sizeof(float));

  // initialize x and y arrays on the host
  for (int i = 0; i < N; i++) {
    x[i] = 2.0f;
    y[i] = 1.0f;
  }

  // on CPU
  float* x_c = new float[N];
  float* y_c = new float[N];
  for(int i=0; i<N; i++)
  {
    x_c[i]=2.0f;
    y_c[i]=1.0f;
  }

  auto start=high_resolution_clock::now();
  cpu_add(N,x_c,y_c);
  auto stop=high_resolution_clock::now();
  auto duration=duration_cast<milliseconds>(stop-start);

  cout<<"CPU duration:"<<duration.count()<<endl;
  cout<<"y_c:"<<endl;
  for(int i=0; i<10; i++) {
    cout<<y_c[i]<<" ";
  }cout<<endl;
  cout<<"x_c:"<<endl;
  for(int i=0; i<10; i++) {
    cout<<x_c[i]<<" ";
  }cout<<endl;


  // Run kernel on 1M elements on the GPU
  start=high_resolution_clock::now();

  int blockSize=256;
  int numBlocks=(N+blockSize-1)/blockSize;
  cout<<"numBlocks"<<numBlocks<<endl;
  add<<<numBlocks, blockSize>>>(N, x, y);
  // add<<<1, 256>>>(N, x, y);
  // Wait for GPU to finish before accessing on host
  cudaDeviceSynchronize();
  stop=high_resolution_clock::now();
  duration=duration_cast<milliseconds>(stop-start);

  cout<<"GPU duration:"<<duration.count()<<endl;
  // Check for errors (all values should be 3.0f)
  cout<<"y:"<<endl;
  for(int i=0; i<10; i++) {
    cout<<y[i]<<" ";
  }cout<<endl;
  cout<<"x:"<<endl;
  for(int i=0; i<10; i++) {
    cout<<x[i]<<" ";
  }cout<<endl;

  // Free memory
  cudaFree(x);
  cudaFree(y);
  delete [] x_c;
  delete [] y_c;
  
  return 0;
}
