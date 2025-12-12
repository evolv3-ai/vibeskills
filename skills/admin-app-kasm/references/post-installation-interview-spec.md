# KASM Post-Installation Interview System - Specification

**Version**: 1.0
**Status**: Draft Specification
**Created**: 2025-11-19
**Purpose**: Interactive customization wizard for KASM Workspaces after successful installation

## Contents
- Executive Summary
- System Architecture
- Module Specifications
- Interview System Flow
- API Integration
- Configuration Templates
- User Experience Features
- Testing Requirements
- Implementation Phases
- Success Metrics
- Future Enhancements
- Documentation Requirements
- Conclusion

---

## Executive Summary

This specification defines an interactive interview system that guides users through KASM Workspaces customization and optimization after successful installation. The system is modular, allowing users to select which customizations to apply and in what order.

### Design Principles

1. **Guided & Interactive**: Ask questions, don't require configuration file editing
2. **Modular**: Each customization module can run independently
3. **Idempotent**: Safe to re-run without breaking existing configurations
4. **Documented**: Every step explains what it does and why
5. **Reversible**: Ability to undo or modify applied configurations
6. **Progressive**: Start simple, advance to complex features over time

---

## System Architecture

### Core Components

```
kasm-post-install-wizard.sh (Main orchestrator)
├── modules/
│   ├── 01-persistent-profiles.sh
│   ├── 02-shared-storage.sh
│   ├── 03-backup-configuration.sh
│   ├── 04-docker-in-docker.sh
│   ├── 05-storage-providers.sh (Nextcloud, S3, etc.)
│   ├── 06-ssl-certificates.sh
│   ├── 07-user-authentication.sh
│   ├── 08-resource-optimization.sh
│   ├── 09-monitoring-setup.sh
│   └── 10-workspace-templates.sh
├── lib/
│   ├── kasm-api.sh (KASM API wrapper functions)
│   ├── prompts.sh (Interactive prompt helpers)
│   ├── validators.sh (Input validation)
│   └── utils.sh (Common utilities)
├── templates/
│   ├── docker-run-config.json.tmpl
│   ├── docker-exec-config.json.tmpl
│   ├── volume-mappings.json.tmpl
│   └── storage-provider.json.tmpl
└── configs/
    └── interview-state.json (Tracks completed modules and user choices)
```

---

## Module Specifications

### Module 01: Persistent Profiles

**Purpose**: Configure persistent user profiles across KASM sessions

**Interview Questions**:
1. "Do you want to enable persistent user profiles? (y/n)"
2. "Where should user profiles be stored?"
   - Options: Local directory, NFS mount, Block storage
3. "What is the storage path?" (default: `/mnt/kasm_profiles`)
4. "Should profiles be user-specific or shared?" (user/shared)
5. "Set storage quota per user? (optional, in GB)"

**Generated Configuration**:
```json
{
  "persistent_profiles": {
    "enabled": true,
    "path": "/mnt/kasm_profiles/{username}/{image_id}",
    "quota_gb": 10,
    "permissions": {
      "uid": 1000,
      "gid": 1000,
      "mode": "0755"
    }
  }
}
```

**Implementation Steps**:
1. Create storage directory: `sudo mkdir -p /mnt/kasm_profiles`
2. Set ownership: `sudo chown -R 1000:1000 /mnt/kasm_profiles`
3. Set permissions: `sudo chmod 755 /mnt/kasm_profiles`
4. Update workspace configurations via KASM API
5. Test profile persistence with sample workspace

**Verification**:
- Directory created with correct permissions
- Test user can write to profile directory
- Workspace configuration updated in KASM database
- Sample file persists across workspace sessions

**Documentation References**:
- `/docs/kasm-installation-verification-and-customization-guide.md` (Lines 160-169)
- `/docs/docker-in-kasm.md` (Lines 95-98)

---

### Module 02: Shared Storage

**Purpose**: Configure shared directories accessible across multiple workspaces

**Interview Questions**:
1. "Do you want to set up shared storage? (y/n)"
2. "What type of shared storage?"
   - Options: Development workspace (/dv), Shared documents, Project files, Custom
