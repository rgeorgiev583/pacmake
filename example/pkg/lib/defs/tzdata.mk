TZDATA_NAME := tzdata
TZDATA_VERSION := 2018i-1
TZDATA_DESCRIPTION := Sources for time zone and daylight saving time data

TZDATA_FILES = $(shell find $(CACHE_PATH)/$(TZDATA_NAME))
TZDATA_TARGET_FILES = $(TZDATA_FILES:$(CACHE_PATH)/$(TZDATA_NAME)%=$(TARGET_PATH)%)

.PHONY: $(TARGETS:%=%_$(TZDATA_NAME))

sync_nodeps_$(TZDATA_NAME):
	mkdir -p $(CACHE_PATH)/$(TZDATA_NAME)
	rsync -az --delete $(SOURCE_PREFIX)/cache/$(TZDATA_NAME)/$(TZDATA_VERSION)/ $(CACHE_PATH)/$(TZDATA_NAME)

sync_$(TZDATA_NAME): $(TZDATA_DEPENDENCIES:%=sync_%) sync_nodeps_$(TZDATA_NAME)

copy_nodeps_$(TZDATA_NAME):
	rsync -a $(CACHE_PATH)/$(TZDATA_NAME)/ $(TARGET_PATH)

copy_$(TZDATA_NAME): $(TZDATA_DEPENDENCIES:%=copy_%) copy_nodeps_$(TZDATA_NAME)

ifdef TZDATA_CONFLICTS
install_$(TZDATA_NAME):
	@echo "error: installation of $(TZDATA_NAME) would conflict with the following already installed packages: $(TZDATA_CONFLICTS)"
	@exit 2
else
install_$(TZDATA_NAME): $(TZDATA_DEPENDENCIES:%=install_%) sync_$(TZDATA_NAME) copy_$(TZDATA_NAME)
	: >$(LIB_PATH)/installed/$(TZDATA_NAME)
	echo "NAME=$(TZDATA_NAME)" >> $(LIB_PATH)/installed/$(TZDATA_NAME)
	echo "VERSION=$(TZDATA_VERSION)" >> $(LIB_PATH)/installed/$(TZDATA_NAME)
	echo "DESCRIPTION=$(TZDATA_DESCRIPTION)" >> $(LIB_PATH)/installed/$(TZDATA_NAME)
	echo "DEPENDENCIES=($(TZDATA_DEPENDENCIES))" >> $(LIB_PATH)/installed/$(TZDATA_NAME)
	echo "DEPENDANTS=($(TZDATA_DEPENDANTS))" >> $(LIB_PATH)/installed/$(TZDATA_NAME)
	echo "CONFLICTS=($(TZDATA_CONFLICTS))" >> $(LIB_PATH)/installed/$(TZDATA_NAME)
	echo "FILES=($(TZDATA_TARGET_FILES))" >> $(LIB_PATH)/installed/$(TZDATA_NAME)
	echo "LAST_UPGRADE_DATE=$$(date -Iseconds)" >> $(LIB_PATH)/installed/$(TZDATA_NAME)
endif

remove_$(TZDATA_NAME):
	rm -f $(TZDATA_TARGET_FILES)

uninstall_cascade_$(TZDATA_NAME): $(TZDATA_DEPENDANTS:%=uninstall_cascade_%) remove_$(TZDATA_NAME)

ifdef TZDATA_DEPENDANTS
uninstall_$(TZDATA_NAME):
	@echo "error: uninstallation of $(TZDATA_NAME) would break the following packages which depend on it: $(TZDATA_DEPENDANTS)"
	@exit 1
else
uninstall_$(TZDATA_NAME): uninstall_cascade_$(TZDATA_NAME)
	rm -f $(LIB_PATH)/installed/$(TZDATA_NAME)
endif