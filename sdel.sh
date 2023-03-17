#!/bin/bash

function print_sintaxe {
    echo "Sintaxe: $0 [file ...] [-r dir] [-t num] [-s num] [-u] [-h]"
}

# Menu
function print_help {
    echo "Sintaxe: $0 [file ...] [-r dir] [-t num] [-s num] [-u] [-h]"
    echo "Apagar ficheiros de forma segura, movendo-os para a diretoria LIXO de forma comprimida"
    echo "Opções:"
    echo "  file                 Ficheiro a ser apapago"
    echo "  -r dir               Sdel é aplicado recursivamente na diretoria dir"
    echo "  -t num               Apaga os ficheiros do LIXO com mais de num horas"
    echo "  -s num               Apaga os ficheiros do LIXO com mais de num KB"
    echo "  -u                   Print do tamanho do maior ficheiro no diretorio LIXO"
    echo "  -h                   Print do manual de utilizador"
}

function log {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> ~/.sdel.log
}

# Verifica se o diretorio LIXO existe, caso contrário irá criar um
if [ ! -d ~/.LIXO ]; then
    mkdir ~/.LIXO
fi

# Verifica se o ficheiro log existe, caso contrário irá criar um
if [ ! -f ~/.sdel.log ]; then
    touch ~/.sdel.log
fi

# opções do menu
while getopts ":r:t:s:uh" opt; do
    case ${opt} in
        r)
            if [ -d "$OPTARG" ]; then
                find "$OPTARG" -type f -exec $0 {} \;
                exit 0
            else
                echo "Erro: $OPTARG não é um diretorio"
                print_sintaxe
                exit 1
            fi
            ;;
        t)
            find ~/.LIXO/* -mmin +$(($OPTARG*60)) -type f -exec rm -f {} \;
            log "Apagar ficheiros do lixo com mais de $OPTARG horas"
            exit 0
            ;;
        s)
            find ~/.LIXO/ -mindepth 1 -type f -name "*.gz" -size +"${OPTARG%k}" -exec rm -f + {} \;
            log "Apagar ficheiros do lixo com mais de $OPTARG KB"
            exit 0
            ;;
        u)
            ls -lS ~/.LIXO | awk '{print $5}' | tail -n +2  | head -n 1 #O tail -n +2, serve para dar skip à primeira linha que nao  dá print a nada
            exit 0
            ;;
        h)
            print_help
            exit 0
            ;;
        \?)
            echo "Erro: Opção inválida -$OPTARG" 1>&2
            print_sintaxe
            exit 1
            ;;
        :)
            echo "Erro: Opção -$OPTARG requer um argumento" 1>&2
            print_sintaxe
            exit 1
            ;;
    esac
done

# Shift the options so that the positional parameters are in $1, $2, etc.
shift $((OPTIND -1))

if [ $# -eq 0 ]; then
    echo "Erro: Nenhum ficheiro especificado"
    print_sintaxe
    exit 1
fi

# Loop nos ficheiros existentes
for file in "$@"; do
    if [ ! -e "$file" ]; then
        echo "Erro: $file não existe"
        continue
    fi

    if [ -d "$file" ]; then #verifica se é diretorio, se for avança para o proximo if
        if [ "$file" == "." ]; then #se o diretorio for . entao é o diretorio atual e pode continuar para o proximo arquivo
            continue
        fi
        find "$file" -type f -exec $0 {} \; #se nao for o diretorio atual,  o script vai executar a funçao recursivamente em todos os arquivos no dir
        continue
    fi
done

    # Comprime os ficheiros invocados e passa-os para o diretorio LIXO
    gzip -c "$file" > ~/.LIXO/"$(date '+%Y-%m-%d_%H:%M:%S')_$file.gz" && rm -f "$file"
    log "Deleted $file"

