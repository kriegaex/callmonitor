##
## Callmonitor for Fritz!Box (callmonitor)
## 
## Copyright (C) 2005--2008  Andreas Bühmann <buehmann@users.berlios.de>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
## 
## http://developer.berlios.de/projects/callmonitor/
##
MOD := freetz
PKG := callmonitor
MAIN_PKG := callmonitor

PKG_LIST := $(notdir $(wildcard pkg/*))
VERSION := $(shell cat .version)
NAME := $(PKG)-$(VERSION)
ARCHIVE := $(NAME)-$(MOD).tar.bz2
CONF := pkg/$(PKG)
BUILD := build/$(MOD)
BNAME := $(BUILD)/$(NAME)
EXTRAS := README COPYING ChangeLog
#ifneq (,$(wildcard common/mod/$(MOD)/install))
#EXTRAS += common/mod/$(MOD)/install
#endif
CODE := base callmonitor actions freetz/root freetz-actions freetz-base

TAR := tar
TAR_OWNER := --owner=root --group=root

.PHONY: $(ARCHIVE) build clean check collect build-all all

all: build-all

build: $(ARCHIVE)

build-all:
	for pkg in $(PKG_LIST); do $(MAKE) build PKG=$$pkg; done

$(NAME)-$(MOD).tar.bz2: collect
	$(TAR) cjf $@ $(TAR_OWNER) -C $(BUILD) $(NAME) \
	    || (rm $@ && false)

$(NAME)-reload.tar.bz2: collect
	$(TAR) cvf $(BNAME)/$(NAME)-root.tar --format=oldgnu \
	    $(TAR_OWNER) -C $(BNAME)/root .
	rm -rf $(BNAME)/root
	$(TAR) cjf $@ $(TAR_OWNER) -C $(BUILD) $(NAME) \
	    || (rm $@ && false)

collect: check
	rm -rf $(BNAME)
	mkdir -p $(BNAME)/root
	$(TAR) c --exclude=.svn -C base . | $(TAR) x -C $(BNAME)/root
	#$(TAR) c --exclude=.svn -C $(CONF) . |  $(TAR) x -C $(BNAME)
	$(TAR) c --exclude=.svn docs | $(TAR) x -C $(BNAME)
	[ -x $(CONF)/collect.sh ] && $(CONF)/collect.sh $(BNAME) || true
	rm -f $(BNAME)/collect.sh
	echo $(VERSION) > $(BNAME)/root/etc/default.$(MAIN_PKG)/.version
	echo $(MOD) > $(BNAME)/root/etc/default.$(MAIN_PKG)/.subversion
	cp $(EXTRAS) $(BNAME)
	find $(BNAME)/root -type f -print0 | xargs -0 common/tools/shstrip
	if [ -e $(BNAME)/install ]; \
	    then common/tools/shstrip $(BNAME)/install; \
	fi

check:
	@[ -d $(CONF) ] || (echo Configuration $(CONF) is missing; false)
	find $(CODE) -name .svn -prune \
	    -or -type f -not \( -name "*.sed" -or -name "*.txt" -or -name "*.cfg" \) -exec busybox ash -n {} \;

clean:
	-rm -f $(PKG)*.tar.bz2
	-rm -rf build
