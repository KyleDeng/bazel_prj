# Makefile

all: main.out

main.out: main.cpp
	g++ $^ /usr/local/lib/libgmock.a /usr/local/lib/libgtest.a -std=c++11 -lpthread -o $@

run: main.out
	./$<

clean:
	rm *.out

.PHONY: all clean

