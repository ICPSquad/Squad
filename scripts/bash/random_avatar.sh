#!/bin/bash

# The goal of this script is to generate a random avatar request.


manifest="./assets/avatar/manifest-avatar.csv"
[ ! -f $manifest ] && { echo "$manifest file not found"; exit 99; }


declare –a array_background=()
declare -a array_profile=()
declare -a array_ears=()
declare -a array_mouth=()
declare -a array_eyes=()
declare -a array_nose=()
declare -a array_hair=()
declare -a array_clothes=()


OLDIFS=$IFS
IFS=','
{
	read # skip headers
	while read Type name layers
	do
        case $Type in 
            background)
                array_background+=($name)
                ;;
            profile)
                array_profile+=($name)
                ;;
            ears)
                array_ears+=($name)
                ;;
            mouth)
                array_mouth+=($name)
                ;;
            eyes)
                array_eyes+=($name)
                ;;
            nose)
                array_nose+=($name)
                ;;
            hair)
                array_hair+=($name)
                ;;
            clothes)
                array_clothes+=($name)
                ;;
        esac
	done
} < $manifest
IFS=$OLDIFS


avatar_background=${array_background[$RANDOM % ${#array_background[@]}]}
avatar_profile=${array_profile[$RANDOM % ${#array_profile[@]}]}
avatar_ears=${array_ears[$RANDOM % ${#array_ears[@]}]}
avatar_mouth=${array_mouth[$RANDOM % ${#array_mouth[@]}]}
avatar_eyes=${array_eyes[$RANDOM % ${#array_eyes[@]}]}
avatar_nose=${array_nose[$RANDOM % ${#array_nose[@]}]}
avatar_hair=${array_hair[$RANDOM % ${#array_hair[@]}]}
avatar_clothes=${array_clothes[$RANDOM % ${#array_clothes[@]}]}

echo "background: $avatar_background"
echo "profile: $avatar_profile"
echo "ears: $avatar_ears"
echo "mouth: $avatar_mouth"
echo "eyes: $avatar_eyes"
echo "nose: $avatar_nose"
echo "hair: $avatar_hair"
echo "clothes: $avatar_clothes"


