BUILDROOT ?= $(CURDIR)
DEPEND_DIR ?= $(BUILDROOT)/depend
OUTPUT_DIR ?= $(BUILDROOT)/build

# pthread
LIBS += -pthread -lpthread
CFLAGS += -pthread

# Wasmtime C API
LIB_WASMTIME_VER ?= v13.0.0
LIB_WASMTIME_TAR = wasmtime-$(LIB_WASMTIME_VER)-x86_64-linux-c-api
LIB_WASMTIME_URL = https://github.com/bytecodealliance/wasmtime/releases/download/$(LIB_WASMTIME_VER)/$(LIB_WASMTIME_TAR).tar.xz

LIB_WASMTIME_DIR = $(DEPEND_DIR)/$(LIB_WASMTIME_TAR)
LIB_WASMTIME = $(LIB_WASMTIME_DIR)/lib/libwasmtime.a
LIB_WASMTIME_C_API_INC = $(LIB_WASMTIME_DIR)/include

#LIBS += -L$(dir $(LIB_WASMTIME))
#LIBS += -lwasmtime -lm -ldl
LIBS += $(LIB_WASMTIME)
CFLAGS += -I$(LIB_WASMTIME_C_API_INC)
DEPS += wasmtime-c-api
PREPS += $(LIB_WASMTIME_SRC)

$(LIB_WASMTIME): | $(DEPEND_DIR)
	curl -sL $(LIB_WASMTIME_URL) | tar -C $(DEPEND_DIR) -xJ

wasmtime-c-api: $(LIB_WASMTIME)
.PHONY: wasmtime-c-api

$(DEPEND_DIR):
	@mkdir -p $@

prepare: $(PREPS) ## fetch dependencies if required
.PHONY: prepare

clobber: distclean ## remove dependencies
	@rm -rf $(DEPEND_DIR)
.PHONY: clobber
