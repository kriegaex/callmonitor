MOD := dsmod
MOD_LIST := $(patsubst conf.%, %, $(wildcard conf.*))
VERSION := $(shell cat .version)
NAME := callmonitor-$(VERSION)
ARCHIVE := $(NAME)-$(MOD).tar.bz2
CONF := conf.$(MOD)
BUILD := build.$(MOD)
BNAME := $(BUILD)/$(NAME)
EXTRAS := README COPYING ChangeLog

.PHONY: $(ARCHIVE) build clean check collect

build: $(ARCHIVE) $(TEL_ARCHIVE)

build-all:
	for mod in $(MOD_LIST); do $(MAKE) build MOD=$$mod; done

$(ARCHIVE): collect
	tar cvjf $@ --owner=root --group=root -C $(BUILD) $(NAME) \
	|| (rm $(ARCHIVE) && false)

collect: check
	rm -rf $(BNAME)
	mkdir -p $(BNAME)/root
	tar c --exclude=.svn -C base . -C ../$(CONF) . | \
	    tar x -C $(BNAME)/root
	tar c --exclude=.svn docs | tar x -C $(BNAME)
	echo $(VERSION) > $(BNAME)/root/etc/default.callmonitor/.version
	echo $(MOD) > $(BNAME)/root/etc/default.callmonitor/.subversion
	cp $(EXTRAS) $(BNAME)

check:
	@[ -d $(CONF) ] || (echo Configuration $(CONF) is missing; false)
	find base conf.* -name .svn -prune \
	-or -type f -exec busybox ash -n {} \;

clean:
	-rm callmonitor*.tar.bz2
	-rm -r build.*
