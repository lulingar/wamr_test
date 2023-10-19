use anyhow::Result;
//use std::sync::Arc;
use std::env;
use std::thread;
use wasmtime::*;
use wasmtime_wasi::{WasiCtx, sync::WasiCtxBuilder};

const N_THREADS: i32 = 2;

struct ModuleState {
    wasi: WasiCtx,
}

fn main() -> Result<()> {
    println!("Initializing...");
    let args: Vec<String> = env::args().collect();

    // Enable the multi-memory feature.
    let mut config = Config::new();
    config.wasm_threads(true);

    // Initialize global per-process state. This state will be shared amonst all
    // threads. Notably this includes the compiled module as well as a `Linker`,
    // which contains all our host functions we want to define.
    let engine = Engine::new(&config)?;
    let module = Module::from_file(&engine, &args[1])?;
    let mut linker = Linker::new(&engine);
    wasmtime_wasi::add_to_linker(&mut linker, |state: &mut ModuleState| &mut state.wasi)?;
    //let linker = Arc::new(linker); // "finalize" the linker

    // Share this global state amongst a set of threads, each of which will
    // create stores and execute instances.
    let children = (0..N_THREADS)
        .map(|_| {
            let engine = engine.clone();
            let module = module.clone();
            let linker = linker.clone();
            thread::spawn(move || {
                run(&engine, &module, &linker).expect("Success");
            })
        })
        .collect::<Vec<_>>();

    for child in children {
        child.join().unwrap();
    }

    Ok(())
}

fn run(engine: &Engine, module: &Module, linker: &Linker<ModuleState>) -> Result<()> {
    // Each sub-thread we have starting out by instantiating the `module`
    // provided into a fresh `Store`.
    println!("Instantiating module...");

    let wasi = WasiCtxBuilder::new()
        .inherit_stdio()
        .inherit_args()?
        .build();
    let mut store = Store::new(&engine, ModuleState {
        wasi
    });
    let instance = linker.instantiate(&mut store, module)?;
    let run = instance.get_typed_func::<(), ()>(&mut store, "_start")?;

    println!("Executing...");
    run.call(&mut store, ())?;
    /*
    thread::sleep(time::Duration::from_millis(100));

    // Also note that that a `Store` can also move between threads:
    println!("> Moving {:?} to a new thread", thread::current().id());
    let child = thread::spawn(move || run.call(&mut store, ()));
    child.join().unwrap()?;
    */

    Ok(())
}
