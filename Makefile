MOD := freetz
PKG := callmonitor

MOD_LIST := $(notdir $(wildcard mod/*))
VERSION := $(shell cat .version)
NAME := $(PKG)-$(VERSION)
ARCHIVE := $(NAME)-$(MOD).tar.bz2
CONF := mod/$(MOD)
BUILD := build/$(MOD)
BNAME := $(BUILD)/$(NAME)
EXTRAS := README COPYING ChangeLog

TAR := tar
TAR_OWNER := --owner=root --group=root
SHSTRIP := tools/shstrip

.PHONY: $(ARCHIVE) build clean check collect

build: $(ARCHIVE)

build-all:
	for mod in $(MOD_LIST); do $(MAKE) build MOD=$$mod; done

$(NAME)-$(MOD).tar.bz2: collect
	$(TAR) cjf $@ $(TAR_OWNER) -C $(BUILD) $(NAME) \
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
	$(TAR) c --exclude=.svn -C base . | $(TAR) x -C $(BNAME)/root
	$(TAR) c --exclude=.svn -C $(CONF) . |  $(TAR) x -C $(BNAME)
	$(TAR) c --exclude=.svn docs | $(TAR) x -C $(BNAME)
	$(TAR) c --exclude=.svn src | $(TAR) x -C $(BNAME)
	echo $(VERSION) > $(BNAME)/root/etc/default.$(PKG)/.version
	echo $(MOD) > $(BNAME)/root/etc/default.$(PKG)/.subversion
	cp $(EXTRAS) $(BNAME)
	./feature-dep $(BNAME)/root
	find $(BNAME)/root -type f -print0 | xargs -0 $(SHSTRIP)
	if [ -e $(BNAME)/install ]; \
	    then $(SHSTRIP) $(BNAME)/install; \
	fi

check:
	@[ -d $(CONF) ] || (echo Configuration $(CONF) is missing; false)
	find base mod/*/root $(wildcard mod/*/install) -name .svn -prune \
	    -or -type f -not \( -name "*.sed" -or -name "*.txt" -or -name "*.cfg" \) -exec busybox ash -n {} \;

clean:
	-rm -f $(PKG)*.tar.bz2
	-rm -rf build
