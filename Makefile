#/* vim:set ts=4 tw=80 sw=4 cindent ai si cino=(0,ml,\:0:
# * ( settings from: http://datapax.com.au/code_conventions/ )
# */
#
#/**********************************************************************
#    Lorem Ipsum
#    Copyright (C) 2012-2014 DaTaPaX (Todd Harbour t/a)
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

# Programs
ARCHIVER    = tar -zcvf
ARCHIVE_EXT = tar.gz

APPNAME = loremipsum
APPBIN  = $(APPNAME).sh
PROGVER="$$(grep APP_VER $(APPBIN)|head -1|cut -d'"' -f2)"
ARCHIVE_NAME="$(APPNAME)-$(PROGVER)"

BUILT_FILES = $(APPNAME).DEFAULT.conf Changelog
DIST_FILES  = $(APPBIN) COPYING README TODO Makefile $(BUILT_FILES)



# Default target
_PHONY: err

svnup:
	# Ensure up to date
	svn up

Changelog: svnup
	@# Generate Changelog
	@echo "Making Changelog..."
	@svn log >Changelog

config: $(APPNAME).DEFAULT.conf

$(APPNAME).DEFAULT.conf: svnup
	@# Generate $(APPNAME).DEFAULT.conf
	@echo "Making $(APPNAME).DEFAULT.conf..."
	@grep -A999 '# \[ CONFIG_START' $(APPBIN)|grep -v '# \[ CONFIG_START'|grep -B999 '# \] CONFIG_END'|grep -v '# \] CONFIG_END' >$(APPNAME).DEFAULT.conf

err:
	@echo "No target specified (try dist)"

dist: $(DIST_FILES)
	@echo "Making " $(ARCHIVE_NAME).$(ARCHIVE_EXT)

	@if [ -d "$(ARCHIVE_NAME)" ]; then \
		echo "Directory '$(ARCHIVE_NAME)' exists"; \
		exit 1; \
	fi

	@if [ -f "$(ARCHIVE_NAME).$(ARCHIVE_EXT)" ]; then \
		echo "Archive '$(ARCHIVE_NAME).$(ARCHIVE_EXT)' exists"; \
		exit 2; \
	fi

	@mkdir "$(ARCHIVE_NAME)"
	
	@cp -a $(DIST_FILES) "$(ARCHIVE_NAME)/"
	@$(ARCHIVER) "$(ARCHIVE_NAME).$(ARCHIVE_EXT)" "$(ARCHIVE_NAME)/"

clean:
	@echo "Cleaning up..."
	
	@if [ -d "$(ARCHIVE_NAME)" ]; then \
		echo "  deleting: $(ARCHIVE_NAME)"; \
		rm -Rf "$(ARCHIVE_NAME)"; \
	fi
	
	@echo "Done."

distclean: clean
	@echo "Cleaning (for distribution)..."
	
	@if [ -f "$(ARCHIVE_NAME).$(ARCHIVE_EXT)" ]; then \
		echo "  deleting: $(ARCHIVE_NAME).$(ARCHIVE_EXT)"; \
		rm "$(ARCHIVE_NAME).$(ARCHIVE_EXT)"; \
	fi
	
	@for f in $(BUILT_FILES); do \
		[ -f "$${f}" ] && rm "$${f}" || true; \
	done
