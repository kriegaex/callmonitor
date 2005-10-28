MOD := ds
ARCHIVE := callmonitor-$(MOD).tar.bz2
CONF := conf.$(MOD)

.PHONY: $(ARCHIVE) build install

install: build
	ssh root@fritz.box tar xvj -C /mod < $(ARCHIVE)

build: $(ARCHIVE)

$(ARCHIVE):
	tar cvjf $@ \
	--format=oldgnu --owner=root --group=root --exclude=.svn \
	-C base . \
	-C ../$(CONF) .
