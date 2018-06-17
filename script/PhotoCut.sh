#!/bin/bash

hello(){
	`zenity --question --title "Feh, ImageMagick i ExifTool" --text "Czy masz zainstalowane programy ExifTool, ImageMagick i Feh?"`
	ISINSTALL=$?
}
install(){
	sudo apt-get update
	sudo apt-get install exiftool
	sudo apt-get install imagemagick
	sudo apt-get install feh
}
getDir(){
	DIR=`zenity --file-selection`
	EXT=($(echo $DIR | cut -d"." -f 2))
	echo $EXT
	while [[ $EXT != "jpg" && $EXT != "png" ]];do
		`zenity --error --text "To nie jest jpg ani png!"`
		DIR=`zenity --file-selection`
		EXT=($(echo $DIR | cut -d"." -f 2))
		echo $EXT
	done
	DIR=$(dirname "$DIR")
}
getDate(){
	NEWDIR=($(exiftool $PHOTO | grep Modification | cut -d":" -f 2,3,4 | cut -d" " -f 2))
}
getAuthor(){
	NEWDIR=($(exiftool $PHOTO | grep Artist | cut -d":" -f 2 | cut -d" " -f 2,3))
}
getPhotos(){
	cd $DIR
	ls > tmp.txt
	while read A; do
		EXT=($(echo $A | cut -d"." -f 2))
		if [[ $EXT == "jpg" || $EXT == "png" ]]; then
			echo "$A" >> s_tmp.txt
		fi
	done < tmp.txt
	index=0
	P_SIZE=0
        while read A; do
                PHOTOS[$index]=$A
                index=$(($index+1))
        done < s_tmp.txt
	P_SIZE=$index
	index=$(($index - 1))
	for j_index in ${!PHOTOS[@]}; do
		if [[ $j_index -gt $index ]]; then	
                	PHOTOS[$j_index]=-1
		fi
	done
	rm tmp.txt
	rm s_tmp.txt
}
makeDirs(){
	
	for index in ${!PHOTOS[@]}; do
		PHOTO=${PHOTOS[$index]}
		case $WHICH in
		1)getDate;;
		2)getAuthor;;
		esac
		[[ -d $NEWDIR ]] || mkdir $NEWDIR
		mv $PHOTO $NEWDIR
	done
}
getFSize(){

	F_WIDTH=($(exiftool $F_PHOTO | grep "Image Size" | cut -d":" -f 2 | cut -d" " -f 2 | cut -d"x" -f 1))
	F_HEIGHT=($(exiftool $F_PHOTO | grep "Image Size" | cut -d":" -f 2 | cut -d" " -f 2 | cut -d"x" -f 2))
}
getSize(){
	WIDTH=($(exiftool $S_PHOTO | grep "Image Size" | cut -d":" -f 2 | cut -d" " -f 2 | cut -d"x" -f 1))
	HEIGHT=($(exiftool $S_PHOTO | grep "Image Size" | cut -d":" -f 2 | cut -d" " -f 2 | cut -d"x" -f 2))
}
isSameSize(){
	if [[ $F_WIDTH == $WIDTH && $F_HEIGHT == $HEIGHT ]]; then
		SAME_SIZE=1
	fi
}
makeToPreview(){
	PREFIX="small_"	
	index=0	
	echo "$A_SIZE"
	while [[ $index -lt $A_SIZE ]]; do
		SMALL=$PREFIX${ARRAY[$index]}
		convert ${ARRAY[$index]} -resize 640x480 $SMALL
		echo "$SMALL" >> s_tmp.txt
		index=$(($index+1))
	done
	feh -f s_tmp.txt
        while read A; do
                rm $A
        done < s_tmp.txt
	rm s_tmp.txt
}
displayPreview(){
	makeToPreview
	index=0	
	TAB=(0)
	echo "$A_SIZE"
	while [[ $index -lt $A_SIZE ]]; do
		TAB[$index]=${ARRAY[$index]}
		index=$(($index+1))
	done
	odp=`zenity --list --column=Zdjęcia "${TAB[@]}" --height=200`
	echo "$odp"
	for index in ${!ARRAY[@]}; do
		if  test ${ARRAY[$index]} = $odp; then
			ARRAY[$index]=1
			break
		fi
	done
	index=0
	while [[ $index -lt $A_SIZE ]]; do
		if [[ ${ARRAY[$index]} != 1 ]]; then
			rm ${ARRAY[$index]}
		fi
		index=$(($index+1))
	done
}
getFirstTime(){
	IFDATA=($(exiftool $F_PHOTO | grep "Metadata Date"))
	if [[ -z $IFDATA ]]; then
		HOURS1=($(exiftool $F_PHOTO | grep "Create Date" | cut -d" " -f 25 | cut -d":" -f 1 | cut -d"+" -f 1 | cut -d"0" -f 2))	
		MINUTES1=($(exiftool $F_PHOTO | grep "Create Date" | cut -d" " -f 25 | cut -d":" -f 2 | cut -d"+" -f 1 | cut -d"0" -f 2))	
		SECONDS1=($(exiftool $F_PHOTO | grep "Create Date" | cut -d" " -f 25 | cut -d":" -f 3 | cut -d"+" -f 1 | cut -d"0" -f 2))	
	
	else
		HOURS1=($(exiftool $F_PHOTO | grep "Metadata Date" | cut -d" " -f 23 | cut -d":" -f 1 | cut -d"+" -f 1 | cut -d"0" -f 2))	
		MINUTES1=($(exiftool $F_PHOTO | grep "Metadata Date" | cut -d" " -f 23 | cut -d":" -f 2 | cut -d"+" -f 1 | cut -d"0" -f 2))	
		SECONDS1=($(exiftool $F_PHOTO | grep "Metadata Date" | cut -d" " -f 23 | cut -d":" -f 3 | cut -d"+" -f 1 | cut -d"0" -f 2))	
	fi
	MINUTES=$(($HOURS1*60))
	MINUTES1=$(($MINUTES1+$MINUTES))
	SEC=$(($MINUTES1*60))
	F_TIME=$(($SECONDS1+$SEC))
}
getSecondTime(){	

	IFDATA=($(exiftool $F_PHOTO | grep "Metadata Date"))
	if [[ -z $IFDATA ]]; then
		HOURS1=($(exiftool $S_PHOTO | grep "Create Date" | cut -d" " -f 25 | cut -d":" -f 1 | cut -d"+" -f 1 | cut -d"0" -f 2))	
		MINUTES1=($(exiftool $S_PHOTO | grep "Create Date" | cut -d" " -f 25 | cut -d":" -f 2 | cut -d"+" -f 1 | cut -d"0" -f 2))	
		SECONDS1=($(exiftool $S_PHOTO | grep "Create Date" | cut -d" " -f 25 | cut -d":" -f 3 | cut -d"+" -f 1 | cut -d"0" -f 2))	
	
	else
		HOURS1=($(exiftool $S_PHOTO | grep "Metadata Date" | cut -d" " -f 23 | cut -d":" -f 1 | cut -d"+" -f 1 | cut -d"0" -f 2))	
		MINUTES1=($(exiftool $S_PHOTO | grep "Metadata Date" | cut -d" " -f 23 | cut -d":" -f 2 | cut -d"+" -f 1 | cut -d"0" -f 2))	
		SECONDS1=($(exiftool $S_PHOTO | grep "Metadata Date" | cut -d" " -f 23 | cut -d":" -f 3 | cut -d"+" -f 1 | cut -d"0" -f 2))	
	fi
	MINUTES=$(($HOURS1*60))
	MINUTES1=$(($MINUTES1+$MINUTES))
	SEC=$(($MINUTES1*60))
	S_TIME=$(($SECONDS1+$SEC))
}

