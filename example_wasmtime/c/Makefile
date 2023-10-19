BUILDROOT ?= .
OUTPUT_DIR ?= $(BUILDROOT)/build
DIST_DIR ?= $(BUILDROOT)/../../dist
PROGRAM = $(DIST_DIR)/test_wasmtime_c
WASM_MODULE = $(DIST_DIR)/wasm_helloworld

all: compile
.PHONY: all

compile: $(PROGRAM)
.PHONY: compile

run: compile $(WASM_MODULE)
	$(PROGRAM) $(WASM_MODULE)
.PHONY: run

CC ?= clang

CSRCS += main.c
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
