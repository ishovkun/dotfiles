HS_HEADERS = /Applications/Hammerspoon.app/Contents/Frameworks/LuaSkin.framework/Headers
INSTALL_DIR = $(HOME)/.hammerspoon

CFLAGS = -O2 -Wall -Wextra -fPIC -I$(HS_HEADERS)
LDFLAGS = -bundle -undefined dynamic_lookup -framework Foundation

hackmac_hs.so: hackmac_hs.m
	clang $(CFLAGS) $(LDFLAGS) -o $@ $<

install: hackmac_hs.so
	cp hackmac_hs.so $(INSTALL_DIR)/

clean:
	rm -f hackmac_hs.so

.PHONY: install clean
