#!/bin/bash

read -p "Enter material name you want generate configurations: " name
read -p "Enter the temperature: " T
read -p "Enter the configuration number: " conf_numb
read -p "Enter the number of atoms: " atom_numb
read -p "Enter the name of the XDAT: " XDAT_name


cd ../../CNA/$name/${T}K/


ss=$(seq 2 1 $(( $atom_numb + 1 )))

	
	mkdir conf_${conf_numb}
	cd ../src/
	cp * ../${T}K/conf_${conf_numb}/
	cd ../${T}K/
	A=$(head -9 POS.A*)
	cd conf_${conf_numb}
	echo "$A" > POSCAR
	cd ..
        for b in $ss; do
                B=$(grep -A${atom_numb} "=  $confignumber" ${XDAT_name} | sed -n ${b}p) #set config numb
		cd conf_${conf_numb}
                echo "$B T T T" >> POSCAR
		cd ..
        done
	cd conf_${conf_numb}
 	#write command line to run the script on the cluster
	cd ..

