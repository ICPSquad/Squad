file=${1}
sed -i '' '1s/.*/Account, Number, Principal, Twitter, Discord, Avatar/' $file
sed -i "" 's/vec//g' $file
sed -i "" 's/record/\n/g' $file
sed -i '' '2d' $file
sed -i '' 's/{//g' $file
sed -i '' 's/: nat;};//g' $file
sed -i '' 's/,},//g' $file
sed -i '' 's/: nat//g' $file
sed -i '' 's/opt principal//g' $file
sed -i '' 's/opt//g' $file
sed -i '' 's/opt//g' $file
sed -i '' 's/opt//g' $file
sed -i '' 's/;/,/g' $file
sed -i '' 's/"//g' $file
# Fix indentations and useless space
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file