ASSEMBLER=as
LINKER=ld

test: test.o pd.o exit.o glz.o wf.o gp.o
	$(LINKER) obj/* -o test

gp.o: getPart.s
	$(ASSEMBLER) getPart.s -o obj/gp.o

test.o: test.s
	$(ASSEMBLER) test.s -o obj/test.o

pd.o: printDecimal.s
	$(ASSEMBLER) printDecimal.s -o obj/pd.o

exit.o: exit.s
	$(ASSEMBLER) exit.s -o obj/exit.o

glz.o: getLeadingZeros.s
	$(ASSEMBLER) getLeadingZeros.s -o obj/glz.o

wf.o: write-float.s
	$(ASSEMBLER) write-float.s -o obj/wf.o
