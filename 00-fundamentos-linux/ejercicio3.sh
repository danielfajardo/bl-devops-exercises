#!/bin/bash -e

DEFAULT_CONTENT='Que me gusta la bash!!!!'

FILE_CONTENT=${1:-${DEFAULT_CONTENT}}

# Control check
if [[ $# -ne 1 ]]; then
    echo "Error: Bad arguments. Please use the following syntax: ejercicio3.sh FILE_CONTENT"
    exit 1
fi

# Create folder structure
mkdir -p foo/{dummy,empty}/

# Create file1.txt based on FILE_CONTENT
echo ${FILE_CONTENT} > foo/dummy/file1.txt

# Create empty file
touch foo/dummy/file2.txt

# Copy file1.txt content into file2.txt
cat foo/dummy/file1.txt > foo/dummy/file2.txt

# Move file2.txt into empty folder
mv foo/{dummy,empty}/file2.txt

# Show tree
echo 'TREE STRUCTURE
--------------------' && tree --du -h

echo

# Show contents
echo 'FILES CONTENT
--------------------' && head -n -0 foo/*/*.txt

