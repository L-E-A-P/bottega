# Setup LaTeX con Font OCR-A e AlegreyaSans

Guida completa per l'installazione e l'uso del sistema di documentazione LEAP con font OCR-A e AlegreyaSans.

## Prerequisiti

- **MacTeX 2025** installato
- **MacPorts** installato (per font OCR-A)
- **Terminale** per i comandi di installazione
- **Editor LaTeX** (TeXShop, VS Code, etc.)

## Installazione Font OCR-A

### Metodo 1: Installazione da MacPorts (Raccomandato)

Se hai MacPorts installato, OCR-A potrebbe già essere disponibile:

```bash
# Verifica se OCR-A è già installato tramite MacPorts
find /opt/local/share/texmf-local -name "*ocr*" -path "*/ocr-a/*" -type f
```

Se trovi file, procedi con l'installazione:

```bash
#!/bin/bash
echo "=== INSTALLAZIONE OCR-A DA MACPORTS ==="

# 1. Crea struttura directory personale
mkdir -p ~/Library/texmf/fonts/tfm/ocr-a
mkdir -p ~/Library/texmf/fonts/type1/ocr-a
mkdir -p ~/Library/texmf/fonts/source/ocr-a
mkdir -p ~/Library/texmf/fonts/map/pdftex/ocr-a

# 2. Copia file TFM da MacPorts
cp /opt/local/share/texmf-local/fonts/tfm/public/ocr-a/*.tfm ~/Library/texmf/fonts/tfm/ocr-a/

# 3. Copia file sorgente (.mf)
cp /opt/local/share/texmf-local/fonts/source/ocr-a/*.mf ~/Library/texmf/fonts/source/ocr-a/

# 4. Crea file MAP per pdfTeX
cat > ~/Library/texmf/fonts/map/pdftex/ocr-a/ocr.map << 'EOF'
ocr10 OCR10 <ocr10.pfb
ocr12 OCR12 <ocr12.pfb  
ocr16 OCR16 <ocr16.pfb
EOF

# 5. Aggiorna database TeXLive
mktexlsr ~/Library/texmf

# 6. Attiva mappa font (IMPORTANTE: usa -user)
updmap-user --enable Map=ocr.map

echo "✅ Installazione OCR-A completata!"
```

### Metodo 2: Installazione manuale da CTAN (Se MacPorts non disponibile)

```bash
# 1. Download e preparazione
cd ~/Downloads
curl -O https://mirrors.ctan.org/fonts/ocr-a.zip
unzip ocr-a.zip
cd ocr-a

# 2. Correzione bug nei file METAFONT
sed -i '' 's/input ocra/input ocr-a/' ocr10.mf
sed -i '' 's/input ocra/input ocr-a/' ocr12.mf
sed -i '' 's/input ocra/input ocr-a/' ocr16.mf

# 3. Verifica correzioni
tail -1 ocr10.mf ocr12.mf ocr16.mf
# Dovrebbe mostrare "input ocr-a;" per tutti e tre

# 4. Installazione nel sistema
kpsewhich -var-value=TEXMFLOCAL
sudo mkdir -p $(kpsewhich -var-value=TEXMFLOCAL)/fonts/source
sudo mv ocr-a $(kpsewhich -var-value=TEXMFLOCAL)/fonts/source/
sudo mktexlsr
```

### Test installazione OCR-A

```bash
# Test con LaTeX
cat > /tmp/test-ocr-final.tex << 'EOF'
\documentclass{article}
\begin{document}
\font\testocr=ocr10
{\testocr OCR-A ABCDEFGHIJKLMNOPQRSTUVWXYZ}
{\testocr 0123456789}
{\testocr KATHEDRALE GONG EOLICO}
\end{document}
EOF

cd /tmp && pdflatex test-ocr-final.tex && open test-ocr-final.pdf
```

Se vedi il testo renderizzato correttamente, l'installazione è riuscita!

## Verifica AlegreyaSans

AlegreyaSans dovrebbe essere già incluso in MacTeX 2025. Verifica con:

