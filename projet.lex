%{
	//Compilation
	//lex -v exemple0.lex
	//gcc -Wall lex.yy.c -o analyseur -lfl


#include <stdio.h>

%}

DATEH_EVT_UNIQUE [0-9]{8}"T"[0-9]{6}"Z"
POSITION_ALARME "-P"[0-9]+"DT"[0-9]+"H"[0-9]+"M"[0-9]+"S"
INTROH_DEBUT_EVT_REPETITIF "DTSTART;TZID="([a-zA-Z]+|"/")*":"
INTROH_FIN_EVT_REPETITIF "DTEND;TZID="([a-zA-Z]+|"/")*":"
DATEH_EVT_REPETITIF [0-9]{8}"T"[0-9]{6}
NOMBRE_ENTIER [0-9]+
LISTE_JOURS(("MO"|"TU"|"WE"|"TH"|"FR"|"SA"|"SU"),)*("MO"|"TU"|"WE"|"TH"|"FR"|"SA"|"SU")
DATE_EVT_JOURNEE [0-9]{8}
FREQUENCE ("DAILY"|"MONTHLY"|"WEEKLY"|"YEARLY")

%START EJ ER EU EUF ERF EJF ARM DATE DESC VEVENT
%%
<EJ>[0-9]{8} {printf("date evt journée: %s \n", yytext); BEGIN 0;}
<ER>[0-9]{8}("T"([0-9]{6})) {printf("date et heure evt repetitif: %s \n", yytext); BEGIN 0;}
<EU>[0-9]{8}\T[0-9]{6}\Z {printf("date et heure evt unique: %s \n", yytext); BEGIN 0;}
<EUF>[0-9]{8}\T[0-9]{6}\Z {printf("date et heure evt unique: %s \n", yytext); BEGIN VEVENT;}
<ERF>[0-9]{8}("T"([0-9]{6})) {printf("date et heure evt repetitif: %s \n", yytext); BEGIN VEVENT;}
<EJF>[0-9]{8} {printf("date evt journée: %s \n", yytext); BEGIN VEVENT;}
<DATE>"DTSTART:" {printf("intro heure début evt unique\n"); BEGIN EU;}
<ARM>"-"([A-Z0-9]*) {printf("position alarme:%s \n", yytext); BEGIN 0;}
<VEVENT>"DESCRIPTION:" {printf("intro description\n"); BEGIN DESC;}
<DESC>(([0-9]+(" "[a-zéèàëêöôâ]+)+)"\\, "[A-Za-zéèàëêöôâ]+)|(([A-Za-zéèàëêöôâ]+" ")*[A-Za-zéèàëêöôâ]+)|""/. {printf("Lieu, description ou titre : %s \n", yytext); BEGIN 0;}



BEGIN:VCALENDAR { printf("début calendrier \n"); BEGIN 0;} 
END:VCALENDAR { printf("fin calendrier \n");}
BEGIN:VEVENT { printf("début événement \n"); BEGIN DATE;}
END:VEVENT { printf("fin événement \n");}
DTSTART: { printf("intro heure début evt unique \n");}
DTEND: { printf("intro heure fin evt unique \n"); BEGIN EUF;}
SUMMARY: { printf("intro titre \n"); BEGIN DESC;}
LOCATION: {printf("intro lieu\n");BEGIN DESC;}
DESCRIPTION: { printf("intro description \n"); BEGIN DESC;}
BEGIN:VALARM { printf("début alarme \n");}
END:VALARM { printf("fin alarme \n");}
TRIGGER: { printf("intro position alarme \n"); BEGIN ARM;}
RRULE: { printf("intro règle répétition \n");}
FREQ= { printf("intro fréquence\n");}
COUNT= { printf("intro compteur \n");}
BYDAY= { printf("intro liste jours \n");}
UNTIL= { printf("intro limite \n");  BEGIN EU;}
WKST=SU { printf("changement de semaine \n");}
; { printf("séparateur options \n");}
DTSTART;VALUE=DATE:  { printf("intro heure début evt journée \n"); BEGIN EJ;}
DTEND;VALUE=DATE: { printf("intro heure fin evt journée \n"); BEGIN EJF;}
DTSTART;TZID=([A-Z][a-z]*("/"([A-Z][a-z]*(":")))) {printf("intro heure debut evt repetitif\n"); BEGIN ER;}
DTEND;TZID=([A-Z][a-z]*("/"([A-Z][a-z]*(":")))) {printf("intro heure fin evt repetitif\n"); BEGIN ERF;}


{DATE_EVT_JOURNEE} {printf("date evt journée :%s\n",yytext);}
{DATEH_EVT_REPETITIF} {printf("date et heure evt répétitif %s\n",yytext);}
{DATEH_EVT_UNIQUE} {printf("date et heure evt unique :%s\n" ,yytext);}
{POSITION_ALARME} {printf("position alarme :%s\n",yytext);}
{INTROH_DEBUT_EVT_REPETITIF} {printf("intro heure début evt répétitif \n");}
{INTROH_FIN_EVT_REPETITIF} {printf("intro heure fin evt répétitif \n");}
{FREQUENCE} {printf("fréquence:%s\n", yytext);}
{LISTE_JOURS} {printf("liste jours :%s\n",yytext);}
{NOMBRE_ENTIER} {printf("nombre entier :%s\n",yytext);}



.|\n ;
%%
int main(){

yylex();
return 0;
}

int yywrap(){
return 1;
}