#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Get values from a .ini file
function iniget() {
    if [[ $# -lt 2 || ! -f $1 ]]; then
        echo "usage: iniget <file> [--list|<section> [key]]"
        return 1
    fi
    local inifile=$1

    if [ "$2" == "--list" ]; then
        for section in $(cat $inifile | grep "^\\s*\[" | sed -e "s#\[##g" | sed -e "s#\]##g"); do
            echo $section
        done
        return 0
    fi

    local section=$2
    local key
    [ $# -eq 3 ] && key=$3

    # This awk line turns ini sections => [section-name]key=value
    local lines=$(awk '/\[/{prefix=$0; next} $1{print prefix $0}' $inifile)
    lines=$(echo "$lines" | sed -e 's/[[:blank:]]*=[[:blank:]]*/=/g')
    while read -r line ; do
        if [[ "$line" = \[$section\]* ]]; then
            local keyval=$(echo "$line" | sed -e "s/^\[$section\]//")
            if [[ -z "$key" ]]; then
                echo $keyval
            else
                if [[ "$keyval" = $key=* ]]; then
                    echo $(echo $keyval | sed -e "s/^$key=//")
                fi
            fi
        fi
    done <<<"$lines"
}

FILE="simulation_Z0.cfg"
TOP_DIR="/data_fast/cnatzke/GammaGammaSurface145mm/Simulations"
RUN_DIR=$PWD
# parse ini file
Z=$(iniget $FILE simulation z)
A=$(iniget $FILE simulation a)
G1=$(iniget $FILE simulation g1)
G2=$(iniget $FILE simulation g2)


if [[ $# != 0 ]]; then
    echo "usage: move_root_files"
    exit 1
elif [[ ! -f $FILE ]]; then
    echo "Missing config file: $FILE"
    exit 2
else
    SIM_DIR="$TOP_DIR/z$Z.a$A/${G1}_${G2}"
    echo "Moving files to $SIM_DIR"
    for i in {0..4..2}; do
        TARGET_DIR="$SIM_DIR/Z$i"
        mkdir -p $TARGET_DIR/Raw $TARGET_DIR/Sorted
        mv g4out_Z${i}_0???.root $TARGET_DIR/Raw
        mv Converted_Z${i}_0???.root $TARGET_DIR/Sorted
        cp run_macro_Z$i.mac simulation_Z${i}.cfg $TARGET_DIR
    done

    # Check for missing/small files
    echo "Checking for missing files"
    cd $SIM_DIR
    /home/cnatzke/Projects/GammaGamma145mmSurface/SimulationUtilities/find_missing_files.sh
    cp missing_files.txt $RUN_DIR
    cd $RUN_DIR

fi
