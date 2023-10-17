#include <assert.h>
#include <pthread.h>
#include <stdlib.h>
#include <stdio.h>

#include <wasm_export.h>

#include "xlog.h"
#include "utils.h"

static void *
wasm_runner(void *vp)
{
    wasm_module_inst_t *module_inst = vp;

    bool ok = wasm_runtime_init_thread_env();
    if (!ok)
    {
        xlog_error("wasm_runtime_init_thread_env failed");
    }

    // TODO: Replace assert (programming error)
    assert(*module_inst != NULL);
    if (!wasm_application_execute_main(*module_inst, 0, NULL))
    {
        const char *exc = wasm_runtime_get_exception(*module_inst);
        xlog_error("wasm_application_execute_main exception: %s", exc);
        if (exc == NULL)
        {
            exc = "Unknown WASM exception";
        }
    }

    wasm_runtime_destroy_thread_env();

    xlog_info("Thread %zu finished", pthread_self());
    return NULL;
}

void spawn_wasm_instance(const wasm_module_t module, pthread_t* thread, wasm_module_inst_t* module_inst)
{
    char error_buf[128];
    // wasm_function_inst_t func;
    // wasm_exec_env_t exec_env;
    size_t stack_size = 8092, heap_size = 8092;

    wasm_runtime_set_wasi_args_ex(module, NULL, 0, NULL, 0, NULL,
                                  0, NULL, 0, -1, 1, 2);

    /* create an instance of the WASM module (WASM linear memory is ready) */
    *module_inst = wasm_runtime_instantiate(module, stack_size, heap_size,
                                           error_buf, sizeof(error_buf));

    wasm_runtime_set_wasi_args_ex(module, NULL, 0, NULL, 0, NULL,
                                  0, NULL, 0, -1, 0, 0);

    xlog_info("Creating thread with stack_size %zd", stack_size);
    int ret = pthread_create(thread, NULL, wasm_runner, module_inst);
    if (ret != 0)
    {
        xlog_error("pthread_create error %d", ret);
    }
}

int main(int argc, char *argv[])
{
    int rc = 1;
    char error_buf[128];
    size_t size;
    unsigned char *buffer;
    wasm_module_t module;

    /* initialize the wasm runtime by default configurations */
    wasm_runtime_init();

    /* read WASM file into a memory buffer */
    buffer = read_wasm_binary_to_buffer(argv[1], &size);
    xlog_info("Buffer size is %zu", size);
    if (size == 0) {
        xlog_error("Could not read file %s", argv[1]);
        goto out;
    }

    /* parse the WASM file from buffer and create a WASM module */
    module = wasm_runtime_load(buffer, size, error_buf, sizeof(error_buf));
    if (module == NULL)
    {
        xlog_error("Failure loading module: %s", error_buf);
        goto out;
    }

    /* add line below if we want to export native functions to WASM app
    wasm_runtime_register_natives(...);
    */

    pthread_t t1, t2;
    wasm_module_inst_t mi_1, mi_2;
    spawn_wasm_instance(module, &t1, &mi_1);
    spawn_wasm_instance(module, &t2, &mi_2);

    pthread_join(t1, NULL);
    pthread_join(t2, NULL);
    rc = 0;

out:
    free(buffer);
    return rc;
}
