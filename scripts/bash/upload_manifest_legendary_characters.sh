#!/bin/bash
canister=${1:charlie}
network=${2:local}

#Confirm before deploying to mainnet
if [[ $network != "local" ]]
then
    read -r -p "Do you confirm uploading to mainnet? [Y/n] " input
        case $input in 
            [yY][eE][sS]|[yY])
                echo "Deploying to mainnet"
                ;;
            [nN][oO]|[nN])
                echo "Aborting"
                exit 0
                ;;
            *)
                echo "Invalid input..."
                exit 1
                ;;
    esac
fi

manifest="./assets/legendaries/manifest-legendary-characters.csv"
[ ! -f $manifest ] && { echo "$manifest file not found"; exit 99; }


OLDIFS=$IFS
IFS=','
{
	read # skip headers
	while read Name minted role
	do  
        file="assets/legendaries/characters/$Name.svg"
        tag_1="legendary"
        tag_2="character"
        echo "Uploading $file to canister $canister on network $network"
            [ ! -f $file ] && { echo "$file file not found"; exit 99; }
            # Upload file
            bash ./scripts/bash/upload_file.sh $file $canister $network "LegendaryCharacter" $tag_1 $tag_2 ""
	done
} < $manifest
IFS=$OLDIFS

