#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to display error and exit
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to display warning
warning() {
    echo -e "${YELLOW}Warning: $1${NC}" >&2
}

# Function to display success
success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to check required environment variables
check_required_vars() {
    local missing_vars=()
    
    # Loop through all provided variables
    for var in "$@"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    # If any variables are missing, show error
    if [ ${#missing_vars[@]} -ne 0 ]; then
        error_exit "Missing required environment variables: ${missing_vars[*]}\nPlease set these in your env.sh file."
    fi
}

# Function to check if environment is initialized
check_environment() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local project_root="$(dirname "$script_dir")"
    
    # Check if env.sh exists
    if [ ! -f "$project_root/env.sh" ]; then
        error_exit "Environment file not found. Please copy env.template.sh to env.sh and configure it."
    fi
    
    # Source the environment file
    source "$project_root/env.sh"
}

# Function to verify command exists
check_command() {
    local cmd="$1"
    local install_msg="${2:-Please install $cmd to proceed.}"
    
    if ! command -v "$cmd" >/dev/null 2>&1; then
        error_exit "$cmd not found. $install_msg"
    fi
}
