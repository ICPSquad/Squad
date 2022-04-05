canister=${1:charlie}
network=${2:local}

#Confirm before deploying to mainnet
if [[ $network != "local" ]]
then
    read -r -p "Do you confirm uploading to mainnet? [Y/n] " input
        case $input in 
            [yY][eE][sS]|[yY])
                echo "Deploying to mainnet"
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


echo "1/4 Uploading manifest for avatar 👦"
bash ./scripts/upload/upload_manifest_avatar.sh $canister $network

echo "2/4 Uploading manifest for accessories 🎩"
bash ./scripts/upload/upload_manifest_accessories.sh $canister $network

echo "3/4 Uploading manifest for legendary characters 🧙‍♂️"
bash ./scripts/upload/upload_manifest_legendary_characters.sh $canister $network

echo "4/4 Uploading manifest for components 👨‍🎨"
bash ./scripts/upload/upload_manifest_components.sh $canister $network

echo "Done 🌈"

