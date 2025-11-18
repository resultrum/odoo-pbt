# 🐍 PyCharm Setup pour Développement Odoo Local

Ce guide configure PyCharm pour développer avec Docker.

---

## 📋 Prérequis

- **PyCharm Professional** (Community a support Docker limité)
- **Docker Desktop** installé et lancé
- **Git** avec SSH configuré pour GitHub
- Projet cloné depuis le template

---

## 🚀 Setup Initial (5 minutes)

### Étape 1: Ouvrir le Projet

```bash
File → Open → Sélectionner le répertoire du projet
```

### Étape 2: Configurer Docker

```
PyCharm → Preferences (macOS) ou Settings (Windows/Linux)
→ Docker
→ Cliquer sur "+"
→ Sélectionner "Docker Desktop"
→ OK
```

PyCharm devrait détecter automatiquement votre installation Docker.

### Étape 3: Configurer Python Interpreter

```
Preferences → Project: <project-name> → Python Interpreter
→ Cliquer sur ⚙️ → Add
→ Docker Compose
```

Configurer:
- **Configuration file**: `docker-compose.yml` (à la racine)
- **Service**: `web`
- **Python interpreter path**: `/usr/local/bin/python3`

→ OK

**Vérification**: En bas à droite de PyCharm, devrait afficher quelque chose comme:
```
Docker (python:3.12 at docker-compose.yml) <service-name>-web
```

---

## 🏃 Lancer les Conteneurs

### Option 1: Via PyCharm (Plus facile)

```
Run → Edit Configurations
→ + (Plus) → Docker Compose
```

Configurer:
- **Name**: `Odoo Dev`
- **Compose file path**: `docker-compose.yml`
- **Services**: Cocher `web` et `db`

→ OK

Maintenant cliquer sur le bouton ▶️ (Play) vert pour lancer.

### Option 2: Via Terminal PyCharm

```
View → Tool Windows → Terminal
```

Puis:
```bash
docker-compose up -d
```

---

## 🔍 Vérifier que Tout Fonctionne

### 1. Les conteneurs tournent?
```bash
docker ps
```

Devrait afficher `<project>-web` et `<project>-db` en status UP.

### 2. Accéder à Odoo

```
Ouvrir navigateur: http://localhost:8069
```

Odoo devrait charger (peut prendre 30 secondes).

**Première connexion:**
- Créer une base de données
- Username: `admin`
- Password: (voir .env ou admin123 par défaut)

### 3. Voir les logs

```
Run → Show Run → web (ou cliquer sur l'onglet "Run")
```

Devrait afficher les logs Odoo en direct.

---

## 💻 Développement

### Éditer un Module Custom

```
addons/custom/<module-name>/
├── models/
├── views/
├── __manifest__.py
└── ...
```

Les fichiers se synchronisent automatiquement dans le conteneur (grâce aux volumes).

### Hot Reload

Odoo se recharge automatiquement quand vous modifiez un fichier (si `--dev=reload` est activé dans docker-compose.dev.yml).

**Pour forcer une synchronisation:**

```bash
docker-compose restart web
```

### Installer/Activer un Module

1. Dans Odoo, aller à **Apps**
2. Chercher votre module
3. Cliquer **Install**

Ou via terminal:
```bash
docker-compose exec web odoo-bin -i module_name --stop-after-init
```

---

## 🐛 Débogage avec Breakpoints

### Ajouter un Breakpoint

1. Ouvrir un fichier Python dans `addons/custom/`
2. Cliquer à gauche du numéro de ligne (un point rouge apparaît)
3. Cliquer sur le bouton **Debug** (⏸ bleu) au lieu de Play

### Déclencher le Code

