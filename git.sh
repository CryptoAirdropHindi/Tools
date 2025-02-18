#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

task() {
    echo -e "${MAGENTA}[TASK]${NC} $1"
}

run_with_spinner() {
    local msg="$1"
    shift
    local cmd=("$@")
    local pid
    local spin_chars='🕘🕛🕒🕡'
    local delay=0.1
    local i=0

    "${cmd[@]}" > /dev/null 2>&1 &
    pid=$!

    printf "${MAGENTA}[TASK]${NC} %s...  " "$msg"

    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r${MAGENTA}[TASK]${NC} %s... ${CYAN}%s${NC}" "$msg" "${spin_chars:$i:1}"
        sleep "$delay"
    done

    wait "$pid"
    local exit_status=$?

    # Clear the line
    printf "\r\033[K"

    return $exit_status
}

# Check for existing Git installation
check_existing_git() {
    if command -v git &>/dev/null; then
        warn "Git is already installed: $(git --version | awk '{print $3}')"
        read -rp "Do you want to reinstall/update Git? (y/N): " choice
        if [[ "${choice,,}" == "y" ]]; then
            return 0
        else
            info "Skipping Git installation."
            exit 0
        fi
    fi
}

install_git() {
    task "Identifying package manager"
    if command -v apt &>/dev/null; then
        info "Detected APT package manager"
        run_with_spinner "Updating package lists" sudo apt update -y || error "Failed to update packages"
        run_with_spinner "Installing Git" sudo apt install git -y || error "Failed to install Git"
        
    elif command -v dnf &>/dev/null; then
        info "Detected DNF package manager"
        run_with_spinner "Installing Git" sudo dnf install git -y || error "Failed to install Git"
        
    elif command -v yum &>/dev/null; then
        info "Detected YUM package manager"
        run_with_spinner "Installing Git" sudo yum install git -y || error "Failed to install Git"
        
    elif command -v pacman &>/dev/null; then
        info "Detected Pacman package manager"
        run_with_spinner "Installing Git" sudo pacman -S git --noconfirm || error "Failed to install Git"
        
    elif command -v zypper &>/dev/null; then
        info "Detected Zypper package manager"
        run_with_spinner "Installing Git" sudo zypper install git -y || error "Failed to install Git"
        
    else
        error "Unsupported package manager. Install Git manually."
    fi
}

verify_installation() {
    task "Verifying installation"
    if command -v git &>/dev/null; then
        success "Git successfully installed: $(git --version | awk '{print $3}')"
    else
        warn "Git binary not found in PATH. Searching system..."
        
        local possible_paths=(
            "/usr/bin/git"
            "/usr/local/bin/git"
            "/opt/homebrew/bin/git"
            "/snap/bin/git"
        )
        
        for path in "${possible_paths[@]}"; do
            if [[ -x "$path" ]]; then
                warn "Found Git at: $path"
                info "You can add this to your PATH by running:"
                info "echo 'export PATH=\"$(dirname "$path"):\$PATH\"' >> ~/.bashrc && source ~/.bashrc"
                return
            fi
        done
        
        error "Git installation verification failed. Check manually with 'which git'"
    fi
}

main() {
    check_existing_git
    install_git
    verify_installation
}

main
