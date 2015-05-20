OPENCM3_DIR ?= lib/libopencm3

INCLUDES	+= $(OPENCM3_DIR)/include
LIBS		+= $(OPENCM3_LIB) c gcc nosys

LDFLAGS		+= -L$(OPENCM3_DIR)/lib