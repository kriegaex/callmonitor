ARCHIVE := callmonitor.tar.bz2

.PHONY: $(ARCHIVE) install

install: $(ARCHIVE)
	cat $(ARCHIVE) | ssh root@fritz.box tar xvj -C /mod

$(ARCHIVE):
	tar cvjf $@ -C root --format=oldgnu --exclude=.svn . 

