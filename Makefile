MOD := ds
VERSION := $(shell cat .version)
NAME := callmonitor-$(VERSION)
ARCHIVE := $(NAME)-$(MOD).tar.bz2
CONF := conf.$(MOD)

.PHONY: $(ARCHIVE) build install-ds clean check

install: install-$(MOD)

#install-ds: build
#	scp $(ARCHIVE) root@fritz.box:
#	ssh root@fritz.box 'tar xvj -C /mod < $(ARCHIVE)'

build: $(ARCHIVE)

$(ARCHIVE): check
	rm -rf ./$(NAME)
	mkdir $(NAME)
	tar c --exclude=.svn -C base . -C ../$(CONF) . | tar x -C $(NAME)
	tar cvjf $@ --format=oldgnu --owner=root --group=root $(NAME) \
	|| (rm $(ARCHIVE) && false)
	rm -rf ./$(NAME)

check:
	find base conf.* -name .svn -prune \
	-or -type f -exec busybox ash -n {} \;

clean:
	-rm callmonitor*.tar.bz2
	-rm -r callmonitor-*
