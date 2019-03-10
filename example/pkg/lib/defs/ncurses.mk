NCURSES_NAME := ncurses
NCURSES_VERSION := 6.1-6
NCURSES_DESCRIPTION := System V Release 4.0 curses emulation library
NCURSES_DEPENDENCIES := gcc-libs glibc

GCC_LIBS_DEPENDANTS += $(NCURSES_NAME)
GLIBC_DEPENDANTS += $(NCURSES_NAME)

NCURSES_FILES = $(shell find $(CACHE_PATH)/$(NCURSES_NAME))
NCURSES_TARGET_FILES = $(NCURSES_FILES:$(CACHE_PATH)/$(NCURSES_NAME)%=$(TARGET_PATH)%)

.PHONY: $(TARGETS:%=%_$(NCURSES_NAME))

sync_nodeps_$(NCURSES_NAME):
	mkdir -p $(CACHE_PATH)/$(NCURSES_NAME)
	rsync -az --delete $(SOURCE_PREFIX)/cache/$(NCURSES_NAME)/$(NCURSES_VERSION)/ $(CACHE_PATH)/$(NCURSES_NAME)

sync_$(NCURSES_NAME): $(NCURSES_DEPENDENCIES:%=sync_%) sync_nodeps_$(NCURSES_NAME)

copy_nodeps_$(NCURSES_NAME):
	rsync -a $(CACHE_PATH)/$(NCURSES_NAME)/ $(TARGET_PATH)

copy_$(NCURSES_NAME): $(NCURSES_DEPENDENCIES:%=copy_%) copy_nodeps_$(NCURSES_NAME)

ifdef NCURSES_CONFLICTS
install_$(NCURSES_NAME):
	@echo "error: installation of $(NCURSES_NAME) would conflict with the following already installed packages: $(NCURSES_CONFLICTS)"
	@exit 2
else
install_$(NCURSES_NAME): $(NCURSES_DEPENDENCIES:%=install_%) sync_$(NCURSES_NAME) copy_$(NCURSES_NAME)
	: >$(LIB_PATH)/installed/$(NCURSES_NAME)
	echo "NAME=$(NCURSES_NAME)" >> $(LIB_PATH)/installed/$(NCURSES_NAME)
	echo "VERSION=$(NCURSES_VERSION)" >> $(LIB_PATH)/installed/$(NCURSES_NAME)
	echo "DESCRIPTION=$(NCURSES_DESCRIPTION)" >> $(LIB_PATH)/installed/$(NCURSES_NAME)
	echo "DEPENDENCIES=($(NCURSES_DEPENDENCIES))" >> $(LIB_PATH)/installed/$(NCURSES_NAME)
	echo "DEPENDANTS=($(NCURSES_DEPENDANTS))" >> $(LIB_PATH)/installed/$(NCURSES_NAME)
	echo "CONFLICTS=($(NCURSES_CONFLICTS))" >> $(LIB_PATH)/installed/$(NCURSES_NAME)
	echo "FILES=($(NCURSES_TARGET_FILES))" >> $(LIB_PATH)/installed/$(NCURSES_NAME)
	echo "LAST_UPGRADE_DATE=$$(date -Iseconds)" >> $(LIB_PATH)/installed/$(NCURSES_NAME)
endif

remove_$(NCURSES_NAME):
	rm -f $(NCURSES_TARGET_FILES)

uninstall_cascade_$(NCURSES_NAME): $(NCURSES_DEPENDANTS:%=uninstall_cascade_%) remove_$(NCURSES_NAME)

ifdef NCURSES_DEPENDANTS
uninstall_$(NCURSES_NAME):
	@echo "error: uninstallation of $(NCURSES_NAME) would break the following packages which depend on it: $(NCURSES_DEPENDANTS)"
	@exit 1
else
uninstall_$(NCURSES_NAME): uninstall_cascade_$(NCURSES_NAME)
	rm -f $(LIB_PATH)/installed/$(NCURSES_NAME)
endif