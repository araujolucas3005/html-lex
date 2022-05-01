%{
// Exemplo de reconhecimento de números e texto 
#include <iostream>
#include <fstream>
using namespace std;

unsigned tabs = 0;
unsigned tags = 0;
unsigned charcount = 0;
unsigned currentcharcount = 0;
unsigned lines = 1;

void printtabs();
void handlecurrentcharcount();
%}

%option noyywrap

whitespaces            [ \t\n]+
letter                 [a-z]
upercaseletters        [A-Z]
number                 [0-9]
char                   .+
parenttags             html|head|style|title|h[1-6]|body|p|b|i|table|tr|th|td|ul|li|a
childlesstags          br|img
attrs                  {letter}+[{number}{letter}]*=\".*\"
opentag                \<{parenttags}(" "{attrs}*)?\>
closetag               <\/{parenttags}\>
childlesstag           \<{childlesstags}(" "{attrs}*)?\>

%%
[ \t]                           { ; }
\n                              { lines++; }
{opentag}                       { handlecurrentcharcount(); printtabs(); cout << YYText() << endl; tabs++; charcount += YYLeng(); }
{closetag}                      { tags++; handlecurrentcharcount(); tabs--; charcount += YYLeng(); printtabs(); cout << YYText() << endl; }
{childlesstag}                  { handlecurrentcharcount(); printtabs(); cout << YYText() << endl; tags++; charcount += YYLeng();  }
.                               { currentcharcount++; }
%%

void handlecurrentcharcount() {
    if (currentcharcount > 0) {
        printtabs();
        cout << "Texto[" << currentcharcount << ']' << endl;
        currentcharcount = 0;
    }
}

void printtabs() {
    for (int i = 0; i < tabs; i++) {
        cout << "|\t";
    }

    cout << "+--";
}

int main(int argc, char ** argv)
{
	yyFlexLexer lexer;
	ifstream fin;

	if (argc > 1) 
	{    
		fin.open(argv[1]);
		if (!fin.is_open()) 
        {
			cout << "Arquivo " << argv[1] << " não pode ser aberto!\n";
			exit(EXIT_FAILURE);
		}
		else
		{
			// altera entrada para arquivo aberto
			lexer.switch_streams(&fin);
		}
	}

	lexer.yylex();
    
	fin.close();
	return 0;
}