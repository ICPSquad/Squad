#!/bin/bash
canister=${1:charlie}
network=${2:local}


manifest="./assets/manifest-components.csv"
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
        layersCandid="vec {"
        for i in "${list[@]}"
        do
            layersCandid+="$i;"
        done
        layersCandid+="}"
        category="variant {$Type}"
        component="record{ name = \"$name\"; category = $category; layers = $layersCandid }"
        #TODO : change name
        dfx canister --network $network call $canister addComponent_new "(\"$name\", $component)" 
	done
} < $manifest
IFS=$OLDIFS


