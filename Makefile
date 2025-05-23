# ------------------------------------------------------------------------------
# Common
# ------------------------------------------------------------------------------

include common.mk

# ------------------------------------------------------------------------------
# Paths
# ------------------------------------------------------------------------------

OUT_PATH             := out
OUT_PATH_EXISTS      := $(wildcard $(OUT_PATH))
SRC_PATH             := src
INCLUDE_PATH         := include
BUILD_PATH           := $(OUT_PATH)/build

# ------------------------------------------------------------------------------
# Files
# ------------------------------------------------------------------------------

SRC                  := $(wildcard $(SRC_PATH)/*.asm)
OBJ                  := $(patsubst $(SRC_PATH)/%.asm,$(BUILD_PATH)/%.o,$(SRC))
DEPEND               := $(patsubst %.o,%.d,$(OBJ))
OUT                  := $(OUT_PATH)/violetmd.bin
SYM                  := $(patsubst $(OUT_PATH)/%.bin,$(BUILD_PATH)/%.sym,$(OUT))
EXPORT               := $(patsubst %.bin,%.inc,$(OUT))

# ------------------------------------------------------------------------------
# Tool flags
# ------------------------------------------------------------------------------

VASM_FLAGS           := $(VASM_FLAGS) -I$(INCLUDE_PATH)
VLINK_FLAGS          := $(VLINK_FLAGS) -symctrl=4 -T linker.link -symfile $(SYM)
MKASMDEP_FLAGS       := $(MKASMDEP_FLAGS) -i $(INCLUDE_PATH)
DUMPASMSYM_FLAGS     := $(DUMPASMSYM_FLAGS) -f VioletMd -xp XREF_

# ------------------------------------------------------------------------------
# Reserved rules
# ------------------------------------------------------------------------------

.PHONY: all clean

# ------------------------------------------------------------------------------
# Make all
# ------------------------------------------------------------------------------

all: $(OUT) $(EXPORT)

# ------------------------------------------------------------------------------
# Clean
# ------------------------------------------------------------------------------

clean:
ifneq ($(OUT_PATH_EXISTS),)
	@$(RMDIR) "$(OUT_PATH)"
endif

# ------------------------------------------------------------------------------
# Rules
# ------------------------------------------------------------------------------

$(EXPORT): $(SYM) | $(OUT_PATH) $(OUT)
	$(EXPORT_MSG)
	@$(DUMPASMSYM) $(DUMPASMSYM_FLAGS) -o $@ $^
	
$(OUT): $(OBJ) | $(OUT_PATH)
	$(LINK_MSG)
	@$(VLINK) $(VLINK_FLAGS) -o $@ $^

$(OBJ): $(BUILD_PATH)/%.o: $(SRC_PATH)/%.asm | $(BUILD_PATH) $(DEPEND)
	$(ASSEMBLE_MSG)
	@$(VASM) $(VASM_FLAGS) -L $(patsubst %.o,%.lst,$@) -o $@ $<

$(DEPEND): $(BUILD_PATH)/%.d: $(SRC_PATH)/%.asm | $(BUILD_PATH)
	$(DEPEND_MSG)
	@$(MKASMDEP) $(MKASMDEP_FLAGS) -o $@ $(patsubst %.d,%.o,$@) $<

# ------------------------------------------------------------------------------
# Path rules
# ------------------------------------------------------------------------------

$(OUT_PATH):
	@$(MKDIR) "$@"

$(BUILD_PATH):
	@$(MKDIR) "$@"

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------

ifneq (clean,$(filter clean,$(MAKECMDGOALS)))
-include $(DEPEND)
endif

# ------------------------------------------------------------------------------