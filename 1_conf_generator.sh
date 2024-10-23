#!/bin/bash

read -p "For which material you want generate configurations?" name

echo "What is the temperature ?"
read T

cd ../../CNA/$name/${T}K/

nb=$(seq 0 1 7)
ss=$(seq 2 1 257)


#dans chaque fichier temperature, on besoin de XDAT. et POS. /AlMg/600K/
for i in $nb; do
	j=$((i+1))
	mkdir conf_$j
	cd ../src/
	cp * ../${T}K/conf_$j/
	cd ../${T}K/
	A=$(head -9 POS.A*)
	cd conf_$j
	echo "$A" > POSCAR
	cd ..
        for b in $ss; do
                B=$(grep -A256 "=  ${j}000" XDAT.Al80Si10Fe10.1200K.8000.36 | sed -n ${b}p)
		cd conf_$j
                echo "$B T T T" >> POSCAR
	cd ..
        done
	cd conf_$j
	oarsub -S ./run.oar
	cd ..
done
