#!/bin/bash
file=${1}
canister=${2:-charlie}
network=${3:-local}
filename=$(echo $file | sed -E "s/.+\///")
extension="${file##*.}"


log_line="Uploading $file to $canister on $network."
echo $log_line

echo "$log_line ...Emptying buffer"
dfx canister --network $network call $canister uploadClear 

echo "$log_line ...Uploading"
byteArray=$(od -An -v -tuC background-base.svg)
byteSize=0;
variable="vec {"
for byte in ${byteArray[@]}; do
    byteSize=$((byteSize+1))
    variable+="${byte};"
done
variable+="}"
dfx canister --network $network call $canister upload "($variable)" 

echo "$log_line ...Finalizing"


echo $mimeType

meta="record{
    \"name\" = \"$name\";\
    \"description"\" = \"$description\";\
    \"tags\" = $filename;\
    \"category\" = $byteSize;\
}"

# dfx canister --network $network call $canister uploadFinalize "(
#     record {\
#         \"contentType\" = \"$mimeType\";\
#         \"meta\" = \"$filename\";\
#         \"filePath\" = $filename;\
#     }\
# )"

echo "$log_line ...Done"
