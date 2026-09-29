# ⚡ Universal Silent Software Auto-Installer

An intelligent Windows Batch script that automates the installation of multiple `.exe` and `.msi` setup files silently in the background without needing to click "Next-Next" or deal with manual installer wizards.

---

## 🚀 Overview

Setting up a fresh Windows machine or reinstalling multiple essential software packages usually requires sitting through endless setup prompts. This script solves that problem:
* Automatically requests **Administrator Privileges**.
* Detects setup file types (`.msi` vs `.exe`).
* Uses dynamic pattern inspection via PowerShell to detect the underlying installer engine (Inno Setup, NSIS, InstallShield, WiX) and applies the correct silent switches automatically.
* Installs all software sequentially in the background.

---

## ✨ Features

- **Zero Interaction Needed:** Installs everything unattended with default settings.
- **Auto Admin Elevation:** Prompts for UAC permissions automatically if not already elevated.
- **MSI Support:** Standard `/qn /norestart` parameters applied to all `.msi` packages.
- **Smart EXE Detection:** Identifies installer technologies:
  - **Inno Setup:** `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-`
  - **Nullsoft Scriptable Install System (NSIS):** `/S`
  - **InstallShield:** `/s /v"/qn"`
  - **WiX Burn Engine:** `/quiet /norestart`
- **Ordered Execution:** Uses `start /wait` so installations don't overlap or corrupt shared system resources.

---

## 📁 Recommended Folder Structure

Place `AutoInstaller.bat` in the exact same directory as your downloaded installer files:

```text
MySoftwares/
│
├── AutoInstaller.bat
├── GoogleChromeStandaloneEnterprise64.msi
├── vlc-setup.exe
├── 7z-x64.exe
├── Git-Setup.exe
└── vscode-setup.exe
```

---

## 🛠️ How to Use

### Step 1: Clone or Download
Clone this repository or download `AutoInstaller.bat`:
```bash
git clone https://github.com/salinder0133/silent-software-installer.git
```

### Step 2: Add Installers
Move all your downloaded `.exe` and `.msi` installers into the folder alongside `AutoInstaller.bat`.

### Step 3: Run the Script
1. **Double-click** `AutoInstaller.bat`.
2. Click **Yes** when prompted by Windows UAC (User Account Control) for Administrator access.
3. Sit back and relax while the terminal displays the progress. Once completed, a completion message will appear.

---

## 🔍 How It Works Under the Hood

1. **Folder Relative Execution (`%~dp0`):**  
   The script resolves the absolute directory path where the batch file is located.
2. **Wildcard Iteration (`*.msi` and `*.exe`):**  
   It enumerates every file ending with `.msi` and `.exe` irrespective of its file name.
3. **PowerShell Signature Scanning:**  
   Before running an `.exe`, the script inspects the binary header bytes (first 1 MB) to detect embedded framework strings like `Inno Setup`, `Nullsoft`, `InstallShield`, or `WixBundle`.

---

## ⚙️ Advanced Customization

### Recursive Subfolder Search
By default, the script processes files located directly in the root folder. If your installers are placed inside subfolders, modify the loops in `AutoInstaller.bat` from:
```cmd
for %%F in ("%~dp0*.exe") do ( ... )
```
to recursive search:
```cmd
for /r "%~dp0" %%F in (*.exe) do ( ... )
```

---

## ⚠️️ Notes & Disclaimer

- Some proprietary `.exe` installers may require custom command-line switches not covered by standard engines. In such cases, run `setup.exe /?` in CMD to check vendor-specific parameters.
- Always ensure you download setups from official, trusted sources.

---

## 👤 Author

Developed by **[salinder0133](https://github.com/salinder0133)**

⭐ If this repository helped you automate your workflow, please consider giving it a star!
