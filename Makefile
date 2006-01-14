MOD := dsmod
PKG := callmonitor

MOD_LIST := $(patsubst conf.%, %, $(wildcard conf.*))
VERSION := $(shell cat .version)
NAME := $(PKG)-$(VERSION)
ARCHIVE := $(NAME)-$(MOD).tar.bz2
CONF := conf.$(MOD)
BUILD := build.$(MOD)
BNAME := $(BUILD)/$(NAME)
EXTRAS := README COPYING ChangeLog
ifneq (,$(wildcard install.$(MOD)))
EXTRAS += install.$(MOD)
endif

TAR := tar
TAR_OWNER := --owner=root --group=root

.PHONY: $(ARCHIVE) build clean check collect

build: $(ARCHIVE)

build-all:
	for mod in $(MOD_LIST); do $(MAKE) build MOD=$$mod; done

$(NAME)-dsmod.tar.bz2: collect
	$(TAR) cvjf $@ $(TAR_OWNER) -C $(BUILD) $(NAME) \
	    || (rm $@ && false)

$(NAME)-reload.tar.bz2: collect
	$(TAR) cvf $(BNAME)/$(NAME)-root.tar --format=oldgnu \
	    $(TAR_OWNER) -C $(BNAME)/root .
	rm -rf $(BNAME)/root
	$(TAR) cvjf $@ $(TAR_OWNER) -C $(BUILD) $(NAME) \
	    || (rm $@ && false)

collect: check
	rm -rf $(BNAME)
	mkdir -p $(BNAME)/root
	$(TAR) c --exclude=.svn -C base . -C ../$(CONF) . | \
	    $(TAR) x -C $(BNAME)/root
	$(TAR) c --exclude=.svn docs | $(TAR) x -C $(BNAME)
	echo $(VERSION) > $(BNAME)/root/etc/default.$(PKG)/.version
	echo $(MOD) > $(BNAME)/root/etc/default.$(PKG)/.subversion
	cp $(EXTRAS) $(BNAME)

check:
	@[ -d $(CONF) ] || (echo Configuration $(CONF) is missing; false)
	find base conf.* $(wildcard install.*) -name .svn -prune \
	    -or -type f -exec busybox ash -n {} \;

clean:
	-rm -f $(PKG)*.tar.bz2
	-rm -rf build.*
