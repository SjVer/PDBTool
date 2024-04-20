EXE = pdbtool.exe

SRCDIR = src
BINDIR = bin

FLAGS := -error-pos-style:unix -subsystem:console

# =================== variables ===================

COMMA := ,
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)

# ==================== targets ====================

$(EXE): $(BINDIR)/$(EXE)

.PHONY: $(BINDIR)/$(EXE)
$(BINDIR)/$(EXE):
	@if not exist "$(BINDIR)" mkdir "$(BINDIR)"
	odin build $(SRCDIR) $(FLAGS) -out:$@ $(if $(release),,-debug)

# ===================== tools =====================

test: $(BINDIR)/$(EXE)
	$(eval _args=$(subst $(COMMA),$(SPACE),$(args)))
	$(BINDIR)/$(EXE) $(_args)

clean:
	@if exist "$(BINDIR)" rd /q /s "$(BINDIR)"