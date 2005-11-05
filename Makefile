MOD := ds
ARCHIVE := callmonitor-$(MOD).tar.bz2
CONF := conf.$(MOD)

.PHONY: $(ARCHIVE) build install-ds clean check

install: install-$(MOD)

install-ds: build
	scp $(ARCHIVE) root@fritz.box:
	ssh root@fritz.box 'tar xvj -C /mod < $(ARCHIVE)'

build: $(ARCHIVE)

$(ARCHIVE): check
	tar cvjf $@ \
	--format=oldgnu --owner=root --group=root --exclude=.svn \
	-C base . \
	-C ../$(CONF) . || (rm $(ARCHIVE) && false)

check:
	find base conf.* -name .svn -prune \
	-or -type f -exec busybox ash -n {} \;

clean:
	-rm callmonitor*.tar.bz2
