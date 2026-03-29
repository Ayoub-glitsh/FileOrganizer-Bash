#!/usr/bin/env bash
# =============================================================================
#  Organisateur de Fichiers — File Organizer
# =============================================================================
#  Auteur  : Organisateur de Fichiers Project
#  Version : 1.0.0
#  Usage   : ./organizer.sh [OPTIONS] [RÉPERTOIRE]
#
#  Description :
#    Ce script organise automatiquement les fichiers d'un répertoire donné
#    (ou du répertoire courant par défaut) en les classant dans des
#    sous-dossiers selon leurs extensions.
#
#  Options :
#    -d, --dry-run       Mode simulation : affiche ce qui serait fait sans
#                        déplacer aucun fichier.
#    -l, --log           Active l'enregistrement dans organizer.log
#    -h, --help          Affiche ce message d'aide.
#
#  Exemples :
#    ./organizer.sh                     # Organise le répertoire courant
#    ./organizer.sh ~/Téléchargements   # Organise un répertoire spécifique
#    ./organizer.sh --dry-run           # Simulation dans le répertoire courant
#    ./organizer.sh -d -l ~/Bureau      # Simulation + log sur ~/Bureau
# =============================================================================

# ---------------------------------------------------------------------------
# CONFIGURATION STRICTE DU SHELL
# ---------------------------------------------------------------------------
# -e : arrête le script en cas d'erreur
# -u : traite les variables non définies comme des erreurs
# -o pipefail : propage les erreurs dans les pipes
set -euo pipefail

# ---------------------------------------------------------------------------
# COULEURS ET STYLES POUR L'AFFICHAGE TERMINAL
# ---------------------------------------------------------------------------
# Vérifie si le terminal supporte les couleurs
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    MAGENTA='\033[0;35m'
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
else
    # Pas de couleurs si la sortie n'est pas un terminal (ex: pipe vers fichier)
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' MAGENTA='' BOLD='' DIM='' RESET=''
fi

# ---------------------------------------------------------------------------
# VARIABLES GLOBALES
# ---------------------------------------------------------------------------
SCRIPT_NAME="$(basename "$0")"         # Nom du script
SCRIPT_VERSION="1.0.0"                 # Version du script
LOG_FILE="organizer.log"               # Nom du fichier de journal
DRY_RUN=false                          # Mode simulation désactivé par défaut
LOGGING=false                          # Journalisation désactivée par défaut
TARGET_DIR="."                         # Répertoire cible (courant par défaut)

# Compteurs de statistiques
COUNT_MOVED=0          # Nombre de fichiers déplacés avec succès
COUNT_SKIPPED=0        # Nombre de fichiers ignorés (déjà présents, etc.)
COUNT_ERRORS=0         # Nombre d'erreurs rencontrées

# ---------------------------------------------------------------------------
# DÉFINITION DES CATÉGORIES ET EXTENSIONS
# ---------------------------------------------------------------------------
# Chaque tableau associe un nom de dossier à une liste d'extensions séparées
# par des espaces. Ajouter une entrée ici suffit pour supporter un nouveau type.

declare -A CATEGORIES=(
    ["Images"]="jpg jpeg png gif bmp svg webp tiff ico"
    ["Documents"]="pdf docx doc txt odt xlsx xls csv pptx ppt md rst"
    ["Vidéos"]="mp4 mkv avi mov wmv flv webm m4v mpeg mpg"
    ["Musique"]="mp3 wav ogg flac aac m4a wma opus"
    ["Archives"]="zip tar gz bz2 7z rar xz tgz tar.gz tar.bz2"
    ["Code"]="sh py js ts html css json xml yaml yml php rb java c cpp h go rs"
    ["Autres"]=""   # Catch-all pour les extensions non reconnues
)

# ---------------------------------------------------------------------------
# FONCTIONS UTILITAIRES
# ---------------------------------------------------------------------------

