/********************************************************
 * systdynam_lexical_analizer.l 
 ********************************************************/
%{
#include "parser.tab.h"
#include <iostream>
#include<string.h>
using namespace std;
%}

%option noyywrap

%%


[(]         { yylval.sym = yytext[0];   return OFNT; }
[)]         { yylval.sym = yytext[0];   return CFNT; }
[\-|\+]     { yylval.sym = yytext[0];   return OPA;  }
[\*|/]      { yylval.sym = yytext[0];   return OPA1; }
[,]         { yylval.sym = yytext[0];   return MORE; }
[=]         { yylval.sym = yytext[0];   return EQL;  }

[0-9]+[.]?[0-9]*     { strcpy(yylval.val, yytext);  return NUM;     }
[a-z][a-z0-9]*       { strcpy(yylval.val, yytext);  return VAR;     }
[a-z][a-z0-9]*[']    { strcpy(yylval.val, yytext);  return DEQQ;    }
[a-z][a-z0-9]*[_][0] { strcpy(yylval.val, yytext);  return INITALC; }


"Sistem:"       {  return STRT;     }
"Parameters:"   {  return STRPAR;   }
"InitialC:"     {  return STRINI;   }

"ti:"           {  return TI;       }
"tf:"           {  return TF;       }
"dt:"           {  return DT;       }
"inputs:"       {  return NINPUT;   }
"outputs:"      {  return NOUTPUT;  }
"input_scale::" {  return IN_SCALE; }
"output_scale:" {  return OUT_SCALE;}
"#"             {  return INPUT_ID; }
"$"             {  return OUTPUT_ID;}

";"             {  return STOP;     }

<<EOF>>     { return 0; }
[ \t\n]+    { }
.           { cerr << "Warning: unknown Token!" << endl; exit(1); }

%% 


