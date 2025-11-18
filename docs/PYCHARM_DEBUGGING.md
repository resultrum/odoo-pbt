# PyCharm Debugging Guide for Odoo Development

Complete guide to debugging Odoo (including core code) with PyCharm using Docker.

---

## 📋 Prerequisites

- **PyCharm Professional Edition** (Community doesn't support remote debugging)
- **Docker Desktop** (with Docker Compose)
- **SSH key configured** in ssh-agent for repo cloning
- **Odoo sources cloned** locally (via `./scripts/clone-odoo-repos.sh`)

---

## 🚀 Quick Start

### 1. Start Development Environment

```bash
# Start SSH agent (if not already running)
eval "$(ssh-agent -s)"

# Add your SSH key
ssh-add ~/.ssh/id_rsa

# Clone Odoo Enterprise sources (if not done yet)
./scripts/clone-odoo-repos.sh

# Copy environment template
cp .env.example .env
# Edit .env with your configuration

# Start Docker containers with dev configuration
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# View logs
docker-compose logs -f web
```

### 2. Configure PyCharm Docker Interpreter

1. **Open PyCharm Preferences** (macOS: `PyCharm → Preferences`, Linux/Windows: `File → Settings`)

2. **Navigate to**: `Project → Python Interpreter`

3. **Click gear icon** → `Add...` → `Docker Compose`

4. **Configure Docker Compose**:
   - **Config file path**: `docker-compose.yml`
   - **Service**: `web`
   - **Compose files**:
     - `docker-compose.yml`
     - `docker-compose.dev.yml`

5. **Click OK** and wait for PyCharm to index

---

## 🐛 Debug Your Code

### Method 1: Using PyCharm Built-in Debugger (Recommended)

#### A. Debug Custom Modules

```python
# Example: addons/custom/my_module/models/my_model.py

class MyModel(models.Model):
    _name = 'my.model'

    def my_method(self):
        value = 10  # ← Click line number to set breakpoint
        return value * 2
```

1. **Set Breakpoint**: Click line number in PyCharm (red dot appears)
2. **Run in Debug Mode**:
   ```bash
   docker-compose exec web python -m ptvsd --host 0.0.0.0 --port 6100 /opt/odoo/odoo-bin \
     -d odoo -u my_module --dev=reload,qweb
   ```
3. **In PyCharm**: `Run → Debug... → Remote` (if not auto-detected)
4. **Trigger your code**: Navigate in Odoo UI
5. **Breakpoint hits**: PyCharm pauses execution, inspect variables

#### B. Debug Odoo Core Code

Since Odoo sources are mounted as volumes, you can debug core code:

```python
# Example: Debugging field.py in Odoo core
# odoo-enterprise/odoo/fields.py

class Field:
    def __get__(self, record, owner):
        # ← Set breakpoint here to debug field access
        return self._compute_value(record)
```

**Process is identical**:
1. Set breakpoint in Odoo core file
2. Run Odoo in debug mode
3. PyCharm pauses when breakpoint is hit
4. Inspect variables, step through code

---

### Method 2: Using ptvsd (Python Tools for Visual Studio Debugger)

#### Setup

1. **Enable in .env**:
   ```bash
   PYCHARM_DEBUG=1
   PYCHARM_DEBUG_PORT=6100
   ```

2. **Start Docker**:
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
   ```

3. **In PyCharm**, go to: `Run → Edit Configurations...`

4. **Create new Debug Configuration**:
   - **Type**: `Python Debug Server`
   - **Host**: `localhost`
   - **Port**: `6100`
   - **Click OK**

5. **Run Debug Server**: `Run → Debug '<config name>'` (or press `Shift+F9`)

6. **Docker will connect** when Python debugger is available

---

### Method 3: Command Line Debugging

#### Start Odoo with Debugger

```bash
# Start interactive debugging
docker-compose exec -it web python -m ptvsd \
  --host 0.0.0.0 \
  --port 6100 \
  /opt/odoo/odoo-bin \
  -d odoo \
  -u my_module \
  --dev=reload,qweb \
  --log-level=debug
```

Then in PyCharm:
- `Run → Debug 'Python Debug Server'`
- PyCharm connects and is ready for debugging

---

## 🔍 Debugging Workflows

### Workflow 1: Debug a Custom Module Method

```bash
# 1. Set breakpoint in your code
# addons/custom/my_module/models/my_model.py:45

# 2. Start Odoo in debug mode
docker-compose exec web python -m ptvsd --host 0.0.0.0 --port 6100 /opt/odoo/odoo-bin \
  -d odoo -u my_module --dev=reload,qweb

# 3. In PyCharm: Run → Debug 'Python Debug Server'

# 4. In Odoo web interface, trigger your code:
#    - Create record
#    - Call method
#    - Run action
#
# 5. PyCharm pauses at breakpoint
#    - Inspect variables with Variables pane
#    - Step through code (F10 = step over, F11 = step into)
#    - Evaluate expressions (right-click → Evaluate Expression)
```

### Workflow 2: Debug Odoo Core Behavior

```python
# Example: Debug why a field isn't computed

# 1. Find relevant code in Odoo:
#    odoo-enterprise/odoo/fields.py
#
# 2. Set breakpoint in compute logic

# 3. Trigger via web UI

# 4. When breakpoint hits in Odoo core:
#    - Inspect self, record, values
#    - Understand compute flow
#    - Track variable changes through code
```

### Workflow 3: Debug API Calls

```bash
# 1. Set breakpoints in your controllers/APIs
#    addons/custom/my_module/controllers/api.py

# 2. Make requests from Postman/curl:
curl -X POST http://localhost:8069/api/endpoint \
  -H "Content-Type: application/json" \
  -d '{"param": "value"}'

# 3. Breakpoint in PyCharm pauses execution
# 4. Inspect request object, parameters, etc.
```

---

## 🛠️ Debugging Tools

### PyCharm Debugger Features

| Feature | Shortcut | Use Case |
|---------|----------|----------|
| **Step Over** | F10 | Execute current line, skip function calls |
| **Step Into** | F11 | Enter function to debug internals |
| **Step Out** | Shift+F11 | Exit current function |
| **Resume** | F9 | Continue execution to next breakpoint |
| **Evaluate Expression** | Option+F9 (macOS) | Execute Python during debugging |
| **Add Watch** | Click variable + click eye | Track variable changes |
| **Conditional Breakpoint** | Right-click breakpoint | Break only when condition true |

### Useful Conditionals

```python
# In breakpoint settings, add conditions:

# Only break for specific record
record.id == 42

# Only break on certain values
amount > 1000

# Only break when logging in
self.env.user.name == 'admin'
```

---

## 🔌 Debugging Connection Issues

### Issue: PyCharm Can't Connect to Debugger

**Symptoms**:
- PyCharm says "Waiting for process connection..."
- Nothing happens after Docker starts

**Solutions**:

1. **Verify debugger is running in Docker**:
   ```bash
   docker-compose logs web | grep ptvsd
   # Should see: "Listening for incoming connections..."
   ```

2. **Check port 6100 is accessible**:
   ```bash
   lsof -i :6100
   # Or in docker-compose.yml, verify port mapping
   ```

3. **Ensure PYCHARM_DEBUG=1 in .env**:
   ```bash
   grep PYCHARM_DEBUG .env
   ```

4. **Restart Docker**:
   ```bash
   docker-compose down
   docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
   ```

### Issue: Breakpoints Don't Hit

**Symptoms**:
- Breakpoint set but not paused
- Code executes without stopping

**Solutions**:

1. **Ensure source code is mounted correctly**:
   ```bash
   # Check if volumes are mounted
   docker inspect $(docker-compose ps -q web) | grep -A 20 Mounts

   # Should show:
   # "/Users/.../odoo-enterprise" → "/opt/odoo"
   ```

2. **PyCharm source path must match container path**:
   - Local: `./odoo-enterprise/odoo/fields.py`
   - Container: `/opt/odoo/odoo/fields.py`

3. **Synchronize source code if debugging installed module**:
   ```bash
   # Make sure modified files are saved before debugging
   # PyCharm should have file auto-save enabled
   ```

4. **Invalid breakpoint marker**:
   - Red dot with X = breakpoint not resolved
   - Ensure file exists in container path
   - Restart PyCharm debugger

---

## 📊 Debugging Database Queries

Debug SQL queries being executed:

```python
# In your code, inspect the SQL:

from odoo import models

class MyModel(models.Model):
    _name = 'my.model'

    def my_method(self):
        # Enable SQL query logging
        with self.env.cr.savepoint():
            records = self.search([('name', '=', 'Test')])
            # breakpoint()  # ← Set breakpoint here
            # Inspect records, check query in logs
            return records
```

**View SQL in logs**:
```bash
docker-compose logs web | grep -i sql
# Or set log level to debug:
# docker-compose exec web ... --log-level=debug
```

---

## 🔐 Debugging Security/Authentication

Debug authentication flows:

```python
# In authentication code, inspect session/user:

# addons/custom/my_module/models/auth.py

class AuthController(http.Controller):
    @route('/api/login', auth='public', method='POST')
    def login(self, **kwargs):
        # breakpoint()  # ← Set here
        # Inspect self.env.user, session, request object
        user = kwargs.get('user')
        return {'success': True}
```

---

## 📝 Tips & Best Practices

### 1. Use Watch Expressions

During debugging, right-click a variable to "Add to Watches":
```python
self.env.user.name      # Track current user
record.id               # Track record ID
self.env.cr.fetchone()  # Track query results
```

### 2. Evaluate Expressions During Pause

Press `Option+F9` (macOS) to evaluate:
```python
self.search([('id', 'in', [1,2,3])])  # Search for records
self.env.user.groups_id.mapped('name')  # Get user's groups
```

### 3. Multi-threaded Debugging

If debugging Odoo under load:
- Set breakpoint in Thread 1
- Other threads continue
- Useful for race condition debugging

### 4. Conditional Breakpoints

Right-click breakpoint → Edit:
```python
# Only break when specific user logs in
user.login == 'admin'

# Only break on large amounts
invoice.amount_total > 10000
```

### 5. Log Points (instead of print())

Right-click breakpoint → Edit → Add log message:
```
User {user} attempted login at {datetime.now()}
```
Logs message without pausing execution.

---

## 🚀 Advanced: Remote Debugging Production

For production debugging (not recommended for live systems):

```bash
# On production server, start Odoo with debugger
ssh user@prod-server
export PYTHONUNBUFFERED=1
docker-compose exec web python -m ptvsd --host 0.0.0.0 --port 6100 ...

# From your laptop, connect via SSH tunnel
ssh -L 6100:localhost:6100 user@prod-server

# In PyCharm: Run → Debug 'Python Debug Server'
```

⚠️ **Warning**: Only use for emergency debugging, never leave debugging enabled in production.

---

## 📚 Additional Resources

- **PyCharm Debugger Docs**: https://www.jetbrains.com/help/pycharm/debugging-code.html
- **Odoo Development**: https://www.odoo.com/documentation/18.0/developer.html
- **ptvsd Documentation**: https://github.com/microsoft/ptvsd
- **Docker Compose in PyCharm**: https://www.jetbrains.com/help/pycharm/docker-compose.html

---

**Happy Debugging!** 🐛✨