prepare(){
	index=0
	A_SIZE=0
        while read A; do
                ARRAY[$index]=$A
                index=$(($index+1))
        done < tmp.txt
	A_SIZE=$index
        index=$(($index - 1))
	for j_index in ${!ARRAY[@]}; do
		if [[ $j_index -gt $index ]]; then	
                	ARRAY[$j_index]=-1
		fi
	done
        displayPreview
}
toCompare(){
	F_INDEX=0
	getDir
	getPhotos
	for index in ${!PHOTOS[@]}; do
		if [[ ${PHOTOS[$index]} != -1 ]]; then
			F_PHOTO=${PHOTOS[$index]}
			getFirstTime
			getFSize
			for j_index in ${!PHOTOS[@]}; do
				if [[ ${PHOTOS[$j_index]} != -1 ]]; then
					SAME_SIZE=0
					S_PHOTO=${PHOTOS[$j_index]}
					getSize
					isSameSize
					if [[ $SAME_SIZE == 1 ]]; then
						getSecondTime
						TIME=$(($F_TIME - $S_TIME))
						if [[ $TIME < 5 ]]; then
							echo "$S_PHOTO" >> tmp.txt
							PHOTOS[$j_index]=-1
						fi
					fi
				fi
				
			done
			prepare
			rm tmp.txt
		fi
	done
}
getHelp(){
	`zenity --info --title=Pomoc/Informacje --text="Program zapewnia katalogowanie zdjęć i usuwanie kopii wykonanych w 5 sekundowym odstępie czasu"`
}
getVersion(){
	`zenity --info --title=Wersja --text="Wersja alpha 0.1"`
}
whichGroup(){
	WHICH_TYPE=("DATA" "AUTOR")
	odp=`zenity --list --column=Zdjęcia "${WHICH_TYPE[@]}" --height=200`
	case $odp in
	DATA)WHICH=1;;
	AUTOR)WHICH=2;;
	esac
}
startProgram(){
	hello
	if [[ $ISINSTALL != 0 ]]
	then
		install
	fi
	getDir
	whichGroup
	getPhotos
	makeDirs
	toCompare
}
while getopts ",h,v,f" OPT; do
	case $OPT in
	h) getHelp;;
	v) getVersion;;
	f) startProgram;;
	esac

done		
