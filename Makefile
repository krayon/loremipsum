#/* vim:set ts=4 tw=80 sw=4 cindent ai si cino=(0,ml,\:0:
# * ( settings from: http://datapax.com.au/code_conventions/ )
# */
#
#/**********************************************************************
#    Lorem Ipsum
#    Copyright (C) 2012-2021 DaTaPaX (Todd Harbour t/a)
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of the GNU General Public License
#    version 3 ONLY, as published by the Free Software Foundation.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program, in the file COPYING or COPYING.txt; if
#    not, see http://www.gnu.org/licenses/ , or write to:
#      The Free Software Foundation, Inc.,
#      51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
# **********************************************************************/


# Krayon's GPG code signing key
GPG_KEY        = 81ECF212

# Programs
ARCHIVER       = tar -zcvf
ARCHIVE_EXT    = tar.gz

APPNAME = loremipsum
APPBIN  = $(APPNAME).bash
APPVER  = $(shell grep APP_VER $(APPBIN)|head -1|cut -d'"' -f2)

ARCHIVE_NAME   = $(APPNAME)-$(APPVER)
ARCHIVE_FILE   = $(ARCHIVE_NAME).$(ARCHIVE_EXT)

BUILT_FILES    = $(APPNAME).DEFAULT.conf Changelog $(APPBIN).asc
DIST_FILES     = $(APPBIN) COPYING README.md TODO.md Makefile $(BUILT_FILES)


# Default target
.PHONY: _PHONY
_PHONY: all



all: $(DIST_FILES) done



gitup:
	@echo "$(APPNAME)"
	@# Ensure up to date
	@echo "Pulling from origin..."
	@git pull || true

Changelog: gitup
	@# Generate Changelog
	@echo "Generating Changelog..."
	@git log --color=never --pretty=tformat:"%ai %an <%aE>%n%w(76,4,4)%h %s%n%+b" >Changelog

config: $(APPNAME).DEFAULT.conf
$(APPNAME).DEFAULT.conf: gitup
	@# Generate $(APPNAME).DEFAULT.conf
	@echo "Making $(APPNAME).DEFAULT.conf..."
	@sed -n '/^# \[ CONFIG_START/,/^# \] CONFIG_END/p' <"$(APPBIN)" >$(APPNAME).DEFAULT.conf



# Error
err:
	@echo "No target specified (try dist)"

# Done
done:
	@echo "BUILD COMPLETE: $(APPNAME) ($(BINNAME)) v$(APPVER)"

# Sign
sign: $(APPBIN).asc



%.asc: %
	@echo "Signing: $${f}..."
	@rm "$@" 2>/dev/null || true
	gpg -o $@ --local-user $(GPG_KEY) --armor --detach-sign $<

$(ARCHIVE_FILE): $(DIST_FILES)
	@echo "Making $(ARCHIVE_FILE)..."
	
	@if [ -d "$(ARCHIVE_NAME)" ]; then \
		echo "Directory '$(ARCHIVE_NAME)' exists"; \
		exit 1; \
	fi
	
	@if [ -f "$(ARCHIVE_FILE)" ]; then \
		echo "Archive '$(ARCHIVE_FILE)' exists"; \
		exit 2; \
	fi
	
	@mkdir "$(ARCHIVE_NAME)"
	
	@cp -a $(DIST_FILES) "$(ARCHIVE_NAME)/"
	@$(ARCHIVER) "$(ARCHIVE_FILE)" "$(ARCHIVE_NAME)/"

#dist: gitup Changelog $(APPNAME).DEFAULT.conf
dist: $(ARCHIVE_FILE) $(ARCHIVE_FILE).asc

clean:
	@echo "Cleaning up..."
	
	@echo "  deleting: Changelog";
	@rm -f Changelog;
	
	@if [ -d "$(ARCHIVE_NAME)" ]; then \
		echo "  deleting: $(ARCHIVE_NAME)"; \
		rm -Rf "$(ARCHIVE_NAME)"; \
	fi
	
	@echo "Done."

distclean: clean
	@echo "Cleaning (for distribution)..."
	
	@for f in $(ARCHIVE_FILE).asc $(ARCHIVE_FILE) $(BUILT_FILES); do \
		[ -f "$${f}" ] && echo "  deleting: $${f}" && rm "$${f}" || true; \
	done
