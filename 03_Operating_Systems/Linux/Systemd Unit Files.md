---
tags:
  - devops
  - configuration
  - systemd
  - linux
  - guide
category: os
status: learning
related: "[[Systemd Architecture]]"
date: 2025-11-23
---
# Systemd Unit Files
## 📝 One-Sentence Summary
*Systemd Unit Files use a declarative, INI-like syntax organized into `[Unit]`, `[Service]`, and `[Install]` sections to define how a resource should be started, monitored, and stopped.*
## ⚙️ Section 1: `[Unit]` (Metadata & Dependencies)
*Defines what the unit is and its relationship to others.*
- **`Description=`**: Human-readable summary.
- **`Documentation=`**: Link to man pages/docs.
- **Dependencies:**
    - **`Requires=`**: Strong dependency. If the required unit fails, this unit fails immediately.
    - **`Wants=`**: Weak dependency. Tries to start the listed unit, but proceeds even if it fails.
    - **`After=` / `Before=`**: Ordering. "Start me after the Network is up."
    - **`Conflicts=`**: This unit cannot run if the conflicting unit is active.

## ⚙️ Section 2: `[Service]` (Execution)
*Defines the actual process logic.*
- **`Type=`**:
    - `simple` (default): The command started *is* the main process.
    - `forking`: The command starts a background daemon and exits (traditional services).
    - `oneshot`: Runs once and exits (like a backup script).
- **`ExecStart=`**: The exact command to run.
- **`ExecStartPre=` / `ExecStartPost=`**: Commands to run before/after the main process.
- **`Restart=`**: When to restart (`on-failure`, `always`, `no`).
- **`User=` / `Group=`**: Run as a specific user.
- **`EnvironmentFile=`**: Load variables from a file.

## ⚙️ Section 3: `[Install]` (Enablement)
*Defines when this unit should start at boot.*
- **`WantedBy=`**: Which target links to this unit? (Usually `multi-user.target`).
- **`Alias=`**: Alternative names for the service.

## 🔗 Example Unit File
```
[Unit]
Description=My Custom Web App
After=network.target mysql.service

[Service]
Type=simple
User=www-data
ExecStart=/usr/bin/python3 /opt/myapp/server.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

## See Also

- [[Systemd Architecture]]
    
- [[Runlevels]] (Targets)