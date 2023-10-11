#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Se necesita un único argumento para ejecutar este script. Usa por ejemplo: ejercicio4.sh DevOps"
    exit 1
fi

readonly URL='https://lemoncode.net/bootcamp-devops#bootcamp-devops/inicio'
readonly FILE_NAME='bootcamp_devops_info.txt'
WORD=$1

curl -o $FILE_NAME -s $URL

OCCURRENCES=$(grep -o $WORD -n $FILE_NAME)

if [ $? -ne 0 ]; then
    echo "No se ha encontrado la palabra \"$WORD\"."
    exit 0
fi

NUM_OCURRENCES=$(echo "$OCCURRENCES" | wc -l)
FIRST_OCCURENCE=$(echo "$OCCURRENCES" | head -n 1)

echo "La palabra \"$WORD\" aparece $NUM_OCURRENCES veces."
echo "Aparece por primera vez en la línea ${FIRST_OCCURENCE%:*}."