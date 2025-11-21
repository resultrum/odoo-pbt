# Quick Start - Odoo Template

## ⚡ **Setup 100% Fonctionnel (5 min)**

### 1️⃣ Docker Actif

```bash
cd ~/Projects/odoo-template
docker-compose up -d
```

**Vérifier:**
```bash
docker ps
# Devrait afficher: odoo-template-web et odoo-template-db
```

### 2️⃣ PyCharm - Configuration Manuelle

**⚠️ Important**: NE PAS configurer Docker Compose comme interpréteur!

1. Ouvrir: `~/Projects/odoo-template`
2. **Settings** (Cmd + ,)
3. **Project → Python Interpreter**
4. **⚙️ Add**
5. **Existing Environment**
6. **Path**: `~/Projects/odoo-template/.venv/bin/python`
7. **OK**

✅ C'est tout! Pas d'erreur PyCharm.

### 3️⃣ Accès à Odoo

```
🌐 http://localhost:8069
👤 admin@odoo.com
🔐 admin
```

---

## 🔧 Commandes Utiles

### Voir les logs Odoo
```bash
docker logs -f odoo-template-web
```

### Accéder au conteneur Odoo
```bash
docker exec -it odoo-template-web bash
```

### Arrêter
```bash
docker-compose down
```

### Redémarrer
```bash
docker-compose up -d
```

---

## 📚 Développement

### Python Venv (Local)
```bash
source .venv/bin/activate
python -m pip list
```

### Installer un package
```bash
source .venv/bin/activate
pip install package_name
```

### Installer un module Odoo custom
```bash
docker exec odoo-template-web odoo -d odoo -i custom_module --without-demo=all
```

---

## ✅ Checklist

- [ ] Docker Compose lancé (`docker-compose up -d`)
- [ ] Conteneurs actifs (`docker ps`)
- [ ] PyCharm ouvert
- [ ] Interpréteur = `.venv/bin/python` (PAS Docker!)
- [ ] Odoo accessible http://localhost:8069
- [ ] Pas d'erreur PyCharm

---

## 🆘 Problèmes?

### Erreur "port 5432 already in use"
```bash
docker-compose down
docker-compose up -d
```

### Erreur PyCharm "Python not found"
```bash
rm -rf ~/Library/Application\ Support/JetBrains/PyCharm*
# Redémarrer PyCharm
# Reconfigurer l'interpréteur
```

### Odoo ne charge pas
```bash
docker logs odoo-template-web
```

---

**Créé**: 18 nov 2025
**Status**: ✅ Production Ready
