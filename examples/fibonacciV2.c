// fibonacciV2.c
/*
   compile with
      emcc fibonacciV2.c -o fibonacciV2.wasm
      
   uses an Emscripten macro to advise the compiler to retain the specified functions,
   otherwise, it simply drops them as unused.
*/

#include "emscripten/emscripten.h"


#ifdef __cplusplus
#define EXTERN extern "C"
#else
#define EXTERN
#endif



EXTERN EMSCRIPTEN_KEEPALIVE int fib(int n)
{
    if(n == 0 || n == 1)
        return 1;
    else
        return fib(n - 1) + fib(n - 2);
}
int main()
{
   
   return 0;
}

