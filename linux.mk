PROGNAME = test_wamr_$(VARIANT)

# Source compilation flags
include $(BUILDROOT)/flags.mk

# Include paths
CFLAGS += -I$(GEN_SRC_DIR)

# POSIX libraries
LIBS += -ldl -lrt

# sources
include $(BUILDROOT)/sources.mk
CSRCS += main_$(VARIANT).c

vpath %.c $(BUILDROOT)/src

# dependencies
include $(BUILDROOT)/depend.mk

OBJS = $(addprefix $(OUTPUT_DIR)/, $(CSRCS:%.c=%.o))
DEPS += $(OUTPUT_DIR)

# build rules
$(OUTPUT_DIR)/$(PROGNAME): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)
	@echo Successfully built $(subst $(BUILDROOT)/,, $@)

compile: $(OUTPUT_DIR)/$(PROGNAME) ## compile
.PHONY: compile

strip: $(OUTPUT_DIR)/$(PROGNAME) ## discard symbols from binary
	@strip -s $<
.PHONY: strip

size: $(OUTPUT_DIR)/$(PROGNAME) ## display binary size
	@size $<
	@ls -sh $<
.PHONY: size

clean: ## remove intermediate files
	@rm -f $(OBJS)
	@rm -f $(OBJS:%.o=%.d)
	@rm -rf $(GEN_SRC_DIR)/*
.PHONY: clean

include $(BUILDROOT)/rules.mk

# include object file dependencies generated with -MD
-include $(OBJS:%.o=%.d)
