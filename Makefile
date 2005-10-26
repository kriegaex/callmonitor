ARCHIVE := callmonitor.tar.bz2

.PHONY: $(ARCHIVE) build install

install: build
	ssh root@fritz.box tar xvj -C /mod < $(ARCHIVE)

build: $(ARCHIVE)

$(ARCHIVE):
	tar cvjf $@ -C root \
	--format=oldgnu --owner=root --group=root --exclude=.svn \
	.
