# Automated LaTeX Invoice Generator

This project provides a set of scripts to automate the generation of monthly invoices using a LaTeX template. It calculates the correct date to run, fills in the invoice details, compiles a PDF, and schedules itself for the next month using cron.It's designed to streamline the monthly invoicing process by dynamically populating data, compiling the document, and organizing the output files.

---

## 🚀 Features

- **Dynamic Data Population:** Automatically calculates dates (issue date, service period) and increments the invoice number for each run.
- **High-Quality Output:** Leverages LaTeX to produce professional-looking, print-ready PDF documents.
- **Template-Based:** Modifies a copy of your LaTeX template, ensuring the original remains untouched for future use.
- **Automated Cleanup:** Cleans up all temporary files (`.aux`, `.log`) after compilation.
- **Organized Output:** Moves the final PDF to a pre-configured directory.

---

## 📋 Requirements

Before you begin, ensure you have the following installed on your system (instructions are tailored for macOS):

1.  **Zsh (Z Shell):** The script is written in Zsh. It comes pre-installed as the default shell on modern macOS.
2.  **Perl:** Used for automatically incrementing the invoice number. Perl is typically pre-installed on macOS.
3.  **A LaTeX Distribution:** You need `pdflatex` to compile the `.tex` file. MacTeX is a comprehensive option for macOS. A smaller distribution like BasicTeX will also work, but you will need to install the required packages manually.
4.  **Required LaTeX Packages:** The template requires several packages. If you use a minimal TeX distribution, install them using the TeX Live Manager (`tlmgr`):
    ```bash
    sudo tlmgr update --self
    sudo tlmgr install geometry tabularx booktabs xcolor ragged2e
    ```
5.  **Python 3:** Required for the date calculation script.
6.  **Python Libraries:** The script needs `pandas` and `python-dateutil`. It's highly recommended to use a virtual environment.

```sh
# Create and activate a virtual environment

python3 -m venv .venv
source .venv/bin/activate

# Install required packages

pip install pandas python-dateutil

# You can deactivate later with `deactivate`
```

---

## 📁 File Structure

Ensure the following files are located in the same directory:

| Filename                                           | Description                                                                             |
| :------------------------------------------------- | :-------------------------------------------------------------------------------------- |
| **[generate_invoice.sh](generate_invoice.sh)**     | The main Zsh script that populates data and compiles the PDF.                           |
| **[invoice_template.tex](invoice_template.tex)**   | The LaTeX template file containing placeholders (`\newcommand`).                        |
| **[programar_invoice.zsh](programar_invoice.zsh)** | (Optional) A helper script to schedule monthly invoice generation via cron.             |
| **[calcular_fecha.py](calcular_fecha.py)**         | (Optional) A Python script used by [programar_invoice.zsh](programar_invoice.zsh) to calculate cron schedules. |

---

## 🛠️ Setup and Usage

Follow these steps to generate your first invoice.

### Step 1: Configure the LaTeX Template

Open [invoice_template.tex](invoice_template.tex) in a text editor (like VS Code, Sublime Text, or nano) and fill in your static information and fill in your static information. These are details that don't change every month..

- **Personal Data:** Update `\MyName`, `\MyAddress`, `\MyEmail`, etc.
- **Client Data:** Update `\BillToName`, `\BillToAddress`, etc.
- **Bank Data:** Update `\BankName`, `\SwiftCode`, `\IBAN`, etc.
- **Rate:** Set your monthly rate in `\RateAmount`.

Update the values inside the curly braces `{}` for commands like:

```latex
% --- Personal data ---
\newcommand{\MyName}{Your Name or Company}
\newcommand{\MyAddress}{Your Street Address}
% ... and so on for BillTo, Bank, and Rate info.
```

**Note:** The script will dynamically overwrite `\InvoiceNumber`, `\IssueDate`, `\PeriodStart`, `\PeriodEnd`, and `\Year`. You do not need to edit these in the `.tex` file.

### Step 2: Configure the Generator Script

Open [generate_invoice.sh](generate_invoice.sh) in a text editor and configure the following variables at the top of the file:

1.  **`TEX_FILE`**: This should match the name of your LaTeX template file. The default is `invoice_template.tex`.
2.  **`INVOICE_DIR`**: Change `~/Documents/truelogic/invoice` to the absolute path where you want your final PDF invoices to be saved.
3.  **`PDF_FILE`:** The name of the output PDF file
4.  **`INVOICE_NUMBER`:** The number of the invoice

```zsh
# --- CONFIGURATION ---
TEX_FILE="invoice_template.tex"
INVOICE_DIR=~/Documents/truelogic/invoice # <<< UPDATE THIS PATH
```

### Step 3: Make the Script Executable

In your terminal, grant the script execution permissions. You only need to do this once.

```bash
chmod +x generate_invoice.sh
chmod +x programar_invoice.zsh
```

---

## ⚙️ Usage

### Manual Generation

To test the setup or generate an invoice manually at any time, run the generation script. This will create a PDF in the directory you configured.

```bash
./generate_invoice.sh
```

The script will perform all the steps and, if successful, you will find your new PDF invoice in the directory you specified in `INVOICE_DIR`.

The [generate_invoice.sh](generate_invoice.sh) script automates the following process:

1.  **Data Preparation:**

    - It reads the `INVOICE_NUMBER` value from a comment within the script itself, increments it by one, and prepares it for injection.
    - It uses the macOS `date` command to calculate the current issue date, and the start and end dates of the current month.

2.  **In-Place Data Replacement:**

    - It iterates through the dynamic data (Invoice Number, Dates).
    - For each piece of data, it uses `sed` to find the corresponding `\newcommand` in [invoice_template.tex](invoice_template.tex) and replace its value. This modification happens directly on the file.

3.  **PDF Compilation:**

    - It runs `pdflatex` twice on the modified template. Running it twice is standard practice to ensure all references and layout elements (like table column widths) are correctly calculated and rendered.
    - The output PDF is named dynamically using the current date (e.g., `20231026.pdf`).

4.  **File Management & Cleanup:**
    - If compilation is successful, the generated PDF is moved to your configured `INVOICE_DIR`.
    - The script then **updates itself** by writing the new, incremented invoice number back into its own `INVOICE_NUMBER=` line.
    - Finally, it removes all temporary files (`.aux`, `.log`) created by LaTeX.

After the script finishes, your [invoice_template.tex](invoice_template.tex) is left with the newly generated data, ready for the next run where it will be updated again.

### 🤖 (Optional) Automated Scheduling with Cron

The [programar_invoice.zsh](programar_invoice.zsh) script is provided to automatically schedule the invoice generation using `cron`.
To set up the automated cron job, run the scheduling script.

### Setup

**Configure the Scheduler Script:** Open [programar_invoice.zsh](programar_invoice.zsh) and set the `INVOICE_SCRIPT` variable to the full path of your [generate_invoice.sh](generate_invoice.sh) script.

```zsh
  # In programar_invoice.zsh
  INVOICE_SCRIPT="/path/to/your/generate_invoice.sh"
```

### Usage

Run the scheduler script. It will calculate the correct date for the end of the month and create two `cron` jobs:

1.  One to run [generate_invoice.sh](generate_invoice.sh).
2.  A second one to re-run [programar_invoice.zsh](programar_invoice.zsh) itself, ensuring the job is rescheduled for the _next_ month.

```bash
chmod +x programar_invoice.zsh
./programar_invoice.zsh
```

You can verify the jobs were added by running `crontab -l`.
