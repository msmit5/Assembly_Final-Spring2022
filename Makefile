ASSEMBLER=as
LINKER=ld
OBJDIR=obj
# make directory if not exit

main: $(OBJDIR) main.o printDecimal.o exit.o getLeadingZeros.o writeFloat.o getPart.o asciiToInt.o verifyInput.o strToFloat.o pow.o factorial.o cos.o deg2rad.o sin.o getDropTime.o parseNormal.o
	$(LINKER) obj/*.o -o main

$(OBJDIR):
	mkdir -p obj

getPart.o: src/getPart.s
	$(ASSEMBLER) src/getPart.s -o obj/getPart.o

main.o: src/main.s
	$(ASSEMBLER) src/main.s -o obj/main.o

printDecimal.o: src/printDecimal.s
	$(ASSEMBLER) src/printDecimal.s -o obj/printDecimal.o

exit.o: src/exit.s
	$(ASSEMBLER) src/exit.s -o obj/exit.o

getLeadingZeros.o: src/getLeadingZeros.s
	$(ASSEMBLER) src/getLeadingZeros.s -o obj/getLeadingZeros.o

writeFloat.o: src/write-float.s
	$(ASSEMBLER) src/write-float.s -o obj/writeFloat.o

asciiToInt.o: src/asciiToInt.s
	$(ASSEMBLER) src/asciiToInt.s -o obj/asciiToInt.o

verifyInput.o: src/verifyInput.s
	$(ASSEMBLER) src/verifyInput.s -o obj/verifyInput.o

strToFloat.o: src/strToFloat.s
	$(ASSEMBLER) src/strToFloat.s -o obj/strToFloat.o

pow.o: src/pow.s
	$(ASSEMBLER) src/pow.s -o obj/pow.o

factorial.o: src/factorial.s
	$(ASSEMBLER) src/factorial.s -o obj/factorial.o

cos.o: src/cos.s
	$(ASSEMBLER) src/cos.s -o obj/cos.o

sin.o: src/sin.s
	$(ASSEMBLER) src/sin.s -o obj/sin.o

deg2rad.o: src/deg2rad.s
	$(ASSEMBLER) src/deg2rad.s -o obj/deg2rad.o

getDropTime.o: src/getDropTime.s
	$(ASSEMBLER) src/getDropTime.s -o obj/getDropTime.o

parseNormal.o: src/parseNormal.s
	$(ASSEMBLER) src/parseNormal.s -o obj/parseNormal.o
