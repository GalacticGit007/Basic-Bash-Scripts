#! /bin/bash

# Qn Write a function-based script with getopts that accepts -f <file> and -v (verbose) flags, loops through the lines of the file, and counts word occurrences into an associative array. Print a sorted summary.

while getopts "f:v" opt
do

    case $opt in
        f) file=$OPTARG ;;
        v) verbose=true ;;
        *) echo "Invalid option: -$OPTARG" >&2

    esac

done

declare -A word_count

if [[ -z $file ]]; then
    echo "Usage: $0 -f <file> [-v]" >&2
    exit 1
fi

checkfile(){

    if [[ -f $file ]]; then
        if [[ $verbose = true ]]; then
            echo "[INFO] File $file exists."
        fi
    else
        echo "[ERROR] $file does not exist"
        exit 1
    fi
}
readfile(){
    word_count=()
    if [[ $verbose = true ]]; then
        echo "[INFO] Reading file $file."
    fi
    set -f
    while read -r line
    do
        for word in $line
        do
            word_count[$word]=$(( ${word_count[$word]:-0} +1 ))
        done
    done < "$file"
    set +f
    if [[ $verbose = true ]]; then
        echo "[INFO] Counting complete."
    fi
}

sortcount(){
    if [[ $verbose = true ]]; then
        echo "[INFO] Sorting results."
    fi
    sort_result=$(printf "%s\n" "${!word_count[@]}" | sort)
    echo -e "Word Occurences \n- - - - - - - -"
    set -f
    for key in $sort_result
    do
        echo "$key = ${word_count[$key]}"
    done
    set +f
}


checkfile
readfile
sortcount