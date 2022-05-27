#!/bin/bash

# Uploading the style
value=$(<./assets/components/css_style.txt)
dfx canister call avatar changeStyle "'($value)'" >> /dev/null 2>&1

NODE_ENV="development" npx ts-node node/upload/upload-cards.ts& 
echo "Uploading assets into avatar & accessory canister (~10 min) 📦"

bash ./scripts/deploy/upload/upload-components.sh "avatar" "local"
wait

echo "Do you also want to upload legendary character (~4 min) [Y/n] "
read input
    case $input in 
        [yY][eE][sS]|[yY])
            echo "Uploading legendary character ⭐️"
            bash ./scripts/deploy/upload/upload-legendary.sh "avatar" "local"
            ;;
        [nN][oO]|[nN])
            echo "Skipping legendary character"
            ;;
        *)
            echo "Invalid input..."
            exit 1
            ;;
    esac

echo "All assets have been uploaded"