# wamr_test

## Motivation
This example serves to explore WAMR's and wasmtime's behavior when spawning more than one instance of the same module, while options such as shared memory or multi-module support are toggled.

## Get started

There are three example embedding programs that attempt to run multiple instances of a simple WASM module. You may first build the WASM module via
```
make -C wasm_module
```
and then you may run these targets:
- `make -C example_wamr run_no_thread`: WAMR loads and executes a single instance of the WASM module.
- `make -C example_wamr run_threaded`: WAMR loads and executes two instances of the WASM module.
- `make -C example_wasmtime/rust run`: wasmtime embedding in Rust, loads and executes two instances of the WASM module.
- `make -C example_wasmtime/c run_no_thread`: wasmtime embedding in C, loads and executes a single instance of the WASM module.
- `make -C example_wasmtime/c run_threaded`: wasmtime embedding in C, loads and executes two instances of the WASM module.

There are also `gdb_*` corresponding targets, to be used for debugging.
