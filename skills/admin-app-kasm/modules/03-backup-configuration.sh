#!/bin/bash

# Module 03: Backup Configuration
# Automated backup of KASM configurations, databases, and user data
# Based on specification: post-installation-interview-spec.md (lines 155-207)

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# Load libraries
source "$SKILL_DIR/lib/prompts.sh"
source "$SKILL_DIR/lib/utils.sh"

# Module information
MODULE_NAME="03-backup-configuration"
MODULE_TITLE="Backup Configuration"
MODULE_VERSION="1.0"

# Function to display module header
show_module_header() {
    print_header "Module 03: Backup Configuration"
    print_info "Automated backup of KASM configurations, databases, and user data"
    print_info "Version: $MODULE_VERSION"
    echo ""
}

# Function to ask interview questions
ask_interview_questions() {
    local config="{}"

    # Question 1: Enable backups?
    print_section "Backup Configuration"
    if ! ask_yes_no "Do you want to configure automated backups?" "y"; then
        echo '{"enabled": false}' | jq .
        return 0
    fi

    config=$(echo "$config" | jq '.enabled = true')

    # Question 2: What to backup?
    echo ""
    print_info "What should be backed up?"
    local backup_what=$(ask_choice "Select backup scope:" \
        "Database only" \
        "Configuration only" \
        "User profiles only" \
        "All of the above (recommended)")

    case "$backup_what" in
        "Database only")
            config=$(echo "$config" | jq '.includes = ["database:kasm"]')
            ;;
        "Configuration only")
            config=$(echo "$config" | jq '.includes = ["/opt/kasm/current/conf"]')
            ;;
        "User profiles only")
            config=$(echo "$config" | jq '.includes = ["/mnt/kasm_profiles"]')
            ;;
        "All of the above (recommended)")
            config=$(echo "$config" | jq '.includes = ["/opt/kasm/current/conf", "database:kasm", "/mnt/kasm_profiles"]')
            ;;
    esac

    # Question 3: Backup destination
    echo ""
    print_info "Backup destination configuration"
    local destination=$(ask_choice "Select backup destination:" \
        "S3-compatible storage (Backblaze B2, AWS S3)" \
        "Local directory" \
        "SFTP server")

    case "$destination" in
        "S3-compatible storage (Backblaze B2, AWS S3)")
            config=$(echo "$config" | jq '.destination_type = "s3"')

            local remote_name=$(ask_input "Rclone remote name" "backblaze")
            local bucket_name=$(ask_input "S3 bucket name" "kasm-s3")
            local backup_path=$(ask_input "Backup path (within bucket)" "kasm-backups/")

            config=$(echo "$config" | jq \
                --arg remote "$remote_name" \
                --arg bucket "$bucket_name" \
                --arg path "$backup_path" \
                '.destination = "s3://" + $bucket + "/" + $path |
                 .rclone_remote = $remote |
                 .rclone_bucket = $bucket')
            ;;
        "Local directory")
            config=$(echo "$config" | jq '.destination_type = "local"')

            local local_path=$(ask_path "Local backup directory" "/mnt/backups/kasm")

            config=$(echo "$config" | jq \
                --arg path "$local_path" \
                '.destination = $path')
            ;;
        "SFTP server")
            config=$(echo "$config" | jq '.destination_type = "sftp"')

            local sftp_host=$(ask_input "SFTP server hostname")
            local sftp_user=$(ask_input "SFTP username")
            local sftp_path=$(ask_input "Remote path" "/backups/kasm")

            config=$(echo "$config" | jq \
                --arg host "$sftp_host" \
                --arg user "$sftp_user" \
                --arg path "$sftp_path" \
                '.destination = "sftp://" + $host + $path |
                 .sftp_host = $host |
                 .sftp_user = $user')
            ;;
    esac

    # Question 4: Backup frequency
    echo ""
    local frequency=$(ask_choice "Select backup frequency:" \
        "Every 4 hours (recommended)" \
        "Daily" \
        "Every 12 hours" \
        "Weekly")

    case "$frequency" in
        "Every 4 hours (recommended)")
            config=$(echo "$config" | jq '.schedule = "0 */4 * * *" | .interval_minutes = 240')
            ;;
        "Daily")
            config=$(echo "$config" | jq '.schedule = "0 2 * * *" | .interval_minutes = 1440')
            ;;
        "Every 12 hours")
            config=$(echo "$config" | jq '.schedule = "0 */12 * * *" | .interval_minutes = 720')
            ;;
        "Weekly")
            config=$(echo "$config" | jq '.schedule = "0 2 * * 0" | .interval_minutes = 10080')
            ;;
    esac

    # Question 5: Retention policy
    echo ""
    print_info "Backup retention policy"
    local daily=$(ask_number "Keep how many daily backups?" "7" 1 30)
    local weekly=$(ask_number "Keep how many weekly backups?" "4" 0 52)
    local monthly=$(ask_number "Keep how many monthly backups?" "12" 0 24)

    config=$(echo "$config" | jq \
        --arg daily "$daily" \
        --arg weekly "$weekly" \
        --arg monthly "$monthly" \
        '.retention = {
            daily: ($daily | tonumber),
            weekly: ($weekly | tonumber),
            monthly: ($monthly | tonumber)
        }')

    # Advanced options
    echo ""
    if ask_yes_no "Configure advanced options?" "n"; then
        local max_retries=$(ask_number "Maximum retry attempts on failure" "3" 1 10)
        local retry_delay=$(ask_number "Delay between retries (seconds)" "300" 60 3600)

        config=$(echo "$config" | jq \
            --arg retries "$max_retries" \
            --arg delay "$retry_delay" \
            '.max_retries = ($retries | tonumber) |
             .retry_delay = ($delay | tonumber)')
    else
        config=$(echo "$config" | jq '.max_retries = 3 | .retry_delay = 300')
    fi

    echo "$config" | jq .
}

