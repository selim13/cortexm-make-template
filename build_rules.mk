# Main build rules for Cortex-M microcontrollers

###
# Tools
PREFIX	?= arm-none-eabi

CC      = $(PREFIX)-gcc
CXX		= $(PREFIX)-g++
AS      = $(PREFIX)-as
SIZE    = $(PREFIX)-size
OBJCOPY = $(PREFIX)-objcopy
OBJDUMP = $(PREFIX)-objdump
NM      = $(PREFIX)-nm
GDB     = $(PREFIX)-gdb
RM		= rm

###
# Main directory with sources
SRC_DIR		?= src

# Directory for buid files
TARGET_DIR	?= target

# Directories to search for header files
INCLUDES += $(SRC_DIR)

# Search paths for c sources, headers and asm files (for make)
vpath %.s $(SRC_DIR)
vpath %.S $(SRC_DIR)
vpath %.c $(SRC_DIR)
vpath %.cpp $(SRC_DIR)
vpath %.h $(INCLUDES)
vpath %.elf $(TARGET_DIR) 

###
OPT		 ?= -Os

# Assembler options
ASFLAGS  = -D__ASSEMBLY__
ASFLAGS += -g 

# C compiler options
CFLAGS += -std=c11
CFLAGS += -Wmissing-prototypes -Wstrict-prototypes

# C++ flags (currently untested)
CXXFLAGS := -Wmissing-declarations

# Common C/C++ flags
CPPFLAGS += $(OPT)
CPPFLAGS += -g -MMD
CPPFLAGS += -Wall -Wextra -Wshadow -Wundef -Wredundant-decls
CPPFLAGS += -fno-common -fdata-sections -ffunction-sections
CPPFLAGS += $(addprefix -I,$(INCLUDES)) # pass includes as -I flags

# Linker flags
LDFLAGS += --static
LDFLAGS += -nostdlib -nostartfiles
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,-Map=$(TARGET_DIR)/$(BIN).map
LDFLAGS += -T$(LINKER_SCRIPT)

###
# Generate object and dependency file names
# Assembler source files
ASMOBJ := $(addprefix $(TARGET_DIR)/,$(SRC:%.s=%.o))
# Assembler source files which must be preprocessed	
PREASMOBJ := $(addprefix $(TARGET_DIR)/,$(SRC:%.S=%.o))
# C source files
COBJ := $(patsubst %.c,$(TARGET_DIR)/%.o,$(SRC))
CDEPS := $(patsubst %.c,$(TARGET_DIR)/%.d,$(SRC))
# C++ source files
CPPOBJ := $(patsubst %.cpp,$(TARGET_DIR)/%.o,$(SRC))
CPPDEPS := $(patsubst %.cpp,$(TARGET_DIR)/%.d,$(SRC))

# Combine
OBJ := $(filter %.o,$(ASMOBJ) $(PREASMOBJ) $(COBJ) $(CPPOBJ))
DEPS := $(filter %.d,$(CDEPS) $(CPPDEPS))

LDLIBS := $(addprefix -l,$(LIBS)) 

###
# Build targets
all: elf bin srec hex lss sym

elf: $(TARGET_DIR)/$(BIN).elf
bin: $(TARGET_DIR)/$(BIN).bin
hex: $(TARGET_DIR)/$(BIN).hex
srec: $(TARGET_DIR)/$(BIN).srec
lss: $(TARGET_DIR)/$(BIN).lss
sym: $(TARGET_DIR)/$(BIN).sym

$(TARGET_DIR)/$(BIN).elf: $(ASM_OBJ) $(OBJ)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@
	$(SIZE) -B $@
	
$(TARGET_DIR)/%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

$(TARGET_DIR)/%.hex: %.elf
	$(OBJCOPY) -O ihex $< $@
	
$(TARGET_DIR)/%.srec: %.elf
	$(OBJCOPY) -O srec $< $@

$(TARGET_DIR)/%.lss: %.elf
	$(OBJDUMP) -h -S -z $< > $@

$(TARGET_DIR)/%.sym: %.elf
	$(NM) -n $< > $@


$(TARGET_DIR)/%.o: %.s
	$(CC) $(ASFLAGS) -c $< -o $@

$(TARGET_DIR)/%.o: %.S
	$(CC) $(ASFLAGS) -c $< -o $@

$(TARGET_DIR)/%.o: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(TARGET_DIR)/%.o: %.cpp
	$(CXX) $(CFLAGS) $(CPPFLAGS) -c $< -o $@
	

-include $(DEPS)

clean:
	$(RM) -f $(OBJ) $(DEPS)	$(TARGET_DIR)/$(BIN).elf $(TARGET_DIR)/$(BIN).map $(TARGET_DIR)/$(BIN).bin $(TARGET_DIR)/$(BIN).hex $(TARGET_DIR)/$(BIN).srec $(TARGET_DIR)/$(BIN).lss $(TARGET_DIR)/$(BIN).sym

.PHONY: clean