1. Dans Odoo, effectuer une action qui va exécuter votre code
2. PyCharm devrait se mettre en pause au breakpoint
3. Utiliser le Debug panel pour:
   - **F7**: Step Into (entrer dans la fonction)
   - **F8**: Step Over (passer la ligne)
   - **F9**: Continue (reprendre l'exécution)
   - Inspecteur de variables (à gauche)

Exemple: Debug d'une button personnalisée
```python
def action_my_button(self):
    # Breakpoint ici ↓
    self.env.cr.execute("SELECT * FROM res_partner")
    result = self.env.cr.fetchall()
```

---

## 📂 Structure du Projet dans PyCharm

```
<project-root>/
├── .idea/                      # Configuration PyCharm
│   ├── runConfigurations/
│   ├── misc.xml               # Python interpreter config
│   └── ...
│
├── addons/
│   ├── custom/
│   │   └── <module>/          # Vos modules (DÉVELOPPER ICI)
│   ├── oca/
│   └── oca-addons/
│
├── scripts/
│   ├── setup-new-project.sh
│   ├── pycharm-setup.sh
│   └── anonymize_database.sql
│
├── .github/workflows/         # CI/CD
├── docker-compose.yml         # Config Docker
├── Dockerfile
├── odoo.conf
└── README.md
```

---

## 🔧 Configuration Avancée

### Custom Odoo Config

Éditer `odoo.conf` pour personnaliser:
- `addons_path` - Où Odoo cherche les modules
- `workers` - Nombre de workers
- `db_host`, `db_user`, `db_password` - Connexion DB
- `log_level` - Niveau de log

### Ajouter des Dépendances Python

Si vous avez besoin d'une librairie Python:

1. Éditer `Dockerfile`:
```dockerfile
RUN pip install requests beautifulsoup4
```

2. Rebuild l'image:
```bash
docker-compose build --no-cache web
docker-compose up -d
```

### Code Style dans PyCharm

```
Preferences → Editor → Code Style → Python
```

Vous pouvez importer `.flake8` ou `.pylintrc` du projet.

---

## 🚨 Troubleshooting

### "Python interpreter not detected"

**Problème**: L'interpréteur Docker ne s'affiche pas

**Solution**:
1. Vérifier que Docker Desktop tourne
2. Aller dans Preferences → Docker
3. Vérifier la connexion Docker (devrait dire "Connected")
4. Relancer PyCharm si nécessaire

### "Port 8069 already in use"

**Problème**: Un autre service utilise le port 8069

**Solution**:
```bash
# Option 1: Arrêter l'autre service
docker-compose down

# Option 2: Utiliser un autre port
# Éditer docker-compose.yml:
# ports: ["8070:8069"]
```

### "Cannot connect to database"

**Problème**: Odoo ne peut pas se connecter à PostgreSQL

**Solution**:
```bash
# Vérifier que le conteneur DB tourne
docker-compose ps

# Voir les logs
docker-compose logs db

# Redémarrer
docker-compose restart db
```

### Module ne s'affiche pas dans Apps

**Problème**: Vous avez créé un module mais il ne s'affiche pas

**Solution**:
1. Vérifier que `addons_path` dans `odoo.conf` inclut le répertoire
2. Redémarrer: `docker-compose restart web`
3. Dans Odoo, aller à Apps et rafraîchir (Ctrl+Shift+R)
4. Chercher votre module

### Breakpoint ne fonctionne pas

**Problème**: Breakpoint ne se déclenche pas

**Solution**:
1. Vérifier que vous utilisez le bouton **Debug** (pas Play)
2. Vérifier que l'interpréteur est bien configuré
3. Le code doit s'exécuter - ajouter print() pour vérifier
4. Vérifier les logs: `docker-compose logs web`

---

## 📚 Ressources

- **[Odoo Documentation](https://www.odoo.com/documentation/18.0/)** - Référence officielle
- **[Python in Docker](https://docs.docker.com/language/python/)** - Docker + Python
- **[PyCharm Docker Support](https://www.jetbrains.com/help/pycharm/docker.html)** - Doc PyCharm

---

## 💡 Tips & Tricks

### Log File Viewer

Afficher les logs en temps réel:
```
View → Tool Windows → Services
→ Cliquer sur web container
```

### Exécuter une Commande dans le Conteneur

```
Run → Edit Configurations → + → Docker
```

Ou via terminal:
```bash
docker-compose exec web odoo-bin --help
```

### Dump & Restore une DB

```bash
# Dump
docker-compose exec db pg_dump -U odoo odoo_db > backup.sql

# Restore
createdb restored_db
psql restored_db < backup.sql
```

### Réinitialiser Complètement

```bash
# Arrêter et nettoyer
docker-compose down -v  # -v supprime les volumes

# Relancer
docker-compose up -d
```

---

**Version**: 1.0
**Odoo**: 18.0 Enterprise
**Dernière mise à jour**: 2025-11-18