# Affiche la bannière d'accueil du script
print_banner() {
    echo -e "${BOLD}${CYAN}"
    echo "  ╔═══════════════════════════════════════════════════╗"
    echo "  ║          🗂️  ORGANISATEUR DE FICHIERS  🗂️          ║"
    echo "  ║                   Version ${SCRIPT_VERSION}                  ║"
    echo "  ╚═══════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

# Affiche l'aide complète du script
print_help() {
    print_banner
    echo -e "${BOLD}UTILISATION :${RESET}"
    echo "  ./${SCRIPT_NAME} [OPTIONS] [RÉPERTOIRE]"
    echo ""
    echo -e "${BOLD}OPTIONS :${RESET}"
    echo "  -d, --dry-run    Mode simulation (aucun fichier déplacé)"
    echo "  -l, --log        Enregistre les actions dans '${LOG_FILE}'"
    echo "  -h, --help       Affiche ce message d'aide"
    echo ""
    echo -e "${BOLD}EXEMPLES :${RESET}"
    echo "  ./${SCRIPT_NAME}                        # Répertoire courant"
    echo "  ./${SCRIPT_NAME} ~/Téléchargements      # Répertoire spécifique"
    echo "  ./${SCRIPT_NAME} --dry-run              # Simulation"
    echo "  ./${SCRIPT_NAME} -d -l ~/Bureau         # Simulation + journal"
    echo ""
    echo -e "${BOLD}CATÉGORIES GÉRÉES :${RESET}"
    for category in "${!CATEGORIES[@]}"; do
        printf "  ${CYAN}%-12s${RESET} → %s\n" "$category" "${CATEGORIES[$category]}"
    done
    echo ""
}

# ---------------------------------------------------------------------------
# log_message [NIVEAU] [MESSAGE]
# Affiche un message formaté et l'écrit dans le journal si activé.
# Niveaux : INFO | SUCCESS | WARNING | ERROR | DRY
# ---------------------------------------------------------------------------
log_message() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    # Sélectionne la couleur et l'icône selon le niveau de log
    local color icon
    case "$level" in
        INFO)    color="${BLUE}";    icon="ℹ️ " ;;
        SUCCESS) color="${GREEN}";   icon="✅" ;;
        WARNING) color="${YELLOW}";  icon="⚠️ " ;;
        ERROR)   color="${RED}";     icon="❌" ;;
        DRY)     color="${MAGENTA}"; icon="🔍" ;;
        *)       color="${RESET}";   icon="  " ;;
    esac

    # Affiche le message dans le terminal avec couleur
    echo -e "  ${color}${icon} ${message}${RESET}"

    # Si la journalisation est activée, écrit dans le fichier log (sans codes couleur)
    if [[ "$LOGGING" == true ]]; then
        echo "[$timestamp] [$level] $message" >> "${TARGET_DIR}/${LOG_FILE}"
    fi
}

# ---------------------------------------------------------------------------
# get_category_for_extension [EXTENSION]
# Retourne le nom du dossier correspondant à une extension donnée.
# Retourne "Autres" si l'extension n'est pas reconnue.
# ---------------------------------------------------------------------------
get_category_for_extension() {
    local ext="${1,,}"   # Convertit l'extension en minuscules

    # Parcourt chaque catégorie et ses extensions associées
    for category in "${!CATEGORIES[@]}"; do
        # Ignore la catégorie "Autres" (catch-all)
        [[ "$category" == "Autres" ]] && continue

        # Vérifie si l'extension est dans la liste de la catégorie
        for known_ext in ${CATEGORIES[$category]}; do
            if [[ "$ext" == "$known_ext" ]]; then
                echo "$category"
                return 0
            fi
        done
    done

    # Aucune catégorie trouvée → retourne "Autres"
    echo "Autres"
}