```bash
# Test rapido
cat > test-alegreya.tex << 'EOF'
\documentclass{article}
\usepackage{AlegreyaSans}
\renewcommand{\familydefault}{\sfdefault}
\begin{document}
Questo è un test di AlegreyaSans.
\end{document}
EOF

pdflatex test-alegreya.tex
```

## Uso nei Documenti

### Template base

```latex
\documentclass[a4paper,12pt]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[italian]{babel}
\usepackage{AlegreyaSans}

% Attiva AlegreyaSans come font di default
\renewcommand{\familydefault}{\sfdefault}

\usepackage{tikz}
\usetikzlibrary{calc}
\usepackage[left=3cm, right=2cm, top=0.7cm, bottom=0.7cm]{geometry}
\usepackage{qrcode}
\usepackage[hidelinks]{hyperref}

% Font OCR-A a comando
\newfont{\ocrfontsmall}{ocr10 at 8pt}
\newfont{\ocrfontnormal}{ocr10}
\newfont{\ocrfontlarge}{ocr10 at 14pt}
\newfont{\ocrfonthuge}{ocr10 at 18pt}

% Comandi semplici per usare OCR-A
\newcommand{\ocr}[1]{{\ocrfontnormal #1}}
\newcommand{\ocrsmall}[1]{{\ocrfontsmall #1}}
\newcommand{\ocrlarge}[1]{{\ocrfontlarge #1}}
\newcommand{\ocrhuge}[1]{{\ocrfonthuge #1}}

% Comando per il codice identificativo verticale
\newcommand{\codiceverticale}[1]{%
    \begin{tikzpicture}[remember picture, overlay]
        \node[rotate=90, anchor=south] at ($(current page.west) + (3cm, 0cm)$) {%
            {\font\tempocr=ocr10 at 81pt \tempocr #1}%
        };
    \end{tikzpicture}%
}

\begin{document}
\thispagestyle{empty}

% Codice identificativo del documento
\codiceverticale{LEAP190725BR0001}

% Il tuo contenuto qui
Testo in AlegreyaSans con codici \ocr{OCR-A} integrati.

\end{document}
```

### Comandi disponibili

#### Font OCR-A
- `\ocr{TESTO}` - OCR-A dimensione normale
- `\ocrsmall{testo}` - OCR-A piccolo
- `\ocrlarge{TESTO}` - OCR-A grande
- `\ocrhuge{TESTO}` - OCR-A molto grande

**Nota**: OCR-A funziona meglio con MAIUSCOLE e NUMERI. Caratteri minuscoli e simboli potrebbero non essere disponibili.

#### Codice verticale
- `\codiceverticale{CODICE}` - Codice identificativo sul margine sinistro

#### QR Code cliccabili
```latex
\href{https://esempio.com}{
    \qrcode[height=3cm]{https://esempio.com}
}
```

## Compilazione con LEAP Compiler

Il sistema LEAP include uno script di compilazione interattivo che sostituisce i Makefile complessi con un'interfaccia semplice e user-friendly.

### Installazione dello script

Lo script `compile.sh` dovrebbe essere presente nella directory root del progetto. Se non c'è, crealo con il contenuto fornito negli artifact.

```bash
# Rendi eseguibile lo script
chmod +x compile.sh
```

### Uso dello script

#### Modalità interattiva (raccomandato)
```bash
# Avvia il menu interattivo
./compile.sh
```

Il menu mostrerà:
- **Lista numerata** di tutti i file .tex disponibili
- **Informazioni** su strumento e tipo di documento
- **Opzioni aggiuntive**: compila tutto, statistiche, pulizia

#### Modalità da linea di comando
```bash
# Compila tutti i file
./compile.sh --all

# Statistiche del repository
./compile.sh --stats

# Pulizia file temporanei
./compile.sh --clean

# Aiuto
./compile.sh --help
```

### Funzionalità dello script

