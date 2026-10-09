// dataXchV1.c
/*
   Because dataXchV1.c is used in both the HTML pages dataXchV1.html and dataXchV2.html,
    with different ways of accessing the wasm module, we seperate there compiles
   
   For dataXchV1.html we compile with, 
      emcc dataXchV1.c -o dataXchV1.wasm -oz
   and load z.wasm
   
   For dataXchV2.html we will compile with, 
      emcc dataXchV1.c -o dataXchV2.wasm
   and load dataXchV2.wasm
*/


/* 
   This programme demonstrates the retrievel of data from Linear Memeory using either Javascript or C.
   Also, for the manner in which we build our script in dataXchV2.htmls, by default, 
      Emscripten-generated code always just calls the main() function; all other functions are eliminated as dead code. 
   Putting EMSCRIPTEN_KEEPALIVE before a function name stops this from happening. 
   You also need to import the emscripten.h library to use EMSCRIPTEN_KEEPALIVE; unfortunately, 
   this also causes several other exported objects to occur in the wasm binary, and must be handled
   in the HTML page: see dataXchV2.html, otherwise, we can use the -oz option in the compile command and
   just load the optimized version of the compile: z.wasm, which does have these extraeneous exported objects,
    as we demonstrate here in version 1 of dataXch. 
*/

#include <string.h>     // for memset
#include "emscripten/emscripten.h"  // for EMSCRIPTEN_KEEPALIVE


#ifdef __cplusplus
#define EXTERN extern "C"
#else
#define EXTERN
#endif


#define BUFFER_SIZE 1024

static char buffer[BUFFER_SIZE];


EXTERN EMSCRIPTEN_KEEPALIVE char* get_buffer_ptr(void) 
{
    return buffer;
}

EXTERN EMSCRIPTEN_KEEPALIVE int get_buffer_len(void)
{
   return (int)BUFFER_SIZE;
}

EXTERN EMSCRIPTEN_KEEPALIVE char getCharFromBuffer(int n)
{
   // arg n inidicates which index within the buffer
   if(n < 0 || n > sizeof buffer)
   {
      return 0xFF;
   }
   return buffer[n];
}

EXTERN EMSCRIPTEN_KEEPALIVE char setCharIntoBuffer(int n, char m)
{  
  // arg n inidicates which index within the buffer
  // arg m is the character to chnage to
  
   if(n < 0 || n > sizeof buffer)
   {
      return m;
   }
   memset(buffer + n, m, 1);
   return m;
}


// token main function
EXTERN EMSCRIPTEN_KEEPALIVE int main()
{
   // initialise buffer with all x's
   memset(buffer,'x',sizeof buffer);
   // change the first character in the buffer
   char a = 'a';
   int one = 1;
   memset(buffer + 1,a,one);
   
   return 0;
}