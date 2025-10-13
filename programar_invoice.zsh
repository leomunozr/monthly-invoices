#!/usr/bin/env zsh

# ----------------------------------------------
# Archivo: programar_invoice.zsh
# Propósito: Crea/actualiza dos cronjobs:
# 1. Una tarea para generar la factura mensual.
# 2. Una tarea para re-ejecutar este mismo script y reprogramar las tareas para el siguiente mes.
# ----------------------------------------------

# --- 1. Definir rutas y configuración ---
PYTHON_SCRIPT="./calcular_fecha.py"
# Job 1: Generar la factura
INVOICE_SCRIPT="/Users/leonardo/scripts/invoice_template/generate_invoice.sh"
CRON_NAME_INVOICE="[TRUELOGIC] - GENERAR INVOICE"
# Job 2: Reprogramarse a sí mismo
CRON_NAME_SELF="[SELF] - REPROGRAMAR INVOICE"

# --- 2. Obtener la programación del script de Python ---
# Captura la salida del script de Python (e.g., "0 8 25 10 *")
# Ejecución directa del intérprete del VENV:
VENV_PATH="./.venv"
CRON_SCHEDULE=$("$VENV_PATH"/bin/python "$PYTHON_SCRIPT")
PYTHON_EXIT_CODE=$?

# Verificar si el script de Python falló
if [[ $PYTHON_EXIT_CODE -ne 0 ]]; then
    echo "❌ Error: El script de Python falló (código de salida: $PYTHON_EXIT_CODE)."
    exit 1
fi

# Verificar que la salida tenga el formato de cron esperado (5 campos)
if ! echo "$CRON_SCHEDULE" | grep -Eq '^(\S+\s+){4}\S+$'; then
    echo "❌ Error: El script de Python devolvió un formato inválido: '$CRON_SCHEDULE'."
    exit 1
fi

echo "✅ Programación calculada para el cron: '$CRON_SCHEDULE'"

# --- 3. Definir los comandos y nombres de los jobs ---
# Job 1: Generar la factura
CRON_COMMAND_INVOICE="/bin/zsh $INVOICE_SCRIPT"
CRON_LINE_INVOICE="$CRON_SCHEDULE $CRON_COMMAND_INVOICE # $CRON_NAME_INVOICE"

# Job 2: Reprogramarse a sí mismo
# Obtener la ruta absoluta de este script para usarla en el cronjob
SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)/$(basename "$0")
CRON_COMMAND_SELF="/bin/zsh $SCRIPT_PATH"
CRON_LINE_SELF="$CRON_SCHEDULE $CRON_COMMAND_SELF # $CRON_NAME_SELF"

echo "✅ Línea de cronjob 1: $CRON_LINE_INVOICE"
echo "✅ Línea de cronjob 2: $CRON_LINE_SELF"

# --- 4. Crear o actualizar los cronjobs ---

# a. Crear copia de seguridad del crontab actual
CRON_FILE="crontab_backup_zsh"
crontab -l 2>/dev/null > "$CRON_FILE"

# b. Gestionar el cronjob de GENERAR INVOICE
if grep -qF "# $CRON_NAME_INVOICE" "$CRON_FILE"; then
    echo "⚠️ Tarea '$CRON_NAME_INVOICE' ya existe. Actualizando..."
    sed -i '' "s~.*# $CRON_NAME_INVOICE~$CRON_LINE_INVOICE~" "$CRON_FILE"
else
    echo "➕ Añadiendo nueva tarea '$CRON_NAME_INVOICE'."
    echo "$CRON_LINE_INVOICE" >> "$CRON_FILE"
fi

# c. Gestionar el cronjob de REPROGRAMAR
if grep -qF "# $CRON_NAME_SELF" "$CRON_FILE"; then
    echo "⚠️ Tarea '$CRON_NAME_SELF' ya existe. Actualizando..."
    sed -i '' "s~.*# $CRON_NAME_SELF~$CRON_LINE_SELF~" "$CRON_FILE"
else
    echo "➕ Añadiendo nueva tarea '$CRON_NAME_SELF'."
    echo "$CRON_LINE_SELF" >> "$CRON_FILE"
fi

# d. Instalar el nuevo crontab
crontab "$CRON_FILE"

# e. Limpieza
rm "$CRON_FILE"

echo "🎉 ¡Cronjobs actualizados con éxito!"
crontab -l | grep "$CRON_NAME_INVOICE"
crontab -l | grep "$CRON_NAME_SELF"