#### 🎯 **Compilazione intelligente**
- **Doppia compilazione automatica** (per QR code e riferimenti)
- **Pulizia automatica** dei file temporanei dopo la compilazione
- **Gestione errori** con indicazione dei log da controllare
- **Apertura automatica** del PDF compilato (opzionale)

#### 🧹 **Pulizia file temporanei**
Lo script può eliminare automaticamente i file temporanei LaTeX:
- `.aux`, `.log`, `.out`, `.synctex.gz`
- `.fls`, `.fdb_latexmk`, `.toc`, `.lof`, `.lot`
- `.bbl`, `.blg`

```bash
# Durante la sessione di lavoro
./compile.sh              # Menu interattivo

# A fine sessione per pulire
./compile.sh --clean       # Pulizia rapida
```

#### 📊 **Statistiche repository**
```bash
./compile.sh --stats
```

Mostra:
- Numero totale di strumenti
- File .tex e .pdf presenti
- Report e fascicoli
- Ratio di compilazione (PDF/TEX)

### Workflow consigliato

#### 1. **Sessione di lavoro tipica**
```bash
# Avvia compilazione interattiva
./compile.sh

# Nel menu:
# - Scegli il numero del file da compilare
# - Oppure 'a' per compilare tutto
# - Oppure 's' per statistiche
# - Oppure 'c' per pulizia
```

#### 2. **Fine sessione**
```bash
# Pulisci tutti i file temporanei
./compile.sh --clean

# Verifica stato finale
./compile.sh --stats
```

#### 3. **Compilazione batch**
```bash
# Compila tutto il repository
./compile.sh --all
```

### Vantaggi rispetto ai Makefile

✅ **Semplicità**: Un solo script vs. multipli Makefile complessi  
✅ **Interattività**: Menu visuale vs. comandi da ricordare  
✅ **Feedback**: Output colorato e informativo  
✅ **Flessibilità**: Modalità interattiva e batch  
✅ **Manutenzione**: Facile da modificare e estendere  
✅ **Debug**: Informazioni chiare su errori e log  

### Personalizzazione

Lo script può essere facilmente personalizzato modificando le variabili in testa:

```bash
# Configurazione (modifica se necessario)
ROOT_DIR="$(pwd)"
INTERVENTI_DIR="$ROOT_DIR/interventi"

# Estensioni file temporanei da eliminare
temp_extensions=("*.aux" "*.log" "*.out" "*.synctex.gz" ...)
```

## Risoluzione Problemi

### Font OCR-A non trovato

1. **Verifica installazione MacPorts**:
   ```bash
   find /opt/local/share/texmf-local -name "*ocr*" -type f
   ```

2. **Verifica database TeX**:
   ```bash
   kpsewhich ocr10.tfm
   ```

3. **Se non funziona, pulisci cache**:
   ```bash
   rm -rf ~/.texlive2025/texmf-var/fonts/pk/ljfour/ocr-a/
   mktexlsr ~/Library/texmf
   ```

### OCR-A compila ma caratteri mancanti

È normale! OCR-A include principalmente:
- **Maiuscole**: A-Z ✅
- **Numeri**: 0-9 ✅  
- **Simboli base**: . , - + ✅
- **Minuscole**: Spesso assenti ❌

### TeXShop vs Terminale

Se TeXShop non compila ma il terminale sì:

1. **Verifica motore**: TeXShop deve usare pdfLaTeX
2. **Forza compilazione**: Aggiungi `%!TEX program = pdflatex` all'inizio del file
3. **PATH diversi**: TeXShop potrebbe non vedere i font locali

### Script non trova file

Se `./compile.sh` non trova file .tex:

1. **Verifica directory**: Esegui dalla root del progetto
2. **Controlla struttura**: Directory `interventi/` deve esistere
3. **Debug attivo**: Lo script mostra informazioni di ricerca

```bash
# Debug manuale
find interventi -name "*.tex" -type f
```

### Errori di compilazione

Se un file non compila:

1. **Controlla log**: Lo script indica il percorso del file .log
2. **Testa manualmente**:
   ```bash
   cd path/to/file
   pdflatex filename.tex
   ```
