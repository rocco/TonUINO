#!/bin/bash

let dirindex=0

# cleanup
rm -r "$1/_tonuino-mp3s" &>/dev/null
mkdir "$1/_tonuino-mp3s"

for directory in "$1"/*;
do
    if [ -d "$directory" ] && [ "${directory##*/}" != "_tonuino-mp3s" ]; then
        echo "now working in dir: ${directory##*/}"

        dirindex=$((dirindex+1))
        dirindexnr=$(printf "%02d" $dirindex)
        # dirindextext="$dirindexnr--${directory##*/}"
        dirindextext="$dirindexnr"

        mkdir "$1/_tonuino-mp3s/$dirindextext"

        let fileindex=1
        for file in "$directory"/*;
        do
            if [ -f "$file" ]; then
                fileindextext=$(printf "%03d" $fileindex)

                # if file is an mp3 just copy it, otherwise convert
                case "${file##*/}" in (*".mp3"*)
                    echo "copying mp3: ${file##*/}";
                    # cp "$file" "$1/_tonuino-mp3s/$dirindextext/$fileindextext--${file##*/}.mp3"
                    cp "$file" "$1/_tonuino-mp3s/$dirindextext/$fileindextext.mp3"

                    # save cover from first file
                    if [ $fileindex -eq 1 ]; then
                        eyeD3 --write-images="$1/_tonuino-mp3s/$dirindextext" "$file"
                        mv "$1/_tonuino-mp3s/$dirindextext/OTHER.PNG" "$1/_tonuino-mp3s/$dirindexnr--cover.png"
                    fi
                    fileindex=$((fileindex+1))
                    ;;
                esac
                case "${file##*/}" in (*".m4a"*)
                    echo "converting m4a: ${file##*/}";
                    # ffmpeg -loglevel error -i "$file" -acodec libmp3lame -b:a 192k "$1/_tonuino-mp3s/$dirindextext/$fileindextext--${file##*/}.mp3"
                    ffmpeg -loglevel error -i "$file" -acodec libmp3lame -b:a 192k "$1/_tonuino-mp3s/$dirindextext/$fileindextext.mp3"

                    # save cover from first file
                    if [ $fileindex -eq 1 ]; then
                        mp4art -of --extract "$file"
                        # ls -l "$directory"/*.png
                        mv "$directory"/*.png "$1/_tonuino-mp3s/$dirindexnr--cover.png"
                    fi
                    fileindex=$((fileindex+1))
                    ;;
                esac

            fi
        done
    fi
done