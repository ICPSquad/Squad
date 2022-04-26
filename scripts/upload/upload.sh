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

echo "Deploying all layers and registering the associated components to canister : $canister on network $network."
bash ./scripts/upload/upload_register_components_avatar.sh $canister $network 

echo "All assets have been deployed to the avatar canister. 🎉"

