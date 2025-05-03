PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
LIBDIR = $(PREFIX)/lib
MANDIR = $(PREFIX)/share/man/man1

.PHONY: all install uninstall

all:
	@echo "Available commands:"
	@echo "  make install   - Install gwtree"
	@echo "  make uninstall - Uninstall gwtree"

install:
	@echo "Installing gwtree..."
	install -d $(BINDIR)
	install -d $(LIBDIR)
	install -d $(MANDIR)
	install -m 755 bin/gwtree $(BINDIR)/gwtree
	install -m 644 lib/gwtree.sh $(LIBDIR)/gwtree.sh
	install -m 644 man/man1/gwtree.1 $(MANDIR)/gwtree.1
	@echo "Installation complete!"
	@echo "Please add the following line to your ~/.zshrc:"
	@echo "source $(LIBDIR)/gwtree.sh"
	@echo "Then run: source ~/.zshrc"

uninstall:
	@echo "Uninstalling gwtree..."
	rm -f $(BINDIR)/gwtree
	rm -f $(LIBDIR)/gwtree.sh
	rm -f $(MANDIR)/gwtree.1
	@echo "Uninstallation complete!"
	@echo "Please remove the 'source $(LIBDIR)/gwtree.sh' line from your ~/.zshrc" 