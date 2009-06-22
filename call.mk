##
## Callmonitor for Fritz!Box (common)
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

# MOD := dsmod
# PKG := telefon

MOD_LIST := $(notdir $(wildcard mod/*))
VERSION := $(shell cat .version)
NAME := $(PKG)-$(VERSION)
ARCHIVE := $(NAME)-$(MOD).tar.bz2
CONF := mod/$(MOD)
BUILD := build/$(MOD)
BNAME := $(BUILD)/$(NAME)
EXTRAS := README COPYING ChangeLog
ifneq (,$(wildcard common/mod/$(MOD)/install))
EXTRAS += common/mod/$(MOD)/install
endif

TAR := tar
TAR_OWNER := --owner=root --group=root

.PHONY: $(ARCHIVE) build clean check collect

build: $(ARCHIVE)

build-all:
	for mod in $(MOD_LIST); do $(MAKE) build MOD=$$mod; done

$(NAME)-$(MOD).tar.bz2: collect
	$(TAR) cjf $@ $(TAR_OWNER) -C $(BUILD) $(NAME) \
	    || (rm $@ && false)

$(NAME)-reload.tar.bz2: collect
	$(TAR) cvf $(BNAME)/$(NAME)-root.tar --format=oldgnu \
	    $(TAR_OWNER) -C $(BNAME)/root .
	rm -rf $(BNAME)/root
	$(TAR) cvjf $@ $(TAR_OWNER) -C $(BUILD) $(NAME) \
	    || (rm $@ && false)

collect: check
	rm -rf $(BNAME)
	mkdir -p $(BNAME)/root
	$(TAR) c --exclude=.svn -C base . | $(TAR) x -C $(BNAME)/root
	$(TAR) c --exclude=.svn -C $(CONF) . |  $(TAR) x -C $(BNAME)
	$(TAR) c --exclude=.svn docs | $(TAR) x -C $(BNAME)
	echo $(VERSION) > $(BNAME)/root/etc/default.$(PKG)/.version
	echo $(MOD) > $(BNAME)/root/etc/default.$(PKG)/.subversion
	cp $(EXTRAS) $(BNAME)
	./feature-dep $(BNAME)/root
	find $(BNAME)/root -type f -print0 | xargs -0 common/tools/shstrip
	if [ -e $(BNAME)/install ]; \
	    then common/tools/shstrip $(BNAME)/install; \
	fi

check:
	@[ -d $(CONF) ] || (echo Configuration $(CONF) is missing; false)
	find base mod/*/root $(wildcard mod/*/install) -name .svn -prune \
	    -or -type f -not \( -name "*.sed" -or -name "*.txt" -or -name "*.cfg" \) -exec busybox ash -n {} \;

clean:
	-rm -f $(PKG)*.tar.bz2
	-rm -rf build
