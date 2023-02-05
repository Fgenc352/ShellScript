#!/bin/bash
filename=$1
NumberOfCityRequested=$2
outfile=$3
AvgTown=0
TotalTown=0
TotalVillage=0
AvgVillage=0
density=0
closest=0
i=0
if [ -f "$outfile" ]; then
    #echo "$outfile exists."
    rm $outfile
fi
#copy the content of citiest. Therefore the changes will be on the copy file.Eof add new line to copy if is not exist
cp $filename copycities.txt
x=`tail -n 1 "copycities.txt"`
if [ "$x" == "" ]; then
    :
else  
    echo >> copycities.txt
fi
# reading each line
while read line; do

	stringarray=($line)
		if [ $i -ne 0 ];then
			population=${stringarray[5]}
			area=${stringarray[4]}
			area=`echo -e $area | tr -d '$'`
			population=`echo -e $population | tr -d '\r'`
			#population=`echo -e $population | tr -d '$'`
			density=`echo "scale=2;$population/$area"|bc`
			#echo $density
			echo -e "$density\t${stringarray[0]}\t${stringarray[1]}" >> Densities.txt
		fi
	i=$(($i+1))
done < copycities.txt
sort -nr Densities.txt >> SortedDensities.txt
#----------------------------------------------------------------------------------------------------------------------
echo "- The most crowded 3 cities based on the density:" >> $outfile
while read line2;do
	stringarray2=($line2)
		if [ $NumberOfCityRequested -ne 0 ];then
			NumberOfCityRequested=$(($NumberOfCityRequested - 1))
			echo -e "\t${stringarray2[1]} ${stringarray2[2]}"   >> $outfile
		fi
done < SortedDensities.txt
#----------------------------------------------------------------------------------------------------------------------
citynumber=0
while read line3;do
	stringarray3=($line3)
	TotalTown=$((${stringarray3[2]} + $TotalTown))
	TotalVillage=$((${stringarray3[3]} + $TotalVillage))
	citynumber=$(($citynumber + 1))
done < copycities.txt
citynumber=$(($citynumber - 1))

AvgTown=`echo "scale=2;$TotalTown/$citynumber"|bc`
echo -e "\n- The average number of towns: $AvgTown" >> $outfile

AvgVillage=`echo "scale=2;$TotalVillage/$citynumber"|bc`
echo "- The average number of villages: $AvgVillage" >> $outfile
#----------------------------------------------------------------------------------------------------------------------
j=0
while read line5;do
stringarray5=($line5)
if [ $j -eq 1 ];then
	if [[ $(echo "${stringarray5[2]}  > $AvgTown" |bc -l) -eq 1 ]];then
		mindifference=`echo "scale=2;${stringarray5[2]}-$AvgTown"|bc`
		closest=${stringarray5[2]}
		closestplate=${stringarray5[0]}
		closestcity=${stringarray5[1]}
	else
		mindifference=`echo "scale=2;$AvgTown-${stringarray5[2]}"|bc`
		closest=${stringarray5[2]}
		closestplate=${stringarray5[0]}
		closestcity=${stringarray5[1]}
	fi
elif [ $j -eq 0 ]; then
	:
else
	if [[ $(echo "${stringarray5[2]}  > $AvgTown" |bc -l) -eq 1 ]];then
		difference=`echo "scale=2;${stringarray5[2]}-$AvgTown"|bc`
			if [[ $(echo "$mindifference  > $difference" |bc -l) -eq 1 ]];then
				mindifference=$difference
				closest=${stringarray5[2]}
				closestplate=${stringarray5[0]}
				closestcity=${stringarray5[1]}
			fi
	else
		difference=`echo "scale=2;$AvgTown-${stringarray5[2]}"|bc`
			if [[ $(echo "$mindifference  > $difference" |bc -l) -eq 1 ]];then
				mindifference=$difference
				closest=${stringarray5[2]}
				closestplate=${stringarray5[0]}
				closestcity=${stringarray5[1]}
			fi
	fi
fi
j=$(($j+1))
done < copycities.txt
echo "- The city with the closest value of average numbers: $closestplate $closestcity" >> $outfile
#----------------------------------------------------------------------------------------------------------------------
k=0
echo "- The cities that do not have ‘a’ or ‘A’ in their names:" >> $outfile
while read line4;do
stringarray4=($line4)
if [ $k -ne 0 ]; then
	ifexists=`echo ${stringarray4[1]} | grep -v '[A*a*]'`
	controlsize=`echo "$ifexists" | wc -c`
	controlsize=$(($controlsize - 1))
	if [[ $controlsize -ne 0 ]];then
		
		echo ${stringarray4[0]} $ifexists >> $outfile
	fi
fi
k=$(($k + 1))
done < copycities.txt
rm copycities.txt Densities.txt SortedDensities.txt

