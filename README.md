# Odoo Template

Template reusable pour créer rapidement de nouveaux projets Odoo Enterprise.

**Version**: 0.1.0
**Odoo Version**: 18.0 Enterprise
**Stack**: Docker + Docker Compose + PostgreSQL

---

## 📋 À propos de ce Template

Ce repository est un **template** pour créer de nouveaux projets Odoo. Il contient:

- ✅ Structure de projet standardisée
- ✅ Docker + Docker Compose configurés
- ✅ Module custom de base (renommable)
- ✅ Scripts d'automatisation
- ✅ Configuration PyCharm pour développement local
- ✅ Scripts de base de données (anonymisation, etc.)

---

## 🚀 Créer un Nouveau Projet depuis ce Template

### Méthode 1: GitHub (Recommandée)
```bash
# 1. Aller sur https://github.com/<org>/odoo-template
# 2. Cliquer sur "Use this template" → "Create a new repository"
# 3. Donner un nom: odoo-<project> (ex: odoo-crm)
```

### Méthode 2: Clone + Setup
```bash
# 1. Cloner le template
git clone https://github.com/<org>/odoo-template.git odoo-<project>
cd odoo-<project>

# 2. Exécuter le script de setup
./scripts/setup-new-project.sh odoo-<project> <module_name> <organization> [enterprise|community]

# Exemple pour Community:
./scripts/setup-new-project.sh odoo-crm crm_base mycompany community

# Exemple pour Enterprise:
./scripts/setup-new-project.sh odoo-pbt pbt_base mycompany enterprise

# 3. Committer les changements
git add .
git commit -m "chore: setup new project odoo-<project>"

# 4. Configurer et lancer
cp .env.example .env
docker-compose up -d
```

---

## 🏗️ Structure du Projet

```
.
├── addons/
│   ├── custom/              # Modules custom (renommé durant setup)
│   │   └── mta_base/        # Sera renommé en <module_name>
│   ├── oca/                 # Dépôts OCA fusionnés (via git-aggregator)
│   └── oca-addons/          # Symlinks vers modules OCA
│
├── scripts/
│   ├── setup-new-project.sh # Setup automatique du projet
│   ├── pycharm-setup.sh     # Configuration PyCharm
│   ├── anonymize_database.sql
│   └── ...
│
├── .github/workflows/       # CI/CD pipelines
├── docker-compose.yml       # Configuration base
├── docker-compose.dev.yml   # Overrides développement
├── docker-compose.prod.yml  # Overrides production
├── Dockerfile               # Image Odoo custom
├── odoo.conf               # Configuration Odoo
├── repos.yml               # Configuration Git-Aggregator
│
└── README.md               # Ce fichier
```

---

## 💻 Développement Local avec PyCharm

### Prérequis
- Docker Desktop
- PyCharm Professional (Community a support limité)
- Git + SSH configuré

### Setup
```bash
# 1. Lancer le script PyCharm
./scripts/pycharm-setup.sh

# 2. Dans PyCharm:
#    - Configurer Docker (Preferences → Docker)
#    - Configurer Python Interpreter (Docker Compose)
#    - Service: web
#    - Path: /usr/local/bin/python3

# 3. Lancer via PyCharm ou:
docker-compose up -d
```

Voir `docs/PYCHARM_SETUP.md` pour les détails complets.

---

## 🗄️ Gestion des Dépôts OCA

Le fichier `repos.yml` vide par défaut. Ajouter des dépôts OCA selon vos besoins:

```yaml
./addons/oca/account-invoicing:
  remotes:
    oca: git@github.com:OCA/account-invoicing.git
    resultrum: git@github.com:resultrum/account-invoicing.git
  merges:
    - oca 18.0
  target: resultrum master-18.0
```

Pour peupler automatiquement: `./scripts/setup-repositories.sh`

---

## 🔐 Anonymisation de Base de Données

Pour utiliser une DB de production en développement:

```bash
# 1. Faire un dump de production
pg_dump -U odoo production_db > production.sql

# 2. Restaurer en local
createdb dev_db
psql dev_db < production.sql

# 3. Anonymiser (Odoo Sh compatible)
psql -U odoo -d dev_db -f scripts/anonymize_database.sql

# 4. Sélectionner la DB dans Odoo
# localhost:8069 → Créer DB → restaurer depuis backup
```

Voir `scripts/anonymize_database.sql` pour les détails (tokens, mails, etc.)

---

## 📖 Documentation

- **docs/PYCHARM_SETUP.md** - Configuration PyCharm détaillée
- **docs/CI_CD_GUIDE.md** - Pipelines GitHub Actions
- **docs/INFRASTRUCTURE.md** - Déploiement sur Azure

---

## 🔄 Workflows Typiques

### Modifier un Module OCA
```bash
# 1. Le module est cloné dans addons/oca/<repo-name>
# 2. Éditer les fichiers
# 3. Commit dans le fork OCA
# 4. Merger via repos.yml (optionnel)
```

### Créer un Module Custom
```bash
# 1. Dans addons/custom/<module-name>/
# 2. Créer __manifest__.py
# 3. Implémenter votre logique
# 4. Installer dans Odoo via Apps
```

### Ajouter une Dépendance OCA
```bash
# 1. Éditer repos.yml
# 2. Ajouter le repo (voir exemple ci-dessus)
# 3. docker-compose down && docker-compose up -d
# 4. Rafraîchir Apps dans Odoo (Ctrl+Shift+R)
```

---

## 🚨 Troubleshooting

**Port 8069 déjà utilisé?**
```bash
docker-compose down
# Ou modifier docker-compose.yml: ports: ["8070:8069"]
```

**Module custom pas détecté?**
```bash
# Vérifier addons_path dans odoo.conf
# Redémarrer: docker-compose restart web
# Rafraîchir: Odoo → Apps → Ctrl+Shift+R
```

**Erreur de connexion DB?**
```bash
docker-compose logs web | grep -i postgres
# Vérifier .env: DB_HOST, DB_USER, DB_PASSWORD
```

---

## 📝 License

Propriétaire Resultrum

---

**Questions?** Voir la documentation dans `docs/` ou les scripts dans `scripts/`
