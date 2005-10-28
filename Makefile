MOD := ds
ARCHIVE := callmonitor-$(MOD).tar.bz2
CONF := conf.$(MOD)

.PHONY: $(ARCHIVE) build install-ds clean

install: install-$(MOD)

install-ds: build
	ssh root@fritz.box tar xvj -C /mod < $(ARCHIVE)

build: $(ARCHIVE)

$(ARCHIVE):
	tar cvjf $@ \
	--format=oldgnu --owner=root --group=root --exclude=.svn \
	-C base . \
	-C ../$(CONF) . || (rm $(ARCHIVE) && false)

clean:
	-rm callmonitor*.tar.bz2
