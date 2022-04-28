#!/bin/bash
# The goal of this script is to clean all svgs files to prevents the clip_path conflits by adding names to the clip_paths
f=${1}
# Loop trough all the svg files 
echo "Cleaning the file: $f"
# Remove the useless lines in <svg>
sed -i '' 's/xmlns:xlink="http:\/\/www.w3.org\/1999\/xlink"//' $f
sed -i '' 's/xml:space="preserve"//' $f
sed -i '' 's/xmlns:serif="http:\/\/www.serif.com\/"//' $f
# Remove everything between serif and "" with an empty string.
sed -i '' 's/serif:id="[^"]'\*'"//' $f
#Get the name of the accessory
name=$(echo $f | awk -F "/" '{print $NF}' | awk -F "." '{print $1}')  

# Prevent potential collision of clipPaths by adding the name of the file to the clipPath.
i=0
grep -e clip-path $f | while read -r line
do  
    sed -i '' 's/'"$line"'/<g clip-path="url(#'$name'_'$i')">/' $f
    i=$((i+1))
done
i=0
grep -e  clipPath\ id=\" $f | while read -r line
do  
    # Replace the clipPath id with the name of the file and the index of the clipPath.
    sed -i '' 's/'"$line"'/<clipPath id="'$name'_'$i'">/' $f
    ((i++))
done
# Prevent potential collision of linearGradients by adding the name of the file to the linearGradient.
sed -i '' 's/_Linear/'$name'_Linear/' $f
echo "Done cleaning the file: $f"