# Automated LaTeX Invoice Generator README

This guide explains how to set up and use the provided Zsh script to automatically generate your monthly invoices in PDF format from the LaTeX template. This process ensures high-quality, professional document output with minimal manual effort.

---

## 🚀 Setup and Requirements

To run this script successfully, you need the following tools installed on your Mac:

1.  **BasicTeX (or TeX Live):** The core typesetting system. If you installed BasicTeX, ensure the necessary packages are installed.
2.  **Required LaTeX Packages:** The template uses packages not included in the default BasicTeX. Install them using the **TeX Live Manager (`tlmgr`)** utility:
    ```bash
    sudo tlmgr install tabularx booktabs xcolor ragged2e
    ```
3.  **Zsh:** Your default shell on modern macOS. The script is written in Zsh to utilize associative arrays for clean data management.

---

## 📁 File Structure

Ensure the following files are located in the same directory:

| Filename | Description |
| :--- | :--- |
| **`invoice.tex`** | The LaTeX template file containing all placeholders (`\newcommand`). |
| **`generate_invoice.zsh`** | The Zsh script that updates data and runs the compiler. |

---

## 🛠️ Step-by-Step Usage

### Step 1: Configure the Script Data

Open the `generate_invoice.zsh` file in a text editor (like VS Code, Sublime Text, or nano) and modify the values in the `NEW_DATA` associative array and the service period variables.

1.  **Review Dynamic Date Variables:** The script automatically calculates the **`FIRST_DAY_FORMATTED`**, **`LAST_DAY_FORMATTED`**, and **`CURRENT_MONTH_YEAR`**. You typically do not need to change these.

2.  **Update `NEW_DATA` Array:** Edit the value on the right side of the equals sign (`=`). The keys (on the left) **must not be changed** as they match the LaTeX command names.

    ```zsh
    declare -A NEW_DATA=(
        # These keys must match the \newcommand in invoice.tex
        ["InvoiceNumber"]="$CURRENT_MONTH_YEAR-01" # Dynamic Invoice Number
        ["IssueDate"]="$LAST_DAY_FORMATTED"
        ["TotalAmount"]='\$4,850.00'             # <<< UPDATE THIS AMOUNT MONTHLY
        ["MyName"]="TrueLogic Consulting S.A."    
        # ... and so on for all static placeholders (BillToName, BankName, etc.)
    )
    ```

3.  **Update Service Period Search:** If you change the default service period placeholder in `invoice.tex`, you must update the `OLD_SERVICE_PERIOD_SEARCH` variable in the script so the `sed` command knows what text to find and replace.

### Step 2: Make the Script Executable

If you haven't already, you must grant the script permission to run:

```bash
chmod +x generate_invoice.zsh
````

### Step 3: Run the Generator

Execute the script from your terminal:

```bash
./generate_invoice.zsh
```

-----

## ✅ Process Flow Explained

The script automates three core tasks every time you run it:

1.  **Data Preparation and Backup:**

      * Calculates the first and last day of the current month using the Mac/BSD `date` command.
      * Creates a backup of the original `invoice.tex` file (`invoice.tex.bak`) for safety.

2.  **In-Place Data Replacement:**

      * Uses a **Zsh loop** to iterate through the `NEW_DATA` associative array.
      * For each entry, a powerful `sed` command is executed to find the line `\newcommand{Key}{Old Value}` and replace it with `\newcommand{Key}{New Value}`.
      * A separate `sed` command updates the service description line inside the document body.

3.  **Compilation and Cleanup:**

      * The `pdflatex` compiler is run **twice** using the `-jobname` option to ensure all table widths and layout elements are rendered correctly. The PDF will be named dynamically (e.g., **`Monthly_Invoice_2025-10.pdf`**).
      * The original template is restored using the backup file (`mv invoice.tex.bak invoice.tex`).
      * All temporary LaTeX files (`.aux`, `.log`, etc.) are deleted.

**Result:** A clean, ready-to-send PDF invoice is generated, and your `invoice.tex` template is reset for the next month.

```