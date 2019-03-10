BASH_NAME := bash
BASH_VERSION := 5.0.0-1
BASH_DESCRIPTION := The GNU Bourne Again shell
BASH_DEPENDENCIES := glibc ncurses readline

GLIBC_DEPENDANTS += $(BASH_NAME)
NCURSES_DEPENDANTS += $(BASH_NAME)
READLINE_DEPENDANTS += $(BASH_NAME)

BASH_FILES = $(shell find $(CACHE_PATH)/$(BASH_NAME))
BASH_TARGET_FILES = $(BASH_FILES:$(CACHE_PATH)/$(BASH_NAME)%=$(TARGET_PATH)%)

.PHONY: $(TARGETS:%=%_$(BASH_NAME))

sync_nodeps_$(BASH_NAME):
	mkdir -p $(CACHE_PATH)/$(BASH_NAME)
	rsync -az --delete $(SOURCE_PREFIX)/cache/$(BASH_NAME)/$(BASH_VERSION)/ $(CACHE_PATH)/$(BASH_NAME)

sync_$(BASH_NAME): $(BASH_DEPENDENCIES:%=sync_%) sync_nodeps_$(BASH_NAME)

copy_nodeps_$(BASH_NAME):
	rsync -a $(CACHE_PATH)/$(BASH_NAME)/ $(TARGET_PATH)

copy_$(BASH_NAME): $(BASH_DEPENDENCIES:%=copy_%) copy_nodeps_$(BASH_NAME)

ifdef BASH_CONFLICTS
install_$(BASH_NAME):
	@echo "error: installation of $(BASH_NAME) would conflict with the following already installed packages: $(BASH_CONFLICTS)"
	@exit 2
else
install_$(BASH_NAME): $(BASH_DEPENDENCIES:%=install_%) sync_$(BASH_NAME) copy_$(BASH_NAME)
	: >$(LIB_PATH)/installed/$(BASH_NAME)
	echo "NAME=$(BASH_NAME)" >> $(LIB_PATH)/installed/$(BASH_NAME)
	echo "VERSION=$(BASH_VERSION)" >> $(LIB_PATH)/installed/$(BASH_NAME)
	echo "DESCRIPTION=$(BASH_DESCRIPTION)" >> $(LIB_PATH)/installed/$(BASH_NAME)
	echo "DEPENDENCIES=($(BASH_DEPENDENCIES))" >> $(LIB_PATH)/installed/$(BASH_NAME)
	echo "DEPENDANTS=($(BASH_DEPENDANTS))" >> $(LIB_PATH)/installed/$(BASH_NAME)
	echo "CONFLICTS=($(BASH_CONFLICTS))" >> $(LIB_PATH)/installed/$(BASH_NAME)
	echo "FILES=($(BASH_TARGET_FILES))" >> $(LIB_PATH)/installed/$(BASH_NAME)
	echo "LAST_UPGRADE_DATE=$$(date -Iseconds)" >> $(LIB_PATH)/installed/$(BASH_NAME)
endif

remove_$(BASH_NAME):
	rm -f $(BASH_TARGET_FILES)

uninstall_cascade_$(BASH_NAME): $(BASH_DEPENDANTS:%=uninstall_cascade_%) remove_$(BASH_NAME)

ifdef BASH_DEPENDANTS
uninstall_$(BASH_NAME):
	@echo "error: uninstallation of $(BASH_NAME) would break the following packages which depend on it: $(BASH_DEPENDANTS)"
	@exit 1
else
uninstall_$(BASH_NAME): uninstall_cascade_$(BASH_NAME)
	rm -f $(LIB_PATH)/installed/$(BASH_NAME)
endif