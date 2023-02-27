CC=gcc
ASMBIN=nasm

all : asm cc link
asm : 
	$(ASMBIN) -o decode.o -f elf -g -l decode.lst decode.asm
cc :
	$(CC) -m32 -c -g -O0 main.c &> errors.txt
link :
	$(CC) -m32 -g -o test main.o decode.o
clean :
	rm *.o
	rm test
	rm errors.txt	
	rm decode.lst
