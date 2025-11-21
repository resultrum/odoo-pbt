# Debugging Odoo Simplifié (sans clone)

Guide pour debugger ton code Odoo **sans avoir besoin de cloner `odoo-enterprise`**.

---

## ✅ Cas Courant: Debugger TON CODE CUSTOM

C'est ce que tu vas faire **99% du temps!**

### Setup (une seule fois)

```bash
# 1. Assure-toi que Docker tourne
docker-compose ps

# 2. Configu PyCharm (voir PYCHARM_SETUP.md)
#    Settings → Project → Python Interpreter → Add → Docker Compose
```

### Mettre un Breakpoint

1. Ouvre ton code: `addons/custom/my_module/models/my_model.py`
2. Clique sur le numéro de ligne → Red dot ✅
3. C'est tout!

```python
class MyModel(models.Model):
    _name = 'my.model'

    def my_method(self):
        value = 10  # ← Clic ici pour breakpoint
        return value * 2
```

### Déclencher le Breakpoint

**Option A: Via Odoo UI**
```bash
# 1. Va à http://localhost:8069
# 2. Fais l'action qui déclenche ton code
# 3. PyCharm pause automatiquement
# 4. Inspect les variables, step through
```

**Option B: Via ligne de commande (plus contrôlé)**
```bash
# Lancer Odoo avec debugger:
docker-compose exec web python -m ptvsd --host 0.0.0.0 --port 6100 /opt/odoo/odoo-bin \
  -d odoo -u my_module --dev=reload,qweb

# Dans PyCharm:
# Run → Debug... → Remote (ou auto-connect)
#
# Puis déclenche ton action dans Odoo
```

### Inspecter les Variables

Quand le breakpoint hit:
- Hover sur les variables pour voir leur valeur
- Panneau "Debug" en bas pour voir local/global vars
- "Evaluate Expression" (Alt+F9) pour custom expressions

---

## 🔧 Cas Avancé: Debugger le CODE ODOO CORE

**Situation**: Tu dois modifier/debugger le code Odoo lui-même (fields.py, models, etc.)

### Sans Clone (Limitation)
```
❌ PyCharm ne peut pas montrer les sources localement
✅ Mais tu peux toujours faire du remote debugging
```

**Steps**:
1. Mets breakpoint dans ton code custom qui **appelle** le code core
2. Step Into (F7) dans le code core
3. PyCharm montre le code du conteneur (limité, pas d'autocomplete)

### Avec Clone (Recommandé si vraiment besoin)
```bash
# Optionnel: si tu vas vraiment modifier Odoo core
./scripts/clone-odoo-repos.sh

# Ou manuellement:
git clone git@github.com:YOUR_REPO/odoo.git odoo-enterprise
cd odoo-enterprise
git checkout 18.0
```

Après clone:
- PyCharm a accès aux sources localement
- Meilleur autocomplete sur le code core
- Peut monter le répertoire comme volume pour live changes

---

## 🐛 Commandes Utiles

### Voir les Logs
```bash
docker-compose logs -f web
```

### Accéder au Shell
```bash
docker-compose exec web bash
# Ensuite: python, ou ls, ou n'importe quoi
```

### Redémarrer Odoo
```bash
docker-compose restart web
```

### Debug Mode
```bash
# Odoo en mode reload automatique (changements de code appliqués directement)
docker-compose logs -f web | grep reload
```

---

## 📌 Résumé

| Cas | Besoin Clone? | Difficulty | Time |
|-----|---|---|---|
| Debugger mon code custom | ❌ Non | ⭐ Facile | 5 min |
| Debugger Odoo core | ✅ Oui (optionnel) | ⭐⭐⭐ Moyen | 15 min |
| Modifier Odoo core | ✅ Oui | ⭐⭐⭐⭐ Difficile | 1h+ |

**Pour commencer**: Pas besoin de clone, just start debugging! 🚀

---

## 🚨 Troubleshooting

**Q: PyCharm ne détecte pas mes breakpoints**
```
A: Vérifier que tu as configuré Docker Compose comme interpreter
   (voir PYCHARM_SETUP.md)
```

**Q: Breakpoint ne pause jamais**
```
A: 1. Vérifier que ton code est vraiment appelé (ajouter logs)
   2. Vérifier que Odoo est en dev mode: ODOO_DEV_MODE=1 dans .env
   3. Redémarrer containers: docker-compose restart web
```

**Q: Peut pas debugger Odoo core code**
```
A: Normal, tu dois cloner odoo-enterprise localement
   Voir section "Cas Avancé" ci-dessus
```

---

**Last updated**: 21 novembre 2025
