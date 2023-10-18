# Common rules used by other Makefiles

pre: $(OBJS:%.o=%.i) ## generate preprocessor output files
.PHONY: pre

asm: $(OBJS:%.o=%.s) ## generate assembly output files
.PHONY: asm

# implicit rules
$(OUTPUT_DIR)/%.o: %.c
	@echo CC: $(subst $(BUILDROOT)/,, $<)
	@mkdir -p $(@D)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) -MD $< -o $@ \
	$($(strip $<)_CFLAGS)

$(OUTPUT_DIR)/%.i: %.c
	@echo CPP: $(subst $(OUTPUT_DIR)/,, $@)
	@mkdir -p $(@D)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) -E $< -o $@ \
	$($(strip $<)_CFLAGS)

$(OUTPUT_DIR)/%.s: %.c
	@echo AS: $(subst $(OUTPUT_DIR)/,, $@)
	@mkdir -p $(@D)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) -S $< -o $@ \
	$($(strip $<)_CFLAGS)
