FILESYSTEM_NAME := filesystem
FILESYSTEM_VERSION := 2018.12-2
FILESYSTEM_DESCRIPTION := Base files
FILESYSTEM_DEPENDENCIES := iana-etc

IANA_ETC_DEPENDANTS += $(FILESYSTEM_NAME)

FILESYSTEM_FILES = $(shell find $(CACHE_PATH)/$(FILESYSTEM_NAME))
FILESYSTEM_TARGET_FILES = $(FILESYSTEM_FILES:$(CACHE_PATH)/$(FILESYSTEM_NAME)%=$(TARGET_PATH)%)

.PHONY: $(TARGETS:%=%_$(FILESYSTEM_NAME))

sync_nodeps_$(FILESYSTEM_NAME):
	mkdir -p $(CACHE_PATH)/$(FILESYSTEM_NAME)
	rsync -az --delete $(SOURCE_PREFIX)/cache/$(FILESYSTEM_NAME)/$(FILESYSTEM_VERSION)/ $(CACHE_PATH)/$(FILESYSTEM_NAME)

sync_$(FILESYSTEM_NAME): $(FILESYSTEM_DEPENDENCIES:%=sync_%) sync_nodeps_$(FILESYSTEM_NAME)

copy_nodeps_$(FILESYSTEM_NAME):
	rsync -a $(CACHE_PATH)/$(FILESYSTEM_NAME)/ $(TARGET_PATH)

copy_$(FILESYSTEM_NAME): $(FILESYSTEM_DEPENDENCIES:%=copy_%) copy_nodeps_$(FILESYSTEM_NAME)

ifdef FILESYSTEM_CONFLICTS
install_$(FILESYSTEM_NAME):
	@echo "error: installation of $(FILESYSTEM_NAME) would conflict with the following already installed packages: $(FILESYSTEM_CONFLICTS)"
	@exit 2
else
install_$(FILESYSTEM_NAME): $(FILESYSTEM_DEPENDENCIES:%=install_%) sync_$(FILESYSTEM_NAME) copy_$(FILESYSTEM_NAME)
	: >$(LIB_PATH)/installed/$(FILESYSTEM_NAME)
	echo "NAME=$(FILESYSTEM_NAME)" >> $(LIB_PATH)/installed/$(FILESYSTEM_NAME)
	echo "VERSION=$(FILESYSTEM_VERSION)" >> $(LIB_PATH)/installed/$(FILESYSTEM_NAME)
	echo "DESCRIPTION=$(FILESYSTEM_DESCRIPTION)" >> $(LIB_PATH)/installed/$(FILESYSTEM_NAME)
	echo "DEPENDENCIES=($(FILESYSTEM_DEPENDENCIES))" >> $(LIB_PATH)/installed/$(FILESYSTEM_NAME)
	echo "DEPENDANTS=($(FILESYSTEM_DEPENDANTS))" >> $(LIB_PATH)/installed/$(FILESYSTEM_NAME)
	echo "CONFLICTS=($(FILESYSTEM_CONFLICTS))" >> $(LIB_PATH)/installed/$(FILESYSTEM_NAME)
	echo "FILES=($(FILESYSTEM_TARGET_FILES))" >> $(LIB_PATH)/installed/$(FILESYSTEM_NAME)
	echo "LAST_UPGRADE_DATE=$$(date -Iseconds)" >> $(LIB_PATH)/installed/$(FILESYSTEM_NAME)
endif

remove_$(FILESYSTEM_NAME):
	rm -f $(FILESYSTEM_TARGET_FILES)

uninstall_cascade_$(FILESYSTEM_NAME): $(FILESYSTEM_DEPENDANTS:%=uninstall_cascade_%) remove_$(FILESYSTEM_NAME)

ifdef FILESYSTEM_DEPENDANTS
uninstall_$(FILESYSTEM_NAME):
	@echo "error: uninstallation of $(FILESYSTEM_NAME) would break the following packages which depend on it: $(FILESYSTEM_DEPENDANTS)"
	@exit 1
else
uninstall_$(FILESYSTEM_NAME): uninstall_cascade_$(FILESYSTEM_NAME)
	rm -f $(LIB_PATH)/installed/$(FILESYSTEM_NAME)
endif