#!/bin/bash

# Print da sintaxe correta
function print_sintaxe {
    echo "Sintaxe: $0 [file ...] [-r dir] [-t num] [-s num] [-u] [-h]"
}

# Menu
function print_help {
    echo "Sintaxe: $0 [file ...] [-r dir] [-t num] [-s num] [-u] [-h]"
    echo "Apagar ficheiros de forma segura, movendo-os para a diretoria LIXO de forma comprimida"
    echo "Opções:"
    echo "  file                 Ficheiro a ser apagado"
    echo "  -r dir               Sdel é aplicado recursivamente na diretoria dir"
    echo "  -t num               Apaga os ficheiros do LIXO com mais de num horas"
    echo "  -s num               Apaga os ficheiros do LIXO com mais de num KB/B"
    echo "  -u                   Print do tamanho do maior ficheiro no diretorio LIXO"
    echo "  -h                   Print do manual de utilizador"
}

# Ficheiro log vai conter todos os logs feitos com o comando
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
while getopts ":r:t:s:uh" opcao; do #':' serve para as opções que requerem argumentos
    case ${opcao} in
        r)
            if [ -d "$OPTARG" ]; then
                # Executa a função find para comprimir e mover os ficheiros para LIXO
                find "$OPTARG" -type f -exec bash -c 'gzip -c "{}" > ~/.LIXO/"$(date '+%Y-%m-%d_%H:%M:%S')_$(basename "{}").gz" && rm -f "{}"' \;
                exit 0
            else
                echo "Erro: $OPTARG não é um diretorio"
                print_sintaxe # Sintaxe correta
                exit 1
            fi
            ;;
        t)
            find ~/.LIXO/* -mmin +$(($OPTARG*60)) -type f -exec rm -f {} \;
            log "Apagar ficheiros do lixo com mais de $OPTARG horas"
            exit 0
            ;;
        s)
            #Apaga os ficheiros com mais de x Bytes
            find ~/.LIXO/ -type f -size +"${OPTARG}"c -exec rm -f {} + # "\;" removido porque assim o + passa o maior numero de argumentos de uma vez para o find sem repetir o comando
            log "Apagar ficheiros do lixo com mais de $OPTARG B/KB"
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
            print_sintaxe # Sintaxe correta
            exit 1
            ;;
        :) # Quando uma opção requer argumento, este bloco de código vai ser executado
            echo "Erro: Opção -$OPTARG requer um argumento" 1>&2
            print_sintaxe # Sintaxe correta
            exit 1
            ;;
    esac
done

# Permite remover argumentos já processados, continuando a processar os próximos argumentos sem erros ou duplicar nada
shift $((OPTIND -1))

# Não deixa o comando sdel ser executado sem argumentos, dando um erro ao usuário
if [ $# -eq 0 ]; then
    echo "Erro: Nenhum ficheiro especificado"
    print_sintaxe
    exit 1
fi

# Loop nos ficheiros passados como argumento para o comando
for file in "$@"; do
    if [ ! -e "$file" ]; then # Verifica se o ficheiro passado como argumento existe
        echo "Erro: $file não existe"
        continue
    else

    	if [ -d "$file" ]; then #verifica se é diretorio, se for avança para o proximo if
            if [ "$file" == "." ]; then #se o diretorio for . entao é o diretorio atual e pode continuar para o proximo arquivo
            	continue
            fi
            find "$file" -type f -exec $0 {} \; #se nao for o diretorio atual,  o script vai executar a funçao recursivamente em todos os arquivos no dir
            continue
        fi

        # Comprime os ficheiros invocados e passa-os para o diretorio LIXO
        gzip -c "$file" > ~/.LIXO/"$(date '+%Y-%m-%d_%H:%M:%S')_$file.gz" && rm -f "$file"
        log "Apagado o ficheiro $file"
    fi
done
