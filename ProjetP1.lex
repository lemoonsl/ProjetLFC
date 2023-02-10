%{
	//Compilation
	//lex -v exemple0.lex
	//gcc -Wall lex.yy.c -o analyseur -lfl
    #include <stdio.h>
%}
DATEH_EVT_UNIQUE [0-9]{8}"T"[0-9]{6}"Z"
POSITION_ALARME "-P"[0-9]"DT"[0-9]"H"[0-9]"M"[0-9]"S"
INTROH_DEBUT_EVT_REPETITIF "DTSTART;TZID="([a-zA-Z]+|"/")*":"
%%
{DATEH_EVT_UNIQUE} {printf("[date et heure evt unique]\n");}
{POSITION_ALARME} {printf("[position alarme]\n");}
{INTROH_DEBUT_EVT_REPETITIF} {printf("[intro heure début evt répétitif]\n");}

%%
int yywrap()
{
    return 1;
}