dfx canister --network ic call avatar get_all_users > users.csv
sed -i "" 's/principal/\n/g' users.csv
sed -i "" "s/ record { height = //g" users.csv
sed -i "" "s/ : nat64)//g" users.csv
sed -i "" "s/\"//g" users.csv
sed -i "" "s/selected_avatar//g" users.csv
sed -i "" "s/\"//g" users.csv
sed -i '' '1s/.*/Principal,Height,Avatar,Invoice,Twitter,Name,RankEmail,Discord /' users.csv
