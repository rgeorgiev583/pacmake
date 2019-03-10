GLIBC_NAME := glibc
GLIBC_VERSION := 2.28-5
GLIBC_DESCRIPTION := GNU C Library
GLIBC_DEPENDENCIES := filesystem linux-api-headers tzdata

FILESYSTEM_DEPENDANTS += $(GLIBC_NAME)
LINUX_API_HEADERS_DEPENDANTS += $(GLIBC_NAME)
TZDATA_DEPENDANTS += $(GLIBC_NAME)

GLIBC_FILES = $(shell find $(CACHE_PATH)/$(GLIBC_NAME))
GLIBC_TARGET_FILES = $(GLIBC_FILES:$(CACHE_PATH)/$(GLIBC_NAME)%=$(TARGET_PATH)%)

.PHONY: $(TARGETS:%=%_$(GLIBC_NAME))

sync_nodeps_$(GLIBC_NAME):
	mkdir -p $(CACHE_PATH)/$(GLIBC_NAME)
	rsync -az --delete $(SOURCE_PREFIX)/cache/$(GLIBC_NAME)/$(GLIBC_VERSION)/ $(CACHE_PATH)/$(GLIBC_NAME)

sync_$(GLIBC_NAME): $(GLIBC_DEPENDENCIES:%=sync_%) sync_nodeps_$(GLIBC_NAME)

copy_nodeps_$(GLIBC_NAME):
	rsync -a $(CACHE_PATH)/$(GLIBC_NAME)/ $(TARGET_PATH)

copy_$(GLIBC_NAME): $(GLIBC_DEPENDENCIES:%=copy_%) copy_nodeps_$(GLIBC_NAME)

ifdef GLIBC_CONFLICTS
install_$(GLIBC_NAME):
	@echo "error: installation of $(GLIBC_NAME) would conflict with the following already installed packages: $(GLIBC_CONFLICTS)"
	@exit 2
else
install_$(GLIBC_NAME): $(GLIBC_DEPENDENCIES:%=install_%) sync_$(GLIBC_NAME) copy_$(GLIBC_NAME)
	: >$(LIB_PATH)/installed/$(GLIBC_NAME)
	echo "NAME=$(GLIBC_NAME)" >> $(LIB_PATH)/installed/$(GLIBC_NAME)
	echo "VERSION=$(GLIBC_VERSION)" >> $(LIB_PATH)/installed/$(GLIBC_NAME)
	echo "DESCRIPTION=$(GLIBC_DESCRIPTION)" >> $(LIB_PATH)/installed/$(GLIBC_NAME)
	echo "DEPENDENCIES=($(GLIBC_DEPENDENCIES))" >> $(LIB_PATH)/installed/$(GLIBC_NAME)
	echo "DEPENDANTS=($(GLIBC_DEPENDANTS))" >> $(LIB_PATH)/installed/$(GLIBC_NAME)
	echo "CONFLICTS=($(GLIBC_CONFLICTS))" >> $(LIB_PATH)/installed/$(GLIBC_NAME)
	echo "FILES=($(GLIBC_TARGET_FILES))" >> $(LIB_PATH)/installed/$(GLIBC_NAME)
	echo "LAST_UPGRADE_DATE=$$(date -Iseconds)" >> $(LIB_PATH)/installed/$(GLIBC_NAME)
endif

remove_$(GLIBC_NAME):
	rm -f $(GLIBC_TARGET_FILES)

uninstall_cascade_$(GLIBC_NAME): $(GLIBC_DEPENDANTS:%=uninstall_cascade_%) remove_$(GLIBC_NAME)

ifdef GLIBC_DEPENDANTS
uninstall_$(GLIBC_NAME):
	@echo "error: uninstallation of $(GLIBC_NAME) would break the following packages which depend on it: $(GLIBC_DEPENDANTS)"
	@exit 1
else
uninstall_$(GLIBC_NAME): uninstall_cascade_$(GLIBC_NAME)
	rm -f $(LIB_PATH)/installed/$(GLIBC_NAME)
endif