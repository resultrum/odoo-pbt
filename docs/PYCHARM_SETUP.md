# PyCharm Setup Guide - Step by Step

Complete guide to set up your Odoo project in PyCharm with full debugging support.

---

## 📋 Prerequisites

- **PyCharm Professional Edition** (required for remote debugging)
- **Docker Desktop** installed and running
- **Project cloned** locally:
  ```bash
  git clone https://github.com/resultrum/odoo-template.git odoo-pbt
  cd odoo-pbt
  ```

---

## 🚀 Setup Steps

### Step 1: Run Setup Script

This clones Odoo sources via SSH and configures everything:

```bash
# Ensure SSH is set up
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# Run setup (automatically clones Odoo Enterprise)
./scripts/setup-new-project.sh odoo-pbt pbt_base "Your Company" enterprise

# This will:
# ✅ Clone odoo-enterprise/ via SSH
# ✅ Create .env file
# ✅ Rename modules
# ✅ Set up docker-compose
```

**Output should show:**
```
✅ Odoo repository cloned successfully
✅ Odoo directory structure verified
✅ Project setup complete!
```

---

### Step 2: Start Docker Containers

```bash
# Start development environment with all volumes
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Verify containers are running
docker-compose ps

# Check logs
docker-compose logs web
```

**Should see:**
```
web_1  | 2025-11-18 12:34:56,789 odoo.tools 25639 INFO odoo: ...
web_1  | 2025-11-18 12:34:56,890 odoo.http 25639 INFO odoo: ...
```

---

### Step 3: Configure PyCharm Docker Interpreter

#### 3.1 Open Preferences

**macOS**: `PyCharm → Preferences`
**Linux/Windows**: `File → Settings`

#### 3.2 Navigate to Python Interpreter

`Project → Python Interpreter`

#### 3.3 Add Docker Compose Interpreter

1. Click **gear icon** → `Add...`
2. Select **Docker Compose**
3. Configure:
   - **Config file path**: `/Users/yourname/Projects/odoo-pbt/docker-compose.yml`
   - **Service**: `web`
   - **Environment file**: (leave empty or point to `.env`)

#### 3.4 Configure Compose Files

Under **Compose files**, add BOTH:
```
docker-compose.yml
docker-compose.dev.yml
```

This ensures:
- SSH agent forwarding ✅
- Source code volumes ✅
- Debugging configuration ✅

#### 3.5 Wait for Indexing

PyCharm will index the Python interpreter. This takes 2-5 minutes.

**Progress shown in bottom right corner.**

Once done: ✅ Green checkmark next to interpreter name

---

### Step 4: Configure Project Structure

1. **File → Project Structure**
2. **Add Content Root**:
   - Click `+ Add Content Root`
   - Select: `odoo-pbt/odoo-enterprise`
   - This makes Odoo core code browsable and debuggable

3. **Source Folders**:
   - Mark as **Sources**: `odoo-enterprise/`
   - Mark as **Sources**: `addons/custom/`

---

### Step 5: Verify Setup

#### Check Docker Interpreter

1. Open **Settings → Project → Python Interpreter**
2. Should show: `Docker Compose (web) - Python 3.10`
3. Should list packages:
   ```
   odoo
   psycopg2
   ...
   ```

#### Test Python Execution

In PyCharm Console:

```python
>>> import odoo
>>> print(odoo.__version__)
18.0
>>> import odoo.addons.pbt_base
>>> print("✅ Custom module accessible!")
```

---

## 🐛 Debugging Setup

### Enable Debugger

1. **Settings → Python Interpreter → Python Debug Server**
2. Configure:
   - **Host**: `localhost`
   - **Port**: `6100`
   - Click **OK**

### Start Debug Server

`Run → Debug 'Python Debug Server'`

(Or press `Shift+F9`)

---

## 🎯 First Debug Session

### 1. Set a Breakpoint

Open your custom module:
```
addons/custom/pbt_base/models/pbt_base.py
```

