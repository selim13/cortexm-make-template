# Result program file
BIN := main

# Program sources (supports: .s, .S, .c and .cpp files)
SRC := main.c

# Linker script
LINKER_SCRIPT := stm32f0.ld

# Optimization level
OPT := -Os

include stm32f0.mk
include libopencm3.mk
include build_rules.mk 