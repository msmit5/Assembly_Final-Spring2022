ASSEMBLER=as
LINKER=ld

test: test.o exit.o vi.o
	$(LINKER) obj/* -o test

vi.o: verifyInput.s
	$(ASSEMBLER) verifyInput.s -o obj/vi.o

test.o: test.s
	$(ASSEMBLER) test.s -o obj/test.o

exit.o: exit.s
	$(ASSEMBLER) exit.s -o obj/exit.o

