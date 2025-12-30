#!/bin/bash

# LEAP Compiler - Script di compilazione interattivo
# Sostituisce i Makefile complessi con una soluzione semplice ed elegante

set -e

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configurazione
ROOT_DIR="$(pwd)"
INTERVENTI_DIR="$ROOT_DIR/interventi"

# Banner
print_banner() {
    echo -e "${MAGENTA}"
    echo "╔═══════════════════════════════════════╗"
    echo "║              LEAP COMPILER            ║"
    echo "║    Laboratorio Elettroacustico        ║"
    echo "║           Permanente                  ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

# Trova tutti i file .tex
find_tex_files() {
    # Debug: mostra la directory di ricerca
    echo -e "${YELLOW}🔍 Cercando file .tex in: $INTERVENTI_DIR${NC}" >&2

    if [ ! -d "$INTERVENTI_DIR" ]; then
        echo -e "${RED}❌ Directory $INTERVENTI_DIR non esiste!${NC}" >&2
        return 1
    fi

    # Cerca ricorsivamente tutti i file .tex
    local files=$(find "$INTERVENTI_DIR" -name "*.tex" -type f 2>/dev/null)

    # Debug: mostra quanti file sono stati trovati
    local count=$(echo "$files" | grep -c . 2>/dev/null || echo 0)
    echo -e "${YELLOW}🔍 Trovati $count file .tex${NC}" >&2

    # Se non trova nulla, mostra la struttura delle directory
    if [ "$count" -eq 0 ]; then
        echo -e "${YELLOW}🔍 Struttura directory interventi:${NC}" >&2
        ls -la "$INTERVENTI_DIR" 2>/dev/null || echo "Impossibile listare $INTERVENTI_DIR" >&2
        echo -e "${YELLOW}🔍 Sottodirectory:${NC}" >&2
        find "$INTERVENTI_DIR" -type d -maxdepth 3 2>/dev/null | head -10 || echo "Nessuna sottodirectory trovata" >&2
    fi

    echo "$files" | sort
}

# Estrai info da path
extract_info() {
    local filepath="$1"
    local filename=$(basename "$filepath" .tex)
    local dirname=$(dirname "$filepath")
    local instrument=$(basename "$(dirname "$dirname")" 2>/dev/null)

    # Se è un fascicolo, usa il nome del file come strumento
    if [[ "$dirname" == *"/fascicolo" ]]; then
        instrument="fascicolo: $filename"
    elif [[ "$filename" == LEAP* ]]; then
        instrument="report: $filename"
    fi

    echo "$instrument|$filepath|$filename"
}

# Compila singolo file
compile_tex() {
    local tex_file="$1"
    local tex_dir=$(dirname "$tex_file")
    local tex_name=$(basename "$tex_file" .tex)

    echo -e "${BLUE}🔧 Compilando: ${CYAN}$tex_name${NC}"
    echo -e "${YELLOW}📁 Directory: $tex_dir${NC}"

    # Vai nella directory del file
    cd "$tex_dir"

    # Prima compilazione
    echo -e "${YELLOW}   → Prima passata...${NC}"
    if ! pdflatex -interaction=nonstopmode "$tex_name.tex" >/dev/null 2>&1; then
        echo -e "${RED}❌ Errore nella prima compilazione!${NC}"
        echo -e "${YELLOW}📋 Controllare il log: $tex_dir/$tex_name.log${NC}"
        cd "$ROOT_DIR"
        return 1
    fi

    # Seconda compilazione (per QR codes, riferimenti, etc.)
    echo -e "${YELLOW}   → Seconda passata (QR codes, riferimenti)...${NC}"
    if ! pdflatex -interaction=nonstopmode "$tex_name.tex" >/dev/null 2>&1; then
        echo -e "${RED}❌ Errore nella seconda compilazione!${NC}"
        echo -e "${YELLOW}📋 Controllare il log: $tex_dir/$tex_name.log${NC}"
        cd "$ROOT_DIR"
        return 1
    fi

    # Cleanup
    rm -f "$tex_name.aux" "$tex_name.log" "$tex_name.out" "$tex_name.synctex.gz" 2>/dev/null

    local pdf_size=$(ls -lh "$tex_name.pdf" 2>/dev/null | awk '{print $5}' || echo "?")
    echo -e "${GREEN}✅ Successo! PDF generato: $tex_name.pdf ($pdf_size)${NC}"

    # Ritorna alla directory root
    cd "$ROOT_DIR"

    # Chiedi se aprire il PDF
    read -p "$(echo -e ${CYAN}📖 Aprire il PDF? [y/N]: ${NC})" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "$tex_dir/$tex_name.pdf" 2>/dev/null || echo -e "${YELLOW}⚠️  Impossibile aprire il PDF${NC}"
    fi
}

# Pulizia file temporanei globale
cleanup_temp_files() {
    echo -e "${BLUE}🧹 Pulizia file temporanei LaTeX...${NC}"
    echo

    # File temporanei da eliminare
    local temp_extensions=("*.aux" "*.log" "*.out" "*.synctex.gz" "*.fls" "*.fdb_latexmk" "*.toc" "*.lof" "*.lot" "*.bbl" "*.blg")

    local total_removed=0
    local total_size=0

    for ext in "${temp_extensions[@]}"; do
        echo -e "${YELLOW}🔍 Cercando file $ext...${NC}"

        # Trova e conta i file
        local files=$(find "$INTERVENTI_DIR" -name "$ext" -type f 2>/dev/null)
        local count=$(echo "$files" | grep -c . 2>/dev/null || echo 0)

        if [ "$count" -gt 0 ]; then
            # Calcola dimensione prima di eliminare
            local size_bytes=$(find "$INTERVENTI_DIR" -name "$ext" -type f -exec stat -f%z {} \; 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
            local size_kb=$((size_bytes / 1024))

            echo -e "${CYAN}   📄 Trovati $count file ($size_kb KB)${NC}"

            # Elimina i file
            find "$INTERVENTI_DIR" -name "$ext" -type f -delete 2>/dev/null

            total_removed=$((total_removed + count))
            total_size=$((total_size + size_kb))
        else
            echo -e "${GREEN}   ✓ Nessun file $ext trovato${NC}"
        fi
    done

    echo
    if [ "$total_removed" -gt 0 ]; then
        echo -e "${GREEN}✅ Pulizia completata!${NC}"
        echo -e "${YELLOW}📊 Eliminati: $total_removed file (${total_size} KB)${NC}"

        # Mostra directory più pulite
        echo -e "${CYAN}🎯 Directory ripulite:${NC}"
        find "$INTERVENTI_DIR" -type d -name "LEAP*" -o -name "fascicolo" 2>/dev/null | head -5 | while read dir; do
            echo -e "${CYAN}   📁 $dir${NC}"
        done
    else
        echo -e "${GREEN}✅ Repository già pulito! Nessun file temporaneo trovato.${NC}"
    fi
}

# Mostra statistiche
show_stats() {
    echo -e "${BLUE}📊 Statistiche Repository LEAP:${NC}"
    echo

    local total_tex=$(find "$INTERVENTI_DIR" -name "*.tex" | wc -l | tr -d ' ')
    local total_pdf=$(find "$INTERVENTI_DIR" -name "*.pdf" | wc -l | tr -d ' ')
    local total_instruments=$(find "$INTERVENTI_DIR" -name "mb-*" -type d | wc -l | tr -d ' ')
    local total_reports=$(find "$INTERVENTI_DIR" -name "LEAP*.tex" | wc -l | tr -d ' ')
    local total_fascicoli=$(find "$INTERVENTI_DIR" -name "fascicolo" -type d | wc -l | tr -d ' ')

    printf "${YELLOW}🎼 Strumenti:      ${NC}%s\n" "$total_instruments"
    printf "${YELLOW}📄 File TEX:       ${NC}%s\n" "$total_tex"
    printf "${YELLOW}📋 File PDF:       ${NC}%s\n" "$total_pdf"
    printf "${YELLOW}📊 Report:         ${NC}%s\n" "$total_reports"
    printf "${YELLOW}📁 Fascicoli:      ${NC}%s\n" "$total_fascicoli"

    # Calcola ratio compilazione
    if [ "$total_tex" -gt 0 ]; then
        local ratio=$((100 * total_pdf / total_tex))
        printf "${YELLOW}✅ Ratio PDF/TEX:  ${NC}%s%%\n" "$ratio"
    fi
}

# Menu interattivo
interactive_menu() {
    local tex_files=($(find_tex_files))

    if [ ${#tex_files[@]} -eq 0 ]; then
        echo -e "${RED}❌ Nessun file .tex trovato in $INTERVENTI_DIR${NC}"
        echo -e "${YELLOW}🔍 Debug - Directory cercata: $INTERVENTI_DIR${NC}"
        echo -e "${YELLOW}🔍 Debug - Comando: find \"$INTERVENTI_DIR\" -name \"*.tex\" -type f${NC}"
        find "$INTERVENTI_DIR" -name "*.tex" -type f 2>&1 || echo "Errore nel comando find"
        exit 1
    fi

    echo -e "${BLUE}📋 File .tex disponibili (${#tex_files[@]} trovati):${NC}"
    echo

    # Array associativo compatibile con bash più vecchie
    declare -a file_paths
    local counter=1

    # Costruisci il menu
    for tex_file in "${tex_files[@]}"; do
        local info=$(extract_info "$tex_file")
        local instrument=$(echo "$info" | cut -d'|' -f1)
        local filepath=$(echo "$info" | cut -d'|' -f2)
        local filename=$(echo "$info" | cut -d'|' -f3)

        printf "${YELLOW}%2d)${NC} ${CYAN}%-25s${NC} ${MAGENTA}%s${NC}\n" \
            "$counter" "$instrument" "$filename"

        file_paths[$counter]="$filepath"
        ((counter++))
    done

    echo
    printf "${YELLOW}%2s)${NC} ${GREEN}%-25s${NC} ${MAGENTA}%s${NC}\n" \
        "a" "Compila tutto" "Tutti i file in sequenza"
    printf "${YELLOW}%2s)${NC} ${GREEN}%-25s${NC} ${MAGENTA}%s${NC}\n" \
        "s" "Statistiche" "Info sul repository"
    printf "${YELLOW}%2s)${NC} ${CYAN}%-25s${NC} ${MAGENTA}%s${NC}\n" \
        "c" "Pulizia" "Elimina file temporanei LaTeX"
    printf "${YELLOW}%2s)${NC} ${RED}%-25s${NC} ${MAGENTA}%s${NC}\n" \
        "q" "Quit" "Esci"

    echo
    read -p "$(echo -e ${BLUE}🎯 Scegli opzione: ${NC})" choice

    case "$choice" in
        [1-9]*)
            if [[ "$choice" -le "${#file_paths[@]}" ]] && [[ -n "${file_paths[$choice]}" ]]; then
                echo
                compile_tex "${file_paths[$choice]}"
            else
                echo -e "${RED}❌ Opzione non valida: $choice${NC}"
            fi
            ;;
        a|A)
            echo -e "${BLUE}🔧 Compilazione di tutti i file...${NC}"
            local success=0
            local total=${#tex_files[@]}

            for tex_file in "${tex_files[@]}"; do
                echo
                if compile_tex "$tex_file"; then
                    ((success++))
                else
                    echo -e "${RED}❌ Errore in $tex_file${NC}"
                fi
            done

            echo
            echo -e "${GREEN}📊 Completato: $success/$total file compilati con successo${NC}"
            ;;
        s|S)
            show_stats
            ;;
        c|C)
            cleanup_temp_files
            ;;
        q|Q)
            echo -e "${GREEN}👋 Arrivederci!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Opzione non valida: $choice${NC}"
            ;;
    esac
}

