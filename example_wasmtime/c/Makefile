BUILDROOT ?= .
OUTPUT_DIR ?= $(BUILDROOT)/build
DIST_DIR ?= $(BUILDROOT)/../../dist
PROGRAM = $(DIST_DIR)/test_wasmtime_c_$(VARIANT)
WASM_MODULE = $(DIST_DIR)/wasm_helloworld

# default rule
help:
	@echo "To build: Run 'make threaded' or 'make no_thread'"
	@echo "To execute: Run 'make run_threaded' or 'make run_no_thread'"
	@echo "To debug: Run 'make gdb_threaded' or 'make gdb_no_thread'"
.PHONY: all

threaded:
	$(MAKE) VARIANT=$@ depend compile
.PHONY: threaded

no_thread:
	$(MAKE) VARIANT=$@ depend compile
.PHONY: no_thread

compile: $(PROGRAM)
.PHONY: compile

CC ?= clang

CSRCS += main_$(VARIANT).c
OBJS = $(addprefix $(OUTPUT_DIR)/, $(CSRCS:%.c=%.o))

# dependencies
include $(BUILDROOT)/depend.mk

$(PROGRAM): $(CSRCS) $(DEPS)
	@mkdir -p $(@D)
	$(CC) $(CSRCS) \
		-I $(LIB_WASMTIME_C_API_INC) \
		$(LIB_WASMTIME) \
		-lpthread -ldl -lm \
		-o $@

$(WASM_MODULE):
	$(MAKE) -C $(BUILDROOT)/../../wasm_module DIST_DIR=$(DIST_DIR)

clean:
	rm -r $(OUTPUT_DIR)
.PHONY: clean

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

_run: $(PROGRAM) $(WASM_MODULE)
	$(PROGRAM) $(WASM_MODULE)
.PHONY: _run

_gdb: $(PROGRAM) $(WASM_MODULE)
	gdb -ex "run $(WASM_MODULE)" $(PROGRAM)
.PHONY: _gdb
