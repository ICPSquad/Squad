#!/bin/bash
canister=${1:charlie}
network=${2:local}

# Get canister ID
export ID=$(dfx canister id $canister)

#Confirm before deploying to mainnet
if [[ $network != "local" ]]
then
    read -r -p "Do you confirm uploading to mainnet? [Y/n] " input
        case $input in 
            [yY][eE][sS]|[yY])
                ID=$(dfx canister --network ic id $canister)
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

manifest="./assets/components/manifest-components.csv"
[ ! -f $manifest ] && { echo "$manifest file not found"; exit 99; }

echo "Uploading all components into the $canister canister : $ID on network : $network"

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
            file="assets/components/avatar/$type/$name/$name-$layer.svg"
            tag_layer=$layer
            tag_component=$type
            [ ! -f $file ] && { echo "$file file not found"; exit 99; }
            # Upload file
            bash ./scripts/deploy/upload/upload-file.sh $file $canister $network "AvatarComponent" $tag_component $tag_layer ""
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
            file="assets/components/accessory/$type/$name/$name-$layer.svg"
            tag_layer=$layer
            tag_component=$type
            [ ! -f $file ] && { echo "$file file not found"; exit 99; }
            # Upload file
            bash ./scripts/deploy/upload/upload-file.sh $file $canister $network "AccessoryComponent" $tag_component $tag_layer ""
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