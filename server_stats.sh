#!/bin/bash

# Función para limpiar la pantalla
clear_screen() {
    if [ "$OS" = "Windows" ]; then
        cmd /c cls
    else
        clear
    fi
}

# Detectar sistema operativo
if [ -f "/etc/os-release" ] || [ -f "/etc/lsb-release" ] || [ -f "/etc/redhat-release" ]; then
    OS="Linux"
elif [ -n "$COMSPEC" ] || [ -n "$COMSPEC" ]; then
    OS="Windows"
else
    OS="Unknown"
fi

# Encabezado
clear_screen
echo "=============================================="
echo "  ESTADÍSTICAS DE RENDIMIENTO DEL SERVIDOR"
echo "  Sistema Operativo: $OS"
echo "  Fecha: $(date)"
echo "=============================================="
echo ""

# 1. Uso total de CPU
echo "=== USO DE CPU ==="
if [ "$OS" = "Linux" ]; then
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
    echo "Uso total de CPU: $cpu_usage"
elif [ "$OS" = "Windows" ]; then
    cpu_usage=$(wmic cpu get loadpercentage | awk 'NR==2 {print $1"%"}')
    echo "Uso total de CPU: $cpu_usage"
fi
echo ""

# 2. Uso de memoria
echo "=== USO DE MEMORIA ==="
if [ "$OS" = "Linux" ]; then
    free -h | awk '/Mem/{printf "Memoria total: %s\nMemoria usada: %s (%s)\nMemoria libre: %s (%s)\n", $2, $3, $3/$2*100"%", $4, $4/$2*100"%"}'
elif [ "$OS" = "Windows" ]; then
    wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /Value | grep -E 'FreePhysicalMemory|TotalVisibleMemorySize' | awk -F'=' '{if($1=="FreePhysicalMemory") free=$2/1024; else total=$2/1024} END {printf "Memoria total: %.2f MB\nMemoria usada: %.2f MB (%.2f%%)\nMemoria libre: %.2f MB (%.2f%%)\n", total, total-free, (total-free)/total*100, free, free/total*100}'
fi
echo ""

# 3. Uso de disco
echo "=== USO DE DISCO ==="
if [ "$OS" = "Linux" ]; then
    df -h --total | grep -v "tmpfs" | grep -v "udev" | tail -n 1 | awk '{printf "Espacio total: %s\nEspacio usado: %s (%s)\nEspacio libre: %s (%s)\n", $2, $3, $5, $4, 100-$5}'
elif [ "$OS" = "Windows" ]; then
    wmic logicaldisk get size,freespace,caption | awk 'NR>1 && $1 {total=$2/1024/1024/1024; free=$3/1024/1024/1024; used=total-free; printf "Disco %s: Total=%.2fGB, Usado=%.2fGB (%.2f%%), Libre=%.2fGB (%.2f%%)\n", $1, total, used, used/total*100, free, free/total*100}'
fi
echo ""

# 4. Top 5 procesos por CPU
echo "=== TOP 5 PROCESOS POR USO DE CPU ==="
if [ "$OS" = "Linux" ]; then
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
elif [ "$OS" = "Windows" ]; then
    tasklist /FO CSV /NH | awk -F',' '{print $1,$5}' | sort -nr -k2 | head -n 5
fi
echo ""

# 5. Top 5 procesos por memoria
echo "=== TOP 5 PROCESOS POR USO DE MEMORIA ==="
if [ "$OS" = "Linux" ]; then
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
elif [ "$OS" = "Windows" ]; then
    tasklist /FO CSV /NH | awk -F',' '{print $1,$4}' | sort -nr -k2 | head -n 5
fi
echo ""

echo "=============================================="
echo "  Fin del reporte"
echo "=============================================="