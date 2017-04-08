test: scanner
	./scanner < myTest/1.c
lex.yy.c: scanner.l
	flex scanner.l
scanner: lex.yy.c
	gcc lex.yy.c -o scanner
clean:
	rm -f scanner lex.yy.c