3. **Verifica font**: Usa il test OCR-A descritto sopra

### AlegreyaSans non attivo
```bash
# Verifica pacchetto
kpsewhich AlegreyaSans.sty

# Se non trovato
tlmgr install alegreya
```

### QR code non funzionano
```bash
# Verifica pacchetto qrcode
kpsewhich qrcode.sty

# Se necessario
tlmgr install qrcode
```

## Diagnostic Script

Se hai problemi, usa questo script per diagnosticare:

```bash
#!/bin/bash
echo "=== DIAGNOSTIC LEAP SYSTEM ==="

echo "1. Font OCR-A:"
kpsewhich ocr10.tfm && echo "✅ OCR-A trovato" || echo "❌ OCR-A mancante"

echo -e "\n2. Pacchetti LaTeX:"
kpsewhich AlegreyaSans.sty && echo "✅ AlegreyaSans OK" || echo "❌ AlegreyaSans mancante"
kpsewhich qrcode.sty && echo "✅ QRcode OK" || echo "❌ QRcode mancante"

echo -e "\n3. Struttura progetto:"
[ -f "./compile.sh" ] && echo "✅ Script presente" || echo "❌ Script mancante"
[ -d "./interventi" ] && echo "✅ Directory interventi OK" || echo "❌ Directory mancante"

echo -e "\n4. File .tex trovati:"
find interventi -name "*.tex" -type f 2>/dev/null | wc -l | awk '{print $1 " file trovati"}'

echo -e "\n5. Test compilazione:"
echo '\documentclass{article}\begin{document}Test\end{document}' > /tmp/test.tex
cd /tmp && pdflatex test.tex >/dev/null 2>&1 && echo "✅ pdflatex funziona" || echo "❌ Problema con pdflatex"
```

## Convenzioni di Naming

### Codici identificativi
- **Formato**: `LEAP + GGMMAA + TIPO + NUMERO`
- **Esempio**: `LEAP190725BR0001`
  - `LEAP` = Laboratorio
  - `190725` = 19 Luglio 2025
  - `BR` = Bottega/Restauro
  - `0001` = Numero progressivo

### File LaTeX
- **Formato**: `LEAP190725BR0001.tex`
- **Corrispondenza**: Nome file = Codice identificativo

## Template Disponibili

1. **report_restauro.tex** - Report completo di restauro
2. **LEAP190725BR000X.tex** - Interventi di bottega
3. **documento_intestato.tex** - Documento base con intestazione

## Note Tecniche

- **OCR-A**: Font ottimizzato per maiuscole e numeri, limitato per minuscole
- **AlegreyaSans**: Font principale per leggibilità
- **QR Code**: Generati automaticamente, cliccabili nei PDF
- **Codici verticali**: Posizionati a 3cm dal bordo sinistro
- **Compilazione**: Script automatico con doppia compilazione
- **Pulizia**: Automatica dopo ogni compilazione
- **Mappe font**: Installazione locale in `~/Library/texmf`
- **Compatibilità**: Testato su macOS con MacTeX 2025 e MacPorts

## Supporto

Per problemi tecnici, verificare nell'ordine:

### Sistema di base
1. **MacTeX 2025** installato e funzionante
2. **MacPorts** installato (se si usa OCR-A)
3. **Script compile.sh** presente ed eseguibile

### Font OCR-A
1. **MacPorts installato** e font OCR-A presente
2. **Script di installazione** eseguito correttamente
3. **Database TeX aggiornato** con `mktexlsr`
4. **Mappe font attive** con `updmap-user`

### Compilazione
1. **Directory corretta**: Esegui dalla root del progetto
2. **File .tex presenti**: In sottocartelle di `interventi/`
3. **Uso corretto**: `./compile.sh` per menu interattivo
4. **Log di errore**: Controlla i file .log indicati

---

**Versione**: 1.2  
**Data**: 7 Agosto 2025  
**Autore**: LEAP - Laboratorio ElettroAcustico Permanente  
**Aggiornamento**: Aggiunto LEAP Compiler script, rimossi Makefile
