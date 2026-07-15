#!/bin/bash

#Qn : Write a script that takes a filename as an argument, checks if it exists and is readable, and prints file size and last-modified date — or a clear error if it doesn't exist.

read -rp "Enter a filename: " filename

if [[ -e $filename ]]; then
 echo "$filename Exists"
 if [[ -r $filename ]]; then
    echo "Readable"
    echo "Size: $(ls -sh "$filename" | cut -d" " -f1)"
    echo "Last modified: $(stat -c %y "$filename" | cut -d" " -f1)"
 else
    echo "$filename is not readable"
fi
echo "Size: $(stat -c %s "$filename") bytes"
echo "Last modified: $(stat -c %y "$filename" | cut -d" " -f1)"
else
    echo "$filename does not exist"
fi
