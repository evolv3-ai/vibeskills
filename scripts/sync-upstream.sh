#!/bin/bash
# Sync with upstream claude-skills using jezweb → vibe → main workflow
# Original repo: https://github.com/jezweb/claude-skills by Jeremy Dawes
# Fork: https://github.com/evolv3-ai/vibe-skills
#
# WORKFLOW:
#   upstream (jezweb/claude-skills) 
#       ↓ fetch + merge
#   jezweb branch (staging for upstream changes)
#       ↓ merge + preserve vibe files
#   vibe branch (testing + custom development)
#       ↓ merge after testing
#   main branch (production)

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Files/folders unique to vibe branch that should be preserved
VIBE_PRESERVED_PATHS=(
    # Scripts
    "scripts/sync-upstream.sh"
    
    # Admin suite skills (not in upstream)
    "skills/admin/"
    "skills/admin-app-coolify/"
    "skills/admin-app-kasm/"
    "skills/admin-devops/"
    "skills/admin-infra-contabo/"
    "skills/admin-infra-digitalocean/"
    "skills/admin-infra-hetzner/"
    "skills/admin-infra-linode/"
    "skills/admin-infra-oci/"
    "skills/admin-infra-vultr/"
    "skills/admin-mcp/"
    "skills/admin-unix/"
    "skills/admin-windows/"
    "skills/admin-wsl/"
    "skills/deckmate/"
    "skills/imagemagick/"
    
    # Tutorials
    "tutorials/"
    
    # Planning docs specific to vibe
    "planning/admin-skills-redesign.md"
    
    # Documentation specific to vibe
    "docs/admin-skills-architecture.md"
    "docs/admin-skills-windows-map.md"
    "docs/cc-powershell.md"
    "docs/IMPLEMENTATION_PHASES.md"
    
    # Root files specific to vibe
    "AGENTS.md"
    "SKILLS_BEST_PRACTICES.md"
)

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}▸${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  fetch         Fetch latest from upstream (no merge)"
    echo "  pull-jezweb   Pull upstream into jezweb branch"
    echo "  preview       Preview what would change merging jezweb → vibe"
    echo "  merge-vibe    Merge jezweb into vibe (preserves vibe-specific files)"
    echo "  merge-main    Merge vibe into main (after testing)"
    echo "  status        Show current branch status and divergence"
    echo "  help          Show this help message"
    echo ""
    echo "Typical workflow:"
    echo "  1. $0 fetch           # See what's new upstream"
    echo "  2. $0 pull-jezweb     # Update jezweb branch"
    echo "  3. $0 preview         # Review changes before merge"
    echo "  4. $0 merge-vibe      # Merge to vibe for testing"
    echo "  5. (test your changes)"
    echo "  6. $0 merge-main      # Promote to main after testing"
}

ensure_upstream_remote() {
    if ! git remote | grep -q "^upstream$"; then
        print_warning "Upstream remote not found."
        echo "Add it with:"
        echo "  git remote add upstream https://github.com/jezweb/claude-skills.git"
        echo ""
        read -p "Add upstream remote now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git remote add upstream https://github.com/jezweb/claude-skills.git
            # Prevent accidental pushes to upstream
            git remote set-url --push upstream no_push
            print_success "Upstream remote added (push disabled)"
        else
            print_error "Cancelled. Add upstream remote manually and try again."
            exit 1
        fi
    fi
}

ensure_branch_exists() {
    local branch=$1
    if ! git show-ref --verify --quiet "refs/heads/$branch"; then
        print_error "Branch '$branch' does not exist locally"
        exit 1
    fi
}

get_current_branch() {
    git branch --show-current
}

save_current_branch() {
    ORIGINAL_BRANCH=$(get_current_branch)
}

restore_original_branch() {
    if [ -n "$ORIGINAL_BRANCH" ]; then
        git checkout "$ORIGINAL_BRANCH" 2>/dev/null || true
    fi
}

cmd_fetch() {
    print_header "Fetching Upstream Changes"
    ensure_upstream_remote
    
    print_step "Fetching from upstream..."
    git fetch upstream
    
    echo ""
    print_step "Upstream branches:"
    git branch -r | grep upstream
    
    echo ""
    print_step "Commits on upstream/main not in jezweb:"
    local count=$(git rev-list --count jezweb..upstream/main 2>/dev/null || echo "0")
    echo "  $count new commits"
    
    if [ "$count" -gt 0 ]; then
        echo ""
        git log --oneline jezweb..upstream/main | head -10
        if [ "$count" -gt 10 ]; then
            echo "  ... and $(($count - 10)) more"
        fi
    fi
    
    print_success "Fetch complete"
}

cmd_pull_jezweb() {
    print_header "Pull Upstream → Jezweb"
    ensure_upstream_remote
    ensure_branch_exists "jezweb"
    save_current_branch
    
    print_step "Switching to jezweb branch..."
    git checkout jezweb
    
    print_step "Fetching upstream..."
    git fetch upstream
    
    print_step "Merging upstream/main into jezweb..."
    if git merge --no-edit upstream/main; then
        print_success "Merge successful"
    else
        print_warning "Merge conflicts detected!"
        echo ""
        echo "Resolve conflicts, then:"
        echo "  git add <resolved-files>"
        echo "  git commit"
        echo ""
        echo "Or abort with: git merge --abort"
        exit 1
    fi
    
    restore_original_branch
    print_success "Jezweb branch updated with upstream changes"
}

