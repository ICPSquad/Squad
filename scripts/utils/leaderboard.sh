dfx canister --network ic call hub get_leaderboard_simplified '(3)' >> leaderboard.csv
sed -i "" 's/record/\n/g' leaderboard.csv
sed -i "" "s/{ principal \"//g" leaderboard.csv
sed -i "" "s/opt vec//g" leaderboard.csv
sed -i "" "s/: nat;};//g" leaderboard.csv
sed -i "" "s/\";/,/g" leaderboard.csv
sed -i "" "s/(//g" leaderboard.csv
sed -i "" "s/{//g" leaderboard.csv
sed -i "" "s/},//g" leaderboard.csv
sed -i "" "s/)//g" leaderboard.csv
sed -i "" 's/ //' leaderboard.csv
sed -i "" 's/ //' leaderboard.csv
sed -i "" 's/ //' leaderboard.csv
sed -i "" 's/: nat;/,/g' leaderboard.csv
sed -i "" 's/ //' leaderboard.csv
sed -i "" 's/ //' leaderboard.csv
sed -i "" 's/ //' leaderboard.csv
sed -i "" 's/ //' leaderboard.csv


sed -i '' '1s/.*/Principal,Style,Engagement,Total/' leaderboard.csv