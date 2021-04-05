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

CFG_FILE="simulation_Z0.cfg"
INPUT_FILE="missing_files.txt"
TOP_DIR="/data_fast/cnatzke/GammaGammaSurface145mm/Simulations"

# parse ini file
Z=$(iniget $CFG_FILE simulation z)
A=$(iniget $CFG_FILE simulation a)
G1=$(iniget $CFG_FILE simulation g1)
G2=$(iniget $CFG_FILE simulation g2)

TARGET_DIR="$TOP_DIR/z$Z.a$A/${G1}_${G2}"
Z0_COUNT=1000
Z2_COUNT=1000
Z4_COUNT=1000

if [[ $# != 0 ]]; then
    echo "usage: replace_bad_files"
    exit 1
elif [[ ! -e $CFG_FILE ]]; then
    echo "Missing config file: $CFG_FILE"
    exit 2
elif [[ ! -e $INPUT_FILE ]]; then
    echo "Missing data file: $INPUT_FILE"
    exit 2
else
    while IFS="," read -r z job; do
        RAW_TARGET="$TARGET_DIR/Z$z/Raw/g4out_Z${z}_$job.root"
        SORT_TARGET="$TARGET_DIR/Z$z/Sorted/Converted_Z${z}_$job.root"

        if [[ $z == '0' ]]; then
            #mv g4out_Z0_$Z0_COUNT.root $RAW_TARGET
            #mv Converted_Z0_$Z0_COUNT.root $SORT_TARGET
            Z0_COUNT=$(printf "%04d" $((10#$Z0_COUNT + 1 )))
        elif [[ $z == '2' ]]; then
            #mv g4out_Z2_$Z2_COUNT.root $RAW_TARGET
            #mv Converted_Z2_$Z2_COUNT.root $SORT_TARGET
            Z2_COUNT=$(printf "%04d" $((10#$Z2_COUNT + 1 )))
        elif [[ $z == '4' ]]; then
            #mv g4out_Z4_$Z4_COUNT.root $RAW_TARGET
            #mv Converted_Z4_$Z4_COUNT.root $SORT_TARGET
            Z4_COUNT=$(printf "%04d" $((10#$Z4_COUNT + 1 )))
        fi
    done < $INPUT_FILE
fi

echo "Z0: $(( $Z0_COUNT - 1000 )) file(s) replaced"
echo "Z2: $(( $Z2_COUNT - 1000 )) file(s) replaced"
echo "Z4: $(( $Z4_COUNT - 1000 )) file(s) replaced"
