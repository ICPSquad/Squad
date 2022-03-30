#!/bin/zsh
file=${1}
filename=$(echo $file | sed -E "s/.+\///")
fileextension=$(echo $file | sed -E "s/.+\.//")
canister=${2:charlie}
network=${3:local}
threshold=${4:250000}

