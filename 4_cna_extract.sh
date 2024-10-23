#!/bin/bash

#banner welcome

read -p "How much elements the system is constituted ?" elements 

read -p "Which material you want to perform CNA on?" name

echo "What is the first temperature ?"
read Tbeg
echo "what is the last temperature ?"
read Tend
echo "what is the temperature step ?"
read pas
indices=$(seq 0 1 10)
T=$(seq $Tbeg $pas $Tend)
cd ../../

cd CNA/$name/
rm coord_*

if [ $elements == 3 ]; then
	for i in ${T[@]}; do
		if [ -e "${i}K" ]; then
		
        		cd ${i}K
			rm CNA_*
			total=$(grep -i "Coordination number type 1:" output*  | awk '{sum+=$5} END{print sum}')
			len=$( grep -i "Coordination number type 1:" output* | wc -l )
			coord_1=$(echo "scale=6; $total / $len" | bc)
        		total=$(grep -i "Coordination number type 2:" output*  | awk '{sum+=$5} END{print sum}')
        		len=$( grep -i "Coordination number type 2:" output* | wc -l )
        		coord_2=$(echo "scale=6; $total / $len" | bc)
                	total=$(grep -i "Coordination number type 3:" output*  | awk '{sum+=$5} END{print sum}')
                	len=$( grep -i "Coordination number type 3:" output* | wc -l )
                	coord_3=$(echo "scale=6; $total / $len" | bc)
			cd ..
			echo $coord_1 >> coord_1.dat
        		echo $coord_2 >> coord_2.dat
			echo $coord_3 >> coord_3.dat
		else
			echo "There is no "${i}"K file" 
		
		fi
	done

	for i in ${T[@]}; do
        	if [ -e "${i}K" ]; then
                	cd ${i}K
                	sed -n '/ CNA particle type 1/,/CNA particle type 2/p' output* > CNA_1.dat
                	sed -i '/CNA/d' CNA_1.dat
                	sed -n '/ CNA particle type 2/,/CNA particle type 3/p' output* > CNA_2.dat
                	sed -i '/CNA/d' CNA_2.dat
                	sed -n '/ CNA particle type 3/,/-------/p' output* > CNA_3.dat
                	sed -i '/CNA/d' CNA_3.dat
			sed -i '/----/d' CNA_3.dat
			for j in ${indices[@]}; do
				for k in ${indices[@]}; do
                        		for l in ${indices[@]}; do
						if grep -Fq "[$j $k $l]" CNA_1.dat; then
						total=$(grep -i "$j $k $l" CNA_1.dat |  awk '{sum+=$4} END{print sum}')
						len=$(grep -i "$j $k $l" CNA_1.dat |  wc -l)
                                        	mean_perc=$(echo "scale=3; $total*100 / $len" | bc)
                                        	if [ $mean_perc \> 1 ]; then
                                                echo "${j}${k}${l} $mean_perc" >> CNA_4.dat
                                        	fi
						fi

						if grep -Fq "[$j $k $l]" CNA_2.dat; then
		                        	total=$(grep -i "$j $k $l" CNA_2.dat |  awk '{sum+=$4} END{print sum}')
                                        	len=$(grep -i "$j $k $l" CNA_2.dat |  wc -l)
                                        	mean_perc=$(echo "scale=3; $total*100 / $len" | bc)
                                        	if [ $mean_perc \> 1 ]; then
                                                	echo "${j}${k}${l} $mean_perc" >> CNA_5.dat
                                        	fi
						fi
                                        	if grep -Fq "[$j $k $l]" CNA_3.dat; then
                                        	total=$(grep -i "$j $k $l" CNA_3.dat |  awk '{sum+=$4} END{print sum}')
                                        	len=$(grep -i "$j $k $l" CNA_3.dat |  wc -l)
                                        	mean_perc=$(echo "scale=3; $total*100 / $len" | bc)
                                        	if [ $mean_perc \> 1 ]; then
                                                	echo "${j}${k}${l} $mean_perc" >> CNA_6.dat
                                        	fi
                                        	fi

					done
				done
			done

                	cd ..
        	else
                	echo "There is no "${i}"K file" 

        	fi
	done
else

        for i in ${T[@]}; do
                if [ -e "${i}K" ]; then

                        cd ${i}K
                        rm CNA_*
                        total=$(grep -i "Coordination number type 1:" output*  | awk '{sum+=$5} END{print sum}')
                        len=$( grep -i "Coordination number type 1:" output* | wc -l )
                        coord_1=$(echo "scale=6; $total / $len" | bc)
                        total=$(grep -i "Coordination number type 2:" output*  | awk '{sum+=$5} END{print sum}')
                        len=$( grep -i "Coordination number type 2:" output* | wc -l )
                        coord_2=$(echo "scale=6; $total / $len" | bc)
                        cd ..
                        echo $coord_1 >> coord_1.dat
                        echo $coord_2 >> coord_2.dat
                else
                        echo "There is no "${i}"K file" 

                fi
        done

   for i in ${T[@]}; do
                if [ -e "${i}K" ]; then
                        cd ${i}K
                        sed -n '/ CNA particle type 1/,/CNA particle type 2/p' output* > CNA_1.dat
                        sed -i '/CNA/d' CNA_1.dat
                        sed -n '/ CNA particle type 2/,/-------/p' output* > CNA_2.dat
                        sed -i '/CNA/d' CNA_2.dat
                        sed -i '/----/d' CNA_2.dat
                        for j in ${indices[@]}; do
                                for k in ${indices[@]}; do
                                        for l in ${indices[@]}; do
                                                if grep -Fq "[$j $k $l]" CNA_1.dat; then
                                                total=$(grep -i "$j $k $l" CNA_1.dat |  awk '{sum+=$4} END{print sum}')
                                                len=$(grep -i "$j $k $l" CNA_1.dat |  wc -l)
                                                mean_perc=$(echo "scale=3; $total*100 / $len" | bc)
                                                if [ $mean_perc \> 1 ]; then
                                                echo "${j}${k}${l} $mean_perc" >> CNA_3.dat
                                                fi
                                                fi

                                                if grep -Fq "[$j $k $l]" CNA_2.dat; then
                                                total=$(grep -i "$j $k $l" CNA_2.dat |  awk '{sum+=$4} END{print sum}')
                                                len=$(grep -i "$j $k $l" CNA_2.dat |  wc -l)
                                                mean_perc=$(echo "scale=3; $total*100 / $len" | bc)
                                                if [ $mean_perc \> 1 ]; then
                                                        echo "${j}${k}${l} $mean_perc" >> CNA_4.dat
                                                fi
                                                fi

                                        done
                                done
                        done

                        cd ..
                else
                        echo "There is no "${i}"K file" 

                fi
        done
fi                                                                                
