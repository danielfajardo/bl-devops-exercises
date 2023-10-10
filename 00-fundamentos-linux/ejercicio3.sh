#!/bin/bash -e

USAGE_MSG='Please use the following syntax: ejercicio3.sh BASE_DIR FILE_CONTENT'
DEFAULT_CONTENT='Que me gusta la bash!!!!'

BASE_DIR=$1
FILE_CONTENT=${2:-${DEFAULT_CONTENT}}

# Control check
if [[ $# -lt 2 ]]; then
    echo "Error: Missing arguments. ${USAGE_MSG}"
    exit 1
elif [[ $# -gt 2 ]]; then
    echo "Error: Too many arguments. ${USAGE_MSG}"
    exit 1
fi

# Create folder structure based on BASE_DIR
mkdir -p ${BASE_DIR}/foo/{dummy,empty}/

# Create file1.txt based on FILE_CONTENT
echo ${FILE_CONTENT} > ${BASE_DIR}/foo/dummy/file1.txt

# Create empty file (although really unnecessary)
touch ${BASE_DIR}/foo/dummy/file2.txt

# Copy file1.txt content into file2.txt
cp ${BASE_DIR}/foo/dummy/file{1,2}.txt

# Move file2.txt into empty folder
mv ${BASE_DIR}/foo/{dummy,empty}/file2.txt

# Show tree
echo 'TREE STRUCTURE
--------------------' && tree --du -h

echo

# Show contents
echo 'FILES CONTENT
--------------------' && head -n -0 ${BASE_DIR}/foo/*/*.txt

