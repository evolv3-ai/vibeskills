# KASM Post-Installation Wizard

**Version**: 1.0
**Status**: Module 03 Implemented ✅
**Last Updated**: 2025-11-19

## Contents
- Overview
- Quick Start
- Available Modules
- MCP Variables
- Architecture
- Usage Examples
- Monitoring Backups
- Troubleshooting
- Development Guide
- Contributing
- Related Documentation
- Roadmap
- License
- Support

---

## Overview

The KASM Post-Installation Wizard is an interactive interview system that guides you through customizing and optimizing your KASM Workspaces installation. Instead of manually editing configuration files, you answer simple questions and the wizard automatically applies the settings.

### Features

- ✨ **Interactive Interview System** - No configuration file editing required
- 🎯 **Modular Design** - Each feature is a separate module you can run independently
- 💾 **State Persistence** - Configurations are saved and tracked
- 🔄 **Idempotent** - Safe to re-run modules without breaking existing configs
- 📝 **Documented** - Every step explains what it does and why
- ↩️ **Reversible** - Configurations can be modified or undone
- 🔌 **MCP Integration** - Supports environment variables for automation

---

## Quick Start

### 1. Run the Wizard

```bash
cd .claude/skills/admin-app-kasm
bash kasm-post-install-wizard.sh
```

### 2. Select a Module

The wizard will show you a menu of available customization modules:

```
╔════════════════════════════════════════════════════════════╗
║  KASM Workspaces Post-Installation Wizard v1.0             ║
╚════════════════════════════════════════════════════════════╝

Installation Detected:
  ✓ KASM Version: 1.17.0
  ✓ Server IP: 157.151.193.18
  ✓ Resources: 2 CPU, 12GB RAM
  ✓ Containers: 10 running

Select customization modules to configure:

  01) Persistent Profiles              [Coming Soon]
  02) Shared Storage                   [Coming Soon]
  03) Backup Configuration             [✓ Completed]
  04) Docker-in-Docker                 [Coming Soon]
  05) Storage Providers                [Coming Soon]
  06) SSL Certificates                 [Coming Soon]
  07) User Authentication              [Coming Soon]
  08) Resource Optimization            [Coming Soon]
  09) Monitoring Setup                 [Coming Soon]
  10) Workspace Templates              [Coming Soon]

  A) Select All Implemented Modules
  I) Show System Information
  S) Show Wizard State
  R) Reset Wizard State
  H) Help
  Q) Quit

Enter your choice:
```

### 3. Follow the Interview

Each module will ask you questions and apply the configuration automatically.

---

## Available Modules

### ✅ Module 03: Backup Configuration (Implemented)

Configure automated backups of KASM data to cloud storage.

**What it configures**:
- Backup destination (S3, Local, SFTP)
- Backup frequency (4 hours, daily, etc.)
- What to backup (database, config, user profiles)
- Retention policy (how long to keep backups)

**Usage**:
```bash
# Interactive mode
bash kasm-post-install-wizard.sh
# Select: 03

# Direct module execution
bash modules/03-backup-configuration.sh

# With MCP variables
export KASM_BACKUP_RCLONE_REMOTE="backblaze"
export KASM_BACKUP_RCLONE_BUCKET="my-backups"
bash modules/03-backup-configuration.sh
```

**Prerequisites**:
- `rclone` installed and configured (for S3 backups)
- `jq` installed

**Example Interview**:
```
Do you want to configure automated backups? [Y/n]: y

What should be backed up?
1) Database only
2) Configuration only
3) User profiles only
4) All of the above (recommended)
Enter choice [1-4]: 4

Select backup destination:
1) S3-compatible storage (Backblaze B2, AWS S3)
2) Local directory
3) SFTP server
Enter choice [1-3]: 1

Rclone remote name [backblaze]: backblaze
S3 bucket name [kasm-s3]: my-kasm-backups

Select backup frequency:
1) Every 4 hours (recommended)
2) Daily
3) Every 12 hours
4) Weekly
Enter choice [1-4]: 1

Keep how many daily backups? [7]: 7
Keep how many weekly backups? [4]: 4
Keep how many monthly backups? [12]: 12

Configure advanced options? [y/N]: n
```

### 🔜 Coming Soon Modules

The following modules are planned and will follow the same pattern:

- **Module 01**: Persistent Profiles
- **Module 02**: Shared Storage
- **Module 04**: Docker-in-Docker
- **Module 05**: Storage Providers (Nextcloud, S3)
- **Module 06**: SSL Certificates
- **Module 07**: User Authentication
- **Module 08**: Resource Optimization
- **Module 09**: Monitoring Setup
- **Module 10**: Workspace Templates

---

## MCP Variables

All modules support MCP (Model Context Protocol) environment variables for automation and non-interactive configuration.

