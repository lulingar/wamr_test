#
# Common compilation flags
#
# Allows setting compilation flags (CFLAGS) in one of four ways:
# 1. specify BUILD=Release to select release build settings
# 2. specify BUILD=Debug to select debug build settings
# 3. specify BUILD=Profile to set sanitizer flags
# 4. pass in a CFLAGS argument to override default flags

BUILD ?= Debug

# default CFLAGS
DEF_CFLAGS = -Wall -Wno-misleading-indentation -fno-common -Wstrict-prototypes
DEBUG_FLAGS = -g3 -O0 -DDEBUG #-Werror
RELEASE_FLAGS = -O3 -DNDEBUG
STATIC_FLAGS =  -Os -DNDEBUG -ffunction-sections -fdata-sections
PROFILE_FLAGS = -g -Os -Werror
PROFILE_FLAGS += -fsanitize=address
PROFILE_FLAGS += -fsanitize-address-use-after-scope
PROFILE_FLAGS += -fsanitize=alignment
PROFILE_FLAGS += -fsanitize=bool
PROFILE_FLAGS += -fsanitize=bounds
PROFILE_FLAGS += -fsanitize=enum
PROFILE_FLAGS += -fsanitize=integer
PROFILE_FLAGS += -fsanitize=implicit-integer-truncation
PROFILE_FLAGS += -fsanitize=implicit-integer-arithmetic-value-change
PROFILE_FLAGS += -fsanitize=implicit-conversion
PROFILE_FLAGS += -fsanitize=object-size
PROFILE_FLAGS += -fsanitize=pointer-overflow
PROFILE_FLAGS += -fsanitize=returns-nonnull-attribute
PROFILE_FLAGS += -fsanitize=shift
PROFILE_FLAGS += -fsanitize=undefined
PROFILE_FLAGS += -fsanitize=unreachable
PROFILE_FLAGS += -fsanitize=unsigned-integer-overflow
PROFILE_FLAGS += -fsanitize=vla-bound
PROFILE_FLAGS += -fcoverage-mapping
PROFILE_FLAGS += -fprofile-instr-generate

ifneq "$(shell $(CC) --version | grep clang)" ""
  DEF_CFLAGS += -Wthread-safety
endif

# release/debug configuration
ifeq ($(BUILD),Debug)
  CFLAGS ?= $(DEBUG_FLAGS) $(DEF_CFLAGS)
else ifeq ($(BUILD),Release)
  CFLAGS ?= $(RELEASE_FLAGS) $(DEF_CFLAGS)
else ifeq ($(BUILD),Static)
  CFLAGS ?= $(STATIC_FLAGS) $(DEF_CFLAGS)
  LDFLAGS += $(STATIC_FLAGS) -static -Wl,--gc-sections
  LIB_CFLAGS = $(STATIC_FLAGS)
else ifeq ($(BUILD),Profile)
  CFLAGS ?= $(PROFILE_FLAGS) $(DEF_CFLAGS)
  LDFLAGS += $(PROFILE_FLAGS)
  export ASAN_OPTIONS = detect_leaks=1:detect_stack_use_after_return=1
  export UBSAN_OPTIONS = print_stacktrace=1
else
  $(error Invalid CONFIG=$(BUILD))
endif