3. "Source directory on host?" (e.g., `/mnt/dev_shared`)
4. "Target mount point in containers?" (e.g., `/home/kasm-user/dv`)
5. "Should this be read-only or read-write?" (ro/rw)
6. "Which user groups should have access?" (all/specific groups)

**Generated Configuration**:
```json
{
  "volume_mappings": {
    "/mnt/dev_shared": {
      "bind": "/home/kasm-user/dv",
      "mode": "rw",
      "uid": 1000,
      "gid": 1000,
      "required": true,
      "skip_check": false
    }
  }
}
```

**Implementation Steps**:
1. Create host directory: `sudo mkdir -p /mnt/dev_shared`
2. Set permissions: `sudo chown -R 1000:1000 /mnt/dev_shared && sudo chmod 775 /mnt/dev_shared`
3. Apply volume mapping to workspace configurations via KASM API
4. Optionally create subdirectories (projects/, docs/, shared/)
5. Test read/write access from workspace

**Verification**:
- Host directory exists with correct permissions
- Volume mapping appears in workspace container
- Files created in workspace persist to host
- Multiple workspaces can access shared directory

**Documentation References**:
- `/docs/kasm-installation-verification-and-customization-guide.md` (Lines 166-168)
- `/docs/docker-in-kasm.md` (Lines 100-112)

---

### Module 03: Backup Configuration

**Purpose**: Automated backup of KASM configurations, databases, and user data

**Interview Questions**:
1. "Do you want to configure automated backups? (y/n)"
2. "What should be backed up?"
   - Options: Database only, Configuration only, User profiles, All of the above
3. "Backup destination?"
   - Options: Local directory, S3-compatible storage (Backblaze B2, AWS S3), SFTP server
4. "Backup frequency?" (hourly/daily/weekly)
5. "Retention policy?" (keep last X backups)

**Generated Configuration**:
```json
{
  "backup": {
    "enabled": true,
    "schedule": "0 2 * * *",
    "destination": "s3://bucket-name/kasm-backups/",
    "includes": [
      "/opt/kasm/current/conf",
      "database:kasm",
      "/mnt/kasm_profiles"
    ],
    "retention": {
      "daily": 7,
      "weekly": 4,
      "monthly": 12
    }
  }
}
```

**Implementation Steps**:
1. Install backup dependencies (rclone, aws-cli, or custom)
2. Configure backup credentials (S3 keys, SFTP credentials)
3. Create backup script based on user choices
4. Set up cron job for automated backups
5. Test backup and restoration procedure
6. Generate backup verification report

**Verification**:
- Backup script created and executable
- Cron job scheduled correctly
- Test backup completes successfully
- Test restore from backup works

**Documentation References**:
- `/docs/kasm-installation-verification-and-customization-guide.md` (Lines 170-173)
- `/docs/backblaze-sync.md`

---

### Module 04: Docker-in-Docker (DinD)

**Purpose**: Configure workspaces to run Docker containers inside KASM workspaces

**Interview Questions**:
1. "Do you want to enable Docker-in-Docker for development workspaces? (y/n)"
2. "Should Docker daemon auto-start in workspaces?" (y/n)
3. "Resource allocation for DinD workspaces:"
   - Memory (default: 4096MB, recommended: 4096-6144MB)
   - CPU cores (default: 2, recommended: 3)
4. "Should workspaces run in privileged mode?" (required for DinD) (y/n)
5. "Enable Docker Compose?" (y/n)

**Generated Configuration**:
```json
{
  "docker_in_docker": {
    "enabled": true,
    "auto_start": true,
    "resources": {
      "memory_mb": 4096,
      "cpu_cores": 3,
      "shm_size": "1g"
    },
    "docker_run_config": {
      "privileged": true,
      "shm_size": "1g",
      "environment": {
        "DOCKER_HOST": "unix:///var/run/docker.sock"
      }
    },
    "docker_exec_config": {
      "first_launch": {
        "user": "root",
        "privileged": true,
        "cmd": "bash -c 'dockerd & sleep 5 && /usr/bin/desktop_ready'"
      }
    }
  }
}
```

**Implementation Steps**:
1. Create/update DinD workspace configuration
2. Apply Docker Run Config Override for privileged mode
3. Configure Docker Exec Config for auto-start
4. Set resource limits (memory, CPU)
5. Test Docker functionality in workspace
6. Verify Docker Compose works (if enabled)