Add code:
```python
class PbtBase(models.Model):
    _name = 'pbt.base'

    name = fields.Char()

    def my_method(self):
        value = 10  # ← Click line number to set breakpoint (red dot)
        return value * 2
```

### 2. Start Odoo in Debug Mode

```bash
# Terminal in PyCharm (Alt+F12)
docker-compose exec web python -m ptvsd \
  --host 0.0.0.0 \
  --port 6100 \
  /opt/odoo/odoo-bin \
  -d odoo \
  -u pbt_base \
  --dev=reload,qweb
```

### 3. Run Debug Server in PyCharm

`Run → Debug 'Python Debug Server'`

Output: `Connected to pydev debugger (build 223.xyz)`

### 4. Trigger Breakpoint

1. Open browser: `http://localhost:8069`
2. Create a record or call your method
3. **PyCharm pauses at breakpoint!** 🎉

### 5. Debug Actions

| Action | Shortcut | Result |
|--------|----------|--------|
| **Step Over** | `F10` | Execute line, skip functions |
| **Step Into** | `F11` | Enter function |
| **Step Out** | `Shift+F11` | Exit current function |
| **Resume** | `F9` | Continue to next breakpoint |
| **Evaluate** | `Option+F9` | Execute Python during pause |

---

## 💡 Pro Tips

### Debug Odoo Core Code

Since `odoo-enterprise/` is mounted as a volume, you can debug **core Odoo code**:

```python
# File: odoo-enterprise/odoo/fields.py

class Field:
    def __get__(self, record, owner):
        # ← Set breakpoint here
        return self._compute_value(record)
```

### Conditional Breakpoints

Right-click breakpoint → **Edit Breakpoint**

Add condition (only break when true):
```python
record.id == 42
amount > 1000
self.env.user.name == 'admin'
```

### Watch Expressions

During debugging, right-click variable → **Add to Watches**

Track changes across execution:
```python
self.env.user.name
record.id
self.env.cr.fetchone()
```

### Console During Debug

Access **Debug Console** to execute Python:

```python
>>> self.env.user.name
'admin'
>>> record.search([('id', '=', 1)])
pbt.base(1,)
```

---

## 🔧 Troubleshooting

### PyCharm Can't Find Docker

**Error**: `Cannot connect to Docker daemon`

**Solution**:
1. Ensure Docker Desktop is running
2. In PyCharm: **Settings → Project → Python Interpreter → Docker → ⚙️**
3. Verify **Docker socket path** is correct

### Breakpoints Don't Pause

**Problem**: Set breakpoint but execution doesn't stop

**Solutions**:
1. **Verify sources mounted**:
   ```bash
   docker inspect $(docker-compose ps -q web) | grep Mounts
   # Should show: "/Users/.../odoo-enterprise" → "/opt/odoo"
   ```

2. **Restart PyCharm debugger**:
   - Run → Debug (F9) again

3. **Verify file sync**:
   - Save file: `Cmd+S`
   - PyCharm should auto-sync to container

### Docker Interpreter Shows Old Python

**Solution**:
1. **Settings → Project → Python Interpreter**
2. Click **gear icon** → **Show All**
3. Remove old Docker interpreter
4. Add new one (follows Step 3 above)

---

## 📚 Next Steps

1. **Review guide**: [`docs/PYCHARM_DEBUGGING.md`](./PYCHARM_DEBUGGING.md)
2. **Explore Odoo core**: Browse `odoo-enterprise/` in PyCharm
3. **Create modules**: Add to `addons/custom/`
4. **Test in browser**: `http://localhost:8069`

---

## ✨ What You've Set Up

✅ Docker Compose interpreter in PyCharm
✅ SSH-cloned Odoo Enterprise sources
✅ Full source code debugging
✅ Breakpoints in custom AND core code
✅ Hot-reload on code changes
✅ Production-ready setup

**Happy debugging!** 🚀
