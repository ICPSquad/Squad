#!/bin/bash
byteArray=$(od -An -v -tuC background-base.svg)
byteSize=0;
variable="vec {"
for byte in ${byteArray[@]}; do
    byteSize=$((byteSize+1))
    variable+="${byte};"
done
variable+="}"
echo $variable
echo $byteSize