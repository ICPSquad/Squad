file=${1}
echo "Removing from ${file}"
sed -i "" 's/<svg viewBox="0 0 800 800" xmlns="http:\/\/www.w3.org\/2000\/svg">//g' $file
sed -i "" 's/<\/svg>//g' $file