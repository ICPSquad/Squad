#!/bin/bash
dir_name=$(date +'%F')
dfx canister --network ic call accessories stats_circulation > scripts/audits/$dir_name.csv
# Clean up the file by remowing expressions that are not needed
sed -i "" 's/vec//g' scripts/audits/$dir_name.csv
sed -i "" 's/record/\n/g' scripts/audits/$dir_name.csv
sed -i "" 's/,//g' scripts/audits/$dir_name.csv
sed -i "" 's/)//g' scripts/audits/$dir_name.csv
sed -i "" 's/(//g' scripts/audits/$dir_name.csv
sed -i "" 's/{//g' scripts/audits/$dir_name.csv
sed -i "" 's/"//g' scripts/audits/$dir_name.csv
sed -i "" 's/: nat32;};//g' scripts/audits/$dir_name.csv
sed -i "" 's/}//g' scripts/audits/$dir_name.csv
sed -i "" 's/;/,/g' scripts/audits/$dir_name.csv
sed -i "" '/^$/d' scripts/audits/$dir_name.csv
sed -i "" '/^$/d' scripts/audits/$dir_name.csv

# Replace the first line by Name, Supply
sed -i '' '1s/.*/Name,Supply/' scripts/audits/$dir_name.csv

# Fix indentation by removing the first space in each line two times    
sed -i '' 's/ //' scripts/audits/$dir_name.csv
sed -i '' 's/ //' scripts/audits/$dir_name.csv
sed -i '' 's/ //' scripts/audits/$dir_name.csv

sed -i '' 's/, /,/' scripts/audits/$dir_name.csv