### Backup Module Variables

```bash
# Enable automated backups
export KASM_BACKUP_ENABLED=true

# Rclone configuration
export KASM_BACKUP_RCLONE_REMOTE=backblaze
export KASM_BACKUP_RCLONE_BUCKET=kasm-s3

# Backup settings
export KASM_BACKUP_ROOT=/mnt
export KASM_BACKUP_INTERVAL_MINUTES=240
export KASM_BACKUP_MAX_RETRIES=3
export KASM_BACKUP_RETRY_DELAY=300

# Paths to backup
export KASM_BACKUP_PATHS="kasm_profiles:profiles,dev_shared:dev-shared"

# Log files
export KASM_BACKUP_LOG_FILE=/var/log/kasm-backup.log
export KASM_BACKUP_STATS_FILE=/var/log/kasm-backup-stats.json
export KASM_BACKUP_REPORT_FILE=/var/log/kasm-backup-report.txt
```

**See**: `assets/env-template` for complete list of variables

---

## Architecture

### Directory Structure

```
.claude/skills/admin-app-kasm/
├── kasm-post-install-wizard.sh    # Main wizard orchestrator
├── README-WIZARD.md                # This file
│
├── modules/                        # Customization modules
│   ├── 03-backup-configuration.sh  # Module 03 (implemented)
│   └── [01-02, 04-10].sh          # Future modules
│
├── lib/                            # Shared libraries
│   ├── kasm-api.sh                # KASM API wrapper functions
│   ├── prompts.sh                 # Interactive prompt helpers
│   └── utils.sh                   # Common utilities
│
├── configs/                        # Configuration storage
│   └── interview-state.json       # Wizard state (auto-generated)
│
├── scripts/                        # Installation scripts
│   └── validate-env.sh            # Environment validation
│
├── assets/                         # Templates and resources
│   └── env-template               # Environment variable template
│
└── specs/                          # Specifications
    └── post-installation-interview-spec.md
```

### How It Works

1. **Main Wizard** (`kasm-post-install-wizard.sh`)
   - Displays menu of available modules
   - Tracks module completion status
   - Provides system information and help

2. **Modules** (`modules/*.sh`)
   - Each module handles one aspect of customization
   - Asks interview questions
   - Applies configuration automatically
   - Verifies installation
   - Updates wizard state

3. **Libraries** (`lib/*.sh`)
   - **kasm-api.sh**: Functions to interact with KASM API
   - **prompts.sh**: User-friendly interactive prompts
   - **utils.sh**: State management, validation, logging

4. **State Persistence**
   - Configurations saved to `configs/interview-state.json`
   - Prevents duplicate work
   - Allows resuming interrupted sessions

---

## Usage Examples

### Example 1: First-Time Setup

```bash
# Run the wizard
cd .claude/skills/admin-app-kasm
bash kasm-post-install-wizard.sh

# Select option 03 (Backup Configuration)
# Answer the questions
# Wizard automatically installs and configures backups
```

### Example 2: Reconfigure a Module

```bash
# Run the same module again
bash kasm-post-install-wizard.sh
# Select: 03

# Wizard detects it's already configured
# Asks if you want to reconfigure
# Applies new settings
```

### Example 3: Automated Setup with MCP Variables

```bash
# Set environment variables
export KASM_BACKUP_ENABLED=true
export KASM_BACKUP_RCLONE_REMOTE=backblaze
export KASM_BACKUP_RCLONE_BUCKET=production-backups
export KASM_BACKUP_INTERVAL_MINUTES=240

# Run module directly (uses variables, minimal prompts)
bash modules/03-backup-configuration.sh
```

### Example 4: Check System Status

```bash
bash kasm-post-install-wizard.sh
# Select: I (System Information)

# Shows:
# - CPU and memory
# - KASM containers
# - Disk usage
```

### Example 5: View Configuration State

```bash
bash kasm-post-install-wizard.sh
# Select: S (Show Wizard State)

# Shows JSON with all module configurations
```

### Example 6: Reset Everything

```bash
bash kasm-post-install-wizard.sh
# Select: R (Reset Wizard State)

# Confirms before deleting all module status
# Fresh start
```

---

## Monitoring Backups

After configuring Module 03, you can monitor backups:

```bash
# View live backup logs
tail -f /var/log/kasm-backup.log

# Generate monitoring report
sudo /opt/kasm-sync/kasm-backup-monitor.sh report

# Check backup statistics
sudo /opt/kasm-sync/kasm-backup-monitor.sh stats

# Run all monitoring checks
sudo /opt/kasm-sync/kasm-backup-monitor.sh all

# Manual backup test
sudo /opt/kasm-sync/kasm-backup-manager.sh
```

---

## Troubleshooting

### Wizard won't start

