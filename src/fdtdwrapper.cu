#include"fdtd.h"

using namespace std;

extern "C"{
  void* FDTD_new(int s_0, int s_1, int s_2, float* arr1hostd, float* arr2hostd)
  {
    FDTD*m = new FDTD(s_0,s_1,s_2,arr1hostd,arr2hostd);
    return (void*)m;
  }
  void FDTD_run(void*p){
    FDTD*m=(FDTD*)p;
    m->run();
  }
}
