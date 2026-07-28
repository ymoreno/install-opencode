# ============================================================
# install-opencode.ps1 — Windows PowerShell installer for OpenCode
# ============================================================

param(
  [switch]$wsl
)

$ErrorActionPreference = "Stop"

function Write-Step($msg) { Write-Host ">>> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "  $msg" -ForegroundColor Green }

function Install-Npm {
  Write-Step "Installing via npm..."
  npm install -g opencode-ai
}

function Install-Choco {
  Write-Step "Installing via Chocolatey..."
  choco install opencode -y
}

function Install-Scoop {
  Write-Step "Installing via Scoop..."
  scoop install opencode
}

function Install-Wsl {
  Write-Step "Installing OpenCode via WSL..."
  wsl -d Ubuntu bash -c "curl -fsSL https://opencode.ai/install | bash"
}

Write-Host ""
Write-Host "=== OpenCode Installer (Windows) ===" -ForegroundColor Green
Write-Host ""

# Option 1: WSL mode (best experience)
if ($wsl) {
  Install-Wsl
  Write-Ok "Done! Run 'wsl -d Ubuntu opencode' to start."
  exit 0
}

# Option 2: Detect available package managers
$hasNpm = $null -ne (Get-Command npm -ErrorAction SilentlyContinue)
$hasChoco = $null -ne (Get-Command choco -ErrorAction SilentlyContinue)
$hasScoop = $null -ne (Get-Command scoop -ErrorAction SilentlyContinue)

if ($hasNpm) {
  Install-Npm
}
elseif ($hasChoco) {
  Install-Choco
}
elseif ($hasScoop) {
  Install-Scoop
}
else {
  Write-Host "No package manager found. Choose an option:" -ForegroundColor Yellow
  Write-Host ""
  Write-Host "  [1] Install via WSL (recommended - best experience)"
  Write-Host "  [2] Install Node.js then npm install -g opencode-ai"
  Write-Host "  [3] Install Chocolatey then choco install opencode"
  Write-Host "  [4] Install Scoop then scoop install opencode"
  Write-Host ""
  $choice = Read-Host "Enter 1-4"

  switch ($choice) {
    "1" {
      Write-Step "Installing WSL Ubuntu..."
      wsl --install -d Ubuntu
      Write-Step "Installing OpenCode inside WSL..."
      wsl -d Ubuntu bash -c "curl -fsSL https://opencode.ai/install | bash"
      Write-Ok "Done! Run 'wsl -d Ubuntu opencode' to start."
    }
    "2" {
      Write-Host "Downloading Node.js installer..."
      $url = "https://nodejs.org/dist/v22.0.0/node-v22.0.0-x64.msi"
      $out = "$env:TEMP\node-installer.msi"
      [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
      Invoke-WebRequest -Uri $url -OutFile $out
      Write-Step "Installing Node.js..."
      Start-Process msiexec.exe -Wait -ArgumentList "/i $out /qn"
      Install-Npm
    }
    "3" {
      Write-Step "Installing Chocolatey..."
      Set-ExecutionPolicy Bypass -Scope Process -Force
      [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
      iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
      Install-Choco
    }
    "4" {
      Write-Step "Installing Scoop..."
      Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
      iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
      Install-Scoop
    }
  }
}

Write-Host ""
Write-Ok "OpenCode installed! Verify with:   opencode --version"
Write-Ok "Then run:                           opencode"
Write-Host ""
Write-Host "TIP: For the best experience on Windows, use WSL:" -ForegroundColor Cyan
Write-Host "  .\install-opencode.ps1 -wsl" -ForegroundColor Gray