CC=g++
CFLAGS=-Wall
all: main.o bezierFun.o
	$(CC) $(CFLAGS) main.o -lSDL2 bezierFun.o -o bezier.o
Main.o: main.cpp
	$(CC) main.cpp -lSDL2 -c -o main.o
bezierFun.o: bezierFun.s
	nasm -f elf64 -o bezierFun.o bezierFun.s
clean:
	rm -f *.o
