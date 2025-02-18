#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Output functions
error() { printf "%b\n" "${RED}[ERROR]${NC} $1" >&2; exit 1; }
warn() { printf "%b\n" "${YELLOW}[WARN]${NC} $1"; }
info() { printf "%b\n" "${BLUE}[INFO]${NC} $1"; }
success() { printf "%b\n" "${GREEN}[SUCCESS]${NC} $1"; }
task() { printf "%b\n" "${MAGENTA}[TASK]${NC} $1"; }

run_with_spinner() {
    local msg="$1" cmd=("${@:2}") pid
    local spin_chars='🕘🕛🕒🕡' delay=0.1 i=0

    "${cmd[@]}" >/dev/null 2>&1 & pid=$!
    printf "%b" "${MAGENTA}[TASK]${NC} ${msg}...  "

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r%b" "${MAGENTA}[TASK]${NC} ${msg}... ${CYAN}${spin_chars:$((i%4)):1}${NC}"
        sleep "$delay" && ((i++))
    done

    if wait "$pid"; then
        printf "\r\033[K"
        return 0
    else
        printf "\r\033[K"
        error "Command failed: ${cmd[*]}"
    fi
}

check_dependencies() {
    if ! command -v curl &>/dev/null; then
        task "Installing curl"
        if command -v apt &>/dev/null; then
            run_with_spinner "Updating packages" sudo apt update -y
            run_with_spinner "Installing curl" sudo apt install -y curl
        elif command -v dnf &>/dev/null; then
            run_with_spinner "Installing curl" sudo dnf install -y curl
        elif command -v yum &>/dev/null; then
            run_with_spinner "Installing curl" sudo yum install -y curl
        elif command -v pacman &>/dev/null; then
            run_with_spinner "Installing curl" sudo pacman -S --noconfirm curl
        elif command -v zypper &>/dev/null; then
            run_with_spinner "Installing curl" sudo zypper install -y curl
        else
            error "Could not install curl - unsupported package manager"
        fi
    fi
}

install_nvm() {
    export NVM_DIR="${HOME}/.nvm"
    local install_url="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh"

    [ -d "$NVM_DIR" ] && {
        warn "Found existing NVM installation - creating backup"
        run_with_spinner "Creating backup" mv "$NVM_DIR" "${NVM_DIR}.bak-$(date +%s)"
    }

    task "Installing NVM"
    run_with_spinner "Downloading installer" \
        bash -c "curl -o- $install_url | PROFILE=/dev/null bash"

    [ -s "${NVM_DIR}/nvm.sh" ] && source "${NVM_DIR}/nvm.sh" || error "NVM loading failed"
    [ -s "${NVM_DIR}/bash_completion" ] && source "${NVM_DIR}/bash_completion"
}

configure_shell() {
    local shell_rc="${HOME}/.bashrc"
    [[ "$SHELL" == *zsh* ]] && shell_rc="${HOME}/.zshrc"

    task "Configuring shell environment"
    if ! grep -q "NVM_DIR" "$shell_rc"; then
        run_with_spinner "Updating $shell_rc" \
            printf "\n# NVM configuration\nexport NVM_DIR=\"%s\"\n[ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"\n[ -s \"\$NVM_DIR/bash_completion\" ] && . \"\$NVM_DIR/bash_completion\"\n" "$HOME/.nvm" >> "$shell_rc"
    fi

    source "$shell_rc" >/dev/null 2>&1
}

get_latest_lts() {
    nvm ls-remote --lts | \
    grep 'Latest LTS' | \
    awk '{print $1}' | \
    sed 's/^v//' | \
    head -n1
}

install_node() {
    task "Managing Node.js"
    local latest_lts="$(get_latest_lts)"
    [ -z "$latest_lts" ] && error "Failed to find latest LTS version"

    if ! command -v node &>/dev/null; then
        run_with_spinner "Installing Node.js LTS (v${latest_lts})" nvm install "$latest_lts"
    else
        local current_version="$(node --version | sed 's/v//')"
        
        if [ "$(printf "%s\n%s" "$current_version" "$latest_lts" | sort -V | tail -n1)" != "$current_version" ]; then
            warn "Current Node.js (v${current_version}) is outdated"
            run_with_spinner "Updating to v${latest_lts}" nvm install "$latest_lts" --reinstall-packages-from=current
        else
            warn "Already using latest LTS: v${current_version}"
        fi
    fi

    run_with_spinner "Setting default version" nvm alias default "$latest_lts"
    run_with_spinner "Updating npm" npm install -g npm@latest
}

check_privileges() {
    [ "$(id -u)" -eq 0 ] && {
        warn "Running as root - NVM should be user-level"
        read -rp "Continue anyway? (y/N) " choice
        [[ "${choice,,}" =~ ^(y|yes)$ ]] || exit 0
    }
}

main() {
    check_privileges
    check_dependencies
    install_nvm
    configure_shell
    install_node

    success "Environment setup complete!"
    printf "%b\n" "Node.js: ${GREEN}$(node --version)${NC}"
    printf "%b\n" "npm:     ${GREEN}$(npm --version)${NC}"
    info "All changes applied to current session"
}

main "$@"
