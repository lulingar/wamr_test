BUILDROOT ?= .
OUTPUT_DIR ?= $(BUILDROOT)/build
DIST_DIR ?= ../dist

WASM_MODULE ?= $(DIST_DIR)/wasm_helloworld
CSRCS = helloworld.c

WASI_PATH ?= /opt/wasi-sdk-20.0

module: $(WASM_MODULE)
.PHONY: module

clean:
	rm -rf $(OUTPUT_DIR)
.PHONY: clean

OBJS = $(addprefix $(OUTPUT_DIR)/, $(CSRCS:%.c=%.o))

$(OUTPUT_DIR)/%.o: %.c
	@mkdir -p $(@D)
	$(WASI_PATH)/bin/clang -target wasm32-wasi-threads \
		-Wall -Werror -pthread -Os -c \
		-o $(OUTPUT_DIR)/$(<:%.c=%.o) $<

$(WASM_MODULE): $(OBJS)
	$(WASI_PATH)/bin/clang -target wasm32-wasi-threads \
		-pthread -lpthread -Wl,--max-memory=$$((1<<20)) -Wl,-allow-undefined \
		-Wl,--export=malloc -Wl,--export=free \
		-Wl,--export=__data_end -Wl,--export=__heap_base \
		$^ -o $@
