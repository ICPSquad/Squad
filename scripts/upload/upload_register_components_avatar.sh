#!/bin/bash
canister=${1:charlie}
network=${2:local}


manifest="./scripts/upload/manifest-global.csv"
[ ! -f $manifest ] && { echo "$manifest file not found"; exit 99; }

OLDIFS=$IFS
IFS=','
{
	read # skip headers
	while read category type name layers
	do  
    if [ "$category" == "avatar" ];
    then
        OLDIFS=$IFS
        IFS="/" read -a list <<< $layers
        IFS=$OLDIFS
        layersCandid="vec {"
        for layer in "${list[@]}"
        do
            file="assets/avatar/$type/$name/$name-$layer.svg"
            tag_layer=$layer
            tag_component=$type
            [ ! -f $file ] && { echo "$file file not found"; exit 99; }
            # Upload file
            bash ./scripts/upload/upload_file.sh $file $canister $network "AvatarComponent" $tag_component $tag_layer ""
        done
        for i in "${list[@]}"
        do
            layersCandid+="$i;"
        done
        layersCandid+="}"
        category="variant {Avatar}"
        component="record{ name = \"$name\"; category = $category; layers = $layersCandid }"
        dfx canister --network $network call $canister registerComponent "(\"$name\", $component)" >> /dev/null
        echo "Registered $name."
    elif [ "$category" == "accessory" ];
    then
        OLDIFS=$IFS
        IFS="/" read -a list <<< $layers
        IFS=$OLDIFS
        layersCandid="vec {"
        for layer in "${list[@]}"
        do
            file="assets/avatar/accessories/$type/$name/$name-$layer.svg"
            tag_layer=$layer
            tag_component=$type
            [ ! -f $file ] && { echo "$file file not found"; exit 99; }
            # Upload file
            bash ./scripts/upload/upload_file.sh $file $canister $network "AccessoryComponent" $tag_component $tag_layer ""
        done
        for i in "${list[@]}"
        do
            layersCandid+="$i;"
        done
        layersCandid+="}"
        category="variant {Accessory}"
        component="record{ name = \"$name\"; category = $category; layers = $layersCandid }"
        # Register component with all layers
        dfx canister --network $network call $canister registerComponent "(\"$name\", $component)" >> /dev/null
        echo "Registered $name."
    elif [ "$category" == "end" ];
    then
        break
        exit 0
    else 
        echo "Unknown category $category"
        exit 99
    fi
	done
} < $manifest
IFS=$OLDIFS