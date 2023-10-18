LIB_BUILD ?= Release
LIB_CFLAGS ?=
BUILDROOT ?= $(CURDIR)
DEPEND_DIR ?= $(BUILDROOT)/depend
OUTPUT_DIR ?= $(BUILDROOT)/build
TOOLS_DIR ?= $(BUILDROOT)/../tools
DEPEND_PARALLEL_JOBS ?= 1

GIT_CHECKOUT = $(TOOLS_DIR)/git_checkout.sh
CMAKE = cmake

include $(BUILDROOT)/libs.mk

# pthread
LIBS += -pthread -lpthread
CFLAGS += -pthread

# wamr
LIB_WAMR = $(OUTPUT_DIR)/wasm-micro-runtime/libvmlib.a
LIB_WAMR_SRC = $(DEPEND_DIR)/wasm-micro-runtime

LIBS += -lvmlib -lm
LIBS += -L$(OUTPUT_DIR)/wasm-micro-runtime
CFLAGS += -I$(LIB_WAMR_SRC)/core/iwasm/include
DEPS += wasm-micro-runtime
PREPS += $(LIB_WAMR_SRC)

$(LIB_WAMR_SRC):
	$(GIT_CHECKOUT) $(LIB_WAMR_GIT_URL) $(LIB_WAMR_GIT_TAG) $@
$(LIB_WAMR): $(LIB_WAMR_SRC)
	mkdir -p $(OUTPUT_DIR)/wasm-micro-runtime
	CFLAGS="$(LIB_CFLAGS)" $(CMAKE) \
		-B $(OUTPUT_DIR)/wasm-micro-runtime \
		-DWAMR_BUILD_TARGET=$(shell CC=$(CC) $(TOOLS_DIR)/guess_wamr_build_target.sh) \
		-DWAMR_BUILD_INTERP=1 \
        -DWAMR_BUILD_FAST_INTERP=1 \
        -DWAMR_BUILD_JIT=0 \
        -DWAMR_BUILD_AOT=1 \
        -DWAMR_BUILD_LIBC_WASI=1 \
        -DWAMR_BUILD_LIBC_BUILTIN=0 \
        -DWAMR_BUILD_LIBC_UVWASI=0 \
        -DWAMR_BUILD_MULTI_MODULE=1 \
        -DWAMR_BUILD_MINI_LOADER=0 \
        -DWAMR_BUILD_SHARED_MEMORY=1 \
        -DWAMR_BUILD_THREAD_MGR=1 \
        -DWAMR_BUILD_LIB_PTHREAD=1 \
        -DWAMR_BUILD_BULK_MEMORY=1 \
		-DCMAKE_BUILD_TYPE=$(LIB_BUILD) \
		$(LIB_WAMR_SRC)
	$(CMAKE) --build $(OUTPUT_DIR)/wasm-micro-runtime -j$(DEPEND_PARALLEL_JOBS)
wasm-micro-runtime: $(LIB_WAMR)
.PHONY: wasm-micro-runtime

$(DEPEND_DIR):
	@mkdir -p $@

prepare: $(PREPS) ## fetch dependencies if required
.PHONY: prepare

clobber: distclean ## remove dependencies
	@rm -rf $(DEPEND_DIR)
.PHONY: clobber
