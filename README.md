# Sdel-Shell
Projeto na área de Sistemas Operativos, programação em Shell!

Com este projeto, pretende-se implementar o comando sdel que permita que se apaguem ficheiros com segurança.
Ou seja, os ficheiros passados como argumento para o comando sdel não serão realmente apagados,
numa primeira fase, mas sim comprimidos, se já não o estiverem, e movidos para uma diretoria lixo
(~/.LIXO). O comando sdel tem a seguinte sintaxe:

          sdel [file ...] [-r dir] [-t num] [-s num] [-u] [-h]
