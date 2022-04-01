#!/bin/bash
canister=${1:charlie}
network=${2:local}


manifest="./assets/avatar/manifest-avatar.csv"
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
            file="assets/avatar/$Type/$name/$name-$layer.svg"
            tag_layer=$layer
            tag_component=$Type
            echo "Uploading $file to canister $canister on network $network"
            [ ! -f $file ] && { echo "$file file not found"; exit 99; }
            # Upload file
            bash ./scripts/bash/upload_file.sh $file $canister $network "AvatarComponent" $tag_component $tag_layer ""

        done
	done
} < $manifest
IFS=$OLDIFS


