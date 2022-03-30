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

byteArray=$(od -An -v -tuC $file)
byteSize=0;
payload="vec {"
for byte in ${byteArray[@]}; do
    byteSize=$((byteSize+1))
    payload+="${byte};"
done
payload+="}"



log_line="Uploading $file of category $category with name $name and size $(( $byteSize / 1024 )) kb to canister $canister on network $network."
echo $log_line


echo "$log_line ...Emptying buffer"
dfx canister --network $network call $canister uploadClear >> upload_log.txt


echo "$log_line ...Uploading file"
dfx canister --network $network call $canister upload "($payload)" >> upload_log.txt

echo "$log_line ...Finalizing"

meta="record {
    name = \"$name\";
    tags = vec{ \"$tags_component\"; \"$tags_layer\" };
    description = \"$description\";
    category = $categoryCandid
}"
finalizeArg="\"$contentType\",$meta,\"$name\""
dfx canister --network $network call $canister uploadFinalize "($finalizeArg)" >> upload_log.txt
echo "$log_line ...Done"
