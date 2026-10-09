// dataXchV3.c


// emcc dataXchV3.c -o dataXchV3.wasm

#include "emscripten/emscripten.h"


#ifdef __cplusplus
#define EXTERN extern "C"
#else
#define EXTERN
#endif

#define SIZE  10
int data[SIZE];


EXTERN EMSCRIPTEN_KEEPALIVE void add(int value) { 
  for (int i=0; i<SIZE; i++) {
    data[i] = data[i] + value;
  }
}

EXTERN EMSCRIPTEN_KEEPALIVE int* getData() {
  return &data[0];
}

// token main function
EXTERN EMSCRIPTEN_KEEPALIVE int main()
{  
   return 0;
}


