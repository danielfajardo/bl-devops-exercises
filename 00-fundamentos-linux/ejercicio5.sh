#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Se necesitan únicamente dos parámetros para ejecutar este script."
    exit 1
fi

URL=$1
WORD=$2
readonly FILE_NAME='bootcamp_devops_info.txt'

curl -o $FILE_NAME -s $URL

OCCURRENCES=$(grep -o $WORD -n $FILE_NAME)

if [ $? -ne 0 ]; then
    echo "No se ha encontrado la palabra \"$WORD\"."
    exit 0
fi

NUM_OCURRENCES=$(echo "$OCCURRENCES" | wc -l)
FIRST_OCCURENCE=$(echo "$OCCURRENCES" | head -n 1)

STR_VECES="veces"
STR_APARECE="por primera vez"


if [[ $NUM_OCURRENCES -eq 1 ]]; then
    STR_VECES="vez"
    STR_APARECE="únicamente"
fi

echo "La palabra \"$WORD\" aparece $NUM_OCURRENCES $STR_VECES."
echo "Aparece $STR_APARECE en la línea ${FIRST_OCCURENCE%:*}."