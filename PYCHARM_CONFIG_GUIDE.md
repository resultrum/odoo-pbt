# Configuration de l'Interpréteur Docker dans PyCharm - Guide Détaillé

## 🔴 **ATTENTION**: Faire EXACTEMENT ceci dans cet ordre!

---

## Étape 1: Attendre que PyCharm Redémarre Complètement

⏳ **Attendre 30-60 secondes** que PyCharm se charge entièrement.

Vous devriez voir:
- La fenêtre PyCharm s'ouvre
- Un message "Loading..." ou "Indexing..."
- L'interface se stabilise

---

## Étape 2: Ouvrir les Préférences

**Menu**: `PyCharm → Settings` (ou `Cmd + ,` sur macOS)

---

## Étape 3: Naviguer vers Python Interpreter

Dans les Settings:

1. Sur la **gauche**: Cliquer sur **`Project: odoo-template`**
2. Puis: **`Python Interpreter`**

Vous devriez voir une liste vide ou "No interpreter configured"

---

## Étape 4: Ajouter un Nouvel Interpréteur

1. En **haut à droite** du panneau principal, cliquer sur **l'engrenage ⚙️**
2. Sélectionner **`Add...`**

Une popup s'ouvre: "Add Python Interpreter"

---

## Étape 5: Sélectionner Docker Compose

Dans la popup "Add Python Interpreter":

1. Sur la **gauche**: Cliquer sur **`Docker Compose`**
2. Un formulaire s'affiche avec ces champs:

---

## Étape 6: Remplir le Formulaire

### 📝 Champ 1: Docker Compose File

**Cliquer sur le bouton 📁** à côté de "Docker Compose file"

Sélectionner: `/Users/jonathannemry/Projects/odoo-template/docker-compose.yml`

### 📝 Champ 2: Service

Dérouler et sélectionner: **`web`**

### 📝 Champ 3: Python Interpreter Path

Laisser **VIDE** ou garder la valeur par défaut

### 📝 Champ 4: Working Directory

Laisser **VIDE**

---

## Étape 7: Cliquer OK

Cliquer sur le bouton **`OK`** en bas à droite de la popup.

**PyCharm va maintenant**:
1. ✅ Créer un nouveau volume PyCharm helper
2. ✅ Lancer un conteneur helper
3. ✅ Détecter l'interpréteur Python du conteneur
4. ✅ Synchroniser les dépendances Odoo (2-5 minutes)

---

## Étape 8: Vérification

Une fois synchronisé, vous devriez voir:

```
Python 3.12.3 (odoo-template-web)
```

Ou quelque chose comme:
```
Docker Compose (web:latest): Python 3.12.x
```

---

## ⚠️ Problèmes Courants et Solutions

### ❌ Erreur: "Docker daemon is not running"

**Solution**:
1. Ouvrir Docker Desktop
2. Attendre qu'il se charge (la baleine doit être stable dans la barre de menu)
3. Réessayer

---

### ❌ Erreur: "Cannot find docker-compose.yml"

**Solution**:
1. Vérifier que le chemin est correct: `/Users/jonathannemry/Projects/odoo-template/docker-compose.yml`
2. Si le fichier n'existe pas, exécuter:
   ```bash
   ls -la ~/Projects/odoo-template/docker-compose.yml
   ```

---

### ❌ Erreur: "Service 'web' not found in docker-compose.yml"

**Solution**:
1. Ouvrir `docker-compose.yml` dans PyCharm
2. Vérifier que le service s'appelle bien `web`
3. Si ça ne s'affiche pas, cliquer sur le bouton **`Refresh`** dans la popup

---

### ❌ Erreur: "Python not found" ou "packaging_tool.py error"

**Solution**:
1. Supprimer l'interpréteur: Cliquer ⚙️ → Remove
2. Attendre 10 secondes
3. Ajouter un nouvel interpréteur Docker Compose
4. **Vérifier que le conteneur `odoo-template-web` est en cours d'exécution**:
   ```bash
   docker ps | grep odoo-template-web
   ```

---

### ❌ Synchronisation très lente (> 10 minutes)

**Solution**:
1. C'est normal pour la première fois (nombreuses dépendances Odoo)
2. **NE PAS ARRÊTER PYCHARM**
3. Attendre patiemment
4. Vérifier dans le Terminal que le conteneur tourne:
   ```bash
   docker logs -f odoo-template-web
   ```

---

## ✅ Checklist Finale

- [ ] PyCharm complètement chargé
- [ ] Docker Desktop actif
- [ ] Conteneur `odoo-template-web` en cours d'exécution (`docker ps`)
- [ ] Fichier `docker-compose.yml` trouvé
- [ ] Service `web` sélectionné
- [ ] Interpréteur Python affiche "3.12.x"
- [ ] Synchronisation terminée (pas de message "Loading..." en bas)

---

## 🎯 Une Fois Configuré

Vous pouvez:

1. **Ouvrir un fichier Python** dans `addons/custom/`
2. **Vérifier la complétion de code** (Ctrl + Espace)
3. **Voir les imports Odoo** sans erreurs rouges
4. **Utiliser le debugger** PyCharm

---

**Créé**: 18 nov 2025
**Support**: Lire `PYCHARM_SETUP.md` pour plus de détails
