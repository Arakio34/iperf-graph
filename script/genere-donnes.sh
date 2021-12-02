#!/bin/bash

#Declaration des foncions utilisers
function generGraph () {
    echo "set terminal png">> ../graph/confplot
    echo "set output \"../graph/diag.png\"">> ../graph/confplot
    echo "set style line 13 lt 3 lw 2 ps 0.5 pt 2 lc 3" >> ../graph/confplot
    echo "set title \"Influence du $1 a echel semi-logarithmique\"" >> ../graph/confplot
    echo "set xlabel \"$1\"" >> ../graph/confplot
    echo "set ylabel \"Debits\"" >> ../graph/confplot
    echo "set logscale y" >> ../graph/confplot
    echo "set key off" >> ../graph/confplot
    echo "plot \"../data/finaldata\" using 2:1 with linespoints" >> ../graph/confplot
    gnuplot -c ../graph/confplot
}

function clearEnv () {
    mkdir ../data
    mkdir ../graph
    touch ../data/finaldata
    touch ../graph/confplot
    echo > ../graph/confplot
    echo > ../data/finaldata
    echo > ../data/rawData
    echo > ../data/cleanData
    sudo ./penaliter.sh delay 0 > /dev/null
    sudo ./penaliter.sh loss 0 > /dev/null
    sudo ./penaliter.sh duplicate 0 /dev/null
}

#function creerGraph(){}

#Declaration variable
TYPE=$1
RATIO=$2
NBREP=$3

#Verification des arguments

if [ $# != 3 ]
then
    echo "INDICATION :" 
    echo "Se script à pour but de tester une connexion en fonction de differents paramètres."
    echo "Il vous retournera donc des graphiques en fonction de ce que vous demandez."
    
    echo "UTILISATION :" 
    echo "La permière chose a faire est d'ouvrir un autre terminal et de lancer le script network.sh de la manière suivante :"
    echo "sudo ./network.sh 10.12.0.1 10.12.0.2 'iperf -B 10.12.0.1 -s'"
    
    echo "Ensuite rentrer dans le premier champ ce que vous souhaitez etudier \"(delay/loss/duplicate)\"."
    echo "Dans le second, le ratio d'incrémentation (1,2,10,20 ...). Bien sûr si vous voulez aucun changement metter 0."
    echo "Dans le troisième champ, indiquer le nombre de relever."
    
    exit 1
fi

#Netoie l'environment de travail

clearEnv

#Recuper les donnes et les remet en forme

for (( i=0 ;i<NBREP ;i++ ))
do
    a=$(($i*$RATIO))
    sudo ./penaliter.sh $TYPE $a
    sudo iperf -B 10.12.0.2%veth-client -c 10.12.0.1 >> ../data/rawData
done

cat ../data/rawData|grep bits|sed -e "s/ //g" |cut -d "s" -f 3-12 >../data/cleanData


data=$(cat ../data/cleanData)
nbLine=$(echo -e "$data"|wc -l|cut -d " " -f 1)

for((i=1 ;i<=$nbLine;i++))
do
    curValue=$(echo "$data"|cut -f $i -d$'\n')
    if [ $(echo $curValue | grep "G") ]
    then
        curData=$(echo $curValue | cut -f 1 -d 'G')
        finalData=$(echo "10^6*$curData"|bc)
    elif [ $(echo $curValue | grep "M") ]
    then
        curData=$(echo $curValue | cut -f 1 -d 'M')
        finalData=$(echo "10^3*$curData"|bc)
    else
        curData=$(echo $curValue | cut -f 1 -d 'b')
        finalData=$curData
    fi
    echo "$finalData $(echo "$i * $RATIO"|bc)" >> ../data/finaldata    
done

generGraph $1

