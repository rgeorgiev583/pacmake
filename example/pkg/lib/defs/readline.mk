READLINE_NAME := readline
READLINE_VERSION := 8.0.0-1
READLINE_DESCRIPTION := GNU readline library
READLINE_DEPENDENCIES := glibc ncurses

GLIBC_DEPENDANTS += $(READLINE_NAME)
NCURSES_DEPENDANTS += $(READLINE_NAME)

READLINE_FILES = $(shell find $(CACHE_PATH)/$(READLINE_NAME))
READLINE_TARGET_FILES = $(READLINE_FILES:$(CACHE_PATH)/$(READLINE_NAME)%=$(TARGET_PATH)%)

.PHONY: $(TARGETS:%=%_$(READLINE_NAME))

sync_nodeps_$(READLINE_NAME):
	mkdir -p $(CACHE_PATH)/$(READLINE_NAME)
	rsync -az --delete $(SOURCE_PREFIX)/cache/$(READLINE_NAME)/$(READLINE_VERSION)/ $(CACHE_PATH)/$(READLINE_NAME)

sync_$(READLINE_NAME): $(READLINE_DEPENDENCIES:%=sync_%) sync_nodeps_$(READLINE_NAME)

copy_nodeps_$(READLINE_NAME):
	rsync -a $(CACHE_PATH)/$(READLINE_NAME)/ $(TARGET_PATH)

copy_$(READLINE_NAME): $(READLINE_DEPENDENCIES:%=copy_%) copy_nodeps_$(READLINE_NAME)

ifdef READLINE_CONFLICTS
install_$(READLINE_NAME):
	@echo "error: installation of $(READLINE_NAME) would conflict with the following already installed packages: $(READLINE_CONFLICTS)"
	@exit 2
else
install_$(READLINE_NAME): $(READLINE_DEPENDENCIES:%=install_%) sync_$(READLINE_NAME) copy_$(READLINE_NAME)
	: >$(LIB_PATH)/installed/$(READLINE_NAME)
	echo "NAME=$(READLINE_NAME)" >> $(LIB_PATH)/installed/$(READLINE_NAME)
	echo "VERSION=$(READLINE_VERSION)" >> $(LIB_PATH)/installed/$(READLINE_NAME)
	echo "DESCRIPTION=$(READLINE_DESCRIPTION)" >> $(LIB_PATH)/installed/$(READLINE_NAME)
	echo "DEPENDENCIES=($(READLINE_DEPENDENCIES))" >> $(LIB_PATH)/installed/$(READLINE_NAME)
	echo "DEPENDANTS=($(READLINE_DEPENDANTS))" >> $(LIB_PATH)/installed/$(READLINE_NAME)
	echo "CONFLICTS=($(READLINE_CONFLICTS))" >> $(LIB_PATH)/installed/$(READLINE_NAME)
	echo "FILES=($(READLINE_TARGET_FILES))" >> $(LIB_PATH)/installed/$(READLINE_NAME)
	echo "LAST_UPGRADE_DATE=$$(date -Iseconds)" >> $(LIB_PATH)/installed/$(READLINE_NAME)
endif

remove_$(READLINE_NAME):
	rm -f $(READLINE_TARGET_FILES)

uninstall_cascade_$(READLINE_NAME): $(READLINE_DEPENDANTS:%=uninstall_cascade_%) remove_$(READLINE_NAME)

ifdef READLINE_DEPENDANTS
uninstall_$(READLINE_NAME):
	@echo "error: uninstallation of $(READLINE_NAME) would break the following packages which depend on it: $(READLINE_DEPENDANTS)"
	@exit 1
else
uninstall_$(READLINE_NAME): uninstall_cascade_$(READLINE_NAME)
	rm -f $(LIB_PATH)/installed/$(READLINE_NAME)
endif