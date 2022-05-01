
# Compiladores
CC=g++
LEX=flex++

# Dependências
all: numtext

numtext: lex.yy.cc
	$(CC) lex.yy.cc -std=c++17 -o lexhtml

lex.yy.cc: lexhtml.l
	$(LEX) lexhtml.l

clean:
	rm lexhtml lex.yy.cc
