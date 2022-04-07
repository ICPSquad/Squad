#!/bin/bash
canister=${1:charlie}
network=${2:local}

#Confirm before deploying to mainnet
if [[ $network != "local" ]]
then
    read -r -p "Do you confirm building all avatars? [Y/n] " input
        case $input in 
            [yY][eE][sS]|[yY])
                echo "Building"
                ;;
            [nN][oO]|[nN])
                echo "Aborting"
                exit 0
                ;;
            *)
                echo "Invalid input..."
                exit 1
                ;;
    esac
fi

manifest="scripts/upgrade/tokens_second_wave.csv"
[ ! -f $manifest ] && { echo "$manifest file not found"; exit 99; }

OLDIFS=$IFS
IFS=','
{
    i=0;
	read # skip headers
	while read Tokens
	do  
        dfx canister --network $network call $canister build_avatar "(\"$Tokens\")" >> scripts/upgrade/upgrade_avatar_log.txt
	done
} < $manifest
IFS=$OLDIFS
