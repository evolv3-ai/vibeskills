#!/bin/bash

# Interactive Prompt Helper Functions
# Provides user-friendly prompts for the KASM post-installation wizard
# Based on specification: post-installation-interview-spec.md

# Colors for prompts
PROMPT_COLOR='\033[1;36m'  # Cyan
INPUT_COLOR='\033[1;33m'   # Yellow
SUCCESS_COLOR='\033[0;32m' # Green
ERROR_COLOR='\033[0;31m'   # Red
INFO_COLOR='\033[0;34m'    # Blue
NC='\033[0m'               # No Color

# Function to display a header
print_header() {
    local title="$1"
    local width=60

    echo ""
    echo -e "${PROMPT_COLOR}╔$(printf '═%.0s' $(seq 1 $width))╗${NC}"
    printf "${PROMPT_COLOR}║${NC} %-${width}s ${PROMPT_COLOR}║${NC}\n" "$title"
    echo -e "${PROMPT_COLOR}╚$(printf '═%.0s' $(seq 1 $width))╝${NC}"
    echo ""
}

# Function to display a section
print_section() {
    local title="$1"
    echo ""
    echo -e "${PROMPT_COLOR}=== $title ===${NC}"
    echo ""
}

# Function to ask a yes/no question
ask_yes_no() {
    local question="$1"
    local default="${2:-n}"
    local response

    if [[ "$default" == "y" ]]; then
        echo -e -n "${PROMPT_COLOR}$question [Y/n]: ${INPUT_COLOR}"
    else
        echo -e -n "${PROMPT_COLOR}$question [y/N]: ${INPUT_COLOR}"
    fi

    read -r response
    echo -e "${NC}"

    response="${response:-$default}"
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

    [[ "$response" =~ ^(y|yes)$ ]]
}

# Function to ask for text input
ask_input() {
    local question="$1"
    local default="$2"
    local response

    if [[ -n "$default" ]]; then
        echo -e -n "${PROMPT_COLOR}$question [${default}]: ${INPUT_COLOR}"
    else
        echo -e -n "${PROMPT_COLOR}$question: ${INPUT_COLOR}"
    fi

    read -r response
    echo -e "${NC}"

    echo "${response:-$default}"
}

# Function to ask for password input (hidden)
ask_password() {
    local question="$1"
    local response

    echo -e -n "${PROMPT_COLOR}$question: ${INPUT_COLOR}"
    read -s -r response
    echo -e "${NC}"
    echo ""

    echo "$response"
}

# Function to ask for choice from options
ask_choice() {
    local question="$1"
    shift
    local options=("$@")
    local choice

    echo -e "${PROMPT_COLOR}$question${NC}"
    echo ""

    for i in "${!options[@]}"; do
        echo -e "  ${INPUT_COLOR}$((i+1))${NC}) ${options[$i]}"
    done

    echo ""
    echo -e -n "${PROMPT_COLOR}Enter choice [1-${#options[@]}]: ${INPUT_COLOR}"
    read -r choice
    echo -e "${NC}"

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
        echo "${options[$((choice-1))]}"
        return 0
    else
        echo -e "${ERROR_COLOR}Invalid choice. Please try again.${NC}" >&2
        return 1
    fi
}

# Function to ask for path input with validation
ask_path() {
    local question="$1"
    local default="$2"
    local must_exist="${3:-false}"
    local path

    while true; do
        path=$(ask_input "$question" "$default")

        # Expand tilde
        path="${path/#\~/$HOME}"

        if [[ "$must_exist" == "true" ]]; then
            if [[ -e "$path" ]]; then
                echo "$path"
                return 0
            else
                echo -e "${ERROR_COLOR}Path does not exist: $path${NC}" >&2
                echo -e "${INFO_COLOR}Please enter a valid path.${NC}" >&2
            fi
        else
            echo "$path"
            return 0
        fi
    done
}

# Function to ask for numeric input
ask_number() {
    local question="$1"
    local default="$2"
    local min="${3:-0}"
    local max="${4:-999999}"
    local number

    while true; do
        number=$(ask_input "$question" "$default")

        if [[ "$number" =~ ^[0-9]+$ ]]; then
            if [ "$number" -ge "$min" ] && [ "$number" -le "$max" ]; then
                echo "$number"
                return 0
            else
                echo -e "${ERROR_COLOR}Number must be between $min and $max${NC}" >&2
            fi
        else
            echo -e "${ERROR_COLOR}Please enter a valid number${NC}" >&2
        fi
    done
}

# Function to display success message
print_success() {
    local message="$1"
    echo -e "${SUCCESS_COLOR}✓ $message${NC}"
}

# Function to display error message
print_error() {
    local message="$1"
    echo -e "${ERROR_COLOR}✗ $message${NC}" >&2
}

# Function to display info message
print_info() {
    local message="$1"
    echo -e "${INFO_COLOR}ℹ $message${NC}"
}

# Function to display warning message
print_warning() {
    local message="$1"
    echo -e "${INPUT_COLOR}⚠ $message${NC}"
}

# Function to show a progress indicator
show_progress() {
    local message="$1"
    local percent="${2:-0}"
    local width=50
    local filled=$((width * percent / 100))
    local empty=$((width - filled))

    printf "\r${PROMPT_COLOR}$message [${SUCCESS_COLOR}"
    printf '%*s' "$filled" '' | tr ' ' '█'
    printf "${NC}"
    printf '%*s' "$empty" '' | tr ' ' '░'
    printf "${PROMPT_COLOR}] ${percent}%%${NC}"

    if [ "$percent" -eq 100 ]; then
        echo ""
    fi
}

# Function to confirm action before proceeding
confirm_action() {
    local action="$1"
    local warning="${2:-This action will make changes to your system.}"

    echo ""
    print_warning "$warning"
    echo ""

    ask_yes_no "Are you sure you want to $action?" "n"
}

# Function to display a menu and get selection
display_menu() {
    local title="$1"
    shift
    local options=("$@")

    print_header "$title"

    for i in "${!options[@]}"; do
        echo -e "  ${INPUT_COLOR}$((i+1))${NC}) ${options[$i]}"
    done

    echo ""
    echo -e "  ${INPUT_COLOR}Q${NC}) Quit"
    echo ""
}

# Function to wait for user to press enter
pause() {
    local message="${1:-Press Enter to continue...}"
    echo ""
    echo -e -n "${INFO_COLOR}$message${NC}"
    read -r
}

# Export functions
export -f print_header
export -f print_section
export -f ask_yes_no
export -f ask_input
export -f ask_password
export -f ask_choice
export -f ask_path
export -f ask_number
export -f print_success
export -f print_error
export -f print_info
export -f print_warning
export -f show_progress
export -f confirm_action
export -f display_menu
export -f pause
