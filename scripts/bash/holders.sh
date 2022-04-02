file=${1}
sed -i '' '1s/.*/Account, Number_of_accessories/' $file
sed -i "" 's/vec//g' $file
sed -i "" 's/record/\n/g' $file
sed -i '' '2d' $file
sed -i '' 's/{//g' $file
sed -i '' 's/: nat;};//g' $file
sed -i '' 's/;/,/g' $file
sed -i '' 's/"//g' $file
# Fix indentations and useless space
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file

