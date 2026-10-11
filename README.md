# <div style="text-align: center">Exploring Web Assembly (WASM)</div>

   <div style="margin-left: 1em">This project consists of several base examples of working with WASM and the various tools, which may be of interest to the curious developer.</div>
    <div style="margin-left: 1em">The project uses the Emscripten toolchain to compile C source code to a wasm file suitable to be used by Javascript in a Web page.</div>
    <div style="margin-left: 1em">The examples include:</div>
 <div style="margin-left: 2em"> • The Web Assembly language built into all modern web browsers;<br>
    • Working with wasm files;<br>
    • Using the Emscripten compiler and its various outputs;<br>
    • Compiling C source code to wasm that includes code to:<br>
        <div style="margin-left: 1em">◦ Call Javascript functions from C;<br>
        ◦ Call C functions from Javascript;<br>
        ◦ How to read/write to Linear memory both in Javascript and in C;
        </div></div>
<div style="margin-left: 1em">Although there are many other tools and methods used in working with Web Assembly, we restrict ourselves to the above.<br>
The following is a list and a short description of the examples in the project:<br>
    <div style="margin-left: 1em">1. hello, the ubiquitous first rendering of a .wasm file, created from a hello.c file and compiled using emcc.<br> 
        <div style="margin-left: 1em">i. Uses the default Javascript and HTML files output by the emcc compiler.<br>
        ii. The c code can use i/o, e.g., printf(...), by the use of the emitted Javascript ″glue″ file from the emcc compiler.</div>
    2. helloV2, 
        <div style="margin-left: 1em">i. Similar to hello but uses a custom web page (helloV2_custom.html) rather than the html page emitted by the emcc compiler.<br>
        ii. Call any Javascript function either from the JS library or a custom function, by including the Emscripten header and using the ″emscripten_run_script″ macro.</div>
    3. fibonacci, 
        <div style="margin-left: 1em">i. Calling a C function from Javascript.<br>
        ii. Using the Module object provided by the emitted Javascript file from the emcc compiler, in particular, the functions ″cwrap()″ and ″ccall()″.<br>
        iii. Await the complete initialisation of a wasm file by using the Module object′s ″onRuntimeInitialized″ property, before proceeding with code that depends on it.<br>
        iv. Providing options to the emcc compiler to recognise exported functions, e.g.,<br>
           <div style="margin-left: 1em"> emcc fibonacci.c -o fibonacci.js -s WASM=1 -s EXPORTED_FUNCTIONS=_fib -sEXPORTED_RUNTIME_METHODS=ccall,cwrap</div></div>	
    4. fibonacciV2, 
        <div style="margin-left: 1em">i. Uses a Web Assembly promise type function in co-operation with the Javascript ″fetch″ function to load, compile and instantiate the wasm file,
        <div style="margin-left: 1em"> WebAssembly.instantiateStreaming(fetch("fibonacciV2.wasm"), importObject)</div>	
        ii. The Javascript ″glue″ file is not required.<br>
        iii. The c file uses an Emscripten macro to retain access to the specified C functions, therefore, the compiler export options are not required,<br>
            <div style="margin-left: 1em"> emcc fibonacciV2.c -o fibonacciV2.wasm<br></div>
        iv. Requires some boiler plate code in the html page to handle exported objects by the wasm file.</div><br>
The next three examples demonstrate the exchange of data between Javascript and C through a shared area of memory established by the compiler in the wasm module,<br>
known as Linear Memory.<br>5) dataXchV1
	<div style="margin-left: 1em"><div style="margin-left: 1em">The Javascript code,</div>
    <div style="margin-left: 1em"><div style="margin-left: 1em">1. Works with the optimized version of the compiled code: -oz compile option; no need to handle wasm extraeneous exported objects,
<br> as the optimised wasm module does not expose any.<br>
    2. Links to the exported  functions in the C code, including main() via the WebAssembly.Instance.prototype.exports property.<br> 
    3. Get a pointer to and the length of a buffer created by the C code, i.e., Linear Memory<br>
    4. Retrieves a character from Linear Memory using an exported C function. The character is retrieved via the pointer to a buffer created by the C code.<br>
    5. Uses TextEncoder and TextDecoder with UInt8Arrays.<br>
    6. Writes a character into C′s buffer using an exported function created in the C code.<br>
    7. Access Linear Memory other than a pointer to C′s buffer: they are one and the same.<br>
    8. Fetch the first byte in Linear memory, a.k.a., C′s buffer, as a Uint8Array.<br>
    9. Decode and log the first byte in the Uint8Array.<br>
    10. Fetch a block of Linear Memory containing a string created within the C code buffer; decode and log it.</div>
	The C code,	
    <div style="margin-left: 1em">1. Includes the Emscipten header in order to use the macro<br>
	 <div style="margin-left: 1em">EXTERN EMSCRIPTEN_KEEPALIVE</div>
    2. Creates and exports several functions for Javascript to call:<br>
        <div style="margin-left: 1em">i. char* get_buffer_ptr(void)<br>
        ii. int get_buffer_len(void)<br>
        iii. char getCharFromBuffer(int n)<br>
        iv. char setCharIntoBuffer(int n, char m)<br>	
        v. int main()</div></div>
    6) dataXchV2<br>
	<div style="margin-left: 1em">No changes are made to the C code but it is compiled without optimisation. This leads to changes in the dataXchV2.html file.<br>
    It also accesses Linear Memory from an Object provided by wasm rather than using C's buffer.
    <div style="margin-left: 1em">1. WASI objects appear within the wasm module as helper code to perform low level i/o. At this time they are extraeneous to our examples.<br>
    2. It defines the objects using dummy functions.<br>
    3. It specifies a second argument to the WebAssembly.instantiateStreaming function pointing to our defined objects.<br>
    4. It accesses Linear Memory in the wasm module through the exported object called ″memory″, which was generated by the compiler.<br>
    5. The memory objects buffer property points to the exact same area of memory as the buffer created in the C code<br>
    6. It retrieves the memory.buffer as a series of Uint8Array bytes, allowing us to use the resulting pointer as a base address into the block of bytes.</div></div>
    7) dataXchV3<br>
    <div style="margin-left: 1em">A further demonstration of Javascript interacting with C to manipulate shared data</div></div></div></div>
    


