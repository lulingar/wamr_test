# build settings
BUILDROOT ?= .
OUTPUT_DIR ?= $(BUILDROOT)/build
DIST_DIR ?= $(BUILDROOT)/../dist
GEN_SRC_DIR ?= $(OUTPUT_DIR)/include
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

include $(BUILDROOT)/linux.mk

distclean: clean ## remove all build files
	rm -rf $(OUTPUT_DIR)
.PHONY: distclean

depend: $(DEPS) ## build dependencies
.PHONY: depend

$(WASM_MODULE):
	$(MAKE) -C $(BUILDROOT)/../wasm_module DIST_DIR=$(DIST_DIR)

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

_run: $(PROGBIN) $(WASM_MODULE)
	$(PROGBIN) $(WASM_MODULE)
.PHONY: _run

_gdb: $(PROGBIN) $(WASM_MODULE)
	gdb -ex "run $(WASM_MODULE)" $(PROGBIN)
.PHONY: _gdb
