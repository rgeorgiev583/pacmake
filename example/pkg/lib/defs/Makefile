TARGETS := sync_nodeps sync copy_nodeps copy install remove uninstall_cascade uninstall
PACKAGES := $(notdir $(wildcard $(LIB_PATH)/installed/*))

include *.mk

.PHONY: sync upgrade all

sync: $(PACKAGES:%=sync_%)

upgrade: $(PACKAGES:%=install_%)

all: upgrade