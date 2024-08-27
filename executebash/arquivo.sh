#!/bin/bash
filename="meu_arquivo1.txt"
touch $filename
if [ -f $filename ]; then
    echo "Arquivo $filename criado com sucesso."
else
    echo "Falha ao criar o arquivo $filename."
fi
