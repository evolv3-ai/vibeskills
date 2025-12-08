# KASM Post-Installation Wizard - Quick Start

## 🚀 Run the Wizard

```bash
cd .claude/skills/admin-app-kasm
bash kasm-post-install-wizard.sh
```

## 📦 What's Implemented

### ✅ Module 03: Backup Configuration
Configure automated backups to cloud storage (Backblaze B2, AWS S3, local, or SFTP).

**What it does:**
- Asks simple questions about your backup preferences
- Installs and configures backup scripts automatically
- Sets up cron jobs for automated backups
- Verifies everything works

**To run:**
```bash
# Option 1: Via wizard menu
bash kasm-post-install-wizard.sh
# Select: 03

# Option 2: Direct module execution
bash modules/03-backup-configuration.sh

# Option 3: Automated with MCP variables
export KASM_BACKUP_RCLONE_REMOTE="backblaze"
export KASM_BACKUP_RCLONE_BUCKET="my-backups"
bash modules/03-backup-configuration.sh
```

## 🔜 Coming Soon

Modules 01, 02, 04-10 will follow the same pattern:
- Interactive questions
- Automatic configuration
- Verification checks
- State tracking

## 📚 Full Documentation

- **User Guide**: `README-WIZARD.md`
- **Integration Details**: `docs/kasm-backup-module-integration-summary.md`
- **Completion Summary**: `docs/kasm-wizard-completion-summary.md`
- **MCP Variables**: `assets/env-template`

## 🎯 Quick Examples

### Example 1: Configure Backups to Backblaze B2
```bash
# 1. Configure rclone first
rclone config

# 2. Run the wizard
bash kasm-post-install-wizard.sh

# 3. Select Module 03
# 4. Answer the questions:
#    - Enable backups? Yes
#    - What to backup? All of the above
#    - Destination? S3-compatible storage
#    - Remote name? backblaze
#    - Bucket? kasm-s3
#    - Frequency? Every 4 hours
#    - Retention? 7 daily, 4 weekly, 12 monthly
# 5. Done! Backups configured automatically
```

### Example 2: Local Backups (No Cloud)
```bash
bash kasm-post-install-wizard.sh
# Select: 03
# Choose: Local directory
# Path: /mnt/backups/kasm
# Frequency: Daily
```

### Example 3: Automated Setup (CI/CD)
```bash
#!/bin/bash
# Set all MCP variables
export KASM_BACKUP_ENABLED=true
export KASM_BACKUP_RCLONE_REMOTE=backblaze
export KASM_BACKUP_RCLONE_BUCKET=production-kasm
export KASM_BACKUP_INTERVAL_MINUTES=240
export KASM_BACKUP_MAX_RETRIES=5

# Run module non-interactively
bash modules/03-backup-configuration.sh
```

## 📊 Monitor Backups

After configuring Module 03:

```bash
# View live logs
tail -f /var/log/kasm-backup.log

# Check backup status
sudo /opt/kasm-sync/kasm-backup-monitor.sh stats

# Generate report
sudo /opt/kasm-sync/kasm-backup-monitor.sh report

# Manual backup test
sudo /opt/kasm-sync/kasm-backup-manager.sh
```

## ❓ Help

```bash
# Show wizard help
bash kasm-post-install-wizard.sh
# Select: H (Help)

# Or read the docs
cat README-WIZARD.md
```

## ✅ Status

- **Main Wizard**: ✅ Complete and tested
- **Module 03**: ✅ Complete and functional
- **Modules 01-02, 04-10**: 🔜 Framework ready, coming soon

---

**Ready to use!** The wizard provides an easy, interactive way to configure KASM advanced features without editing configuration files.
