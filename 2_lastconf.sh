#!/bin/bash


read -p "Enter the number of atoms: " numberatoms

nb=$(seq 1 1 10)
ss=$(seq 2 1 $(( $numberatoms + 1 )))
read -p "Enter the material name: " name
read -p "Enter the temperature: " temperature

cd ../../CNA/$name/${temperature}K/

mkdir POSfile

#dans chaque fichier temperature, on besoin de XDAT. et POS.
for i in $nb; do
        A=$(head -9 POS.A*)
        cd POSfile/
        echo "$A" > POS${i}.OPT
        cd ../conf_$i/
        for b in $ss; do
		m=$(grep -i "Direct" XDATCAR | tail -1)
                B=$(grep -A${numberatoms} "$m" XDATCAR | sed -n ${b}p)
                cd ../POSfile/
                echo "$B T T T" >> POS${i}.OPT
                cd ../conf_$i/
        done
        cd ..
done
      
