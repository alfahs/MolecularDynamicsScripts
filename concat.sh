#!/bin/bash

                                
                                read -p "Enter the number of files you want to concatunate: " numb_concat
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

