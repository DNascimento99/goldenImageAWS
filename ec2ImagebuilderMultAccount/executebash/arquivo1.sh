#!/bin/bash
filename="meu_arquivo.txt"
touch $filename
if [ -f $filename ]; then
    echo "Arquivo $filename criado com sucesso."
else
    echo "Falha ao criar o arquivo $filename."
fi
