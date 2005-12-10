MOD := dsmod
VERSION := $(shell cat .version)
NAME := callmonitor-$(VERSION)
TEL_NAME := telefon-$(VERSION)
ARCHIVE := $(NAME)-$(MOD).tar.bz2
TEL_ARCHIVE := $(TEL_NAME)-$(MOD).tar.bz2
CONF := conf.$(MOD)

.PHONY: $(ARCHIVE) build clean check

build: $(ARCHIVE) $(TEL_ARCHIVE)

$(ARCHIVE): check
	rm -rf ./$(NAME)
	mkdir $(NAME)
	tar c --exclude=.svn -C base . -C ../$(CONF) . | tar x -C $(NAME)
	tar cvjf $@ --format=oldgnu --owner=root --group=root $(NAME) \
	|| (rm $(ARCHIVE) && false)
	rm -rf ./$(NAME)

$(TEL_ARCHIVE): check
	rm -rf ./$(TEL_NAME)
	mkdir $(TEL_NAME)
	tar c --exclude=.svn -C telefon . | tar x -C $(TEL_NAME)
	tar cvjf $@ --format=oldgnu --owner=root --group=root $(TEL_NAME) \
	|| (rm $(TEL_ARCHIVE) && false)
	rm -rf ./$(TEL_NAME)

check:
	find base conf.* telefon -name .svn -prune \
	-or -type f -exec busybox ash -n {} \;

clean:
	-rm callmonitor*.tar.bz2 telefon*.tar.bz2
	-rm -r callmonitor-[0-9]* telefon-[0-9]*
