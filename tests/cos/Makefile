ASSEMBLER=as
LINKER=ld

test: test.o pd.o exit.o glz.o wf.o gp.o atoi.o vi.o stf.o pow.o fac.o cos.o d2r.o sin.o
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

atoi.o: asciiToInt.s
	$(ASSEMBLER) asciiToInt.s -o obj/atoi.o

vi.o: verifyInput.s
	$(ASSEMBLER) verifyInput.s -o obj/vi.o

stf.o: strToFloat.s
	$(ASSEMBLER) strToFloat.s -o obj/stf.o

pow.o: pow.s
	$(ASSEMBLER) pow.s -o obj/pow.o

fac.o: factorial.s
	$(ASSEMBLER) factorial.s -o obj/fac.o

cos.o: cos.s
	$(ASSEMBLER) cos.s -o obj/cos.o

sin.o: sin.s
	$(ASSEMBLER) sin.s -o obj/sin.o

d2r.o: deg2rad.s
	$(ASSEMBLER) deg2rad.s -o obj/d2r.o
