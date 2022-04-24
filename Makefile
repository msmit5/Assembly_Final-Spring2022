##
# Project 4 and 5 Makefile
#
# @file
# @version 0.1

ASSEMBLER=as
LINKER=ld
OBJ := $(shell find obj/* -type f)

main: main.o
	$(LINKER) obj/main.o -o main

main.o: src/main.s
	$(ASSEMBLER) src/main.s -o obj/main.o

exit.o: src/exit.s
	$(ASSEMBLER) src/exit.s -o obj/exit.o
# end