**Verification**:
- Workspace launches with privileged mode
- `docker ps` works in workspace
- `docker run hello-world` succeeds
- Docker Compose commands work (if enabled)
- Resources allocated correctly

**Documentation References**:
- `/docs/docker-in-kasm.md` (Complete guide, lines 1-297)

---

### Module 05: Storage Providers (Nextcloud, S3, etc.)

**Purpose**: Configure external storage providers for workspace access

**Interview Questions**:
1. "Do you want to connect external storage providers? (y/n)"
2. "Which provider?"
   - Options: Nextcloud, S3-compatible (AWS, Backblaze), SFTP, WebDAV, Custom
3. For Nextcloud:
   - "Nextcloud server URL?" (e.g., `https://nextcloud.example.com`)
   - "Default username format?" (e.g., `user@domain.com`)
   - "Use application passwords?" (recommended: yes)
4. "Where should storage be mounted in workspaces?" (e.g., `/nextcloud`)
5. "Should storage be user-specific or shared?" (user/shared)

**Generated Configuration**:
```json
{
  "storage_providers": {
    "nextcloud": {
      "enabled": true,
      "driver": "rclone",
      "driver_opts": {
        "type": "webdav",
        "url": "https://nextcloud.example.com/remote.php/dav/files/",
        "vendor": "nextcloud",
        "uid": "1000",
        "gid": "1000",
        "allow_other": "true"
      },
      "mount_point": "/nextcloud",
      "user_specific": true
    }
  }
}
```

**Implementation Steps**:
1. Install rclone Docker plugin (if not already installed)
2. Create storage provider in KASM via API
3. Create storage mapping configuration
4. Test storage provider connection
5. Assign to user groups or workspaces
6. Generate user instructions for authentication

**Verification**:
- Storage provider appears in KASM admin panel
- Test user can authenticate and mount storage
- Files created in workspace sync to external storage
- Read/write permissions work correctly

**Documentation References**:
- `/docs/kasm-nextcloud-troubleshooting.md` (Complete guide, lines 1-218)

---

### Module 06: SSL Certificates

**Purpose**: Configure SSL certificates for secure HTTPS access

**Interview Questions**:
1. "Do you want to configure SSL certificates? (y/n)"
2. "Which method?"
   - Options: Let's Encrypt (automatic), Custom certificate, Self-signed (development)
3. For Let's Encrypt:
   - "Domain name for KASM?" (e.g., `kasm.example.com`)
   - "Email for certificate notifications?"
4. For Custom certificate:
   - "Path to certificate file?"
   - "Path to private key file?"
   - "Path to CA bundle?" (optional)

**Generated Configuration**:
```json
{
  "ssl": {
    "enabled": true,
    "method": "letsencrypt",
    "domain": "kasm.example.com",
    "email": "admin@example.com",
    "auto_renew": true,
    "redirect_http": true
  }
}
```

