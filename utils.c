#include <stdio.h>
#include <stdlib.h>

#include "xlog.h"

unsigned char *read_wasm_binary_to_buffer(const char *module_path, size_t *size)
{
    FILE *file;
    unsigned char *buffer;
    size_t bytes_read;

    file = fopen(module_path, "rb");
    if (file == NULL)
    {
        xlog_error("Error opening file");
        return NULL;
    }

    // Get the size of the file
    fseek(file, 0, SEEK_END);
    *size = ftell(file);
    fseek(file, 0, SEEK_SET);

    // Allocate memory for the buffer
    buffer = (unsigned char *)malloc(*size);
    if (buffer == NULL)
    {
        xlog_error("Memory allocation error");
        fclose(file);
        return NULL;
    }

    // Read the file into the buffer
    bytes_read = fread(buffer, 1, *size, file);
    if (bytes_read != *size)
    {
        xlog_error("File read error");
        free(buffer);
        fclose(file);
        return NULL;
    }

    // Close the file and return the buffer
    fclose(file);
    return buffer;
}
