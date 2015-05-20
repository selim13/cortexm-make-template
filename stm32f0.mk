# Arch specific flags for STM32F0 series controllers

OPENCM3_LIB = opencm3_stm32f0

ASFLAGS += -mcpu=cortex-m0 -mthumb
CPPFLAGS += -DSTM32F0XX -DSTM32F0
CPPFLAGS += -mcpu=cortex-m0 -mthumb -msoft-float