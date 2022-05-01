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
%x 								TEXT
%x 								COMMENT

whitespaces            			[ \t\n]+
letter                 			[a-z]
upercaseletters        			[A-Z]
number                 			[0-9]
char                   			.+
parenttags             			html|head|style|title|h[1-6]|body|p|b|i|table|tr|th|td|ul|li|a
childlesstags          			br|img|!DOCTYPE
attrs                  			{letter}+[{number}{letter}]*(=\".*\")?
opentag                			\<{parenttags}(" "{attrs}*)?\>
closetag               			<\/{parenttags}\>
childlesstag           			\<{childlesstags}(" "{attrs}*)?\>

%%
"<!--"							{ BEGIN COMMENT; }
<COMMENT>\n						{ lines++; }
<COMMENT>"-->"					{ BEGIN INITIAL; }
<COMMENT>.						{ ; }
[ \t]                           { ; }
\n                              { lines++; }
{opentag}                       { printtabs(); cout << YYText() << endl; tabs++; charcount += YYLeng(); }
{closetag}                      { tags++; tabs--; charcount += YYLeng(); printtabs(); cout << YYText() << endl; }
{childlesstag}                  { printtabs(); cout << YYText() << endl; tags++; charcount += YYLeng(); }
.                               { BEGIN TEXT; currentcharcount++; }
<TEXT>{opentag}					{ yyless(0); handlecurrentcharcount(); BEGIN INITIAL; }
<TEXT>{closetag}				{ yyless(0); handlecurrentcharcount(); BEGIN INITIAL; }
<TEXT>{childlesstag}			{ yyless(0); handlecurrentcharcount(); BEGIN INITIAL; }
<TEXT>"<!--"					{ yyless(0); BEGIN INITIAL; }
<TEXT>\n						{ lines++; }
<TEXT>.							{ currentcharcount++; charcount++; }
%%

void handlecurrentcharcount() {
	printtabs();
	cout << "Texto[" << currentcharcount << ']' << endl;
	currentcharcount = 0;
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

	cout << endl << "TAGS: " << tags << endl;
	cout << "CHARS: " << charcount << endl;
	cout << "LINES: " << lines << endl;
    
	fin.close();
	return 0;
}