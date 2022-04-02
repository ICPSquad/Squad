file=${1}
sed -i '' '1s/.*/Token,Time,Seller,Buyer,Price/' $file
sed -i "" 's/vec//g' $file
sed -i "" 's/record/\n/g' $file
sed -i "" 's/token = //g' $file
sed -i "" 's/time = //g' $file
sed -i "" 's/seller = //g' $file
sed -i "" 's/buyer = //g' $file
sed -i "" 's/price = //g' $file
sed -i "" 's/ : nat64;};//g' $file
sed -i "" 's/ { //g' $file
sed -i "" 's/"//g' $file
sed -i "" 's/ : int//g' $file
sed -i "" 's/;/,/g' $file
sed -i '' '2d' $file
sed -i '' 's/principal//g' $file
sed -i '' 's/{//g' $file
# Fix indentations and useless space
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file
sed -i '' 's/ //' $file
