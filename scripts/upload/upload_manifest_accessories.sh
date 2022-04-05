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

manifest="./assets/accessories/manifest-accessories.csv"
[ ! -f $manifest ] && { echo "$manifest file not found"; exit 99; }

OLDIFS=$IFS
IFS=','
{
	read # skip headers
	while read Type name layers
	do  
        OLDIFS=$IFS
        IFS="/" read -a list <<< $layers
        IFS=$OLDIFS
        for layer in "${list[@]}"
        do
            file="assets/accessories/$Type/$name/$name-$layer.svg"
            tag_layer=$layer
            tag_slot=$Type
            echo "Uploading $file to canister $canister on network $network"
            [ ! -f $file ] && { echo "$file file not found"; exit 99; }
            # Upload file
            bash ./scripts/upload/upload_file.sh $file $canister $network "AccessoryComponent" $tag_slot $tag_layer ""

        done
	done
} < $manifest
IFS=$OLDIFS