# Function to implement backup configuration
implement_backup() {
    local config="$1"

    print_section "Implementing Backup Configuration"

    # Check if backups are enabled
    local enabled=$(echo "$config" | jq -r '.enabled // false')
    if [[ "$enabled" != "true" ]]; then
        print_info "Backup configuration skipped (not enabled)"
        return 0
    fi

    # Get configuration values
    local destination_type=$(echo "$config" | jq -r '.destination_type')
    local rclone_remote=$(echo "$config" | jq -r '.rclone_remote // "backblaze"')
    local rclone_bucket=$(echo "$config" | jq -r '.rclone_bucket // "kasm-s3"')
    local interval_minutes=$(echo "$config" | jq -r '.interval_minutes // 240')
    local max_retries=$(echo "$config" | jq -r '.max_retries // 3')
    local retry_delay=$(echo "$config" | jq -r '.retry_delay // 300')
    local backup_paths=$(echo "$config" | jq -r '.includes | join(",")')

    # Export MCP variables for backup scripts
    export KASM_BACKUP_RCLONE_REMOTE="$rclone_remote"
    export KASM_BACKUP_RCLONE_BUCKET="$rclone_bucket"
    export KASM_BACKUP_INTERVAL_MINUTES="$interval_minutes"
    export KASM_BACKUP_MAX_RETRIES="$max_retries"
    export KASM_BACKUP_RETRY_DELAY="$retry_delay"

    # Convert backup paths to the format expected by the manager script
    if [[ -n "$backup_paths" ]]; then
        # Transform paths like "/mnt/kasm_profiles" to "kasm_profiles:profiles"
        local formatted_paths=""
        IFS=',' read -ra PATHS <<< "$backup_paths"
        for path in "${PATHS[@]}"; do
            if [[ "$path" == /mnt/* ]]; then
                local dir_name=$(basename "$path")
                local remote_name=$(echo "$dir_name" | tr '_' '-')
                formatted_paths+="${dir_name}:${remote_name},"
            fi
        done
        export KASM_BACKUP_PATHS="${formatted_paths%,}"
    fi

    # Step 1: Check required commands
    show_progress "Checking prerequisites" 10
    if ! check_required_commands "rclone" "jq"; then
        print_error "Missing required commands. Please install rclone and jq"
        return 1
    fi
    show_progress "Prerequisites OK" 20

    # Step 2: Test rclone configuration
    show_progress "Testing rclone configuration" 30
    if ! rclone about "$rclone_remote:$rclone_bucket" >/dev/null 2>&1; then
        print_warning "Rclone configuration test failed"
        print_info "Please configure rclone before running backups:"
        print_info "  rclone config"
        # Don't fail here, just warn
    fi
    show_progress "Rclone configuration checked" 40

    # Step 3: Run the backup installer script
    show_progress "Installing backup system" 50

    local installer_script="$SKILL_DIR/../../docs/scripts/kasm-backup-installer.sh"
    if [[ ! -f "$installer_script" ]]; then
        print_error "Backup installer script not found: $installer_script"
        return 1
    fi

    if bash "$installer_script"; then
        show_progress "Backup system installed" 80
        print_success "Backup system installed successfully"
    else
        print_error "Backup system installation failed"
        return 1
    fi

    # Step 4: Test backup
    show_progress "Testing backup configuration" 90
    print_info "You can test the backup manually by running:"
    print_info "  sudo /opt/kasm-sync/kasm-backup-manager.sh"

    show_progress "Backup configuration complete" 100
    echo ""

    return 0
}

# Function to verify backup configuration
verify_backup() {
    local config="$1"

    print_section "Verifying Backup Configuration"

    local enabled=$(echo "$config" | jq -r '.enabled // false')
    if [[ "$enabled" != "true" ]]; then
        print_info "Backup not enabled, skipping verification"
        return 0
    fi

    local checks_passed=0
    local checks_total=5

    # Check 1: Backup script exists
    if [[ -f "/opt/kasm-sync/kasm-backup-manager.sh" ]]; then
        print_success "Backup manager script installed"
        ((checks_passed++))
    else
        print_error "Backup manager script not found"
    fi

    # Check 2: Monitor script exists
    if [[ -f "/opt/kasm-sync/kasm-backup-monitor.sh" ]]; then
        print_success "Backup monitor script installed"
        ((checks_passed++))
    else
        print_error "Backup monitor script not found"
    fi

    # Check 3: Cron job installed
    if crontab -l 2>/dev/null | grep -q "kasm-backup-manager.sh"; then
        print_success "Backup cron job installed"
        ((checks_passed++))
    else
        print_error "Backup cron job not found"
    fi

    # Check 4: Log directory writable
    if test_directory_write "/var/log"; then
        print_success "Log directory is writable"
        ((checks_passed++))
    else
        print_error "Log directory is not writable"
    fi

    # Check 5: Sync directory exists
    if [[ -d "/opt/kasm-sync" ]]; then
        print_success "Sync directory exists"
        ((checks_passed++))
    else
        print_error "Sync directory not found"
    fi

    echo ""
    print_info "Verification: $checks_passed/$checks_total checks passed"

    if [[ $checks_passed -eq $checks_total ]]; then
        print_success "All verification checks passed!"
        return 0
    else
        print_warning "Some verification checks failed"
        return 1
    fi
}

# Main module execution
main() {
    show_module_header

    # Check module status
    local status=$(get_module_status "$MODULE_NAME")
    if [[ "$status" == "completed" ]]; then
        print_warning "This module has already been completed"
        if ! ask_yes_no "Do you want to reconfigure?" "n"; then
            return 0
        fi
    fi

    # Ask interview questions
    local config=$(ask_interview_questions)

    # Show configuration summary
    echo ""
    print_section "Configuration Summary"
    echo "$config" | jq .
    echo ""

    # Confirm before implementing
    if ! confirm_action "implement this backup configuration"; then
        print_info "Backup configuration cancelled"
        return 0
    fi

    # Implement configuration
    if implement_backup "$config"; then
        # Verify implementation
        if verify_backup "$config"; then
            # Update module status
            update_module_status "$MODULE_NAME" "completed" "$config"

            echo ""
            print_success "Module 03: Backup Configuration completed successfully!"

            # Show next steps
            echo ""
            print_section "Next Steps"
            print_info "1. Monitor backup logs: tail -f /var/log/kasm-backup.log"
            print_info "2. View backup reports: cat /var/log/kasm-backup-report.txt"
            print_info "3. Check backup stats: sudo /opt/kasm-sync/kasm-backup-monitor.sh stats"
            print_info "4. Test manual backup: sudo /opt/kasm-sync/kasm-backup-manager.sh"
            echo ""
        else
            print_warning "Backup configuration completed with warnings"
            update_module_status "$MODULE_NAME" "completed_with_warnings" "$config"
        fi
    else
        print_error "Backup configuration failed"
        update_module_status "$MODULE_NAME" "failed" "$config"
        return 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
