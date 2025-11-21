# Configuration PyCharm - Odoo Template

## ✅ État du Projet

**Date**: 18 novembre 2025
**Odoo Version**: 18.0 Enterprise
**Docker Status**: ✅ Actif et fonctionnel
**Services Actifs**:
- `odoo-template-web` → http://localhost:8069
- `odoo-template-db` → localhost:5432

---

## 📋 Étapes de Configuration PyCharm

### 1️⃣ Ouverture du Projet

Le projet devrait s'ouvrir automatiquement dans PyCharm. Si ce n'est pas le cas:

```bash
open -a PyCharm ~/Projects/odoo-template
```

### 2️⃣ Configurer l'Interpréteur Python (Docker)

**Menu**: `PyCharm → Settings → Project → Python Interpreter`

**Étapes détaillées**:

1. Cliquer sur l'engrenage ⚙️ en haut à droite
2. Sélectionner **"Add"** ou **"Add..."**
3. Choisir **"Docker Compose"**
4. Remplir le formulaire:
   - **Docker Compose**: Sélectionner le fichier `/Users/jonathannemry/Projects/odoo-template/docker-compose.yml`
   - **Service**: `web`
   - **Python interpreter path**: (Laisser vide, PyCharm le détectera)
5. Cliquer sur **OK**

PyCharm va:
- ✅ Créer les volumes helpers Docker propres
- ✅ Détecter l'interpréteur Python du conteneur
- ✅ Synchroniser les dépendances Odoo
- ⏳ Prendre 2-5 minutes pour la synchronisation initiale

### 3️⃣ Vérifier la Configuration

Une fois la synchronisation terminée:

1. **Vérifier l'interpréteur**:
   - Aller dans `Settings → Project → Python Interpreter`
   - Vous devriez voir: `Docker Compose (web:latest): Python 3.12.x`

2. **Vérifier les dépendances**:
   - Ouvrir un fichier Python dans le projet
   - PyCharm devrait avoir la complétion de code pour Odoo

3. **Tester PyCharm**:
   - Ouvrir `addons/custom/` (ou un module custom)
   - Vérifier que la coloration syntaxique et la complétion fonctionnent

---

## 🚀 Accès à Odoo

### Navigateur Web

- **URL**: http://localhost:8069
- **Email**: `admin@odoo.com`
- **Mot de passe**: `admin`

### Terminal PyCharm (Bonus)

Dans PyCharm, vous pouvez accéder au terminal du conteneur:

```bash
# Voir les logs en temps réel
docker logs -f odoo-template-web

# Exécuter une commande dans le conteneur
docker exec -it odoo-template-web bash

# Installer un addon spécifique
docker exec odoo-template-web odoo -d odoo -i custom_module --without-demo=all
```

---

## 🔧 Dépannage

### Problème: PyCharm dit "Python not found"

**Solution**:
1. Recréer l'interpréteur Docker:
   - `Settings → Project → Python Interpreter → ⚙️ → Remove`
   - Ajouter un nouvel interpréteur Docker Compose

2. Vérifier que Docker Desktop est actif:
   ```bash
   docker ps
   ```

### Problème: Synchronisation très lente

**Solution**:
- La première synchronisation peut prendre 5-10 minutes
- Vérifier la bande passante Internet (nombreuses dépendances Odoo)
- Vérifier que les conteneurs tournent: `docker ps`

### Problème: Le port 8069 est occupé

**Solution**:
```bash
# Arrêter les conteneurs
docker-compose down

# Nettoyer les réseaux orphelins
docker network prune -f

# Redémarrer
docker-compose up -d
```

---

## 📦 Structure du Projet

```
odoo-template/
├── addons/
│   ├── custom/          # Modules custom (renommer "template")
│   ├── oca/             # Modules OCA (optionnel)
│   └── oca-addons/      # Modules OCA supplémentaires
├── docker-compose.yml   # Configuration Docker
├── Dockerfile           # Image Odoo personnalisée
├── odoo.conf            # Configuration Odoo
├── entrypoint.sh        # Script de démarrage
└── PYCHARM_SETUP.md     # Ce fichier!
```

---

## ✅ Checklist de Vérification

- [ ] PyCharm est ouvert
- [ ] Interpréteur Python Docker Compose configuré
- [ ] Services Docker en cours d'exécution (`docker ps`)
- [ ] Odoo accessible via http://localhost:8069
- [ ] Complétion de code fonctionnelle pour Odoo
- [ ] Les logs Docker ne montrent pas d'erreurs

---

## 📚 Ressources Utiles

- **Documentation Odoo**: https://www.odoo.com/documentation/18.0/
- **Docker Compose**: https://docs.docker.com/compose/
- **PyCharm Docker Integration**: https://www.jetbrains.com/help/pycharm/docker.html

---

**Créé le**: 18 nov 2025
**Dernière mise à jour**: Auto-généré par Claude Code
