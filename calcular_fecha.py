import pandas as pd
from datetime import date
from dateutil.relativedelta import relativedelta
import sys

def calcular_fecha(fecha_referencia=None):
    """
    Calcula el tercer día hábil previo al último día del mes y devuelve
    una expresión cron para ejecutarse a las 8:00 AM de ese día.
    Formato: "minuto hora día_del_mes mes *"
    """
    if fecha_referencia is None:
        # Usa el primer día del mes actual. La fecha de inicio no afecta 
        # el cálculo del último día del mes si estamos en ese mismo mes.
        fecha_referencia = date.today().replace(day=1) 
    
    # 1. Encontrar el último día del mes
    primer_dia_siguiente_mes = fecha_referencia.replace(day=1) + relativedelta(months=1)
    ultimo_dia_del_mes = primer_dia_siguiente_mes - relativedelta(days=1)
    
    # Convertir a Timestamp para usar la lógica de BusinessDay de Pandas
    ts_ultimo_dia = pd.Timestamp(ultimo_dia_del_mes)
    
    # 2. Calcular el tercer día hábil previo (n=3)
    tercer_dia_habil_previo = ts_ultimo_dia - pd.tseries.offsets.BusinessDay(n=3)
    
    # 3. Extraer día y mes
    dia_cron = tercer_dia_habil_previo.day
    mes_cron = tercer_dia_habil_previo.month
    
    # 4. Formatear la cadena para el cronjob (minuto, hora, día, mes, día_semana)
    return f"0 8 {dia_cron} {mes_cron} *"

if __name__ == "__main__":
    try:
        # Imprime la expresión del cronjob a la salida estándar
        print(calcular_fecha())
        sys.exit(0)
    except Exception as e:
        # En caso de error (e.g., pandas no instalado), imprime el error a stderr
        sys.stderr.write(f"Error al calcular la fecha: {e}\n")
        sys.exit(1)