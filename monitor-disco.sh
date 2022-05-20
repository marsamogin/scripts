#!/bin/bash
#----------------------------------------------------------------------------------
# 25/07/2018 [Fabio Prado] -> Script criado para monitorar espaco em disco nos pontos de montagem principais do servidor. Manda msg quando espaco estiver ocupado em 90% ou mais.
#    a) Atribua para a var mntlist os nomes dos pontos de montagens que vc deseja monitorar, separados por espaços em branco
#    b) Altere o e-mail teste@oracle.com para o qual vc deseja enviar as msgs de monitoramento
#----------------------------------------------------------------------------------
mntlist="/ /boot"
for ml in $mntlist
do
    # grava na var "usedSpc" o valor do percentual de uso do ponto de montagem, extraido do comando "df -h":
    usedSpc=$(df -h $ml | sed '1d' | awk '{print $5}' | grep -v capacity | cut -d "%" -f1 -)
    # grava na var "BOX" o nome da maquina:
    BOX=$(uname -a | awk '{print $2}')

    case $usedSpc in
        [0-9])
            arcStat="$ml => Relaxe,_ha_muito_espaco uso_de_$usedSpc%"
            ;;
        [1-7][0-9])
            arcStat="$ml => Espaco_em_disco_OK uso_de_$usedSpc%"
            ;;
        [8][0-9])
            arcStat="$ml => WARNING:_espaco_em_disco_esta_ficando_baixo uso_de_$usedSpc%"
            ;;
        [9][0-9])
            arcStat="$ml => CRITICAL:_espaco_em_disco_esta_ACABANDO uso_de_$usedSpc%"
            echo $arcStat $ml | mailx -s "Espaco em: $BOX" marcio@unicamp.br
            ;;
        [1][0][0])
            arcStat="$ml => CRITICAL:_espaco_em_disco_JA_ACABOU uso_de_$usedSpc%"
            ;;
        *)
        arcStat="% uso: $usedSpc"
    esac

    echo $arcStat
    #
done
#
exit 0
