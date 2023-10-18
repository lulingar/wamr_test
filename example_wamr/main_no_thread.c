#include <stdlib.h>
#include <stdio.h>

#include <wasm_export.h>

#include "xlog.h"
#include "utils.h"

int main(int argc, char *argv[])
{
    int rc = 1;
    unsigned char *buffer;
    char error_buf[128];
    wasm_module_t module;
    wasm_module_inst_t module_inst;
    // wasm_function_inst_t func;
    // wasm_exec_env_t exec_env;
    size_t size, stack_size = 8092, heap_size = 8092;

    /* initialize the wasm runtime by default configurations */
    wasm_runtime_init();

    /* read WASM file into a memory buffer */
    buffer = read_wasm_binary_to_buffer(argv[1], &size);
    xlog_info("Buffer size is %zu", size);

    /* add line below if we want to export native functions to WASM app
    wasm_runtime_register_natives(...);
    */

    /* parse the WASM file from buffer and create a WASM module */
    module = wasm_runtime_load(buffer, size, error_buf, sizeof(error_buf));
    if (module == NULL)
    {
        xlog_error("Failure loading module: %s", error_buf);
        goto out;
    }

    /* From wedge-agent:
        wasm_runtime_set_wasi_args_ex(
            module,
            NULL, 1,
            NULL, 0, NULL, 0, NULL, 0, -1, 0, 0);
    */

    /* create an instance of the WASM module (WASM linear memory is ready) */
    module_inst = wasm_runtime_instantiate(module, stack_size, heap_size,
                                           error_buf, sizeof(error_buf));

    /*
     * Clear wasi args to ensure it won't be used for
     * other module instances even when it shares the same module.
     * (This should not be necessary. Otherwise, we should move
     * wasm_module_t management from module_impl_wasm to
     * module_instance_impl_wasm.)
     */
    wasm_runtime_set_wasi_args_ex(module, NULL, 0, NULL, 0, NULL,
                                  0, NULL, 0, 0, 0, 0);

    if (!wasm_application_execute_main(module_inst, 0, NULL))
    {
        const char *exc = wasm_runtime_get_exception(module_inst);
        xlog_error("wasm_application_execute_main exception: %s", exc);
        if (exc == NULL)
        {
            exc = "Unknown WASM exception";
        }
    }
    else {
        rc = 0;
    }

out:
    free(buffer);
    return rc;
}
