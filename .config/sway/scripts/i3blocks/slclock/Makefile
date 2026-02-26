# slclock Makefile
# Build configurations for different use cases

# Compiler settings
CC = gcc
CFLAGS = -Wall -Wextra -O2
LDFLAGS =

# Installation paths
PREFIX = /usr/local
BINDIR = $(PREFIX)/bin

# Source files
SRC = slclock.c
TARGET = slclock

# Build targets
.PHONY: all clean install uninstall help minimal embedded strip

# Default build with help text
all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(TARGET) $(SRC)

# Build without help text for minimal binary size
minimal: CFLAGS += -DNOHELP
minimal: clean $(TARGET)
	@echo "Built minimal version (no help text)"

# Build for embedded systems (minimal + size optimization)
embedded: CFLAGS += -DNOHELP -Os -ffunction-sections -fdata-sections
embedded: LDFLAGS += -Wl,--gc-sections
embedded: clean $(TARGET)
	strip --strip-all $(TARGET)
	@echo "Built embedded version (minimal + optimized for size)"

# Strip symbols from existing binary
strip:
	strip --strip-all $(TARGET)
	@echo "Stripped debug symbols"

# Install to system
install: $(TARGET)
	install -Dm755 $(TARGET) $(DESTDIR)$(BINDIR)/$(TARGET)
	@echo "Installed to $(DESTDIR)$(BINDIR)/$(TARGET)"

# Uninstall from system
uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(TARGET)
	@echo "Uninstalled from $(DESTDIR)$(BINDIR)/$(TARGET)"

# Clean build artifacts
clean:
	rm -f $(TARGET)

# Show size comparison
size-compare: all
	@echo "=== Size Comparison ==="
	@echo -n "Full version:     "
	@ls -lh $(TARGET) | awk '{print $$5}'
	@$(MAKE) -s minimal
	@echo -n "Minimal version:  "
	@ls -lh $(TARGET) | awk '{print $$5}'
	@$(MAKE) -s embedded
	@echo -n "Embedded version: "
	@ls -lh $(TARGET) | awk '{print $$5}'
	@echo "======================="

# Show available targets
help:
	@echo "slclock build targets:"
	@echo "  make              - Build with help text (default)"
	@echo "  make minimal      - Build without help text (-DNOHELP)"
	@echo "  make embedded     - Build for embedded systems (minimal + size opts)"
	@echo "  make strip        - Strip symbols from existing binary"
	@echo "  make install      - Install to $(BINDIR)"
	@echo "  make uninstall    - Remove from $(BINDIR)"
	@echo "  make clean        - Remove build artifacts"
	@echo "  make size-compare - Compare binary sizes across build types"
	@echo ""
	@echo "Environment variables:"
	@echo "  PREFIX=<path>     - Installation prefix (default: /usr/local)"
	@echo "  CC=<compiler>     - C compiler (default: gcc)"
	@echo ""
	@echo "Examples:"
	@echo "  make minimal                    # Build without help"
	@echo "  make embedded                   # Smallest possible binary"
	@echo "  PREFIX=/usr make install        # Install to /usr/bin"
	@echo "  CC=clang make                   # Build with clang"
