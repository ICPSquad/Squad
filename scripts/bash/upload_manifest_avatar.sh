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

manifest="./assets/avatar/manifest-avatar.csv"
[ ! -f $manifest ] && { echo "$manifest file not found"; exit 99; }

OLDIFS=$IFS
IFS=','
{
	read # skip headers
	while read Type name layers
	do  
        # Storing as array into myarray
        OLDIFS=$IFS
        IFS="/" read -a list <<< $layers
        IFS=$OLDIFS
        for layer in "${list[@]}"
        do
            file="assets/avatar/$Type/$name/$name-$layer.svg"
            echo "Uploading $file to canister $canister on network $network"
            [ ! -f $file ] && { echo "$file file not found"; exit 99; }
        done
	done
} < $manifest
IFS=$OLDIFS