```bash
# Check prerequisites
which docker  # Should return path
which jq      # Should return path

# Check KASM is running
docker ps | grep kasm

# Check permissions
ls -la kasm-post-install-wizard.sh
# Should be executable: chmod +x kasm-post-install-wizard.sh
```

### Module 03 fails to install backups

```bash
# Check rclone configuration
rclone config
rclone about backblaze:kasm-s3

# Check disk space
df -h /opt/kasm-sync
df -h /var/log

# Check sudo access
sudo -v

# View detailed logs
tail -100 /var/log/kasm-wizard.log
```

### State file issues

```bash
# View current state
cat /opt/kasm-sync/configs/interview-state.json

# Reset state
rm -f /opt/kasm-sync/configs/interview-state.json

# Reinitialize
bash kasm-post-install-wizard.sh
# Select: S (creates new state file)
```

---

## Development Guide

### Creating a New Module

Follow Module 03 as a template:

1. **Create module file**: `modules/XX-module-name.sh`
2. **Load libraries**:
   ```bash
   source "$SKILL_DIR/lib/prompts.sh"
   source "$SKILL_DIR/lib/utils.sh"
   source "$SKILL_DIR/lib/kasm-api.sh"  # If needed
   ```

3. **Define module info**:
   ```bash
   MODULE_NAME="XX-module-name"
   MODULE_TITLE="Module Title"
   MODULE_VERSION="1.0"
   ```

4. **Implement functions**:
   - `show_module_header()` - Display module info
   - `ask_interview_questions()` - Interactive Q&A, returns JSON config
   - `implement_configuration()` - Apply the config
   - `verify_configuration()` - Check it worked
   - `main()` - Orchestrate the flow

5. **Update main wizard**:
   - Add to `IMPLEMENTED_MODULES` array
   - Add module info to `MODULES` associative array

6. **Test**:
   ```bash
   # Test standalone
   bash modules/XX-module-name.sh

   # Test via wizard
   bash kasm-post-install-wizard.sh
   ```

### Library Functions Available

**prompts.sh**:
- `ask_yes_no()` - Yes/no questions
- `ask_input()` - Text input
- `ask_choice()` - Multiple choice
- `ask_number()` - Numeric input
- `ask_path()` - Path with validation
- `print_success/error/warning/info()` - Colored messages
- `show_progress()` - Progress bars

**utils.sh**:
- `load_state()` / `save_state()` - State persistence
- `get_module_status()` / `update_module_status()` - Module tracking
- `check_required_commands()` - Dependency checking
- `create_directory()` - Directory creation with permissions
- `log_message()` - Logging

**kasm-api.sh**:
- `get_kasm_api_creds()` - Extract API credentials
- `get_workspaces()` - List workspaces
- `update_workspace_config()` - Modify workspace settings
- `apply_volume_mapping()` - Add volume mounts
- `apply_persistent_profile()` - Configure profiles

---

## Contributing

To add new modules or improve existing ones:

1. Follow the Module 03 pattern
2. Use MCP variables for all configurable values
3. Implement interview questions from the spec
4. Add verification checks
5. Update this README
6. Test thoroughly

---

## Related Documentation

- **Full Specification**: `specs/post-installation-interview-spec.md`
- **Integration Summary**: `docs/kasm-backup-module-integration-summary.md`
- **Backup Scripts Overview**: `docs/kasm-backup-script-map.md`
- **MCP Variables**: `assets/env-template`
- **KASM Skill Documentation**: `SKILL.md`

---

## Roadmap

### Phase 1: Core Framework ✅
- ✅ Main orchestrator script
- ✅ Module loading system
- ✅ State persistence
- ✅ Library functions (prompts, utils, kasm-api)

### Phase 2: Essential Modules (Current)
- ✅ Module 03: Backup Configuration
- 🔜 Module 01: Persistent Profiles
- 🔜 Module 02: Shared Storage
- 🔜 Module 08: Resource Optimization

### Phase 3: Advanced Features
- 🔜 Module 04: Docker-in-Docker
- 🔜 Module 05: Storage Providers
- 🔜 Module 09: Monitoring

### Phase 4: Enterprise Features
- 🔜 Module 06: SSL Certificates
- 🔜 Module 07: Authentication
- 🔜 Module 10: Workspace Templates

### Phase 5: Polish
- 🔜 Comprehensive testing
- 🔜 Video tutorials
- 🔜 Web-based interface option

---

## License

MIT License - Same as KASM Workspaces Skill

---

## Support

- **Issues**: https://github.com/anthropics/claude-code/issues
- **Skill Documentation**: `.claude/skills/admin-app-kasm/SKILL.md`
- **KASM Documentation**: https://kasmweb.com/docs/latest/

---

**Status**: Production Ready (Module 03) ✅
**Framework**: Complete ✅
**Ready for**: Additional module development ✅
