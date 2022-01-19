#!/bin/bash

# Optimize the files with svgo, creates a defs file with svgstore and output the result in index.html 
# Need to make a copy of components folder because strange behaviour with svgo that can cause files to be cleared after processing that way we never touch the "original" folder


cp -r src/website/assets/components src/website/assets/copy
mkdir Opti/
svgo src/website/assets/copy/**/*.svg -o Opti/ 
svgstore -o defs.svg --inline  Opti/**.svg
sed -i "" -e '1s|svg|svg xlmns="http//www.w3.org/2000/svg" version="1.1" class="h-0"|' defs.svg 
sed -i "" '/<svg /,/<\/svg>/d' src/website/src/index.html
sed -i "" '/<body>/r defs.svg' src/website/src/index.html
rm -r Opti 
rm -r src/website/assets/copy

echo "Done and folder cleared :)"
