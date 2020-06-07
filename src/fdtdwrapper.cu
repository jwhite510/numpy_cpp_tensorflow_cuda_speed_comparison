#include"fdtd.h"

using namespace std;

extern "C"{
  void* FDTD_new()
  {
    FDTD*m = new FDTD;
    return (void*)m;
  }
  void FDTD_runarr1(void*p){
    FDTD*m=(FDTD*)p;
    m->run();
  }
}
