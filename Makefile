# build settings
BUILDROOT ?= .
OUTPUT_DIR ?= $(BUILDROOT)/build
GEN_SRC_DIR ?= $(OUTPUT_DIR)/include
WASM_MODULE = $(OUTPUT_DIR)/wasm_helloworld

# default rule
help:
	@echo "To build: Run 'make threaded' or 'make no_thread'"
	@echo "To execute: Run 'make run_threaded' or 'make run_no_thread'"
	@echo "To debug: Run 'make gdb_threaded' or 'make gdb_no_thread'"
.PHONY: all

threaded:
	$(MAKE) VARIANT=$@ depend compile wasm_helloworld
.PHONY: threaded

no_thread:
	$(MAKE) VARIANT=$@ depend compile wasm_helloworld
.PHONY: no_thread

# source compilation rules depending on build configuration
include $(BUILDROOT)/linux.mk

distclean: clean ## remove all build files
	rm -rf $(OUTPUT_DIR)
.PHONY: distclean

depend: $(DEPS) ## build dependencies
.PHONY: depend

$(OUTPUT_DIR):
	@mkdir -p $@

#### WASM module build ####

wasm_helloworld: $(WASM_MODULE)
.PHONY: wasm_helloworld

$(WASM_MODULE): helloworld.c
	/opt/wasi-sdk-20.0/bin/clang -target wasm32-wasi-threads \
		-Wall -Werror -pthread -Os -c \
		-o build/$(^:%.c=%.o) $^
	/opt/wasi-sdk-20.0/bin/clang -target wasm32-wasi-threads \
		-pthread -lpthread -Wl,--max-memory=$$((1<<20)) -Wl,-allow-undefined \
		-Wl,--export=malloc -Wl,--export=free \
		-Wl,--export=__data_end -Wl,--export=__heap_base \
		build/$(^:%.c=%.o) -o $@

#### Run targets ####

run_threaded:
	@$(MAKE) VARIANT=threaded _run
.PHONY: run_threaded

gdb_threaded:
	@$(MAKE) VARIANT=threaded _gdb
.PHONY: gdb_threaded

run_no_thread:
	@$(MAKE) VARIANT=no_thread _run
.PHONY: run_no_thread

gdb_no_thread:
	@$(MAKE) VARIANT=no_thread _gdb
.PHONY: gdb_no_thread

_run: $(OUTPUT_DIR)/$(PROGNAME) $(WASM_MODULE)
	$(OUTPUT_DIR)/$(PROGNAME) $(WASM_MODULE)
.PHONY: _run

_gdb: $(OUTPUT_DIR)/$(PROGNAME) $(WASM_MODULE)
	gdb -ex "run $(WASM_MODULE)" $(OUTPUT_DIR)/$(PROGNAME)
.PHONY: _gdb
