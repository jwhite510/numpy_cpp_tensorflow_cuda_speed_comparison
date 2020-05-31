#include <iostream>
#include<chrono>
#include <math.h>

using namespace std;
using namespace std::chrono;

// Kernel function to add the elements of two arrays
__global__
void add(int n, float *x, float *y)
{
  for (int i = 0; i < n; i++)
    y[i] = x[i] + y[i];
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
    x[i] = 1.0f;
    y[i] = 3.0f;
  }

  // Run kernel on 1M elements on the GPU
  auto start=high_resolution_clock::now();
  add<<<1, 1>>>(N, x, y);

  // Wait for GPU to finish before accessing on host
  cudaDeviceSynchronize();
  auto stop=high_resolution_clock::now();
  auto duration=duration_cast<microseconds>(stop-start);

  cout<<"duration:"<<duration.count()<<endl;

  // Check for errors (all values should be 3.0f)
  for(int i=0; i<10; i++)
  {
    cout<<y[i]<<" ";
  }cout<<endl;


  // float maxError = 0.0f;
  // for (int i = 0; i < N; i++)
    // maxError = fmax(maxError, fabs(y[i]-3.0f));
  // std::cout << "Max error: " << maxError << std::endl;

  // Free memory
  cudaFree(x);
  cudaFree(y);
  
  return 0;
}
