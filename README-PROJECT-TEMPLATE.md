# {{PROJECT_NAME}} - Odoo Project

Projet Odoo {{EDITION}} basé sur le template [odoo-template](https://github.com/{{ORG_NAME}}/odoo-template).

**Version**: 0.1.0
**Odoo**: 18.0 {{EDITION_UPPER}}
**Stack**: Docker + Docker Compose + PostgreSQL 15

---

## 📋 À propos

{{PROJECT_NAME}} est un projet Odoo {{EDITION}} Edition avec:

- ✅ Docker & Docker Compose configurés
- ✅ Module custom {{MODULE_NAME}} (renommable)
- ✅ Scripts d'automatisation
- ✅ Configuration PyCharm pour développement
- ✅ CI/CD GitHub Actions
- ✅ Support OCA modules via git-aggregator

---

## 🚀 Démarrage Rapide

### Prérequis
- Docker Desktop
- Git
- PyCharm Professional (optionnel)

### Setup (1 minute)

```bash
# 1. Cloner le projet
git clone https://github.com/{{ORG_NAME}}/{{PROJECT_NAME}}.git
cd {{PROJECT_NAME}}

# 2. Créer .env
cp .env.example .env

# 3. Lancer Docker
docker-compose up -d

# 4. Accéder à Odoo
# 🌐 http://localhost:8069
# 👤 admin@odoo.com
# 🔐 admin
```

---

## 💻 Développement

### Configuration PyCharm

1. **Settings** → **Project** → **Python Interpreter**
2. **Add** → **Docker Compose**
3. Select service: `web`
4. **OK**

### Debugger ton Code

```python
# Ajouter breakpoint dans addons/custom/{{MODULE_NAME}}/...

class MonModel(models.Model):
    _name = 'mon.model'

    def ma_methode(self):
        valeur = 10  # ← Clic ici pour breakpoint
        return valeur * 2
```

1. Clic sur le numéro de ligne → Red dot
2. Va à http://localhost:8069 et déclenche l'action
3. PyCharm pause sur le breakpoint ✅

Voir `docs/DEBUGGING_SIMPLE.md` pour plus de détails.

---

## 📚 Structure du Projet

```
.
├── addons/
│   ├── custom/
│   │   └── {{MODULE_NAME}}/      # Ton module custom
│   ├── oca/                      # Dépôts OCA clonés
│   └── oca-addons/               # Symlinks vers modules OCA
│
├── scripts/
│   ├── setup-new-project.sh
│   ├── backup.sh
│   ├── health-check.sh
│   └── ...
│
├── docker-compose.yml            # Config dev
├── docker-compose.dev.yml        # Overrides dev
├── docker-compose.prod.yml       # Overrides prod
├── Dockerfile
├── odoo.conf                     # Config Odoo
├── repos.yml                     # Git-aggregator config
│
├── docs/
│   ├── DEBUGGING_SIMPLE.md
│   ├── PYCHARM_SETUP.md
│   └── ...
│
└── README.md                     # Ce fichier
```

---

## 🗄️ Gestion des Modules OCA

### Ajouter un Dépôt OCA

Edit `repos.yml`:

```yaml
./addons/oca/account-invoicing:
  remotes:
    oca: git@github.com:OCA/account-invoicing.git
    {{ORG_NAME}}: git@github.com:{{ORG_NAME}}/account-invoicing.git
  merges:
    - oca 18.0
  target: {{ORG_NAME}} master-18.0
```

Puis:

```bash
docker-compose down
docker-compose up -d
```

Voir [odoo-template README](https://github.com/{{ORG_NAME}}/odoo-template#-gestion-des-dépôts-oca) pour plus d'infos.

---

## 🔐 Base de Données

### Utiliser une DB Existante

```bash
# 1. Dump production
pg_dump -U odoo production_db > prod.sql

# 2. Charger en local
docker exec odoo-template-db psql -U odoo -d odoo < prod.sql

# 3. Anonymiser (optionnel)
docker exec odoo-template-db psql -U odoo -d odoo -f scripts/anonymize_database.sql

# 4. Sélectionner dans Odoo
# http://localhost:8069 → Create DB → Restore from backup
```

---

## 🔄 Commandes Courantes

```bash
# Voir les logs
docker-compose logs -f web

# Accéder au shell
docker-compose exec web bash

# Redémarrer
docker-compose restart web

# Arrêter
docker-compose down

# Rajeunir les containers
docker-compose up -d --force-recreate
```

---

## 📊 CI/CD

Automatisation via GitHub Actions:

- ✅ **ci.yml** - Tests Python, linting, manifests
- ✅ **docker.yml** - Build & push à GHCR
- ✅ **validate.yml** - Config validation
- ✅ **pre-commit.yml** - Code quality

Voir `.github/workflows/` pour les détails.

---

## 🚨 Troubleshooting

### Port déjà utilisé?
```bash
# Changer dans docker-compose.yml:
ports: ["8070:8069"]
```

### Module custom pas détecté?
```bash
# Redémarrer
docker-compose restart web

# Rafraîchir Odoo
# Apps → Ctrl+Shift+R
```

### Erreur de connexion DB?
```bash
docker-compose logs web | grep -i postgres
# Vérifier .env: DB_HOST, DB_USER, DB_PASSWORD
```

### Problème Docker?
```bash
# Nettoyer complètement
docker-compose down -v
docker system prune -a
docker-compose up -d
```

---

## 📖 Documentation

- **docs/DEBUGGING_SIMPLE.md** - Debugging guide
- **docs/PYCHARM_SETUP.md** - PyCharm config détaillée
- **docs/TEMPLATE_ARCHITECTURE.md** - Architecture du template
- **docs/CI_CD_WORKFLOWS.md** - GitHub Actions details

---

## 🔗 Modifier le Remote Git

**Important**: Après clonage depuis le template, changer le remote vers ton repo!

```bash
# 1. Vérifier le remote actuel
git remote -v
# origin https://github.com/{{ORG_NAME}}/odoo-template.git

# 2. Changer vers ton nouveau repo
git remote set-url origin https://github.com/{{ORG_NAME}}/{{PROJECT_NAME}}.git

# 3. Vérifier le changement
git remote -v
# origin https://github.com/{{ORG_NAME}}/{{PROJECT_NAME}}.git ✅

# 4. Vérifier le branch local
git branch
# * main

# 5. Push vers le nouveau repo
git push -u origin main
```

**Alternative avec SSH** (recommandé):

```bash
# 1. Changer le remote
git remote set-url origin git@github.com:{{ORG_NAME}}/{{PROJECT_NAME}}.git

# 2. S'assurer que SSH est configuré
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# 3. Tester la connexion
ssh -T git@github.com

# 4. Push
git push -u origin main
```

---

## 🎯 Workflow Typique

### 1. Créer un Module Custom

```bash
# Module est pré-créé comme {{MODULE_NAME}}
# Voir: addons/custom/{{MODULE_NAME}}/

# Développer:
# - addons/custom/{{MODULE_NAME}}/models/
# - addons/custom/{{MODULE_NAME}}/views/
# - addons/custom/{{MODULE_NAME}}/data/
```

### 2. Installer dans Odoo

```bash
# Via UI
# http://localhost:8069 → Apps → Search {{MODULE_NAME}} → Install

# Ou via ligne de commande
docker exec {{PROJECT_NAME}}-web odoo -d odoo -i {{MODULE_NAME}} --without-demo=all
```

### 3. Commit & Push

```bash
git add -A
git commit -m "feat: implement feature X in {{MODULE_NAME}}"
git push origin main
```

### 4. CI/CD Automatique

- Tests exécutés
- Image Docker buildée et pushée à GHCR
- Prête pour déploiement

---

## 📝 License

Propriétaire {{ORG_NAME}}

---

## 🤝 Support

- **Questions?** Voir `docs/`
- **Issues?** Créer une issue GitHub
- **Template?** [odoo-template](https://github.com/{{ORG_NAME}}/odoo-template)

---

**Créé depuis**: odoo-template
**Dernière mise à jour**: [DATE_CREATION]
**Status**: ✅ Production Ready
