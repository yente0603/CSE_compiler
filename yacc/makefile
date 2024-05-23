all: clean y.tab.c lex.yy.c
	gcc lex.yy.c y.tab.c -lfl -o b096060041.out
y.tab.c:
	bison -y -d -Wcounterexamples b096060041.y
lex.yy.c:
	flex b096060041.l
clean:
	rm -rf b096060041.out lex.yy.c y.tab.c y.tab.h
