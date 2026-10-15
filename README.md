# ⚡ Universal Silent Software Auto-Installer

An intelligent Windows Batch utility with a modern ANSI CLI dashboard that automates the silent installation of multiple `.exe` and `.msi` packages in the background—eliminating the need to click through endless "Next → Next → Install" wizards.

---

## 🚀 Overview

Setting up a fresh Windows machine or deploying multiple essential software packages usually requires sitting through tedious manual setup prompts. This script solves that problem:
- Automatically requests **Administrator Privileges (UAC)**.
- Pre-scans the working directory and displays a live progress counter (`[1/N]`).
- Uses memory-safe binary header inspection via PowerShell (`FileStream`) to detect the underlying installer engine and applies the exact silent switches automatically.
- Displays a color-coded **CLI Dashboard** with real-time status badges and a final **Deployment Summary Report**.

---

## ✨ Key Features

- **Zero Interaction Needed:** Installs everything unattended in the background with default settings.
- **Modern Color-Coded CLI UI:** Uses native Windows ANSI escape sequences for clean visual hierarchy, live package counters, and status badges (`[ SUCCESS ]`, `[ FAILED ]`, `[ WARN ]`).
- **Auto Admin Elevation:** Prompts for UAC permissions automatically if not already running as Administrator.
- **Memory-Safe Smart EXE Detection:** Streams only the first `1 MB` of `.exe` files using `.NET FileStream`—preventing RAM spikes even on multi-gigabyte installers.
- **Smart Exit Code Handling:** Accurately distinguishes between standard completions (`Exit Code 0`), installations requiring a system reboot (`Exit Code 3010`), and failed setups.
- **Sequential Execution:** Uses `start /wait` so installations never overlap or lock Windows Installer (`msiexec`) resources.

---

## 🧩 Supported Installer Engines

| Installer Engine / Framework | Common Software Examples | Applied Silent Switches |
| :--- | :--- | :--- |
| **Windows Installer (`.msi`)** | 7-Zip MSI, Node.js, Enterprise packages | `/qn /norestart` |
| **Inno Setup** | VS Code, Git, VeraCrypt, ShareX | `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-` |
| **Nullsoft (NSIS)** | VLC, Notepad++, OBS Studio, 7-Zip EXE | `/S` |
| **InstallShield** | Audio/Video Drivers, Enterprise tools | `/s /v"/qn"` |
| **WiX Burn Engine** | .NET Runtimes, Visual C++ Redistributables | `/quiet /norestart` |
| **Squirrel / Electron** | Discord, Slack, Postman, WhatsApp | `--silent` |
| **Google Update / Omaha** | Google Chrome, Brave Browser | `/silent /install` |
| **Generic Fallback** | Unidentified `.exe` installers | `/S` |

---

## 🖥️ Terminal UI Preview

```text
 +====================================================================+
 |               UNIVERSAL SILENT SOFTWARE INSTALLER                  |
 +====================================================================+
   Directory : C:\MySoftwares\
   Detected  : 1 MSI  |  3 EXE  |  4 Total Packages
 +--------------------------------------------------------------------+

 [ PHASE 1 : DEPLOYING MSI PACKAGES ]
 --------------------------------------------------------------------
 [1/4] Package : 7z2408-x64.msi
       Engine  : Windows Installer [MSI]  |  Switch: /qn /norestart
       Status  : Installing silently, please wait...
       Result  : [ SUCCESS ] Installed successfully
 --------------------------------------------------------------------

 [ PHASE 2 : DEPLOYING EXE PACKAGES ]
 --------------------------------------------------------------------
 [2/4] Package : Git-2.47.0-64-bit.exe
       Engine  : Inno Setup        |  Switch: /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
       Status  : Installing silently, please wait...
       Result  : [ SUCCESS ] Installed successfully
 --------------------------------------------------------------------

 +====================================================================+
 |                        DEPLOYMENT SUMMARY                          |
 +====================================================================+
   Total Processed : 4
   Succeeded       : 4
   Failed / Manual : 0
 +====================================================================+
```

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
└── VSCodeUserSetup-x64.exe
```

---

## 🛠️ How to Use

### Step 1: Clone or Download
Clone this repository or download `AutoInstaller.bat` directly:
```bash
git clone https://github.com/salinder0133/silent-software-installer.git
```

### Step 2: Add Installers
Move all your downloaded `.exe` and `.msi` installers into the folder alongside `AutoInstaller.bat`.

### Step 3: Run the Script
1. **Double-click** `AutoInstaller.bat`.
2. Click **Yes** when prompted by Windows UAC (User Account Control) for Administrator access.
3. Sit back and relax while the terminal displays real-time installation progress and the final summary report.

---

## 🔍 How It Works Under the Hood

1. **Folder Relative Execution (`%~dp0`):**  
   Resolves the exact directory path where the batch script resides, ensuring safe execution even after UAC elevation shifts the default working directory to `C:\Windows\System32`.
2. **Pre-Scan & Wildcard Iteration (`*.msi` and `*.exe`):**  
   Counts all valid packages upfront to power the `[current/total]` progress indicator and processes `.msi` packages first, followed by `.exe` packages.
3. **Fast 1 MB Binary Header Stream (`FileStream`):**  
   Instead of loading entire executables into memory, the embedded PowerShell snippet opens a read-only `FileStream` and inspects only the first `1,048,576 bytes` (1 MB) for framework signatures (`Inno Setup`, `Nullsoft`, `InstallShield`, `WixBundle`, `Squirrel.Windows`, `Google Update`).

---

## ⚙️ Advanced Customization

### Recursive Subfolder Search
By default, the script processes files located directly in the root folder. If your installers are organized inside subfolders, replace the `for` loops in `AutoInstaller.bat`:
```cmd
for %%F in ("%~dp0*.exe") do ( ... )
```
with recursive iteration:
```cmd
for /r "%~dp0" %%F in (*.exe) do ( ... )
```

---

## ⚠️ Notes & Disclaimer

- Some proprietary or custom-packaged `.exe` installers may require vendor-specific command-line switches. In such cases, run `setup.exe /?` in CMD to check supported parameters.
- Do not place standalone portable `.exe` apps (programs that run directly without installation) in the deployment folder, as the script will launch them and wait for them to close.
- Always ensure you download software installers from official, trusted sources.

---

## 👤 Author

Developed by **[salinder0133](https://github.com/salinder0133)**

⭐ If this repository helped you automate your workflow, please consider giving it a star!
