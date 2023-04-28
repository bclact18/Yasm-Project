#user can use tab to include .asm or without
VAR=${1%.*}

yasm -g dwarf2 -f elf64 $VAR.asm -l $VAR.lst && ld -g -o $VAR $VAR.o

