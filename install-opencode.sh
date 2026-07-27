#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# install-opencode.sh — Cross-platform installer for OpenCode
# Supports: macOS, Linux, Windows (Git Bash / WSL)
# ============================================================

REPO="anomalyco/opencode"
INSTALL_URL="https://opencode.ai/install"

detect_os() {
  case "$(uname -s)" in
    Darwin*)  echo "macos" ;;
    Linux*)   echo "linux" ;;
    CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
    *)        echo "unknown" ;;
  esac
}

detect_cmd() { command -v "$1" >/dev/null 2>&1; }

install_curl() {
  echo " Installing via curl (universal script)..."
  curl -fsSL "$INSTALL_URL" | bash
  echo ""
  echo " Add to PATH if needed:"
  echo '   export PATH="$HOME/.opencode/bin:$PATH"'
}

install_brew() {
  echo " Installing via Homebrew..."
  brew install anomalyco/tap/opencode
}

install_npm() {
  echo " Installing via npm..."
  npm install -g opencode-ai
}

install_choco() {
  echo " Installing via Chocolatey..."
  choco install opencode
}

install_scoop() {
  echo " Installing via Scoop..."
  scoop install opencode
}

post_msg() {
  echo ""
  echo " OpenCode installed! Verify with:"
  echo "   opencode --version"
  echo ""
  echo " Then run:"
  echo "   opencode"
}

main() {
  echo "=== OpenCode Installer ==="
  echo ""

  OS=$(detect_os)
  echo " Detected OS: $OS"

  case "$OS" in
    macos)
      if detect_cmd brew; then
        install_brew
      elif detect_cmd npm; then
        install_npm
      else
        install_curl
      fi
      ;;

    linux)
      if detect_cmd npm; then
        install_npm
      else
        install_curl
      fi
      ;;

    windows)
      echo " Windows detected — recommended: use WSL and run this script again inside it."
      echo ""
      if detect_cmd npm; then
        install_npm
      elif detect_cmd choco; then
        install_choco
      elif detect_cmd scoop; then
        install_scoop
      else
        echo " No package manager found."
        echo " Options:"
        echo "   1. Open PowerShell as Admin and run:"
        echo '      Set-ExecutionPolicy Bypass -Scope Process -Force;'
        echo '      [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;'
        echo '      iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))'
        echo '      choco install opencode'
        echo "   2. Install Node.js from https://nodejs.org then run:"
        echo '      npm install -g opencode-ai'
        echo "   3. Use WSL (recommended):"
        echo '      wsl --install -d Ubuntu'
        echo '      # then run this script inside WSL'
        exit 1
      fi
      ;;

    *)
      echo " Unknown OS — falling back to curl + npm."
      if detect_cmd npm; then
        install_npm
      else
        install_curl
      fi
      ;;
  esac

  post_msg
}

main