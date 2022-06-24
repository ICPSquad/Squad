#!/bin/bash
canister=${1:charlie}
network=${2:local}


manifest="./assets/legendaries/manifest-legendary-characters.csv"
[ ! -f $manifest ] && { echo "$manifest file not found"; exit 99; }


OLDIFS=$IFS
IFS=','
{
	read # skip headers
	while read Name minted 
	do  
        file="assets/legendaries/characters/$Name.svg"
        tag_1="legendary"
        tag_2="character"
            [ ! -f $file ] && { echo "$file file not found"; exit 99; }
            # Upload file
            bash ./scripts/deploy/upload/upload-file.sh $file $canister $network "LegendaryCharacter" $tag_1 $tag_2 ""
	done
} < $manifest
IFS=$OLDIFS

