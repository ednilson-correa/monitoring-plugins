#!/bin/bash

#count dos arquivos .cfg gerados pela config do merlin
#deverá haver um .cfg para cada probe declarada
if [ -d "/var/cache/merlin/config" ] ; then
	POLLERS=$(ls /var/cache/merlin/config/*.cfg | wc -l)
else
	echo "merlin settings dir not found! has merlin been configured?"
	exit 3

#count da quantidade minima de argumentos que o plugin receberá
#se receber menos que o mínimo, encerra com codigo 3
if [ $# -ne 4 ] ; then
	echo "usage:"
	echo "./check_merlin_connections -s [a|l|w|e|s] -p <port>"
	echo "-s must be only one state!"
	echo "-s state: a:all, l:listen, w:wait, e:established, s:syn"
	exit 3
fi

#validação da entrada de dados e atribuição nas variáveis
if [ $1 = -s ] && [ $3 = -p ] ; then
	PORT=$4 #atribui a porta digitada como argumento na variavel PORT
	COUNT=$POLLERS #atribui o count dos .cfg na variavel COUNT
else
	echo "invalid arguments! (./check_merlin_connections $1 $2 $3 $4)"
	echo "usage:"
	echo "./check_merlin_connections -s [a|l|w|e|s] -p <port>"
	echo "-s must be only one state!"
	echo "-s state: a:all, l:listen, w:wait, e:established, s:syn"
	exit 3
fi


#atribuição do valor digitado [a|l|w|e|s] e montagem do grep da porta e state
case "$2" in
	a)	CONN=`netstat -tan | grep $PORT | wc -l` ;;
	l)	CONN=`netstat -tan | grep $PORT | grep LISTEN | wc -l` ;;
	w)	CONN=`netstat -tan | grep $PORT | grep TIME_WAIT | wc -l` ;;
	e)	CONN=`netstat -tan | grep $PORT | grep ESTABLISHED | wc -l` ;;
	s)	CONN=`netstat -tan | grep $PORT | grep SYN | wc -l` ;;
esac

#aplicação dos thresholds
if [ $CONN -lt $COUNT ] ; then
	echo "CRITICAL - Probes Configuradas: $COUNT. Probes Conectadas: $CONN | conn=$CONN;;$COUNT;0;"
	exit 2
else
	echo "OK - Probes Configuradas: $COUNT. Probes Conectadas: $CONN | conn=$CONN;;$COUNT;0;"
	exit 0
fi
