# run in docker container cnatzke/ntuple via
# docker run --user $(id -u):$(id -g) --rm=true -it -v $(pwd):/scratch -w /scratch cnatzke/ntuple:ggac_surface /bin/bash
# Usage:
#   run_ntuple_cronos.sh

#!/bin/bash

# variables
ROOT_VERSION="v6.14.06"
INPUT_FILE="missing_files.txt"
NUM_FILES=$(cat $INPUT_FILE | wc -l)
COUNTER=0

if [[ ! -f $INPUT_FILE ]]; then
    echo "$INPUT_FILE not found, exiting..."
    exit 1
fi

# source root
source /softwares/RootCern/${ROOT_VERSION}/bin/thisroot.sh

while IFS="," read -r z job; do
    ROOT_FILE="Z$z/Raw/g4out_Z${z}_$job.root"
    SORTED_FILE="Z$z/Sorted/Converted_Z${z}_$job.root"
    COUNTER=$(( $COUNTER + 1 ))
    echo "Sorting file $COUNTER of $NUM_FILES"
    /softwares/NTuple/NTuple -sf /softwares/NTuple/Settings.dat -if $ROOT_FILE -of $SORTED_FILE -vl 1
done < $INPUT_FILE
