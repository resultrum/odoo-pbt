# Guide: Utiliser le Template Odoo pour Créer un Nouveau Projet

Ce guide explique comment créer un nouveau projet Odoo à partir du template `odoo-template`.

---

## 📋 Prérequis

- Git configuré avec SSH (recommandé)
- Docker Desktop
- Accès au repo GitHub `odoo-template`
- Repo GitHub créé pour ton nouveau projet

---

## 🚀 Étapes de Création

### **Option A: Via GitHub "Use this template" (Recommandée)**

#### Étape 1: Créer le Repo depuis le Template

1. Va sur https://github.com/{{ORG_NAME}}/odoo-template
2. Clique sur **"Use this template"** → **"Create a new repository"**
3. Configure:
   - **Repository name**: `odoo-<project>` (ex: `odoo-crm`)
   - **Owner**: Ton organisation
   - **Description**: Court description du projet
   - **Public/Private**: Selon tes préférences
4. Clique **"Create repository from template"**

#### Étape 2: Cloner Localement

```bash
# Clone ton nouveau repo
git clone https://github.com/{{ORG_NAME}}/odoo-crm.git
cd odoo-crm

# Vérifier le remote
git remote -v
# origin https://github.com/{{ORG_NAME}}/odoo-crm.git ✅
```

✅ **Le remote est DÉJÀ correct!** Pas besoin de le changer.

#### Étape 3: Exécuter Setup

```bash
# Setup avec parameters
./scripts/setup-new-project.sh odoo-crm crm_base mycompany [enterprise|community]

# Exemple Community
./scripts/setup-new-project.sh odoo-crm crm_base mycompany community

# Exemple Enterprise
./scripts/setup-new-project.sh odoo-crm crm_base mycompany enterprise
```

**Le script générera automatiquement `README.md` avec tes valeurs!**

---

### **Option B: Via Clone + Setup (Si pas d'accès "Use this template")**

#### Étape 1: Cloner le Template

```bash
# Clone le template
git clone https://github.com/{{ORG_NAME}}/odoo-template.git odoo-crm
cd odoo-crm
```

#### Étape 2: Créer le Repo Distant

1. Va sur GitHub
2. **New repository**
3. Nom: `odoo-crm`
4. Clique **"Create repository"** (SANS initialiser avec README)

#### Étape 3: Changer le Remote

**Important!** Pointer vers ton nouveau repo:

```bash
# Vérifier le remote actuel
git remote -v
# origin https://github.com/{{ORG_NAME}}/odoo-template.git ❌

# Changer vers ton nouveau repo
git remote set-url origin https://github.com/{{ORG_NAME}}/odoo-crm.git

# Vérifier le changement
git remote -v
# origin https://github.com/{{ORG_NAME}}/odoo-crm.git ✅
```

**Avec SSH (recommandé):**

```bash
# Changer le remote avec SSH
git remote set-url origin git@github.com:{{ORG_NAME}}/odoo-crm.git

# S'assurer que SSH fonctionne
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
ssh -T git@github.com
```

#### Étape 4: Push vers le Nouveau Repo

```bash
# Push la branche main
git push -u origin main

# Vérifier
git branch -v
# * main abc1234 [ahead of origin/main] ...
```

#### Étape 5: Exécuter Setup

```bash
./scripts/setup-new-project.sh odoo-crm crm_base mycompany community
```

---

## 📝 Ce que Fait le Setup Script

Le script `setup-new-project.sh` automatise:

```
1️⃣ Setup .env
   → Crée .env de .env.example
   → Remplace variables avec tes valeurs

2️⃣ Renomme module custom
   → mta_base → crm_base

3️⃣ Met à jour manifests
   → __manifest__.py avec ton nom de projet

4️⃣ Renomme test files
   → test_mta_base.py → test_crm_base.py

5️⃣ Configure docker-compose
   → Remplace "odoo-template" par "odoo-crm"

6️⃣ Configure Dockerfile
   → Sélectionne variant enterprise ou community

7️⃣ Met à jour GitHub workflows
   → Change image_name dans .github/workflows/

8️⃣ Génère README.md
   → À partir du template avec tes valeurs

9️⃣ Réinitialise VERSION
   → À 0.1.0
```

**Résultat**: Un projet prêt à l'emploi! ✅

---

## 🔄 Vérification Après Setup

Après exécution du script:

```bash
# 1. Voir les changements
git status
# Beaucoup de fichiers modifiés ✅

# 2. Vérifier le README généré
cat README.md | head -20
# Devrait contenir "odoo-crm", pas "odoo-template"

# 3. Vérifier la structure
ls -la addons/custom/
# crm_base/ (pas mta_base) ✅

# 4. Vérifier docker-compose
grep PROJECT_NAME .env
# PROJECT_NAME=odoo-crm ✅

# 5. Committer
git add .
git commit -m "chore: setup new project - odoo-crm community edition"
git push origin main
```

