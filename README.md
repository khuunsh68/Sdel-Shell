# Sdel-Shell
Projeto na área de Sistemas Operativos, programação em Shell!

Com este projeto, pretende-se implementar o comando sdel que permita que se apaguem ficheiros com segurança.
Ou seja, os ficheiros passados como argumento para o comando sdel não serão realmente apagados,
numa primeira fase, mas sim comprimidos, se já não o estiverem, e movidos para uma diretoria lixo
(~/.LIXO). O comando sdel tem a seguinte sintaxe:

          sdel [file ...] [-r dir] [-t num] [-s num] [-u] [-h]
![terminal-longshadow](https://user-images.githubusercontent.com/116800150/225991839-985f92a1-3ad4-4e8a-bbe7-300a3a4a6e8e.png)