# Verifica prerequisiti
check_prerequisites() {
    if ! command -v pdflatex &> /dev/null; then
        echo -e "${RED}❌ pdflatex non trovato! Installare MacTeX.${NC}"
        exit 1
    fi

    if [ ! -d "$INTERVENTI_DIR" ]; then
        echo -e "${RED}❌ Directory interventi/ non trovata!${NC}"
        echo -e "${YELLOW}💡 Eseguire dalla directory root del progetto.${NC}"
        exit 1
    fi
}

# Gestione argomenti da linea di comando
handle_cli_args() {
    case "${1:-}" in
        --help|-h)
            echo "LEAP Compiler - Script di compilazione LaTeX"
            echo
            echo "Uso:"
            echo "  $0                 # Menu interattivo"
            echo "  $0 --all           # Compila tutti i file"
            echo "  $0 --clean         # Pulisce file temporanei"
            echo "  $0 --stats         # Mostra statistiche"
            echo "  $0 --help          # Questa guida"
            echo
            echo "Esempi:"
            echo "  $0                 # Avvia menu interattivo"
            echo "  $0 --all           # Compila tutto"
            echo "  $0 --clean         # Pulizia fine sessione"
            exit 0
            ;;
        --all)
            local tex_files=($(find_tex_files))
            echo -e "${BLUE}🔧 Compilazione batch di ${#tex_files[@]} file...${NC}"

            local success=0
            for tex_file in "${tex_files[@]}"; do
                echo
                if compile_tex "$tex_file"; then
                    ((success++))
                fi
            done

            echo
            echo -e "${GREEN}📊 Completato: $success/${#tex_files[@]} file compilati${NC}"
            exit 0
            ;;
        --clean)
            print_banner
            cleanup_temp_files
            exit 0
            ;;
        --stats)
            print_banner
            show_stats
            exit 0
            ;;
        "")
            # Nessun argomento, modalità interattiva
            ;;
        *)
            echo -e "${RED}❌ Argomento sconosciuto: $1${NC}"
            echo -e "${YELLOW}💡 Usa $0 --help per la guida${NC}"
            exit 1
            ;;
    esac
}

# Main
main() {
    handle_cli_args "$@"
    check_prerequisites
    print_banner

    echo -e "${GREEN}📁 Repository: $ROOT_DIR${NC}"
    echo -e "${GREEN}🎯 Modalità: Interattiva${NC}"
    echo

    # Loop principale
    while true; do
        interactive_menu
        echo
        read -p "$(echo -e ${BLUE}🔄 Continuare? [Y/n]: ${NC})" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo -e "${GREEN}👋 Arrivederci!${NC}"
            break
        fi
        echo
    done
}

# Avvia il programma
main "$@"
