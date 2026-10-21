(module

    ;; this module requires WASI resources: i.e., fd_write
    ;; Run with: wasamtime hellov3.wat 

    ;; ******** GLOBAL SECTION
    (import "wasi_snapshot_preview1" "fd_write" 
        (func $wasi_fd_write (param i32 i32 i32 i32) (result i32))
    )
    
    (memory (export "memory") 1)


;; setup data section Characters, and global values.
;; setup functions to copy/fill, i32.load8_u / i32.store8

    ;; ***** GLOBALS *****
    (global $intbin2decPtr (mut i32) (i32.const 64))        ;; ptr for the work area for the bin2dec function, which aggregates down memory
    (global $intbin2decReturnAddr (mut i32) (i32.const 0))  ;; the address returned by bin2dec to the start of the decimal string
    (global $intCharMsgAddr (mut i32) (i32.const 96))       ;;  start address of leading characters for the output message
    (global $intCharMsgLen (mut i32) (i32.const 15))         ;; length of leading output string
    (global $intOutPutArea (mut i32) (i32.const 32))        ;; start of staging area
    (global $intFDIovec (mut i32) (i32.const 0))            ;; location of iovec for fd_write
    (global $intFDDevice (mut i32) (i32.const 1))           ;; code for stdout
    (global $intFDIovecs (mut i32) (i32.const 1))           ;; number of iovecs
    (global $intFDBytesWritten (mut i32) (i32.const 8))     ;; number of bytes output by fd_write
    
    ;; ***** DATA SECTION *****
    (data (i32.const 96) "The result is: ")




(;
 ;; The iovec structure starts at memory address 8:
    ;; - Bytes 8-11: Pointer to the text buffer (offset 16)
    ;; - Bytes 12-15: Length of the text buffer (13 bytes)
    (data (i32.const 8) "\10\00\00\00\0d\00\00\00")
    ;; The actual string buffer starts at memory address 16
    (data (i32.const 16) "Hello World!")
    (data (i32.const 27) "\38\20\20\n")
;)



    ;;
    ;; ******* helper functions
    ;;
       
    (func $copyData (param $Offset i32) (param $dataIn i32)
        ;; Set the offset within memory to copy the data to
        local.get $Offset
        ;; Set the data
        local.get $dataIn
        ;; Copy the data into memory
        i32.store
    )

    (func $resetMemory
    ;; Set the offset within memory to start filling
    i32.const 0
    ;; Set the value to fill memory with
    i32.const 0x20    ;; space character
    ;; Set the number of bytes to fill
    i32.const 256
    ;; Fill the memory with the data
    memory.fill
    )

   
    (func $bin2dec (param $num i32) (param $ptr i32) (result i32)
        ;; Function to convert an unsigned 32-bit integer to a decimal ASCII string
        ;; Returns the memory offset pointing to the start of the string
        ;; $num: the number to convert from binary to ascii decimal characters
        ;; $ptr: Pointer to walk backwards in memory
        
        (local $digit i32)    ;; Holds the remainder (current decimal digit)

        ;; Start writing at the end of a safe buffer zone 
        ;; An unsigned 32-bit integer has a max length of 10 digits

        ;; Handle the edge case where the input number is exactly 0
        local.get $num
        i32.eqz
        if 
            ;; $num = 0
            (local.set $ptr (i32.sub (local.get $ptr) (i32.const 1)))
            (i32.store8 (local.get $ptr) (i32.const 48))                 ;; ASCII '0'
            (return (local.get $ptr))
        end
        
        ;; Loop to extract base-10 digits
        loop $digit_loop

            ;; Extract the rightmost digit: digit = num % 10
            (local.set $digit (i32.rem_u (local.get $num) (i32.const 10)))
            ;; Convert the numeric digit to its ASCII character value (digit + 48)
            ;; and store it in linear memory at the pointer address
            (i32.store8 
                (local.get $ptr) 
                (i32.add (local.get $digit) (i32.const 48))
            )
            ;; Drop the extracted digit from the number: num = num / 10
            (local.set $num (i32.div_u (local.get $num) (i32.const 10)))
            ;; Move pointer backward by 1 byte
            (local.set $ptr (i32.sub (local.get $ptr) (i32.const 1)))
            ;; Continue looping if the remaining number is greater than 0
            (br_if $digit_loop (i32.gt_u (local.get $num) (i32.const 0)))
        end
        ;; Return the pointer where the decimal string starts
        (local.set $ptr (i32.add (local.get $ptr) (i32.const 1)))       ;; 1 was subtracted in anticipation of looping: put it back
        (local.get $ptr)
    )

    ;;
    ;; ***** MAIN LOGIC *****
    ;;
    ;;  Define and export the entry point function
    (func $main (export "_start")
    
        ;;
        ;; init
        ;;
        (local $intResLen i32)    ;; length of characters in the result
        (local $intResOffset i32) ;; offset into the staging area for the result
        
        ;; call $resetMemory   ;; set memory for easy read of memeory dump in debugger, if necessary
        
        ;;
        ;; main process
        ;;
        i32.const 15                ;; first arg for bin2dec: binary number to convert
        global.get $intbin2decPtr   ;; second arg for bin2dec: result work area
        call $bin2dec
        global.set $intbin2decReturnAddr    ;; save address of start of decimal string

        ;; build staging area for message to be output by fd_write
        ;; prepare for a memory copy
        global.get $intOutPutArea               ;; start of staging area
        global.get $intCharMsgAddr              ;; start of literal message data
        global.get $intCharMsgLen               ;; number of bytes to copy
        memory.copy
        


        ;; finish setting up staging area by appending result
        ;; get length of characters in result
        (local.set $intResLen (i32.sub (global.get $intbin2decPtr) (global.get $intbin2decReturnAddr)))   ;; calculate length
        (local.set $intResLen (i32.add (local.get $intResLen) (i32.const 1)))   ;; add 1 for inclusivity
        ;; get location to append to end of string
        (local.set $intResOffset (i32.add (global.get $intOutPutArea) (global.get $intCharMsgLen)))   ;;
        local.get $intResOffset             ;; to address
        global.get $intbin2decReturnAddr    ;; from address
        local.get $intResLen                ;; length to copy
        memory.copy
        ;; add a carriage return at end of msg
        local.get $intResOffset
        local.get $intResLen
        i32.add
        i32.const 0x0A
        i32.store8
        
        
        
        ;; setup fd_write
        ;;
        ;; build iovec
        ;;
        global.get $intFDIovec                  ;; location of iovec
        global.get $intOutPutArea               ;; start address of msg
        i32.store                               ;; 
        global.get $intFDIovec                  ;; location of iovec
        i32.const 4                             
        i32.add                                 ;; second part of iovec: memory offset for i32.store
        ;; calculate total length of msg and push it
        ;;
        local.get $intResLen
        global.get $intCharMsgLen
        i32.add
        i32.const 1                             ;; add 1 for the carriage return control character
        i32.add
        i32.store
        
        ;; build wasi_fd_write
        global.get $intFDDevice                 ;; device type: stdout
        global.get $intFDIovec                  ;; address of iovec
        global.get $intFDIovecs                 ;; number of iovecs
        global.get $intFDBytesWritten           ;; location to store number of bytes output
        
        call $wasi_fd_write
        ;; fd_write returns an error code (0 for success). 
        ;; We use drop here to clean it off the stack.
        drop 

    ) ;; end function
)   ;; end module