# ---------------------------------------------------------------------------
# ensure_directory [CHEMIN]
# Crée un répertoire s'il n'existe pas encore.
# En mode dry-run, simule uniquement la création.
# ---------------------------------------------------------------------------
ensure_directory() {
    local dir_path="$1"

    if [[ ! -d "$dir_path" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            log_message "DRY" "Créerait le dossier : ${dir_path}"
        else
            # Crée le dossier (et les parents si nécessaire) et gère les erreurs
            if mkdir -p "$dir_path" 2>/dev/null; then
                log_message "INFO" "Dossier créé : ${dir_path}"
            else
                log_message "ERROR" "Impossible de créer le dossier : ${dir_path}"
                return 1
            fi
        fi
    fi
    return 0
}

# ---------------------------------------------------------------------------
# move_file [FICHIER_SOURCE] [DOSSIER_DESTINATION]
# Déplace un fichier vers le dossier de destination.
# Gère les conflits de nom et les erreurs de permission.
# En mode dry-run, simule uniquement le déplacement.
# ---------------------------------------------------------------------------
move_file() {
    local source_file="$1"
    local dest_dir="$2"
    local filename
    filename="$(basename "$source_file")"
    local dest_file="${dest_dir}/${filename}"

    # --- MODE SIMULATION (DRY-RUN) ---
    if [[ "$DRY_RUN" == true ]]; then
        if [[ -f "$dest_file" ]]; then
            log_message "DRY" "[SIMULATION] '${filename}' → ${dest_dir}/ (⚠️  fichier déjà existant)"
        else
            log_message "DRY" "[SIMULATION] '${filename}' → ${dest_dir}/"
        fi
        (( COUNT_MOVED++ )) || true
        return 0
    fi

    # --- MODE RÉEL ---

    # Vérification : le fichier destination existe déjà ?
    if [[ -f "$dest_file" ]]; then
        log_message "WARNING" "'${filename}' existe déjà dans '${dest_dir}/' → ignoré"
        (( COUNT_SKIPPED++ )) || true
        return 0
    fi

    # Tentative de déplacement du fichier
    if mv "$source_file" "$dest_file" 2>/dev/null; then
        log_message "SUCCESS" "'${filename}' → ${dest_dir}/"
        (( COUNT_MOVED++ )) || true
    else
        # Gestion des erreurs : permission refusée, disque plein, etc.
        local error_code=$?
        if [[ ! -w "$dest_dir" ]]; then
            log_message "ERROR" "Permission refusée pour '${filename}' → ${dest_dir}/"
        elif [[ ! -r "$source_file" ]]; then
            log_message "ERROR" "Impossible de lire '${filename}' (permission refusée)"
        else
            log_message "ERROR" "Échec du déplacement de '${filename}' (code: ${error_code})"
        fi
        (( COUNT_ERRORS++ )) || true
        return 1
    fi
}

# ---------------------------------------------------------------------------
# print_summary
# Affiche un résumé des opérations effectuées à la fin du script.
# ---------------------------------------------------------------------------
print_summary() {
    echo ""
    echo -e "${BOLD}${CYAN}  ════════════════════ RÉSUMÉ ════════════════════${RESET}"

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${MAGENTA}  🔍 Mode simulation — aucun fichier n'a été déplacé${RESET}"
        echo ""
    fi

    echo -e "  ${GREEN}✅ Fichiers déplacés (ou simulés) : ${BOLD}${COUNT_MOVED}${RESET}"
    echo -e "  ${YELLOW}⏭️  Fichiers ignorés (déjà présents) : ${BOLD}${COUNT_SKIPPED}${RESET}"
    echo -e "  ${RED}❌ Erreurs rencontrées              : ${BOLD}${COUNT_ERRORS}${RESET}"

    if [[ "$LOGGING" == true ]]; then
        echo ""
        echo -e "  ${DIM}📋 Journal enregistré dans : ${TARGET_DIR}/${LOG_FILE}${RESET}"
    fi

    echo -e "${CYAN}  ══════════════════════════════════════════════${RESET}"
    echo ""

    # Message de conclusion selon le résultat
    if [[ $COUNT_ERRORS -eq 0 && $COUNT_MOVED -gt 0 ]]; then
        echo -e "  ${GREEN}${BOLD}Organisation terminée avec succès ! 🎉${RESET}"
    elif [[ $COUNT_MOVED -eq 0 && $COUNT_SKIPPED -eq 0 && $COUNT_ERRORS -eq 0 ]]; then
        echo -e "  ${YELLOW}${BOLD}Aucun fichier à organiser trouvé.${RESET}"
    elif [[ $COUNT_ERRORS -gt 0 ]]; then
        echo -e "  ${YELLOW}${BOLD}Organisation terminée avec ${COUNT_ERRORS} erreur(s). Vérifiez les permissions.${RESET}"
    else
        echo -e "  ${CYAN}${BOLD}Organisation terminée.${RESET}"
    fi
    echo ""
}

# ---------------------------------------------------------------------------
# organize_directory [RÉPERTOIRE]
# Fonction principale qui parcourt le répertoire et organise les fichiers.
# ---------------------------------------------------------------------------
organize_directory() {
    local target="$1"

    echo ""
    echo -e "${BOLD}  📁 Répertoire cible : ${CYAN}${target}${RESET}"
    echo -e "${DIM}  ─────────────────────────────────────────────────${RESET}"

    # Initialise le fichier de journal avec un en-tête si activé
    if [[ "$LOGGING" == true && "$DRY_RUN" == false ]]; then
        {
            echo "======================================================"
            echo " JOURNAL — Organisateur de Fichiers v${SCRIPT_VERSION}"
            echo " Date     : $(date '+%Y-%m-%d %H:%M:%S')"
            echo " Répertoire : ${target}"
            echo "======================================================"
        } >> "${target}/${LOG_FILE}"
    fi

    # Compteur pour savoir si on a trouvé des fichiers à traiter
    local files_found=0

    # Parcourt TOUS les fichiers dans le répertoire cible (non récursif)
    # Le globbing est utilisé pour éviter les problèmes avec les noms de fichiers spéciaux
    while IFS= read -r -d '' file; do

        # ---- Ignore les éléments qui ne sont pas des fichiers réguliers ----
        [[ -f "$file" ]] || continue

        # Récupère le nom de fichier sans le chemin
        local filename
        filename="$(basename "$file")"

        # ---- Ignore le script lui-même et le fichier de journal ----
        [[ "$filename" == "$SCRIPT_NAME" ]] && continue
        [[ "$filename" == "$LOG_FILE" ]] && continue

        # ---- Ignore les fichiers cachés (commençant par un point) ----
        [[ "$filename" == .* ]] && continue

        (( files_found++ )) || true

        # ---- Détermine l'extension du fichier ----
        local extension=""
        if [[ "$filename" == *.* ]]; then
            extension="${filename##*.}"   # Extrait ce qui est après le dernier point
        fi

        # ---- Trouve la catégorie correspondante ----
        local category
        if [[ -z "$extension" ]]; then
            # Fichier sans extension → dossier "Autres"
            category="Autres"
        else
            category="$(get_category_for_extension "$extension")"
        fi

        # ---- Construit le chemin du dossier de destination ----
        local dest_dir="${target}/${category}"

        # ---- Crée le dossier si nécessaire ----
        ensure_directory "$dest_dir" || continue

        # ---- Déplace le fichier ----
        move_file "$file" "$dest_dir"

    done < <(find "$target" -maxdepth 1 -type f -print0)
    # -maxdepth 1 : seulement le niveau courant (pas récursif)
    # -type f     : seulement les fichiers réguliers (ignore les dossiers)
    # -print0     : séparateur null (gère les espaces dans les noms)

    # Affiche un message si aucun fichier n'a été trouvé
    if [[ $files_found -eq 0 ]]; then
        log_message "INFO" "Aucun fichier à organiser dans '${target}'"
    fi
}

# ---------------------------------------------------------------------------
# POINT D'ENTRÉE PRINCIPAL — Analyse des arguments
# ---------------------------------------------------------------------------
main() {
    # ---- Analyse des options de la ligne de commande ----
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                # Affiche l'aide et quitte proprement
                print_help
                exit 0
                ;;
            -d|--dry-run)
                # Active le mode simulation
                DRY_RUN=true
                shift
                ;;
            -l|--log)
                # Active la journalisation dans organizer.log
                LOGGING=true
                shift
                ;;
            -*)
                # Option inconnue → erreur
                echo -e "${RED}Erreur : option inconnue '$1'${RESET}" >&2
                echo "Utilisez './${SCRIPT_NAME} --help' pour l'aide." >&2
                exit 1
                ;;
            *)
                # Argument positionnel : chemin du répertoire cible
                TARGET_DIR="$1"
                shift
                ;;
        esac
    done

    # ---- Validation du répertoire cible ----
    # Résout le chemin absolu pour les messages d'erreur clairs
    TARGET_DIR="$(realpath "$TARGET_DIR" 2>/dev/null || echo "$TARGET_DIR")"

    if [[ ! -d "$TARGET_DIR" ]]; then
        echo -e "${RED}❌ Erreur : le répertoire '${TARGET_DIR}' n'existe pas.${RESET}" >&2
        exit 1
    fi

    if [[ ! -r "$TARGET_DIR" ]]; then
        echo -e "${RED}❌ Erreur : permission de lecture refusée pour '${TARGET_DIR}'.${RESET}" >&2
        exit 1
    fi

    # ---- Affichage de la bannière ----
    print_banner

    # ---- Affiche les modes actifs ----
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${MAGENTA}${BOLD}🔍 MODE SIMULATION ACTIVÉ — aucun fichier ne sera déplacé${RESET}"
    fi
    if [[ "$LOGGING" == true ]]; then
        echo -e "  ${BLUE}📋 Journalisation activée → ${TARGET_DIR}/${LOG_FILE}${RESET}"
    fi

    # ---- Lance l'organisation du répertoire ----
    organize_directory "$TARGET_DIR"

    # ---- Affiche le résumé final ----
    print_summary

    # ---- Code de sortie selon les erreurs ----
    # Retourne 0 si tout s'est bien passé, 1 s'il y a eu des erreurs
    [[ $COUNT_ERRORS -eq 0 ]]
}

# Lance le programme principal avec tous les arguments passés au script
main "$@"
