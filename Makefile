
CC = gcc

p1: ttyecho.o
	$(CC) -o ttyecho ttyecho.o

p1.o: ttyecho.c
	$(CC) -c ttyecho.c

