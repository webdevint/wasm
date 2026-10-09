/*
   HelloV2.c
   
   compile with
         emcc helloV2.c -o helloV2.html -s WASM=1
   this version demonstrates the fact that we can call any Javascript function from our c programme by including
   the emscripten header library file, including a custom function defined in your html page.
*/

#include <emscripten.h>

int main(){
    // simple run script
    emscripten_run_script("alert('I have been called from C!')"); // a Javascript function run in c!
    emscripten_run_script("squareIt(12)");
    return 0;
}