#!/usr/bin/env zsh

#
# setup.sh: Interactive setup script for the Automated LaTeX Invoice Generator
#
# This script will:
# 1. Check for essential system dependencies (pdflatex, tlmgr, python3).
# 2. Install required LaTeX packages via tlmgr.
# 3. Create a Python virtual environment and install required libraries.
# 4. Prompt for and configure user-specific paths in the scripts.
# 5. Set executable permissions on all necessary scripts.
#

set -e # Exit immediately if a command exits with a non-zero status.

echo "🚀 Starting setup for the Automated LaTeX Invoice Generator..."

# --- 1. Dependency Checks ---
echo "\n[1/5] Checking system dependencies..."

if ! command -v pdflatex &> /dev/null; then
    echo "❌ ERROR: 'pdflatex' not found."
    echo "Please install a LaTeX distribution like MacTeX (https://www.tug.org/mactex/) and run this script again."
    exit 1
fi

if ! command -v tlmgr &> /dev/null; then
    echo "❌ ERROR: 'tlmgr' (TeX Live Manager) not found."
    echo "Please ensure your LaTeX distribution includes tlmgr and it's in your PATH."
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "❌ ERROR: 'python3' not found."
    echo "Please install Python 3 (https://www.python.org/downloads/) and run this script again."
    exit 1
fi

echo "✅ All system dependencies are present."

# --- 2. Install LaTeX Packages ---
echo "\n[2/5] Installing required LaTeX packages..."
echo "This may require your administrator password for 'sudo'."

sudo tlmgr update --self
sudo tlmgr install geometry booktabs xcolor ragged2e
# sudo tlmgr install tabularx

echo "✅ LaTeX packages installed successfully."

# --- 3. Setup Python Environment ---
VENV_PATH="./.venv"
echo "\n[3/5] Setting up Python virtual environment..."

if [ ! -d "$VENV_PATH" ]; then
    echo "Creating virtual environment in '$VENV_PATH'..."
    python3 -m venv "$VENV_PATH"
else
    echo "Virtual environment already exists."
fi

echo "Installing Python libraries (pandas, python-dateutil)..."
"$VENV_PATH"/bin/pip install -q pandas python-dateutil

echo "✅ Python environment is ready."

# --- 4. Configure Scripts ---
echo "\n[4/5] Configuring user-specific paths..."

# Configure generate_invoice.sh
echo "\nPlease specify the full path where your final PDF invoices should be saved."
echo "Example: /Users/yourname/Documents/Invoices"
vared -p "Enter invoice directory path: " -c INVOICE_DIR

# Use a different delimiter for sed to handle paths with slashes
sed -i '' "s|INVOICE_DIR=.*|INVOICE_DIR=${INVOICE_DIR}|" "generate_invoice.sh"
echo "✅ 'generate_invoice.sh' updated with output directory: $INVOICE_DIR"

# Configure programar_invoice.zsh
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
INVOICE_SCRIPT_PATH="$SCRIPT_DIR/generate_invoice.sh"

sed -i '' "s|INVOICE_SCRIPT=.*|INVOICE_SCRIPT=\"${INVOICE_SCRIPT_PATH}\"|" "programar_invoice.zsh"
echo "✅ 'programar_invoice.zsh' updated with script path: $INVOICE_SCRIPT_PATH"

# --- 5. Set Permissions ---
echo "\n[5/5] Setting executable permissions..."

chmod +x generate_invoice.sh
chmod +x programar_invoice.zsh
chmod +x calcular_fecha.py

echo "✅ Permissions set for all scripts."

# --- Final Message ---
cat << EOF

🎉 Setup Complete!

---------------------------------------------------------------------
Next Steps:

1.  **Fill in your details:**
    Manually edit 'invoice_template.tex' to add your personal, client, and bank information.

2.  **Generate a test invoice:**
    Run './generate_invoice.sh'

3.  **Schedule automatic generation (optional):**
    Run './programar_invoice.zsh' to set up the monthly cron job.
---------------------------------------------------------------------

EOF