#!/bin/bash

if ! [ "$1" ];then
    echo "Devi passare il file di configurazione come argomento"
    exit
fi

JSON="$1"
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

consegna(){
    echo
    echo "Processo di consegna iniziato"
    for j in `seq 0 $n_client`; do
        name=$(jq -r ".[$i].hosts[$j].name"  "$JSON")
        host=$(jq -r ".[$i].hosts[$j].host"  "$JSON")
        scp -r root@$host:$TMPDIR ${TMPDIR}/${name}
        echo "Copiati i file dall'host $name in $TMPDIR"
        ssh root@$host pkill inotifywait
    done
    echo "Vuoi creare l'archivio manualmente così da poter effettuare ulteriori modifiche? [y/N]"
    read tarreq
    name=$(jq -r ".[$i].name" < "$JSON")
    if [ "$tarreq" = "y" -o "$tarreq" = "Y" ];then
        cp -r $TMPDIR consegna
        echo "Tutti i file copiati in ./consegna"
    else
        tar -C $TMPDIR -czvf $name  .
        echo "L'archivio $name è stato creato"
    fi
    rm -rf $TMPDIR
}

monitor(){
    TMPDIR=$1
    shift
    otherpaths="$@"
    mkdir -p $TMPDIR
    inotifywait /etc /root /home/las/.bash_history $otherpaths -rm -e modify -e create --format "%w%f %e" 2>/dev/null |
    while read filepath event;do
        if [ $event = "DELETE" ];then
            rm ${TMPDIR}$filepath
        else
            new=${TMPDIR}$(echo $filepath | egrep -o '.*/')
            mkdir -p $new
            cp $filepath $new 2>/dev/null 
        fi
    done
}

n_client=$(jq ".[0].hosts | length - 1" < "$JSON")
echo "Inizio del monitoraggio di /etc, /root e /home/las/.bash_history negli host specificati nel file di configurazione"
echo "Vuoi specificare altri path da monitorare? [y/N]"
read other
if [ "$other" = "y" -o "$other" = "Y" ];then
    echo "Scrivi i path assoluti aggiuntivi da monitorare. Se più di uno devono essere separati da spazi"
    read otherpaths
fi
for j in `seq 0 $n_client`; do
    host=$(jq -r ".[$i].hosts[$j].host"  "$JSON")
    ssh root@$host "$(typeset -f monitor); monitor $TMPDIR $otherpaths" &
    echo
    echo "Quando vuoi interrompere il monitoraggio ed avviare il processo di consegna premi Ctrl+C, altrimenti se vuoi interrompere l'esecuzione di questo script premi Ctrl+\\"
done

trap consegna SIGINT

sleep 3h
