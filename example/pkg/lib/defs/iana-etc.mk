IANA_ETC_NAME := iana-etc
IANA_ETC_VERSION := 20190219-1
IANA_ETC_DESCRIPTION := /etc/protocols and /etc/services provided by IANA

IANA_ETC_FILES = $(shell find $(CACHE_PATH)/$(IANA_ETC_NAME))
IANA_ETC_TARGET_FILES = $(IANA_ETC_FILES:$(CACHE_PATH)/$(IANA_ETC_NAME)%=$(TARGET_PATH)%)

.PHONY: $(TARGETS:%=%_$(IANA_ETC_NAME))

sync_nodeps_$(IANA_ETC_NAME):
	mkdir -p $(CACHE_PATH)/$(IANA_ETC_NAME)
	rsync -az --delete $(SOURCE_PREFIX)/cache/$(IANA_ETC_NAME)/$(IANA_ETC_VERSION)/ $(CACHE_PATH)/$(IANA_ETC_NAME)

sync_$(IANA_ETC_NAME): $(IANA_ETC_DEPENDENCIES:%=sync_%) sync_nodeps_$(IANA_ETC_NAME)

copy_nodeps_$(IANA_ETC_NAME):
	rsync -a $(CACHE_PATH)/$(IANA_ETC_NAME)/ $(TARGET_PATH)

copy_$(IANA_ETC_NAME): $(IANA_ETC_DEPENDENCIES:%=copy_%) copy_nodeps_$(IANA_ETC_NAME)

ifdef IANA_ETC_CONFLICTS
install_$(IANA_ETC_NAME):
	@echo "error: installation of $(IANA_ETC_NAME) would conflict with the following already installed packages: $(IANA_ETC_CONFLICTS)"
	@exit 2
else
install_$(IANA_ETC_NAME): $(IANA_ETC_DEPENDENCIES:%=install_%) sync_$(IANA_ETC_NAME) copy_$(IANA_ETC_NAME)
	: >$(LIB_PATH)/installed/$(IANA_ETC_NAME)
	echo "NAME=$(IANA_ETC_NAME)" >> $(LIB_PATH)/installed/$(IANA_ETC_NAME)
	echo "VERSION=$(IANA_ETC_VERSION)" >> $(LIB_PATH)/installed/$(IANA_ETC_NAME)
	echo "DESCRIPTION=$(IANA_ETC_DESCRIPTION)" >> $(LIB_PATH)/installed/$(IANA_ETC_NAME)
	echo "DEPENDENCIES=($(IANA_ETC_DEPENDENCIES))" >> $(LIB_PATH)/installed/$(IANA_ETC_NAME)
	echo "DEPENDANTS=($(IANA_ETC_DEPENDANTS))" >> $(LIB_PATH)/installed/$(IANA_ETC_NAME)
	echo "CONFLICTS=($(IANA_ETC_CONFLICTS))" >> $(LIB_PATH)/installed/$(IANA_ETC_NAME)
	echo "FILES=($(IANA_ETC_TARGET_FILES))" >> $(LIB_PATH)/installed/$(IANA_ETC_NAME)
	echo "LAST_UPGRADE_DATE=$$(date -Iseconds)" >> $(LIB_PATH)/installed/$(IANA_ETC_NAME)
endif

remove_$(IANA_ETC_NAME):
	rm -f $(IANA_ETC_TARGET_FILES)

uninstall_cascade_$(IANA_ETC_NAME): $(IANA_ETC_DEPENDANTS:%=uninstall_cascade_%) remove_$(IANA_ETC_NAME)

ifdef IANA_ETC_DEPENDANTS
uninstall_$(IANA_ETC_NAME):
	@echo "error: uninstallation of $(IANA_ETC_NAME) would break the following packages which depend on it: $(IANA_ETC_DEPENDANTS)"
	@exit 1
else
uninstall_$(IANA_ETC_NAME): uninstall_cascade_$(IANA_ETC_NAME)
	rm -f $(LIB_PATH)/installed/$(IANA_ETC_NAME)
endif