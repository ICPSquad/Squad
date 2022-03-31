#!/bin/bash
byteArray=( $(od -An -v -tuC assets/legendaries/characters/Alexa.svg))
byteSize=${#byteArray[*]}
echo $byteSize
threshold=250000
i=0
while [ $i -le $byteSize ]; do
    echo "$log_line ...Uploading #$(($i/$threshold+1))/$(($byteSize/$threshold+1))"
    payload="vec {"
    for byte in ${byteArray[@]:$i:$threshold}; do
        payload+="${byte};"
    done
    payload+="}"
    dfx canister --network $network call $canister upload "($payload)" >> upload_log.txt
    i=$(($i+$threshold))
done