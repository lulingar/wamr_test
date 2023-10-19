BUILDROOT ?= .
OUTPUT_DIR ?= $(BUILDROOT)/build
DIST_DIR ?= $(BUILDROOT)/../../dist
PROGRAM = $(DIST_DIR)/test_wasmtime_rust
WASM_MODULE = $(DIST_DIR)/wasm_helloworld

all: compile
.PHONY: all

compile: $(PROGRAM)
.PHONY: compile

run: compile $(WASM_MODULE)
	$(PROGRAM) $(realpath $(WASM_MODULE))
.PHONY: run

clean:
	rm -r $(OUTPUT_DIR)
.PHONY: clean

$(PROGRAM): Cargo.toml src/main.rs
	@mkdir -p $(OUTPUT_DIR)
	@cargo build --target-dir $(OUTPUT_DIR)
	@rm -f $@
	@ln -s $(realpath $(OUTPUT_DIR)/debug/$(notdir $@)) $@

$(WASM_MODULE):
	$(MAKE) -C $(BUILDROOT)/../../wasm_module DIST_DIR=$(DIST_DIR)
