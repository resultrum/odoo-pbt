# Architecture du Template Odoo

Ce document explique la cohérence et l'architecture du template.

---

## 📐 Composants Clés

### 1. **Dockerfiles** (Variants d'Édition)

Le template fournit **3 variantes de Dockerfile**:

#### `Dockerfile.enterprise`
- **Base Image**: `FROM odoo:18.0` (fallback Community)
- **Objectif**: Configuration Enterprise Edition development
- **Inclut**: Python symlink + PyCharm helpers + packaging_tool.py
- **TODO**: Changer le `FROM` vers une image Enterprise (GitHub GHCR ou source)

#### `Dockerfile.community`
- **Base Image**: `FROM odoo:18.0` (Community Edition)
- **Objectif**: Configuration Community Edition development
- **Inclut**: Python symlink + PyCharm helpers + packaging_tool.py
- **Prêt**: Aucune modification requise

#### `Dockerfile` (symlink/alias)
- **Utilisé par**: `docker-compose.yml` et `docker build`
- **Généré par**: Script `setup-new-project.sh`
- **Logique**:
  - Si edition = `enterprise` → copie `Dockerfile.enterprise` → `Dockerfile`
  - Si edition = `community` → copie `Dockerfile.community` → `Dockerfile`

#### `Dockerfile.prod`
- **Objectif**: Production deployments
- **Pas affecté** par le script setup

---

## 🔄 Flux du Setup Script

Le script `./scripts/setup-new-project.sh` automatise cette cohérence:

```
INPUT: edition (enterprise|community)
  ↓
STEP 4b: Configure Dockerfile variant
  ├─ Si enterprise:
  │  └─ cp Dockerfile.enterprise → Dockerfile
  │     (Inclut TODO pour changer la base image)
  │
  └─ Si community:
     └─ cp Dockerfile.community → Dockerfile
        (Prêt à l'usage)
  ↓
OUTPUT: Dockerfile compatible avec l'édition
        + Instructions pour Enterprise (si applicable)
```

### Exemple d'exécution

```bash
# Community
./scripts/setup-new-project.sh odoo-crm crm_base mycompany community
# → Dockerfile.community est copié
# → Dockerfile utilise FROM odoo:18.0
# → Prêt pour docker-compose up -d

# Enterprise
./scripts/setup-new-project.sh odoo-pbt pbt_base mycompany enterprise
# → Dockerfile.enterprise est copié
# → Dockerfile inclut instructions TODO pour changer l'image
# → L'utilisateur doit modifier le FROM avant docker-compose up -d
```

---

## 🐍 Corrections PyCharm Incluses

**Tous les Dockerfiles** (enterprise + community) incluent maintenant:

### 1. **Python Symlink**
```dockerfile
ln -s /usr/bin/python3 /usr/bin/python
```
**Raison**: PyCharm appelle `python` directement, pas `python3`.

### 2. **PyCharm Helpers Directory**
```dockerfile
RUN mkdir -p /opt/.pycharm_helpers
```
**Raison**: PyCharm y stocke les scripts d'introspection.

### 3. **Custom packaging_tool.py**
```dockerfile
COPY packaging_tool.py /opt/.pycharm_helpers/packaging_tool.py
RUN chmod +x /opt/.pycharm_helpers/packaging_tool.py
```
**Raison**: Corrige le bug `TypeError: sequence item 0: expected str instance, NoneType found` causé par les packages avec métadonnées corrompues (ex: charset_normalizer).

---

## 📋 Workflow Utilisateur

### Pour Community Edition

```bash
# 1. Setup
./scripts/setup-new-project.sh odoo-crm crm_base mycompany community

# 2. Output du script
# ✅ Community Edition configured
# Your Dockerfile is ready to use: FROM odoo:18.0

# 3. Lancer directement
docker-compose up -d
```

### Pour Enterprise Edition

```bash
# 1. Setup
./scripts/setup-new-project.sh odoo-pbt pbt_base mycompany enterprise

# 2. Output du script inclut
# ⚠️  IMPORTANT - Enterprise Edition Setup
# 📝 NEXT STEP: Update the Docker base image
# Edit your Dockerfile and uncomment/choose ONE of these options:

# 3. Modifier le Dockerfile (changer le FROM)
# Option A: FROM ghcr.io/odoo/odoo:18.0-enterprise
# Option B: FROM odoo:18.0  (déjà configuré)
# Option C: Build from Odoo Enterprise source

# 4. Authentifier (si Option A)
docker login ghcr.io -u <username> -p <token>

# 5. Lancer
docker-compose up -d --build
```

---

## 🔍 Cohérence Vérifiée

✅ **Script de setup** → Sélectionne le bon variant de Dockerfile
✅ **Dockerfile variants** → Incluent toutes les corrections PyCharm
✅ **Documentation** → Alignée avec le comportement du script
✅ **Pas de modifications manuelles** pour PyCharm (déjà incluses)
✅ **Une seule modification requise** pour Enterprise (la base image)

---

## 🛠️ Maintenance

Si vous modifiez les Dockerfiles:

1. **Mettre à jour les 2 variantes** (enterprise + community) en parallèle
2. **Garder les corrections PyCharm** dans les deux
3. **Mettre à jour `Dockerfile`** uniquement via le script setup
4. **Vérifier cohérence** entre:
   - `setup-new-project.sh` ligne 162-176
   - `Dockerfile.enterprise` et `Dockerfile.community`
   - `README.md` section "Après Setup (Enterprise Uniquement)"

---

## ⚠️ Pièges à Éviter

❌ Modifier uniquement `Dockerfile.enterprise` sans `Dockerfile.community`
❌ Copier des changements dans `Dockerfile` directement (il est généré)
❌ Oublier le symlink Python dans les variants
❌ Ne pas inclure packaging_tool.py dans les variants
❌ Oublier de mettre à jour la documentation après changes Dockerfile

---

**Dernière mise à jour**: 21 novembre 2025
**Status**: ✅ Architecture cohérente et validée
