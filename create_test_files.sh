#!/usr/bin/env bash
# =============================================================================
#  Générateur de fichiers de test — create_test_files.sh
# =============================================================================
#  Ce script crée un ensemble de fichiers factices dans un dossier "test_dir/"
#  pour pouvoir tester le script organizer.sh sans risquer vos vrais fichiers.
#
#  Usage : ./create_test_files.sh
# =============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Répertoire de test
TEST_DIR="./test_dir"

echo -e "${BOLD}${CYAN}Création du répertoire de test...${RESET}"
mkdir -p "$TEST_DIR"

# Tableau de fichiers de test à créer (nom → contenu simulé)
declare -A TEST_FILES=(
    # Images
    ["photo_vacances.jpg"]="JPEG image data"
    ["logo_entreprise.png"]="PNG image data"
    ["banniere.gif"]="GIF89a animation"
    ["avatar.jpeg"]="JPEG photo"
    ["icone_app.svg"]="<svg>...</svg>"

    # Documents
    ["rapport_annuel.pdf"]="PDF document content"
    ["notes_reunion.txt"]="Compte-rendu de la réunion du lundi"
    ["contrat.docx"]="Document Word content"
    ["budget.xlsx"]="Spreadsheet data"
    ["presentation.pptx"]="PowerPoint slides"
    ["lisez_moi.md"]="# Documentation"

    # Vidéos
    ["film_vacances.mp4"]="MP4 video data"
    ["tutoriel_bash.mkv"]="MKV video data"
    ["clip_musique.avi"]="AVI video data"

    # Musique
    ["chanson_favorite.mp3"]="MP3 audio data"
    ["ambiance.wav"]="WAV audio PCM"
    ["podcast.ogg"]="OGG audio data"
    ["album_track.flac"]="FLAC lossless audio"

    # Archives
    ["backup_projet.zip"]="PK archive data"
    ["sources.tar.gz"]="gzip compressed tar"
    ["donnees.7z"]="7-Zip archive"

    # Code
    ["script_deploy.sh"]="#!/bin/bash"
    ["app.py"]="print('Hello World')"
    ["index.html"]="<!DOCTYPE html>"
    ["style.css"]="body { margin: 0; }"
    ["config.json"]='{"version": "1.0"}'

    # Fichiers sans extension (doivent aller dans Autres)
    ["makefile"]="all: build"
    ["readme"]="Read me first"

    # Fichiers cachés (doivent être ignorés)
    [".gitignore"]="*.log"
    [".env"]="SECRET_KEY=abc123"
)

echo -e "${CYAN}Création des fichiers de test...${RESET}"
echo ""

count=0
for filename in "${!TEST_FILES[@]}"; do
    content="${TEST_FILES[$filename]}"
    echo "$content" > "${TEST_DIR}/${filename}"
    echo -e "  ${GREEN}✓${RESET} Créé : ${filename}"
    (( count++ )) || true
done

echo ""
echo -e "${BOLD}${GREEN}✅ ${count} fichiers de test créés dans '${TEST_DIR}/'${RESET}"
echo ""
echo -e "Pour tester l'organisateur, lancez :"
echo -e "  ${CYAN}./organizer.sh --dry-run ${TEST_DIR}${RESET}   # Simulation d'abord"
echo -e "  ${CYAN}./organizer.sh -l ${TEST_DIR}${RESET}           # Organisation réelle + journal"
echo ""
