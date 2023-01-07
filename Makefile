#
# LBBS -- The Lightweight Bulletin Board System
#
# Top level Makefile
#
# Copyright (C) 2023, Naveen Albert
#
# Naveen Albert <bbs@phreaknet.org>
#

export BBSTOPDIR		# Top level dir, used in subdirs' Makefiles

BBSTOPDIR:=$(subst $(space),\$(space),$(CURDIR))

CC		= gcc
CFLAGS = -Wall -Werror -Wunused -Wextra -Wmaybe-uninitialized -Wstrict-prototypes -Wmissing-prototypes -Wdeclaration-after-statement -Wmissing-declarations -Wno-deprecated-declarations -Wmissing-format-attribute -Wnull-dereference -Wformat=2 -Wshadow -Wsizeof-pointer-memaccess -std=gnu99 -pthread -O0 -g -Wstack-protector -fno-omit-frame-pointer -fwrapv -D_FORTIFY_SOURCE=2
EXE		= lbbs
PREFIX	= /usr/local
BINDIR	= $(PREFIX)/bin
LIBS	= -lrt -lm -ldl -lbfd -lcap -lcrypt -lssl -lcrypto -lcurl -ljansson -lreadline -rdynamic
RM		= rm -f
LN		= ln
INSTALL = install

# XXX missing terms since currently no term modules
MOD_SUBDIR:=doors modules nets
SUBDIRS:=$(MOD_SUBDIR)
SUBDIRS_INSTALL:=$(SUBDIRS:%=%-install)
SUBDIRS_CLEAN:=$(SUBDIRS:%=%-clean)

# SUBMAKE:=$(MAKE) --quiet --no-print-directory
SUBMAKE:=$(MAKE)
MOD_SUBDIR_CFLAGS="-I$(BBSTOPDIR)/include"

# MODULE_PREFIX:=mod
MAIN_SOURCES := $(wildcard *.c) $(cami/wildcard *.c)
INCLUDE_FILES := $(wildcard include/*.h)
MAIN_OBJ = $(MAIN_SOURCES:.c=.o)

VALGRIND = valgrind -s --keep-debuginfo=yes

# ALL_C_MODS+=$(foreach p,$(MOD_SUBDIR)/$(MODULE_PREFIX),$(patsubst %.c,%.so,$(wildcard $(p)_*.c)))

export CC
export CFLAGS

export EXE
export LIBS

# This is the first target, so it's the default for just "make":
all : bbs $(MOD_SUBDIR) external
	@echo " +--------- LBBS has been compiled ---------+"
	@echo " You may now install it by running make install"

bbs : $(MAIN_OBJ)
	@echo " +--------- make bbs ---------+"
	$(SUBMAKE) --no-builtin-rules -C $@ all

$(MOD_SUBDIR):
	@echo " +--------- make $@ ---------+"
# $(SUBMAKE) --no-builtin-rules -C $@ SUBDIR=$@ all
	$(SUBMAKE) --no-builtin-rules -C $@ all

external :
	@echo " +--------- make $@ ---------+"
	$(SUBMAKE) --no-builtin-rules -C $@ all

clean :
	$(RM) lbbs
	$(RM) bbs/*.i bbs/*.o
	$(RM) include/*.gch
	$(SUBMAKE) --no-builtin-rules -C external clean
	@for i in $(MOD_SUBDIR); do \
		$(RM) $${i}/*.i $${i}/*.o $${i}/*.so; \
	done
	$(RM) /usr/lib/lbbs/modules/*.so
	$(RM) /var/lib/lbbs/external/*

bininstall: bbs
	$(INSTALL) -m 755 bbs/$(EXE) "/usr/sbin/lbbs"

modinstall: $(MOD_SUBDIR)
	@if [ ! -d /usr/lib/lbbs ]; then\
		mkdir /usr/lib/lbbs;\
	fi
	@if [ ! -d /usr/lib/lbbs/modules ]; then\
		mkdir /usr/lib/lbbs/modules;\
	fi
	@echo "Installing modules to /usr/lib/lbbs/modules"
	@for i in $(MOD_SUBDIR); do \
		echo " -> Installing modules in $${i}"; \
		$(INSTALL) -m 755 $${i}/*.so /usr/lib/lbbs/modules; \
	done

extinstall:
	@if [ ! -d /var/lib/lbbs ]; then\
		mkdir /var/lib/lbbs;\
	fi
	@if [ ! -d /var/lib/lbbs/external ]; then\
		mkdir /var/lib/lbbs/external;\
	fi
	$(SUBMAKE) --no-builtin-rules -C external install

install : all bininstall modinstall extinstall
	@echo " +--- LBBS and associated modules have been installed ---+"

samples :
	@if [ ! -d /etc/lbbs ]; then\
		mkdir /etc/lbbs;\
	fi
	cp -n configs/*.conf /etc/lbbs

valgrindfg :
	$(VALGRIND) --leak-check=full --show-leak-kinds=all --suppressions=valgrind.supp /usr/sbin/$(EXE) -c

valgrind :
	$(VALGRIND) --leak-check=full --show-leak-kinds=all --suppressions=valgrind.supp --log-fd=9 /usr/sbin/$(EXE) -c 9>valgrind.txt

valgrindsupp :
	$(VALGRIND) --leak-check=full --show-leak-kinds=all --gen-suppressions=all --log-fd=9 /usr/sbin/$(EXE) -c 9>valgrind.txt

helgrind :
	$(VALGRIND) --tool=helgrind /usr/sbin/$(EXE) -c

.PHONY: all
.PHONY: bbs
.PHONY: $(MOD_SUBDIR)
.PHONY: external
.PHONY: clean
.PHONY: install
.PHONY: samples
.PHONY: valgrindfg
.PHONY: valgrind
.PHONY: valgrindsupp
.PHONY: helgrind
