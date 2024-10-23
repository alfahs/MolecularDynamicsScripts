#!/bin/bash

read -p "Enter the material name: " name

echo "Enter the temperature (the first if there is many):"
read Tbeg

read -p "Is there many temperatures? [yes,no]: " ans

if [ $ans == yes ]; then

	echo "Enter the last temperature "
	read Tend

	echo "Enter the temperature step "
	read pas

	T=$(seq $Tbeg $pas $Tend)

else

	T=$Tbeg
fi

cd ../$name/

for i in ${T[@]}; do
   if [ -e "${i}K" ]; then
        cd ${i}K
	rm -f vasp_2n*
        sleep 1
	echo "------------------------------------"
	echo "Entering in the $name/${i}K/ file..."
	sleep 1
	TBEG=$(grep -i "TEBEG" INCAR |  cut -f2 -d '=')
        TEND=$(grep -i "TEEND" INCAR |  cut -f2 -d '=')
	echo "The beginning temperature in the INCAR file is: ${TBEG} and the temperature end is: ${TEND}"
	sleep 1
	current_step=$(grep -i "T=" OSZICAR | tail -1 | awk '{print($1)}')
	echo "The current timestep is: "
	sleep 1
	echo $current_step
	sleep 1
	final_step=$(grep -i "NSW" INCAR | cut -f2 -d '=')
	sleep 1 
	echo "The final timestep is: "
	sleep 1
	echo $final_step

	if [[ "$current_step" -eq "$final_step" ]]; then
		
		echo "The simulation is OVER at "${i}" K "
		sleep 1
		echo "The previous simulation numbers are: "
		find out* | cut -f5 -d '.' | sort -n 
		sleep 1
		echo "Enter the new simulation number: "
		read numb_sim
		./rerun $name.${i}K.$current_step.$numb_sim
		grep -i "t=" out.*.$current_step.$numb_sim | awk '{print($1,$3,$9)}' > temperature.$current_step.$numb_sim.dat
		grep -i "external pressure" OUTCAR.*.$current_step.$numb_sim | awk '{print($4)}' > pressure.$current_step.$numb_sim.dat
		#grep -i "mag=" out.*.$current_step.$numb_sim | awk '{print($17)}' > magnetic.$current_step.$numb_sim.dat
		nb=$(wc -l XDAT.*.$current_step.$numb_sim | awk '{print($1)}')
		nbb=$((nb-7))
		#echo $nbb
		tail -$nbb XDAT.*.$current_step.$numb_sim  > x.$current_step.$numb_sim.dat 
		cat entete x.$current_step.$numb_sim.dat  > xISAACS.$current_step.$numb_sim.dat 
		total_pressure=$(paste -sd+ pressure.$current_step.$numb_sim.dat | bc)	
		mean_pressure=$(echo "scale=4; $total_pressure*0.1/$current_step" | bc)
		total_temperature=$(awk '{print($2)}' temperature.$current_step.$numb_sim.dat | paste -sd+  | bc)
		mean_temperature=$(echo "scale=4; $total_temperature / $current_step" | bc)
		#total_magnetism=$(paste -sd+ magnetic.$current_step.$numb_sim.dat | bc)
                #mean_magnetism=$(echo "scale=4; $total_magnetism / $current_step" | bc)
		sleep 1
		echo "The mean pressure (GPa) is : " $mean_pressure
		sleep 1
		echo "The mean temperature (K) is : " $mean_temperature	
		sleep 1
                #echo "The mean total magnetic moment (MuB) is : " $mean_magnetism 
		#sleep 1

		if (( $(echo "$mean_pressure > -0.5" | bc -l) )) &&  (( $(echo "$mean_pressure < 0.5" | bc -l) )); then

			echo "The pressure is OK!"
			sleep 1
                        read -p 'Do you want to create another temperature? [yes,no]' answer
                        if [ $answer == yes ]; then
				sleep 1
				read -p 'Enter the quenching temperature: ' quench_temp
				T_final=$(( ${i} + ${quench_temp} ))
				sleep 1
				echo "The temperature after quenching is: " $T_final
				sleep 1
				echo "Creating the directory:  /${name}/${T_final}K"
				cd ..
				mkdir ${T_final}K
				cd ${i}K
				cp KPOINTS rerun run.oar POSCAR POTCAR INCAR entete ../${T_final}K/
				cd ../${T_final}K/
                                sed -i 's/TEBEG=.*/TEBEG='${T_final}'/g' INCAR
				sed -i 's/TEEND=.*/TEEND='${T_final}'/g' INCAR
				sleep 1
                                echo "Enter the number of steps:"
                                read step
                                sed -i 's/NSW = .*/NSW = '${step}'/g' INCAR
                                oarsub -S ./run.oar
                                cd ../${i}K
				
			else
				sleep 1
				echo "OK!"
				
			fi
			sleep 1
			read -p 'Do you want rerun after convergence ? [yes,no]' answer
			if [ $answer == yes ]; then
				sleep 1
				echo "Enter the new number of steps :"
                        	read step
                        	sed -i 's/NSW = .*/NSW = '${step}'/g' INCAR
			        oarsub -S ./run.oar
				cd ..
			else	
				read -p 'Do you want concatunate files ? [yes,no]' answer
				if [ $answer == yes ]; then
				read -p "Enter the number of files you want to concatunate at the end: " numb_concat
				last_file=$(find out* | cut -f5 -d '.' | sort -n | tail -1)
				start_file=$(( $last_file - $numb_concat + 1 ))
				sleep 1
				echo "Numbers of the simulation files are: "
				array=$(seq $start_file 1 $last_file)
				sleep 1
				echo $array
				sleep 1
				read -p "Enter the number of atoms " number_of_atoms
				cat entete > xISAACS.dat
				sum=0
				for file in $array; do
        				timesteps=$(grep -i "Direct" x.*.${file}.dat | awk '{print($3)}' | tail -1)
        				steps=$(seq 1 1 $timesteps)
        				for step in $steps; do
                			sum=$(( $sum + 1 ))
                			if [[ "$step" -ge "1" && "$step" -lt "10" ]]; then

                        			echo "Direct configuration=     $sum" >> xISAACS.dat
                        			grep -A${number_of_atoms} "Direct configuration=     $step"  x.*.${file}.dat | sed 1d >> xISAACS.dat

                			fi
                			if [[ "$step" -ge "10" && "$step" -lt "100" ]]; then

                        			echo "Direct configuration=    $sum" >> xISAACS.dat
                        			grep -A${number_of_atoms} "Direct configuration=    $step"  x.*.${file}.dat | sed 1d >> xISAACS.dat

                			fi
                			if [[ "$step" -ge "100" && "$step" -lt "1000" ]]; then

                        			echo "Direct configuration=   $sum" >> xISAACS.dat
                        			grep -A${number_of_atoms} "Direct configuration=   $step"  x.*.${file}.dat | sed 1d >> xISAACS.dat
                			fi
                			if [[ "$step" -ge "1000" && "$step" -lt "10000" ]]; then

                        			echo "Direct configuration=  $sum" >> xISAACS.dat
                        			grep -A${number_of_atoms} "Direct configuration=  $step"  x.*.${file}.dat | sed 1d >> xISAACS.dat
                			fi
               	 			if [[ "$step" -ge "10000" && "$step" -lt "100000" ]]; then

                        			echo "Direct configuration= $sum" >> xISAACS.dat
                        			grep -A${number_of_atoms} "Direct configuration= $step"  x.*.${file}.dat | sed 1d >> xISAACS.dat
                			fi

        				done
				done

				
				cd ..
				mv ${i}K/ finish_file/
				
			        else

			        	cd ..
                                	mv ${i}K/ finish_file/
				fi	
			fi
		else
			sleep 1
			echo "The pressure is NOT OK!"
			sleep 1
			echo "The current length of the simulation box is :"
        		sed -n 2p POSCAR | awk '{print($1)}'
        		lengthold=$(sed -n 2p POSCAR | awk '{print($1)}')
			sleep 1
        		echo "Enter the new length of the simulation box (decrease/increase the length if the pressure is negative/positive): "
        		read length
        		sed -i 's/'${lengthold}'/'${length}'/g' POSCAR
			sleep 1
			echo "Enter the new number of steps :"
        		read step
        		sed -i 's/NSW = .*/NSW = '${step}'/g' INCAR

			oarsub -S ./run.oar
			cd ..
		fi
	
	else
		sleep 1
		echo "The simulation is NOT over at "${i}" K"
		sleep 1
		read -p "Do you want to delete the job at the current timestep ? [yes,no]" answer
		if [ $answer == yes ]; then
                        jobnumber=$(find vasp_2n.*.out | cut -f2 -d '.' | sort -n | tail -1)
                        oardel $jobnumber
		else
			sleep 1
			echo "OK!"
		fi
                read -p "Do you want take the results at the current timestep ? [yes,no]" answer
		if [ $answer == yes ]; then
			#jobnumber=$(find job_name.*.out | cut -f2 -d '.' | sort -n | tail -1)
			#ccc_mdel $jobnumber
			sleep 1
			echo "The previous simulation numbers are: "
                	find out* | cut -f5 -d '.' | sort -n
			sleep 1
     			echo "Enter the new simulation number:"
                	read numb_sim
                	./rerun $name.${i}K.$current_step.$numb_sim
                	grep -i "t=" out.*.$current_step.$numb_sim | awk '{print($1,$3,$9)}' > temperature.$current_step.$numb_sim.dat
                	grep -i "external pressure" OUTCAR.*.$current_step.$numb_sim | awk '{print($4)}' > pressure.$current_step.$numb_sim.dat
			#grep -i "mag=" out.*.$current_step.$numb_sim | awk '{print($17)}' > magnetic.$current_step.$numb_sim.dat
                	nb=$(wc -l XDAT.*.$current_step.$numb_sim | awk '{print($1)}')
                	nbb=$((nb-7))
                	#echo $nbb
                	tail -$nbb XDAT.*.$current_step.$numb_sim  > x.$current_step.$numb_sim.dat 
                	cat entete x.$current_step.$numb_sim.dat  > xISAACS.$current_step.$numb_sim.dat 
                	total_pressure=$(paste -sd+ pressure.$current_step.$numb_sim.dat | bc)  
                	mean_pressure=$(echo "scale=4; $total_pressure*0.1/$current_step" | bc)
                	total_temperature=$(awk '{print($2)}' temperature.$current_step.$numb_sim.dat | paste -sd+  | bc)
                	mean_temperature=$(echo "scale=4; $total_temperature / $current_step" | bc)
	                #total_magnetism=$(paste -sd+ magnetic.$current_step.$numb_sim.dat | bc)
	                #mean_magnetism=$(echo "scale=4; $total_magnetism / $current_step" | bc)		
			sleep 1
                	echo "The mean pressure (GPa) is : " $mean_pressure
			sleep 1
                	echo "The mean temperature (K) is : " $mean_temperature
			sleep 1 
	                #echo "The mean total magnetic moment (MuB) is : " $mean_magnetism 
        	        #sleep 1
                
                	if (( $(echo "$mean_pressure > -0.5" | bc -l) )) &&  (( $(echo "$mean_pressure < 0.5" | bc -l) )); then
				sleep 1
                        	echo "The pressure is OK!"
				sleep 1
                        	read -p 'Do you want to create another temperature? [yes,no]' answer
                        	if [ $answer == yes ]; then
                                	sleep 1
                                	read -p 'Enter the quenching temperature: ' quench_temp
                                	T_final=$(( ${i} + ${quench_temp} ))
                                	sleep 1
                                	echo "The temperature after quenching is: " $T_final
                                	sleep 1
                                	echo "Creating the directory:  /${name}/${T_final}K"
                                	cd ..
                                	mkdir ${T_final}K
                                	cd ${i}K
                                	cp KPOINTS rerun run.oar POSCAR POTCAR INCAR entete ../${T_final}K/
                                	cd ../${T_final}K/
                                        sed -i 's/TEBEG=.*/TEBEG='${T_final}'/g' INCAR
                                 	sed -i 's/TEEND=.*/TEEND='${T_final}'/g' INCAR
                                        echo "Enter the number of steps:"
                                        read step
                                        sed -i 's/NSW = .*/NSW = '${step}'/g' INCAR
                                	oarsub -S ./run.oar
                                	cd ../${i}K

                        	else
                                	sleep 1
                                	echo "OK!"

                            fi

                            read -p 'Do you want rerun after convergence ? [yes,no]' answer
                            if [ $answer == yes ]; then
					sleep 1
                                	echo "Enter the new number of steps "
                                	read step
                                	sed -i 's/NSW = .*/NSW = '${step}'/g' INCAR
                                	oarsub -S ./run.oar
                                	cd ..
                            else
                                read -p 'Do you want concatunate files ? [yes,no]' answer
                                if [ $answer == yes ]; then
                                read -p "Enter the number of files you want to concatunate at the end: " numb_concat
                                last_file=$(find out* | cut -f5 -d '.' | sort -n | tail -1)
                                start_file=$(( $last_file - $numb_concat + 1 ))
                                sleep 1
                                echo "Numbers of the simulation files are: "
                                array=$(seq $start_file 1 $last_file)
                                sleep 1
                                echo $array
                                sleep 1
                                read -p "Enter the number of atoms " number_of_atoms
                                cat entete > xISAACS.dat
                                sum=0
                                for file in $array; do
                                        timesteps=$(grep -i "Direct" x.*.${file}.dat | awk '{print($3)}' | tail -1)
                                        steps=$(seq 1 1 $timesteps)
                                        for step in $steps; do
                                        sum=$(( $sum + 1 ))
                                        if [[ "$step" -ge "1" && "$step" -lt "10" ]]; then

                                                echo "Direct configuration=     $sum" >> xISAACS.dat
                                                grep -A${number_of_atoms} "Direct configuration=     $step"  x.*.${file}.dat | sed 1d >> xISAACS.dat

                                        fi
                                        if [[ "$step" -ge "10" && "$step" -lt "100" ]]; then

                                                echo "Direct configuration=    $sum" >> xISAACS.dat
                                                grep -A${number_of_atoms} "Direct configuration=    $step"  x.*.${file}.dat | sed 1d >> xISAACS.dat

                                        fi
                                        if [[ "$step" -ge "100" && "$step" -lt "1000" ]]; then

                                                echo "Direct configuration=   $sum" >> xISAACS.dat
                                                grep -A${number_of_atoms} "Direct configuration=   $step"  x.*.${file}.dat | sed 1d >> xISAACS.dat
                                        fi
                                        if [[ "$step" -ge "1000" && "$step" -lt "10000" ]]; then

                                                echo "Direct configuration=  $sum" >> xISAACS.dat
                                                grep -A${number_of_atoms} "Direct configuration=  $step"  x.*.${file}.dat | sed 1d >> xISAACS.dat
                                        fi
                                        if [[ "$step" -ge "10000" && "$step" -lt "100000" ]]; then

                                                echo "Direct configuration= $sum" >> xISAACS.dat
                                                grep -A${number_of_atoms} "Direct configuration= $step"  x.*.${file}.dat | sed 1d >> xISAACS.dat
                                        fi

                                        done
                                done
				
                                	cd ..
                                	mv ${i}K/ finish_file/
				else
                                        cd ..
                                        mv ${i}K/ finish_file/
				fi
                             fi


                	else
				sleep 1
                        	echo "The pressure is NOT OK!"
				sleep 1
                        	echo "The current length of the simulation box is: "
                        	sed -n 2p POSCAR | awk '{print($1)}'
                        	lengthold=$(sed -n 2p POSCAR | awk '{print($1)}')
				sleep 1
                        	echo "Enter the new length of the simulation box (decrease/increase the length if the pressure is negative/positive): "
                        	read length
                        	sed -i 's/'${lengthold}'/'${length}'/g' POSCAR
				sleep 1
                        	echo "Enter the new number of steps :"
                        	read step
                        	sed -i 's/NSW = .*/NSW = '${step}'/g' INCAR
                        	oarsub -S ./run.oar
                        	cd ..
			fi

                else
			sleep 1
			read -p 'Do you want rerun ? [yes,no]' answer
                        if [ $answer == yes ]; then
                         	sleep 1
                                echo "Enter the new number of steps :"
                                read step
                                sed -i 's/NSW = .*/NSW = '${step}'/g' INCAR
                                oarsub -S ./run.oar
                                cd ..
			else
				sleep 1
				echo "OK !"
				sleep 1
				read -p 'Do you want concatunate files ? [yes,no]' answer
                                if [ $answer == yes ]; then
				read -p "Enter the number of files you want to concatunate at the end: " numb_concat
                                last_file=$(find out* | cut -f5 -d '.' | sort -n | tail -1)
                                start_file=$(( $last_file - $numb_concat + 1 ))
                                sleep 1
                                echo "Numbers of the simulation files are: "
                                array=$(seq $start_file 1 $last_file)
                                sleep 1
                                echo $array
                                sleep 1
                                read -p "Enter the number of atoms " number_of_atoms
                                cat entete > xISAACS.dat
                                sum=0
                                for file in $array; do
                                        timesteps=$(grep -i "Direct" x.*.${file}.dat | awk '{print($3)}' | tail -1)
                                        steps=$(seq 1 1 $timesteps)
                                        for step in $steps; do
                                        sum=$(( $sum + 1 ))
                                        if [[ "$step" -ge "1" && "$step" -lt "10" ]]; then

                                                echo "Direct configuration=     $sum" >> xISAACS.dat
                                                grep -A${number_of_atoms} "Direct configuration=     $step"  x.*.${file}.dat | sed 1d >> xISAACS.dat

                                        fi
                                        if [[ "$step" -ge "10" && "$step" -lt "100" ]]; then

                                                echo "Direct configuration=    $sum" >> xISAACS.dat
                                                grep -A${number_of_atoms} "Direct configuration=    $step"  x.*.${file}.dat | sed 1d >> xISAACS.dat

                                        fi
                                        if [[ "$step" -ge "100" && "$step" -lt "1000" ]]; then

                                                echo "Direct configuration=   $sum" >> xISAACS.dat
                                                grep -A${number_of_atoms} "Direct configuration=   $step"  x.*.${file}.dat | sed 1d >> xISAACS.dat
                                        fi
                                        if [[ "$step" -ge "1000" && "$step" -lt "10000" ]]; then

                                                echo "Direct configuration=  $sum" >> xISAACS.dat
                                                grep -A${number_of_atoms} "Direct configuration=  $step"  x.*.${file}.dat | sed 1d >> xISAACS.dat
                                        fi
                                        if [[ "$step" -ge "10000" && "$step" -lt "100000" ]]; then

                                                echo "Direct configuration= $sum" >> xISAACS.dat
                                                grep -A${number_of_atoms} "Direct configuration= $step"  x.*.${file}.dat | sed 1d >> xISAACS.dat
                                        fi

                                        done
                                done
			else
				echo "OK !"

			fi
			cd ..
			fi
                fi



	fi

   else
     sleep 1
     echo "The file ${i}K doesn't exist !"

   fi

done	

