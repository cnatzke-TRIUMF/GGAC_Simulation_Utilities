#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

TOP_DIR=$(pwd)
OUTPUT_FILE="missing_files.txt"
FILE_PREFIX="Converted"
COUNT=0

if [[ -e $OUTPUT_FILE ]]; then
    rm $OUTPUT_FILE
fi

for z in {0..4..2}; do
    for job in {0000..0999}; do
        # set the correct path for the filetype
        if [[ $FILE_PREFIX == "g4out" ]]; then
            FILE="$TOP_DIR/Z$z/Raw/${FILE_PREFIX}_Z${z}_$job.root"
        elif [[ $FILE_PREFIX == "Converted" ]]; then
            FILE="$TOP_DIR/Z$z/Sorted/${FILE_PREFIX}_Z${z}_$job.root"
        fi

        # Check if file exists or is small, if not record which file is missing
        MIN_SIZE=3000000 # 3MB
        if [[ ! -e $FILE ]]; then
            COUNT=$(( $COUNT + 1))
            echo "$z,$job" >> missing_files.txt
        elif [[ -e $FILE ]]; then
            FILE_SIZE="$(stat -c %s $FILE)"
            if [[ $FILE_SIZE -le $MIN_SIZE ]]; then 
                COUNT=$(( $COUNT + 1))
                echo "$z,$job" >> missing_files.txt
            fi
        fi
    done
done

if [[ $COUNT == 0 ]]; then
    echo "No files missing"
else
    echo "Missing $COUNT files"
fi