---

## 🐳 Lancer le Projet

```bash
# 1. Créer .env (déjà fait par setup)
cp .env.example .env

# 2. Lancer Docker
docker-compose up -d

# 3. Attendre 10-15 secondes...

# 4. Accéder à Odoo
# 🌐 http://localhost:8069
# 👤 admin@odoo.com
# 🔐 admin
```

---

## 📋 Checklist Post-Setup

- [ ] Remote git pointe vers `odoo-crm` (pas `odoo-template`)
- [ ] `README.md` généré avec bon projet name
- [ ] Module custom renommé: `crm_base` (pas `mta_base`)
- [ ] `.env` créé avec `PROJECT_NAME=odoo-crm`
- [ ] Changes commitées et pushées
- [ ] Docker démarre correctement
- [ ] Odoo répond sur http://localhost:8069
- [ ] PyCharm interpreter configuré (optionnel)

---

## ⚠️ Pièges Courants

### ❌ Pièges à Éviter

| Piège | Solution |
|-------|----------|
| Ne pas changer le remote | Vérifier: `git remote -v` |
| Oublier de générer README | Le script le fait automatiquement |
| Module custom pas renommé | Script s'en charge: `crm_base` |
| Garder "odoo-template" partout | Script remplace partout |
| Ne pas committer les changements | `git add . && git commit && git push` |
| Lancer docker sans `.env` | `cp .env.example .env` |

---

## 🚀 Prochaines Étapes

### 1. Configurer PyCharm
```bash
# Voir docs/PYCHARM_SETUP.md
Settings → Project → Python Interpreter → Add → Docker Compose
```

### 2. Développer ton Module
```bash
addons/custom/crm_base/
├── models/          # Business logic
├── views/           # UI (XML)
├── data/            # Demo data
├── static/          # CSS/JS
└── tests/           # Unit tests
```

### 3. Ajouter des Modules OCA
```bash
# Edit repos.yml et ajouter:
./addons/oca/account-invoicing:
  remotes:
    oca: git@github.com:OCA/account-invoicing.git
    mycompany: git@github.com:mycompany/account-invoicing.git
  merges:
    - oca 18.0
  target: mycompany master-18.0
```

### 4. Committer & Push
```bash
git add .
git commit -m "feat: implement feature X"
git push origin main

# CI/CD auto-trigger:
# ✅ Tests exécutés
# ✅ Docker image buildée
# ✅ Image pushée à GHCR
```

---

## 📖 Documentation Pertinente

- **README.md** - Overview du projet (généré automatiquement)
- **docs/DEBUGGING_SIMPLE.md** - Comment debugger
- **docs/PYCHARM_SETUP.md** - Configuration PyCharm
- **docs/CI_CD_WORKFLOWS.md** - Workflows GitHub Actions
- **.github/workflows/** - CI/CD pipelines

---

## 🔧 Troubleshooting

### Le script setup a échoué?

```bash
# Réexécuter avec parametres:
./scripts/setup-new-project.sh odoo-crm crm_base mycompany community

# Si encore erreur:
git status
git diff
# Vérifier ce qui a changé
```

### Remote toujours pointé vers template?

```bash
# Vérifier
git remote -v

# Si mauvais, changer:
git remote set-url origin https://github.com/myorg/odoo-crm.git

# Vérifier
git remote -v
```

### README.md n'a pas été généré?

```bash
# Le script l'aurait généré de README-PROJECT-TEMPLATE.md
# Vérifier si le template existe:
ls -la README-PROJECT-TEMPLATE.md

# Si manquant, pull from origin:
git pull origin main
```

### Docker ne démarre pas?

```bash
# Vérifier le .env:
cat .env | head -10

# Relancer:
docker-compose down -v
docker-compose up -d
docker logs odoo-crm-web
```

---

## ✅ Résumé

```
Option A (Recommandée):
1. "Use this template" sur GitHub
2. Clone le nouveau repo
3. ./scripts/setup-new-project.sh
4. git push (c'est déjà le bon remote!)
5. docker-compose up -d

Option B (Alternative):
1. Clone le template
2. Crée nouveau repo sur GitHub
3. Change le remote: git remote set-url origin ...
4. ./scripts/setup-new-project.sh
5. git push -u origin main
6. docker-compose up -d
```

**Le template gère tout automatiquement - c'est magique!** ✨

---

**Questions?** Voir `docs/` ou créer une issue GitHub.
