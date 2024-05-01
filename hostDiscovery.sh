#!/bin/bash

# Función para manejar la interrupción (Ctrl+C)
function ctrl_c() {
    echo -e "\n\n[!] Saliendo...\n"
    exit 1
}

# Función para mostrar el menú de ayuda
function show_help() {
    echo "Uso: $0 [--help] [--ip IP] [--segmento SEGMENTO]"
    echo "  --help                 Muestra este mensaje de ayuda"
    echo "  --ip IP                Enumera los hosts especificados en modo verbose (separados por comas)"
    echo "  --segmento SEGMENTO    Escanea todos los hosts activos en el segmento de red y muestra los puertos abiertos"
    exit 1
}

# Establecer trap para la señal SIGINT (Ctrl+C)
trap ctrl_c INT

# Parsear los argumentos de línea de comandos
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --help|-h) 
            show_help
            ;;
        --ip) 
            ips="$2"
            shift
            ;;
        --segmento) 
            segmento="$2"
            shift
            ;;
        *) 
            echo "Opción inválida: $1" 1>&2
            exit 1
            ;;
    esac
    shift
done

# Verificar si se proporcionan direcciones IP
if [ -n "$ips" ]; then
    # Convertir las direcciones IP separadas por comas en un array
    IFS=',' read -ra ip_array <<< "$ips"
    
    # Iterar sobre cada dirección IP
    for ip in "${ip_array[@]}"; do
        echo -e "\n[+] Enumerando el host $ip:\n"
        for port in $(seq 1 10000); do
            timeout 1 bash -c "echo '' >/dev/tcp/$ip/$port" 2>/dev/null && echo -e "\t[+] Port $port is open" &
        done; wait
    done
    
    tput cnorm
    exit 0
fi

# Verificar si se proporciona un segmento de red
if [ -n "$segmento" ]; then
    echo "[*] Escaneando hosts en el segmento de red $segmento:"
    for host in $(seq 1 254); do
        target="$segmento.$host"
        if timeout 1 bash -c "ping -c 1 $target" &>/dev/null; then
            echo "[+] El host $target está activo"
            echo "[*] Enumerando puertos abiertos en $target:"
            for port in {1..65535}; do
                timeout 1 bash -c "</dev/tcp/$target/$port" &>/dev/null && echo "Puerto $port abierto"
            done
        fi
    done
    exit 0
fi

# Si no se proporciona ninguna opción válida, mostrar la ayuda
show_help