**Implementation Steps**:
1. Install certbot (for Let's Encrypt)
2. Obtain SSL certificate
3. Update KASM configuration to use certificate
4. Configure automatic renewal
5. Set up HTTP to HTTPS redirect
6. Test HTTPS access

**Verification**:
- Certificate obtained successfully
- HTTPS works with valid certificate
- HTTP redirects to HTTPS
- Auto-renewal configured correctly

**Documentation References**:
- `/docs/kasm-installation-verification-and-customization-guide.md` (Lines 143-146)

---

### Module 07: User Authentication

**Purpose**: Configure advanced authentication methods

**Interview Questions**:
1. "Do you want to configure advanced authentication? (y/n)"
2. "Which authentication method?"
   - Options: Local (default), LDAP, Active Directory, SAML, OIDC
3. For LDAP/AD:
   - "LDAP server URL?"
   - "Base DN?"
   - "Bind DN and password?"
   - "User filter?"
4. For SAML/OIDC:
   - "Provider URL?"
   - "Client ID and secret?"
   - "Attribute mappings?"

**Generated Configuration**:
```json
{
  "authentication": {
    "method": "ldap",
    "ldap": {
      "server": "ldaps://ldap.example.com:636",
      "base_dn": "dc=example,dc=com",
      "bind_dn": "cn=admin,dc=example,dc=com",
      "user_filter": "(uid={username})",
      "group_filter": "(memberUid={username})"
    }
  }
}
```

**Implementation Steps**:
1. Test authentication provider connectivity
2. Configure KASM authentication settings via API
3. Create test user account
4. Verify authentication works
5. Configure group mappings (if applicable)
6. Document user login procedures

**Verification**:
- Test user can authenticate
- Group memberships sync correctly
- Existing local users still work
- Authentication logs show successful connections

**Documentation References**:
- `/docs/kasm-installation-verification-and-customization-guide.md` (Lines 148-152)

---

### Module 08: Resource Optimization

**Purpose**: Optimize resource allocation for workspaces and server

**Interview Questions**:
1. "Do you want to optimize resource allocation? (y/n)"
2. "Server total resources:"
   - CPU cores available: (auto-detect or manual)
   - RAM available: (auto-detect or manual)
3. "Default workspace allocation:"
   - Memory per workspace (MB): (default: 2048)
   - CPU cores per workspace: (default: 1)
4. "Maximum concurrent sessions?" (default: based on resources)
5. "Enable resource usage monitoring?" (y/n)

**Generated Configuration**:
```json
{
  "resources": {
    "server": {
      "cpu_cores": 12,
      "memory_gb": 24
    },
    "defaults": {
      "memory_mb": 2048,
      "cpu_cores": 2,
      "concurrent_limit": 8
    },
    "monitoring": {
      "enabled": true,
      "alerts": {
        "cpu_threshold": 80,
        "memory_threshold": 85
      }
    }
  }
}
```

**Implementation Steps**:
1. Analyze current server resources
2. Calculate optimal defaults based on capacity
3. Update workspace default resources
4. Configure resource limits
5. Enable monitoring (if selected)
6. Generate resource utilization report

**Verification**:
- Workspace resource settings updated
- Test workspace launches with new resources
- Resource limits enforced correctly
- Monitoring shows accurate metrics

**Documentation References**:
- `/docs/kasm-installation-verification-and-customization-guide.md` (Lines 176-182)

---

### Module 09: Monitoring Setup

**Purpose**: Configure health monitoring and alerting

**Interview Questions**:
1. "Do you want to set up monitoring? (y/n)"
2. "What should be monitored?"
   - Options: Container health, Resource usage, User sessions, Database, All
3. "Enable email alerts?" (y/n)
4. "Alert email address?"
5. "Alert thresholds:"
   - CPU usage: (default: 80%)
   - Memory usage: (default: 85%)
   - Disk usage: (default: 90%)

**Generated Configuration**:
```json
{
  "monitoring": {
    "enabled": true,
    "checks": [
      "container_health",
      "resource_usage",
      "user_sessions",
      "database_connectivity"
    ],
    "alerts": {
      "email": "admin@example.com",
      "thresholds": {
        "cpu_percent": 80,
        "memory_percent": 85,
        "disk_percent": 90
      }
    },
    "schedule": "*/5 * * * *"
  }
}
```

**Implementation Steps**:
1. Create monitoring script
2. Configure email alerting (if enabled)
3. Set up cron job for periodic checks
4. Test monitoring and alerts
5. Generate initial health report
6. Document monitoring procedures

**Verification**:
- Monitoring script runs successfully
- Test alert triggers correctly
- Logs show monitoring activity
- Health reports generated

**Documentation References**:
- `/docs/kasm-installation-verification-and-customization-guide.md` (Lines 223-231)

---

### Module 10: Workspace Templates

**Purpose**: Create custom workspace templates for common use cases

**Interview Questions**:
1. "Do you want to create custom workspace templates? (y/n)"
2. "Which template types?"
   - Options: Development (Node.js, Python, etc.), Docker-in-Docker, Browser isolation, Office productivity, Custom
3. For Development template:
   - "Programming languages?" (Node.js, Python, Go, Java, etc.)
   - "Include development tools?" (git, vim, VS Code, etc.)
   - "Enable Docker?" (y/n)
4. "Default resources for this template?"
   - Memory (MB)
   - CPU cores

**Generated Configuration**:
```json
{
  "workspace_templates": {
    "dev-nodejs": {
      "base_image": "kasmweb/ubuntu-jammy-desktop:1.17.0",
      "packages": [
        "nodejs",
        "npm",
        "git",
        "build-essential"
      ],
      "resources": {
        "memory_mb": 3072,
        "cpu_cores": 2
      },
      "volume_mappings": {
        "/mnt/dev_shared": {
          "bind": "/home/kasm-user/projects",
          "mode": "rw"
        }
      }
    }
  }
}
```

**Implementation Steps**:
1. Create workspace configuration
2. Install specified packages/tools
3. Configure resource allocation
4. Apply volume mappings
5. Test workspace launch
6. Save as template for users

**Verification**:
- Template appears in workspace list
- All specified tools installed
- Resources allocated correctly
- Volume mappings work

**Documentation References**:
- `/docs/kasm-installation-verification-and-customization-guide.md` (Lines 197-202)

---

## Interview System Flow

### Main Menu

```
╔════════════════════════════════════════════════════════════╗
║       KASM Workspaces Post-Installation Wizard             ║
║                    Version 1.0                             ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  Welcome! This wizard will help you customize your KASM   ║
║  installation with advanced features and optimizations.   ║
║                                                            ║
║  Installation detected:                                    ║
║  ✓ KASM Version: 1.17.0                                   ║
║  ✓ Server IP: <SERVER_IP>                                 ║
║  ✓ Resources: 2 CPU, 12GB RAM                             ║
║  ✓ Containers: 10/10 running                              ║
║                                                            ║
╠════════════════════════════════════════════════════════════╣
║  Select customization modules to configure:                ║
║                                                            ║
║  [ ] 01. Persistent Profiles                              ║
║  [ ] 02. Shared Storage                                   ║
║  [ ] 03. Backup Configuration                             ║
║  [ ] 04. Docker-in-Docker                                 ║
║  [ ] 05. Storage Providers (Nextcloud, S3)                ║
║  [ ] 06. SSL Certificates                                 ║
║  [ ] 07. User Authentication                              ║
║  [ ] 08. Resource Optimization                            ║
║  [ ] 09. Monitoring Setup                                 ║
║  [ ] 10. Workspace Templates                              ║
║                                                            ║
║  [A] Select All  [N] Select None  [R] Run Selected        ║
║  [S] Save Progress  [Q] Quit                              ║
╚════════════════════════════════════════════════════════════╝
```

### Interview Progress Tracking

```json
{
  "interview_state": {
    "version": "1.0",
    "started": "2025-11-19T00:00:00Z",
    "last_updated": "2025-11-19T00:30:00Z",
    "modules": {
      "01-persistent-profiles": {
        "status": "completed",
        "completed_at": "2025-11-19T00:10:00Z",
        "config": {...}
      },
      "02-shared-storage": {
        "status": "in_progress",
        "started_at": "2025-11-19T00:25:00Z",
        "config": {...}
      },
      "03-backup-configuration": {
        "status": "pending"
      }
    }
  }
}
```

---

## API Integration

### KASM API Wrapper Functions

The wizard will use KASM's REST API to apply configurations:

```bash
# lib/kasm-api.sh

# Get KASM API credentials from installation
get_kasm_api_creds() {
    KASM_API_URL="https://localhost/api"
    KASM_API_KEY=$(sudo grep "api_key" /opt/kasm/current/conf/app/api.app.config.yaml | awk '{print $2}')
    KASM_API_SECRET=$(sudo grep "api_key_secret" /opt/kasm/current/conf/app/api.app.config.yaml | awk '{print $2}')
}

# Update workspace configuration
update_workspace_config() {
    local workspace_id="$1"
    local config_json="$2"

    curl -X POST "$KASM_API_URL/api/public/update_workspace" \
        -H "Content-Type: application/json" \
        -u "$KASM_API_KEY:$KASM_API_SECRET" \
        -d "$config_json"
}

# Create storage mapping
create_storage_mapping() {
    local mapping_json="$1"

    curl -X POST "$KASM_API_URL/api/public/create_storage_mapping" \
        -H "Content-Type: application/json" \
        -u "$KASM_API_KEY:$KASM_API_SECRET" \
        -d "$mapping_json"
}
```

---

## Configuration Templates

### Docker Run Config Template

```json
{
  "hostname": "kasm",
  "privileged": {{PRIVILEGED}},
  "shm_size": "{{SHM_SIZE}}",
  "environment": {
    {{#if DOCKER_ENABLED}}
    "DOCKER_HOST": "unix:///var/run/docker.sock",
    {{/if}}
    "KASMVNC_DESKTOP_ALLOW_RESIZE": "{{ALLOW_RESIZE}}",
    "KASMVNC_DESKTOP_RESOLUTION_WIDTH": "{{WIDTH}}",
    "KASMVNC_DESKTOP_RESOLUTION_HEIGHT": "{{HEIGHT}}"
  }
}
```

### Volume Mappings Template

```json
{
  "{{HOST_PATH}}": {
    "bind": "{{CONTAINER_PATH}}",
    "mode": "{{MODE}}",
    "uid": {{UID}},
    "gid": {{GID}},
    "required": {{REQUIRED}},
    "skip_check": {{SKIP_CHECK}}
  }
}
```

---

## User Experience Features

### Visual Progress Indicators

```bash
Installing persistent profiles...
[████████████████████████████░░░░] 80% - Setting permissions
```

### Validation and Error Handling

- **Pre-validation**: Check prerequisites before applying (disk space, network, permissions)
- **Live validation**: Validate inputs as user enters them
- **Post-validation**: Verify configuration was applied successfully
- **Rollback**: Automatic rollback if configuration fails
- **Error reporting**: Clear error messages with suggested fixes

### Help System

- **Contextual help**: `?` at any prompt shows detailed help
- **Examples**: Show example values for each input
- **Documentation links**: Reference to relevant docs
- **Preview**: Show what will be configured before applying

---

## Testing Requirements

### Unit Tests

- Each module can be tested independently
- Mock KASM API responses for testing
- Validate configuration generation
- Test rollback procedures

### Integration Tests

- Test full interview flow
- Test with actual KASM installation
- Verify configurations apply correctly
- Test concurrent module execution

### User Acceptance Tests

- Real users complete interview
- Measure completion time
- Gather feedback on clarity
- Test with various configurations

---

## Implementation Phases

### Phase 1: Core Framework (Week 1)
- Main orchestrator script
- Module loading system
- State persistence
- Basic prompts and validation

### Phase 2: Essential Modules (Week 2)
- Module 01: Persistent Profiles
- Module 02: Shared Storage
- Module 08: Resource Optimization

### Phase 3: Advanced Features (Week 3-4)
- Module 04: Docker-in-Docker
- Module 05: Storage Providers
- Module 09: Monitoring

### Phase 4: Enterprise Features (Week 5-6)
- Module 06: SSL Certificates
- Module 07: Authentication
- Module 03: Backup Configuration

### Phase 5: Polish & Documentation (Week 7)
- Module 10: Workspace Templates
- Comprehensive testing
- User documentation
- Video tutorials

---

## Success Metrics

1. **Completion Rate**: % of users who complete interview
2. **Time to Complete**: Average time to configure all modules
3. **Error Rate**: Configuration failures requiring manual intervention
4. **User Satisfaction**: Survey rating of interview experience
5. **Support Tickets**: Reduction in configuration-related support requests

---

## Future Enhancements

1. **Web-based Interface**: Browser-based wizard instead of CLI
2. **Import/Export**: Share configurations between installations
3. **Preset Profiles**: Pre-configured sets for common use cases (development, training, enterprise)
4. **Auto-discovery**: Detect optimal settings based on server resources
5. **Health Checks**: Periodic re-validation of configurations
6. **Configuration Diff**: Show changes before applying
7. **Multi-language Support**: Internationalization
8. **Integration Testing**: Built-in verification after each module

---

## Documentation Requirements

### For Developers

- API documentation for all modules
- Architecture decision records
- Testing procedures
- Contribution guidelines

### For Users

- Quick start guide
- Module-specific guides
- Troubleshooting FAQ
- Video walkthroughs

### For Administrators

- Installation guide
- Configuration reference
- Backup/restore procedures
- Security considerations

---

## Conclusion

This post-installation interview system transforms KASM Workspaces from a basic installation into a fully customized, production-ready VDI platform through an intuitive, guided process. By leveraging existing documentation and proven configurations, users can confidently optimize their KASM deployment without deep technical expertise.

The modular design ensures flexibility while the interactive approach reduces configuration errors and accelerates time to value.