cmd_preview() {
    print_header "Preview: Jezweb → Vibe"
    ensure_branch_exists "jezweb"
    ensure_branch_exists "vibe"
    
    echo "Files that would change (excluding preserved vibe paths):"
    echo ""
    
    # Show diff excluding preserved paths
    local exclude_args=""
    for path in "${VIBE_PRESERVED_PATHS[@]}"; do
        exclude_args="$exclude_args ':!$path'"
    done
    
    eval "git diff vibe..jezweb --stat -- $exclude_args" | head -50
    
    echo ""
    print_step "Commits on jezweb not in vibe:"
    local count=$(git rev-list --count vibe..jezweb 2>/dev/null || echo "0")
    echo "  $count commits"
    
    if [ "$count" -gt 0 ]; then
        echo ""
        git log --oneline vibe..jezweb | head -15
    fi
    
    echo ""
    print_step "Files that will be PRESERVED (not overwritten):"
    for path in "${VIBE_PRESERVED_PATHS[@]}"; do
        if [ -e "$path" ] || git ls-tree -r vibe --name-only | grep -q "^$path"; then
            echo "  ✓ $path"
        fi
    done
}

cmd_merge_vibe() {
    print_header "Merge: Jezweb → Vibe (with preservation)"
    ensure_branch_exists "jezweb"
    ensure_branch_exists "vibe"
    save_current_branch
    
    print_step "Switching to vibe branch..."
    git checkout vibe
    
    print_step "Stashing any uncommitted changes..."
    git stash push -m "sync-upstream: pre-merge stash" 2>/dev/null || true
    
    print_step "Merging jezweb into vibe (no auto-commit)..."
    if git merge jezweb --no-commit --no-ff 2>/dev/null; then
        print_success "Merge preparation successful (no conflicts)"
    else
        print_warning "Merge conflicts or changes detected"
    fi
    
    echo ""
    print_step "Restoring vibe-preserved paths..."
    for path in "${VIBE_PRESERVED_PATHS[@]}"; do
        if git ls-tree -r HEAD --name-only | grep -q "^$path" 2>/dev/null; then
            git checkout HEAD -- "$path" 2>/dev/null && echo "  ✓ Restored: $path" || true
        fi
    done
    
    echo ""
    print_success "Merge preparation complete!"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "  1. Review changes:        git status"
    echo "  2. Check diff:            git diff --cached"
    echo "  3. Test your changes"
    echo "  4. Commit when ready:     git commit -m 'Sync upstream: [describe changes]'"
    echo "  5. Or abort:              git merge --abort"
    echo ""
    echo -e "${GREEN}💡 Tip:${NC} Vibe-specific files have been preserved"
}

cmd_merge_main() {
    print_header "Merge: Vibe → Main (production)"
    ensure_branch_exists "vibe"
    ensure_branch_exists "main"
    save_current_branch
    
    echo -e "${YELLOW}⚠️  This will merge vibe into main (production branch)${NC}"
    read -p "Have you tested the changes on vibe? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Cancelled. Test on vibe first."
        exit 1
    fi
    
    print_step "Switching to main branch..."
    git checkout main
    
    print_step "Merging vibe into main..."
    if git merge vibe --no-ff -m "Merge vibe: upstream sync + tested changes"; then
        print_success "Merge successful"
    else
        print_warning "Merge conflicts detected!"
        echo "Resolve conflicts, then commit."
        exit 1
    fi
    
    echo ""
    print_success "Main branch updated!"
    echo ""
    echo "Don't forget to push:"
    echo "  git push origin main"
}

cmd_status() {
    print_header "Branch Sync Status"
    
    local current=$(get_current_branch)
    echo "Current branch: $current"
    echo ""
    
    ensure_upstream_remote
    git fetch upstream --quiet 2>/dev/null || true
    
    echo "Branch divergence:"
    echo ""
    
    # upstream vs jezweb
    local up_jez=$(git rev-list --count jezweb..upstream/main 2>/dev/null || echo "?")
    local jez_up=$(git rev-list --count upstream/main..jezweb 2>/dev/null || echo "?")
    echo "  upstream/main ↔ jezweb:  +$up_jez ahead / -$jez_up behind"
    
    # jezweb vs vibe
    local jez_vibe=$(git rev-list --count vibe..jezweb 2>/dev/null || echo "?")
    local vibe_jez=$(git rev-list --count jezweb..vibe 2>/dev/null || echo "?")
    echo "  jezweb ↔ vibe:           +$jez_vibe ahead / -$vibe_jez behind"
    
    # vibe vs main
    local vibe_main=$(git rev-list --count main..vibe 2>/dev/null || echo "?")
    local main_vibe=$(git rev-list --count vibe..main 2>/dev/null || echo "?")
    echo "  vibe ↔ main:             +$vibe_main ahead / -$main_vibe behind"
    
    echo ""
    echo "Recommended workflow:"
    if [ "$up_jez" -gt 0 ]; then
        echo "  → Run: $0 pull-jezweb  (upstream has $up_jez new commits)"
    fi
    if [ "$jez_vibe" -gt 0 ]; then
        echo "  → Run: $0 merge-vibe   (jezweb has $jez_vibe commits to merge)"
    fi
    if [ "$vibe_main" -gt 0 ]; then
        echo "  → Run: $0 merge-main   (vibe has $vibe_main tested commits)"
    fi
    if [ "$up_jez" -eq 0 ] && [ "$jez_vibe" -eq 0 ] && [ "$vibe_main" -eq 0 ]; then
        print_success "All branches are in sync!"
    fi
}

# Main command router
case "${1:-help}" in
    fetch)
        cmd_fetch
        ;;
    pull-jezweb)
        cmd_pull_jezweb
        ;;
    preview)
        cmd_preview
        ;;
    merge-vibe)
        cmd_merge_vibe
        ;;
    merge-main)
        cmd_merge_main
        ;;
    status)
        cmd_status
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        print_error "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac
