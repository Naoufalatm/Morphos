##
# Project Nawmoj
#
# @file
# @version 0.1

# CC=gcc
# CFLAGS=-I
# DEBUGFLAGS=-g
# FILE=main.c src/thread.c src/scheduler.c src/fallback.c src/run_script.c

# all:
# 	$(CC) $(DEBUGFLAGS) -o output.elf $(FILE)

# run: all
# 	./output.elf



# Compiler and tool settings
CC = gcc
AR = ar
CFLAGS = -fPIC -Wall -Wextra -O2 -pthread
LDFLAGS = -shared -pthread

# Version information
MAJOR_VERSION = 1
MINOR_VERSION = 0
PATCH_VERSION = 0
VERSION = $(MAJOR_VERSION).$(MINOR_VERSION).$(PATCH_VERSION)

# Directory structure
SRC_DIR = src
INC_DIR = include
LIB_DIR = lib
BUILD_DIR = build
TEST_DIR = tests
DOC_DIR = docs

# Library names
LIB_NAME = libobzruntime
STATIC_LIB = $(LIB_DIR)/$(LIB_NAME).a
SHARED_LIB = $(LIB_DIR)/$(LIB_NAME).so.$(VERSION)
SONAME = $(LIB_NAME).so.$(MAJOR_VERSION)

# Source files organization (add your modules)
CORE_SRCS = $(wildcard $(SRC_DIR)/*.c)

# Combine all sources
ALL_SRCS = $(CORE_SRCS)
OBJS = $(ALL_SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)

# Include paths for all subdirectories
INCLUDE_PATHS = $(shell find $(INC_DIR) -type d)
INCLUDES = $(INCLUDE_PATHS:%=-I%)

# Default target
all: directories $(SHARED_LIB) $(STATIC_LIB)

# Create necessary directories
directories:
	mkdir -p $(BUILD_DIR)/
	mkdir -p $(LIB_DIR)

# Pattern rule for object files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

# Create shared library
$(SHARED_LIB): $(OBJS)
	$(CC) $(LDFLAGS) -Wl,-soname,$(SONAME) -o $@ $^
	cd $(LIB_DIR) && ln -sf $(LIB_NAME).so.$(VERSION) $(LIB_NAME).so
	cd $(LIB_DIR) && ln -sf $(LIB_NAME).so.$(VERSION) $(SONAME)

# Create static library
$(STATIC_LIB): $(OBJS)
	$(AR) rcs $@ $^

# Example program
example: example.c $(SHARED_LIB)
	$(CC) -o $@ $< -L$(LIB_DIR) -l$(LIB_NAME:lib%=%) -Wl,-rpath,$(shell pwd)/$(LIB_DIR)

# Generate documentation (if you use doxygen)
docs:
	doxygen Doxyfile

clean:
	rm -rf ./build ./lib

.PHONY: all example
