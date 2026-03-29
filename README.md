<div align="center">

<!-- Typing Animation — readme-typing-svg by DenverCoder9 -->
[![Typing SVG](https://readme-typing-svg.demolab.com?font=Fira+Code&weight=700&size=32&duration=3000&pause=1000&color=00D9FF&center=true&vCenter=true&multiline=true&width=600&height=100&lines=🗂️+Organisateur+de+Fichiers;File+Organizer+v1.0.0)](https://git.io/typing-svg)

<br/>

> Script **Bash** intelligent pour organiser automatiquement vos fichiers par type et extension.

<br/>

<!-- Tech Stack Badges -->
### 🛠️ Stack Technique

<!-- Bash -->
<img src="https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white" alt="Bash"/>
<!-- Linux -->
<img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux"/>
<!-- GNU -->
<img src="https://img.shields.io/badge/GNU_Tools-A42E2B?style=for-the-badge&logo=gnu&logoColor=white" alt="GNU Tools"/>
<!-- Terminal -->
<img src="https://img.shields.io/badge/Terminal-241F31?style=for-the-badge&logo=gnometerminal&logoColor=white" alt="Terminal"/>
<!-- Git -->
<img src="https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white" alt="Git"/>
<!-- WSL -->
<img src="https://img.shields.io/badge/WSL2-0078D4?style=for-the-badge&logo=windows&logoColor=white" alt="WSL2"/>
<!-- VS Code -->
<img src="https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge&logo=visualstudiocode&logoColor=white" alt="VS Code"/>

<br/><br/>

<!-- Stats rapides -->
![Version](https://img.shields.io/badge/version-1.0.0-blue?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)
![Shell](https://img.shields.io/badge/shell-bash%204%2B-orange?style=flat-square&logo=gnubash)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20WSL-lightgrey?style=flat-square)

</div>

---

## ✨ Fonctionnalités

| Fonctionnalité | Description |
|---|---|
| 📂 **Tri automatique** | Classe les fichiers dans des dossiers selon leur extension |
| 🔍 **Mode simulation** | Prévisualise ce qui serait fait sans modifier quoi que ce soit |
| 📋 **Journal (log)** | Enregistre toutes les actions dans `organizer.log` |
| 📁 **Répertoire personnalisé** | Spécifiez n'importe quel répertoire en argument |
| 🛡️ **Gestion des erreurs** | Gère les conflits de noms, permissions refusées, etc. |
| 🎨 **Affichage coloré** | Interface terminal claire et lisible avec icônes |

---

## 📁 Catégories gérées

| Dossier | Extensions |
|---|---|
| 📷 `Images` | `.jpg`, `.jpeg`, `.png`, `.gif`, `.bmp`, `.svg`, `.webp`, `.tiff`, `.ico` |
| 📄 `Documents` | `.pdf`, `.docx`, `.doc`, `.txt`, `.odt`, `.xlsx`, `.csv`, `.pptx`, `.md` |
| 🎬 `Vidéos` | `.mp4`, `.mkv`, `.avi`, `.mov`, `.wmv`, `.flv`, `.webm`, `.mpeg` |
| 🎵 `Musique` | `.mp3`, `.wav`, `.ogg`, `.flac`, `.aac`, `.m4a`, `.wma`, `.opus` |
| 🗜️ `Archives` | `.zip`, `.tar`, `.gz`, `.bz2`, `.7z`, `.rar`, `.xz`, `.tgz` |
| 💻 `Code` | `.sh`, `.py`, `.js`, `.ts`, `.html`, `.css`, `.json`, `.php`, `.java` |
| 📦 `Autres` | Tout ce qui ne correspond à aucune catégorie ci-dessus |

---

## 🚀 Installation & Utilisation

### 1. Cloner / télécharger le projet

```bash
git clone <url-du-repo>
cd bash_project
```

### 2. Rendre le script exécutable

```bash
chmod +x organizer.sh
chmod +x create_test_files.sh
```

### 3. Utilisation de base

```bash
# Organise le répertoire courant
./organizer.sh

# Organise un répertoire spécifique
./organizer.sh ~/Téléchargements

# Afficher l'aide
./organizer.sh --help
```

### 4. Options avancées

```bash
# Mode simulation (dry-run) — RECOMMANDÉ avant le premier usage
./organizer.sh --dry-run ~/Téléchargements

# Activer le journal (log)
./organizer.sh --log ~/Téléchargements

# Combinaison : simulation + journal
./organizer.sh -d -l ~/Téléchargements
```

---

## 🧪 Tester sans risque

Un script de génération de fichiers factices est fourni pour tester en toute sécurité :

```bash
# Étape 1 : Créer des fichiers de test
./create_test_files.sh

# Étape 2 : Simuler l'organisation (aucun fichier ne bouge)
./organizer.sh --dry-run ./test_dir

# Étape 3 : Organiser réellement + créer un journal
./organizer.sh --log ./test_dir

# Étape 4 : Vérifier le résultat
ls -la ./test_dir/
cat ./test_dir/organizer.log
```

---

## 📋 Exemple de sortie

```
  ╔═══════════════════════════════════════════════════╗
  ║          🗂️  ORGANISATEUR DE FICHIERS  🗂️          ║
  ║                   Version 1.0.0                  ║
  ╚═══════════════════════════════════════════════════╝

  📁 Répertoire cible : /home/user/Téléchargements
  ─────────────────────────────────────────────────
  ✅ 'photo_vacances.jpg' → Téléchargements/Images/
  ✅ 'rapport.pdf'        → Téléchargements/Documents/
  ✅ 'film.mp4'           → Téléchargements/Vidéos/
  ⚠️  'backup.zip' existe déjà dans 'Archives/' → ignoré

  ════════════════════ RÉSUMÉ ════════════════════
  ✅ Fichiers déplacés : 3
  ⏭️  Fichiers ignorés   : 1
  ❌ Erreurs            : 0
  ════════════════════════════════════════════════

  Organisation terminée avec succès ! 🎉
```

---

## 📄 Structure du projet

```
bash_project/
├── organizer.sh           # Script principal
├── create_test_files.sh   # Générateur de fichiers de test
├── README.md              # Documentation
└── test_dir/              # (créé par create_test_files.sh)
    ├── Images/
    ├── Documents/
    ├── Vidéos/
    ├── Musique/
    ├── Archives/
    ├── Code/
    ├── Autres/
    └── organizer.log      # (créé avec l'option --log)
```

---

## 🔧 Personnalisation

Pour ajouter une nouvelle catégorie ou extension, éditez le tableau `CATEGORIES` dans `organizer.sh` :

```bash
declare -A CATEGORIES=(
    ["Images"]="jpg jpeg png gif bmp svg webp tiff ico"
    ["Documents"]="pdf docx doc txt odt xlsx xls csv pptx ppt md rst"
    # ... ajoutez votre catégorie ici :
    ["Ebooks"]="epub mobi azw3 fb2"
)
```

---

## ⚙️ Compatibilité

- ✅ Linux (Ubuntu, Debian, Fedora, Arch...)
- ✅ macOS (avec Bash 4+ via Homebrew : `brew install bash`)
- ✅ Windows avec WSL (Windows Subsystem for Linux)
- ✅ Git Bash / MSYS2

> **Note :** Le script requiert **Bash 4.0+** pour les tableaux associatifs (`declare -A`).  
> Vérifiez avec `bash --version`.

---

## 📜 Licence

MIT © 2026 — Libre d'utilisation, modification et distribution.
