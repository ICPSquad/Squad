#!/bin/bash
file=${1}
canister=${2:-charlie}
network=${3:-local}
category=${4}
tags_component=${5}
tags_layer=${6}
description=${7:-}

filePath=$(echo $file | sed -E "s/.+\///")
name=${filePath%%.*}
extension="${file##*.}"
contentType=$(file --mime-type -b $file)
categoryCandid="variant {$category}"


# Upper limit for chunks due to shell restrictions.
threshold=250000

# Only work if byte size is less than 250Kb.
byteArray=( $(od -An -v -tuC $file))
byteSize=${#byteArray[*]}
threshold=250000

log_line="Uploading $file of category $category with name $name and size $(( $byteSize / 1024 )) kb to canister $canister on network $network."
echo $log_line


echo "$log_line ...Emptying buffer"
dfx canister --network $network call $canister uploadClear >> /dev/null


echo "$log_line ...Uploading file"
i=0
while [ $i -le $byteSize ]; do
    echo "$log_line ...Uploading #$(($i/$threshold+1))/$(($byteSize/$threshold+1))"
    payload="vec {"
    for byte in ${byteArray[@]:$i:$threshold}; do
        payload+="${byte};"
    done
    payload+="}"
    dfx canister --network $network call $canister upload "($payload)" >> /dev/null
    i=$(($i+$threshold))
done

echo "$log_line ...Finalizing"

meta="record {
    name = \"$name\";
    tags = vec{ \"$tags_component\"; \"$tags_layer\" };
    description = \"$description\";
    category = $categoryCandid
}"
finalizeArg="\"$contentType\",$meta,\"$name\""
dfx canister --network $network call $canister uploadFinalize "($finalizeArg)" >> /dev/null
echo "$log_line ...Done"
