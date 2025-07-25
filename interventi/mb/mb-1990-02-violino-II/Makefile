# Makefile per singolo strumento MB
# Da copiare in ogni directory mb-xxxx-xx

# Trova tutti i file .tex nella directory corrente
TEX_FILES := $(wildcard LEAP*.tex)
PDF_FILES := $(TEX_FILES:.tex=.pdf)
AUX_FILES := $(TEX_FILES:.tex=.aux)
LOG_FILES := $(TEX_FILES:.tex=.log)
OUT_FILES := $(TEX_FILES:.tex=.out)

# Strumento corrente (dal nome directory)
INSTRUMENT := $(notdir $(CURDIR))

# Colori per output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
NC=\033[0m # No Color

.PHONY: all clean step help list

# Target principale: compila tutto e pulisce file intermedi
all: $(PDF_FILES) clean-temp
	@echo "$(GREEN)✅ $(INSTRUMENT): Compilazione completata!$(NC)"

# Target step: compila una volta senza cleanup
step: step-compile
	@echo "$(GREEN)✅ $(INSTRUMENT): Compilazione step completata!$(NC)"

# Compila tutti i PDF (doppia compilazione per QR code)
$(PDF_FILES): %.pdf: %.tex
	@echo "$(BLUE)🔧 Compilando $< (prima passata)...$(NC)"
	@pdflatex -interaction=nonstopmode $< > /dev/null 2>&1 || \
		(echo "$(RED)❌ Errore nella prima compilazione di $<$(NC)" && \
		 echo "$(YELLOW)📋 Log disponibile in $*.log$(NC)" && exit 1)
	@echo "$(BLUE)🔧 Compilando $< (seconda passata per QR code)...$(NC)"
	@pdflatex -interaction=nonstopmode $< > /dev/null 2>&1 || \
		(echo "$(RED)❌ Errore nella seconda compilazione di $<$(NC)" && \
		 echo "$(YELLOW)📋 Log disponibile in $*.log$(NC)" && exit 1)
	@echo "$(GREEN)✅ $@ generato$(NC)"

# Compilazione step (una sola volta)
step-compile:
	@for tex in $(TEX_FILES); do \
		echo "$(BLUE)🔧 Compilando $$tex (step)...$(NC)"; \
		pdflatex -interaction=nonstopmode $$tex > /dev/null 2>&1 || \
			(echo "$(RED)❌ Errore nella compilazione di $$tex$(NC)" && \
			 echo "$(YELLOW)📋 Log disponibile in $${tex%.tex}.log$(NC)" && exit 1); \
		echo "$(GREEN)✅ $${tex%.tex}.pdf generato$(NC)"; \
	done

# Pulizia file temporanei (mantiene PDF)
clean-temp:
	@if [ -n "$(AUX_FILES)" ]; then \
		echo "$(YELLOW)🧹 Eliminando file temporanei...$(NC)"; \
		rm -f $(AUX_FILES) $(LOG_FILES) $(OUT_FILES); \
	fi

# Pulizia completa (inclusi PDF)
clean: clean-temp
	@if [ -n "$(PDF_FILES)" ]; then \
		echo "$(YELLOW)🧹 Eliminando PDF...$(NC)"; \
		rm -f $(PDF_FILES); \
	fi
	@echo "$(GREEN)✅ $(INSTRUMENT): Pulizia completata!$(NC)"

# Lista file nel progetto
list:
	@echo "$(BLUE)📋 Contenuto $(INSTRUMENT):$(NC)"
	@if [ -n "$(TEX_FILES)" ]; then \
		echo "$(YELLOW)  📄 File TEX:$(NC)"; \
		for tex in $(TEX_FILES); do echo "    $$tex"; done; \
	fi
	@if [ -n "$(PDF_FILES)" ]; then \
		echo "$(YELLOW)  📋 File PDF:$(NC)"; \
		for pdf in $(PDF_FILES); do \
			if [ -f "$$pdf" ]; then \
				size=$$(ls -lh "$$pdf" | awk '{print $$5}'); \
				echo "    $$pdf ($$size)"; \
			else \
				echo "    $$pdf $(RED)[mancante]$(NC)"; \
			fi; \
		done; \
	fi

# Forza ricompilazione
force: clean all

# Debug: mostra log dell'ultimo errore
debug:
	@echo "$(BLUE)🐛 Debug $(INSTRUMENT):$(NC)"
	@for log in $(LOG_FILES); do \
		if [ -f "$$log" ]; then \
			echo "$(YELLOW)📋 Contenuto $$log:$(NC)"; \
			tail -20 "$$log"; \
			echo ""; \
		fi; \
	done

# Apri PDF compilati
open:
	@for pdf in $(PDF_FILES); do \
		if [ -f "$$pdf" ]; then \
			echo "$(BLUE)📖 Aprendo $$pdf$(NC)"; \
			open "$$pdf"; \
		else \
			echo "$(RED)❌ $$pdf non trovato$(NC)"; \
		fi; \
	done

# Verifica dipendenze
check:
	@echo "$(BLUE)🔍 Verifica dipendenze $(INSTRUMENT):$(NC)"
	@command -v pdflatex >/dev/null 2>&1 || \
		(echo "$(RED)❌ pdflatex non trovato$(NC)" && exit 1)
	@echo "$(GREEN)✅ pdflatex disponibile$(NC)"
	@kpsewhich qrcode.sty >/dev/null 2>&1 || \
		echo "$(YELLOW)⚠️  pacchetto qrcode potrebbe mancare$(NC)"
	@kpsewhich AlegreyaSans.sty >/dev/null 2>&1 || \
		echo "$(YELLOW)⚠️  pacchetto AlegreyaSans potrebbe mancare$(NC)"

# Info strumento
info:
	@echo "$(BLUE)ℹ️  Informazioni $(INSTRUMENT):$(NC)"
	@echo "$(YELLOW)  📁 Directory: $(CURDIR)$(NC)"
	@echo "$(YELLOW)  🎼 Strumento: $(INSTRUMENT)$(NC)"
	@echo "$(YELLOW)  📄 File TEX: $(words $(TEX_FILES))$(NC)"
	@echo "$(YELLOW)  📋 File PDF: $(words $(PDF_FILES))$(NC)"

# Help
help:
	@echo "$(BLUE)🚀 Makefile LEAP - Sistema di compilazione report$(NC)"
	@echo ""
	@echo "$(YELLOW)Target disponibili:$(NC)"
	@echo "  $(GREEN)make$(NC)              - Compila tutti i report (con cleanup)"
	@echo "  $(GREEN)make step-all$(NC)     - Compila tutti i report (senza cleanup)"
	@echo "  $(GREEN)make clean$(NC)        - Pulisce tutti i file intermedi"
	@echo "  $(GREEN)make list$(NC)         - Lista tutti i report disponibili"
	@echo "  $(GREEN)make stats$(NC)        - Mostra statistiche repository"
	@echo ""
	@echo "$(YELLOW)Target per singoli strumenti:$(NC)"
	@echo "  $(GREEN)make instrument INST=mb-1990-01$(NC) - Compila singolo strumento"
	@echo ""
	@echo "$(YELLOW)Esempi:$(NC)"
	@echo "  make                    # Compila tutto"
	@echo "  make instrument INST=mb-1990-01"
	@echo "  make clean              # Pulisce tutto"

# Default target: compila tutto
.DEFAULT_GOAL := all
