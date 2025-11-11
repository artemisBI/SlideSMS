# SlideSMS Setup Requirements

Complete guide to installing all dependencies required to run the SlideSMS application.

## Overview of Dependencies

| Dependency                    | Purpose                                                                | Required?     |
| ----------------------------- | ---------------------------------------------------------------------- | ------------- |
| **Docker Desktop**            | Run PostgreSQL database in containers                                  | ✅ Yes        |
| **Python 3.12+**              | Backend runtime (FastAPI, FastAPI dependencies)                        | ✅ Yes        |
| **Node.js & npm**             | Frontend runtime (React, Vite)                                         | ✅ Yes        |
| **Visual Studio Build Tools** | Compile C/C++ extensions for Python packages                           | ✅ Yes        |
| **Rust & Cargo**              | Compile some Python dependencies (optional, can skip with adjustments) | ⚠️ Optional\* |
| **Git**                       | Version control                                                        | ✅ Yes        |

\*Note: Rust is only needed if using certain dependency versions. Current setup uses alternatives that don't require Rust.

---

## Installation Steps (In Order)

### 1. Install Git

**Purpose:** Version control system

1. Go to [git-scm.com](https://git-scm.com/download/win)
2. Download and run the Windows installer
3. Accept all defaults or customize as needed
4. **Restart your terminal** after installation
5. Verify: `git --version`

---

### 2. Install Docker Desktop

**Purpose:** Run PostgreSQL database locally

1. Go to [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Download Docker Desktop for Windows
3. Run the installer
4. Follow the setup wizard (enable WSL 2 if prompted)
5. **Restart your computer** after installation
6. Verify: `docker --version` and `docker-compose --version`

---

### 3. Install Visual Studio Build Tools

**Purpose:** Compile C/C++ extensions for Python packages

1. Go to [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/)
2. Download "Build Tools for Visual Studio 2022"
3. Run the installer
4. Select **"Desktop development with C++"** workload
5. Ensure these are checked:
   - ✅ MSVC v143 (or latest compiler)
   - ✅ Windows 11 SDK (or your Windows version)
   - ✅ CMake tools
6. Complete installation
7. **Restart your computer**
8. Verify: `cl.exe /?` and `link.exe /?`

---

### 4. Install Python 3.12

**Purpose:** Backend runtime

1. Go to [python.org/downloads](https://www.python.org/downloads/)
2. Download **Python 3.12** (NOT 3.15 - compatibility issues)
3. Run the installer
4. ⚠️ **IMPORTANT:** Check **"Add Python to PATH"** during installation
5. Choose "Install for current user" or "Install for all users"
6. Complete installation
7. **Restart your terminal**
8. Verify: `py --version` or `python --version`

---

### 5. Install Node.js

**Purpose:** Frontend runtime

1. Go to [nodejs.org](https://nodejs.org/)
2. Download the **LTS (Long Term Support)** version
3. Run the installer
4. Accept all defaults
5. ✅ **Ensure npm is included** (should be by default)
6. **Restart your terminal**
7. Verify: `node --version` and `npm --version`

---

### 6. Install Rust (Optional)

**Purpose:** Compile certain Python packages (not required with current setup)

**Skip this unless you're using different dependency versions.**

If needed:

1. Go to [rustup.rs](https://rustup.rs/)
2. Download and run the installer
3. During installation, choose **MSVC toolchain** (default option)
4. **Restart your terminal and computer**
5. Verify: `rustc --version` and `cargo --version`

---

### 7. Configure PowerShell (Windows)

**Purpose:** Allow PowerShell scripts to run

1. Open **PowerShell as Administrator**
2. Run this command:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Confirm by typing `Y` and pressing Enter

---

### 8. Clone and Setup SlideSMS Repository

**Purpose:** Get the project code and install project dependencies

```bash
# Clone the repository
git clone https://github.com/artemisBI/SlideSMS.git
cd SlideSMS

# Copy environment configuration
cp .env.example .env

# Edit .env with your configuration
# Required values to update:
#   - DATABASE_URL: postgresql+pg8000://postgres:postgres@localhost:5432/savethis
#   - TWILIO_ACCOUNT_SID: Your Twilio test credentials
#   - TWILIO_AUTH_TOKEN: Your Twilio test token
#   - TWILIO_PHONE_NUMBER: Your Twilio test phone number
# Use VS Code or your preferred editor to update .env
```

---

## Running the Application

**That's it!** You now have all dependencies installed. To start the entire application:

```bash
# From the repository root
bash scripts/run_all.sh
```

This single command will:

1. ✅ Create Python virtual environment (if needed)
2. ✅ Install Python dependencies
3. ✅ Start PostgreSQL in Docker
4. ✅ Start FastAPI backend (port 8000) in background
5. ✅ Install frontend dependencies
6. ✅ Start Vite frontend (port 5173) in foreground
7. ✅ Automatically open your browser to `http://localhost:5173`

**That's all you need to do!**

---

## Troubleshooting

### Python not found

- Ensure Python 3.12 was installed with "Add Python to PATH" checked
- Restart your terminal after installation

### PowerShell script execution disabled

- Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### Docker not starting

- Ensure Docker Desktop is running
- May need to enable WSL 2 (Docker will prompt you)
- Restart your computer after Docker installation

### Build tool errors (C1083, link.exe errors)

- Reinstall Visual Studio Build Tools
- Select "Desktop development with C++" workload
- Ensure Windows SDK is checked

### Node modules conflict

- Delete `node_modules` folder and `package-lock.json`
- Run: `npm install`

---

## System Requirements

- **OS:** Windows 10/11 (64-bit)
- **RAM:** 8GB minimum (16GB recommended)
- **Disk Space:** ~10GB (includes Docker images, virtual environments, node_modules)
- **Internet:** Required for downloading dependencies

---

## Summary Table

| Step | Dependency      | Download                                                         | Time      | Required |
| ---- | --------------- | ---------------------------------------------------------------- | --------- | -------- |
| 1    | Git             | [git-scm.com](https://git-scm.com)                               | 5 min     | ✅       |
| 2    | Docker Desktop  | [docker.com](https://docker.com)                                 | 10 min    | ✅       |
| 3    | VS Build Tools  | [visualstudio.microsoft.com](https://visualstudio.microsoft.com) | 15-20 min | ✅       |
| 4    | Python 3.12     | [python.org](https://python.org)                                 | 5 min     | ✅       |
| 5    | Node.js LTS     | [nodejs.org](https://nodejs.org)                                 | 5 min     | ✅       |
| 6    | Rust (optional) | [rustup.rs](https://rustup.rs)                                   | 5 min     | ⚠️       |

**Total setup time: ~45-60 minutes**
