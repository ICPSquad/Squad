file=${1}
sed -i '' '1s/.*/Tokens/' $file
sed -i "" 's/vec//g' $file
sed -i '' 's/;/\n/g' $file
sed -i '' 's/"//g' $file
sed -i '' 's/)//g' $file
sed -i '' 's/{//g' $file
sed -i '' 's/},//g' $file
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file