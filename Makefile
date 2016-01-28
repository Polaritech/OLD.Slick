# Slick Project Main Makefile
# Builds all dependent projects

#=====================================================================#
# Define First Target                                                 #
#=====================================================================#
.PHONY: all check clean install
all:

#=====================================================================#
# Disable Builtin Rules                                               #
#=====================================================================#
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

#=====================================================================#
# Tools                                                               #
#=====================================================================#

# To change the C Compiler, change this value.
CC := x86_64-elf-gcc-5.3.0
# To change the C++ Compiler, change this value.
CXX := x86_64-elf-g++-5.3.0
# To change the Linker, change this value.
LD := x86_64-elf-ld-2.26
# To change the Assembler, change this value.
AS := nasm

RM := rm -rf
MKDIR := mkdir -p
TR := tr
FIND := find

BUILD.o.c = $(CC) $(CPPFLAGS) $(CFLAGS) -c
BUILD.o.cpp = $(CXX) $(CPPFLAGS) $(CXXFLAGS) -c
BUILD.o.asm = $(AS) $(ASFLAGS)
OUTPUT.file = -o $@

MODULES := $(shell $(FIND) Projects/* -maxdepth 0 -type d | sed 's/Projects\///g')

#=====================================================================#
# Macros                                                              #
#=====================================================================#
define get_files
vpath
vpath %.c Projects/$1/Source
vpath %.cpp Projects/$1/Source
vpath %.asm Projects/$1/Source
OBJ_C := $(addprefix Build/Objects/$1/,$(patsubst %.c,%.o,$(shell find Projects/$1/Source -type f -name '*.c' | sed 's/Projects\/$1\/Source\///g')))
OBJ_CPP := $(addprefix Build/Objects/$1/,$(patsubst %.cpp,%.o,$(shell find Projects/$1/Source -type f -name '*.cpp' | sed 's/Projects\/$1\/Source\///g')))
OBJ_ASM := $(addprefix Build/Objects/$1/,$(patsubst %.asm,%.o,$(shell find Projects/$1/Source -type f -name '*.asm' | sed 's/Projects\/$1\/Source\///g')))
OBJ_$(1) := $$(OBJ_C) $$(OBJ_CPP) $$(OBJ_ASM)
endef

define get_rules
Build/Objects/$(1)/%.o: %.c
	@$$(MKDIR) $$(@D)
	@$$(BUILD.o.c) $$(OUTPUT.file) $$<
Build/Objects/$(1)/%.c: %.cpp
	@$$(MKDIR) $$(@D)
	@$$(BUILD.o.cpp) $$(OUTPUT.file) $$<
Build/Objects/$(1)/%.o: %.asm
	@$$(MKDIR) $$(@D)
	@$$(BUILD.o.asm) $$(OUTPUT.file) $$<
endef

define make_target
include Projects/$1/module.mk
$(eval $(call get_files,$1))
$(eval $(call get_rules,$1))
PHONY: $1
$1: Build/Binaries/$$($1.Target)
#Build/Binaries/$$($1.Target): $$(OBJ_$1)
#	@cat $$< > $$@
#	@$$(CC) -T Projects/$1/linker.ld -o $$@ -ffreestanding -O2 -nostdlib $$< -lgcc
#include Projects/$1/replacerules.mk
endef

$(foreach module,$(MODULES),$(eval $(call make_target,$(module))))

all: $(MODULES)

check:

clean:
	@$(RM) Build/Objects/* Build/Libraries/* Build/Binaries/*

install: