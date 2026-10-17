(module

;; see example set.wat for a similar process but is self running through the start command
  (import "console" "log" (func $log (param i32)))
  (func (export "logIt")
    i32.const 13
    call $log
  )
)