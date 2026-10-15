# Exploring Web Assembly (WASM) Through Examples

This package consists of several base examples of working with WASM and the various tools, which may be of interest to the curious developer.

The examples use the Emscripten toolchain to compile C source code to a wasm file suitable to be used by Javascript in a Web page.

For WAT files (wasm text), the examples use the wasm2wat, wat2wasm and wasmrun tools

The examples include:

- The Web Assembly language built into all modern web browsers;

- Working with wasm files;

- Using the Emscripten compiler and its various outputs;

-  Compiling C source code to wasm that includes code to:

  - Call Javascript functions from C;

  - Call C functions from Javascript;

  - How to read/write to Linear memory both in Javascript and in C.

- Working with wasm text language .wat files.

Although there are many other tools and methods used in working with Web Assembly, we restrict ourselves to the above.
The following is a list, by topic, and a short description of the examples in the project:

**hello**:     the ubiquitous first rendering of a .wasm file, created from a hello.c file and compiled using emcc.

1. Uses the default Javascript and HTML files output by the emcc compiler;

2. The c code can use i/o, e.g., printf(...), by the use of the emitted Javascript ″glue″ file from the emcc compiler.

**helloV2**: 

1. Similar to hello but uses a custom web page (helloV2_custom.html) rather than the html page emitted by the emcc compiler;

2. Call any Javascript function either from the JS library or a custom function, by including the Emscripten header and using the ″emscripten_run_script″ macro.

**fibonacci**

1. Calling a C function from Javascript;

2. Using the Module object provided by the emitted Javascript file from the emcc compiler, in particular, the functions ″cwrap()″ and ″ccall()″;

3. Await the complete initialisation of a wasm file by using the Module object′s ″onRuntimeInitialized″ property, before proceeding with code that depends on it.

4. Providing options to the emcc compiler to recognise exported functions, e.g.,
   emcc fibonacci.c -o fibonacci.js -s WASM=1 -s EXPORTED_FUNCTIONS=_fib -sEXPORTED_RUNTIME_METHODS=ccall,cwrap

5. 

**fibonacciV2**

1. Uses a Web Assembly promise type function in co-operation with the Javascript ″fetch″ function to load, compile and instantiate the wasm file,
   WebAssembly.instantiateStreaming(fetch("fibonacciV2.wasm"), importObject)

2. The Javascript ″glue″ file is not required;

3. The c file uses an Emscripten macro to retain access to the specified C functions, therefore, the compiler export options are not required,
   emcc fibonacciV2.c -o fibonacciV2.wasm

4. Requires some boiler plate code in the html page to handle exported objects by the wasm file.

The next three examples demonstrate the exchange of data between Javascript and C through a shared area of memory established by the compiler in the wasm module, known as Linear Memory.

**dataXchV1**

The Javascript code portion,

1. Works with the optimized version of the compiled code: -oz compile option; no need to handle wasm extraeneous exported objects, as the optimised wasm module does not expose any;

2. Links to the exported  functions in the C code, including main() via the WebAssembly.Instance.prototype.exports property;

3. Get a pointer to and the length of a buffer created by the C code, i.e., Linear Memory;

4. Retrieves a character from Linear Memory using an exported C function. The character is retrieved via the pointer to a buffer created by the C code;

5. Uses TextEncoder and TextDecoder with UInt8Arrays;

6. Writes a character into C′s buffer using an exported function created in the C code;

7. Access Linear Memory other than a pointer to C′s buffer: they are one and the same;

8. Fetch the first byte in Linear memory, a.k.a., C′s buffer, as a Uint8Array

9. Decode and log the first byte in the Uint8Array;

10. Fetch a block of Linear Memory containing a string created within the C code buffer; decode and log it.



The C code portion,

1. Includes the Emscipten header in order to use the macro,
   EXTERN EMSCRIPTEN_KEEPALIVE

2. Creates and exports several functions for Javascript to call:

   1. char* get_buffer_ptr(void)

   2. int get_buffer_len(void)

   3. char getCharFromBuffer(int n)

   4. char setCharIntoBuffer(int n, char m)

   5. int main()

**dataXchV2**

No changes are made to the C code but it is compiled without optimisation. This leads to changes in the dataXchV2.html file.

It also accesses Linear Memory from an Object provided by wasm rather than using C's buffer.

1. WASI objects appear within the wasm module as helper code to perform low level i/o, at this time they are extraeneous to our examples;

2. It defines unused objects as dummy functions;

3. It specifies a second argument to the WebAssembly.instantiateStreaming function pointing to our defined objects;

4. It accesses Linear Memory in the wasm module through the exported object called ″memory″, which was generated by the compiler;

5. The memory objects buffer property points to the exact same area of memory as the buffer created in the C code;

6. It retrieves the memory.buffer as a series of Uint8Array bytes, allowing us to use the resulting pointer as a base address into the block of bytes.

**dataXchV3**

A further demonstration of Javascript interacting with C to manipulate shared data












