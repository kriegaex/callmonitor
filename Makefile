MOD := dsmod
MOD_LIST := $(patsubst conf.%, %, $(wildcard conf.*))
VERSION := $(shell cat .version)
NAME := callmonitor-$(VERSION)
ARCHIVE := $(NAME)-$(MOD).tar.bz2
CONF := conf.$(MOD)
BUILDDIR := build.$(MOD)

.PHONY: $(ARCHIVE) build clean check

build: $(ARCHIVE) $(TEL_ARCHIVE)

build-all:
	for mod in $(MOD_LIST); do $(MAKE) build MOD=$$mod; done

$(ARCHIVE): check
	rm -rf $(BUILDDIR)/$(NAME)
	mkdir -p $(BUILDDIR)/$(NAME)/root
	tar c --exclude=.svn -C base . -C ../$(CONF) . | \
	    tar x -C $(BUILDDIR)/$(NAME)/root
	tar c --exclude=.svn docs | tar x -C $(BUILDDIR)/$(NAME)
	tar cvjf $@ --owner=root --group=root -C $(BUILDDIR) $(NAME) \
	|| (rm $(ARCHIVE) && false)

check:
	[ -d $(CONF) ] || (echo Configuration $(CONF) is missing; false)
	find base conf.* -name .svn -prune \
	-or -type f -exec busybox ash -n {} \;

clean:
	-rm callmonitor*.tar.bz2
	-rm -r build.*
