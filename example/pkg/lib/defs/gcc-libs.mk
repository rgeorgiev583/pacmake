GCC_LIBS_NAME := gcc-libs
GCC_LIBS_VERSION := 8.2.1+20181127-1
GCC_LIBS_DESCRIPTION := Runtime libraries shipped by GCC
GCC_LIBS_DEPENDENCIES := glibc

GLIBC_DEPENDANTS += $(GCC_LIBS_NAME)

GCC_LIBS_FILES = $(shell find $(CACHE_PATH)/$(GCC_LIBS_NAME))
GCC_LIBS_TARGET_FILES = $(GCC_LIBS_FILES:$(CACHE_PATH)/$(GCC_LIBS_NAME)%=$(TARGET_PATH)%)

.PHONY: $(TARGETS:%=%_$(GCC_LIBS_NAME))

sync_nodeps_$(GCC_LIBS_NAME):
	mkdir -p $(CACHE_PATH)/$(GCC_LIBS_NAME)
	rsync -az --delete $(SOURCE_PREFIX)/cache/$(GCC_LIBS_NAME)/$(GCC_LIBS_VERSION)/ $(CACHE_PATH)/$(GCC_LIBS_NAME)

sync_$(GCC_LIBS_NAME): $(GCC_LIBS_DEPENDENCIES:%=sync_%) sync_nodeps_$(GCC_LIBS_NAME)

copy_nodeps_$(GCC_LIBS_NAME):
	rsync -a $(CACHE_PATH)/$(GCC_LIBS_NAME)/ $(TARGET_PATH)

copy_$(GCC_LIBS_NAME): $(GCC_LIBS_DEPENDENCIES:%=copy_%) copy_nodeps_$(GCC_LIBS_NAME)

ifdef GCC_LIBS_CONFLICTS
install_$(GCC_LIBS_NAME):
	@echo "error: installation of $(GCC_LIBS_NAME) would conflict with the following already installed packages: $(GCC_LIBS_CONFLICTS)"
	@exit 2
else
install_$(GCC_LIBS_NAME): $(GCC_LIBS_DEPENDENCIES:%=install_%) sync_$(GCC_LIBS_NAME) copy_$(GCC_LIBS_NAME)
	: >$(LIB_PATH)/installed/$(GCC_LIBS_NAME)
	echo "NAME=$(GCC_LIBS_NAME)" >> $(LIB_PATH)/installed/$(GCC_LIBS_NAME)
	echo "VERSION=$(GCC_LIBS_VERSION)" >> $(LIB_PATH)/installed/$(GCC_LIBS_NAME)
	echo "DESCRIPTION=$(GCC_LIBS_DESCRIPTION)" >> $(LIB_PATH)/installed/$(GCC_LIBS_NAME)
	echo "DEPENDENCIES=($(GCC_LIBS_DEPENDENCIES))" >> $(LIB_PATH)/installed/$(GCC_LIBS_NAME)
	echo "DEPENDANTS=($(GCC_LIBS_DEPENDANTS))" >> $(LIB_PATH)/installed/$(GCC_LIBS_NAME)
	echo "CONFLICTS=($(GCC_LIBS_CONFLICTS))" >> $(LIB_PATH)/installed/$(GCC_LIBS_NAME)
	echo "FILES=($(GCC_LIBS_TARGET_FILES))" >> $(LIB_PATH)/installed/$(GCC_LIBS_NAME)
	echo "LAST_UPGRADE_DATE=$$(date -Iseconds)" >> $(LIB_PATH)/installed/$(GCC_LIBS_NAME)
endif

remove_$(GCC_LIBS_NAME):
	rm -f $(GCC_LIBS_TARGET_FILES)

uninstall_cascade_$(GCC_LIBS_NAME): $(GCC_LIBS_DEPENDANTS:%=uninstall_cascade_%) remove_$(GCC_LIBS_NAME)

ifdef GCC_LIBS_DEPENDANTS
uninstall_$(GCC_LIBS_NAME):
	@echo "error: uninstallation of $(GCC_LIBS_NAME) would break the following packages which depend on it: $(GCC_LIBS_DEPENDANTS)"
	@exit 1
else
uninstall_$(GCC_LIBS_NAME): uninstall_cascade_$(GCC_LIBS_NAME)
	rm -f $(LIB_PATH)/installed/$(GCC_LIBS_NAME)
endif