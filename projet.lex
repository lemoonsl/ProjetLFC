%{
	//Compilation
	//lex -v exemple0.lex
	//gcc -Wall lex.yy.c -o analyseur -lfl


#include <stdio.h>

%}
%START VCVE EJ ER EU EUF ERF EJF ARM DATE DESC FQ VEVENT

DATEH_EVT_UNIQUE [0-9]{8}"T"[0-9]{6}"Z"
POSITION_ALARME "-P"[0-9]+"DT"[0-9]+"H"[0-9]+"M"[0-9]+"S"
INTROH_DEBUT_EVT_REPETITIF "DTSTART;TZID="([a-zA-Z]+|"/")*":"
INTROH_FIN_EVT_REPETITIF "DTEND;TZID="([a-zA-Z]+|"/")*":"
DATEH_EVT_REPETITIF [0-9]{8}"T"[0-9]{6}
NOMBRE_ENTIER [0-9]+
LISTE_JOURS(("MO"|"TU"|"WE"|"TH"|"FR"|"SA"|"SU"),)*("MO"|"TU"|"WE"|"TH"|"FR"|"SA"|"SU")
DATE_EVT_JOURNEE [0-9]{8}
FREQUENCE ("DAILY"|"MONTHLY"|"WEEKLY"|"YEARLY")

LIEU ([0-9]+" "([a-z]" ")*[a-z])"\,"[A-Z][a-z]*
DESCRIPTION([A-Za-z]" ")*[A-Za-z]
GLOBAL (LIEU | DESCRIPTION)
%%

BEGIN:VCALENDAR { printf("début calendrier \n");
} ;
END:VCALENDAR { printf("fin calendrier \n");
} ;
BEGIN:VEVENT { printf("début événement \n");
} ;
END:VEVENT { printf("fin événement \n");
} ;
DTSTART: { printf("intro heure début evt unique \n");
} ;
DTEND: { printf("intro heure fin evt unique \n");
} ;
SUMMARY: { printf("intro titre \n");
} ;
LOCATION: { printf("intro lieu \n");
} ;
DESCRIPTION: { printf("intro description \n");
} ;
BEGIN:VALARM { printf("début alarme \n");
} ;
END:VALARM { printf("fin alarme \n");
} ;
TRIGGER: { printf("intro position alarme \n");
} ;
RRULE: { printf("intro règle répétition \n");
} ;
FREQ= { printf("intro fréquence\n");
} ;
COUNT= { printf("intro compteur \n");
} ;
BYDAY= { printf("intro liste jours \n");
} ;
UNTIL= { printf("intro limite \n");
} ;
WKST=SU { printf("changement de semaine \n");
} ;
; { printf("séparateur d’options \n");
} ;
DTSTART;VALUE=DATE:  { printf("intro heure début evt journée \n");
} ;
DTEND;VALUE=DATE: { printf("intro heure fin evt journée \n");
} ;




{DATE_EVT_JOURNEE} {printf("date evt journée :%s\n",yytext);}

{DATEH_EVT_REPETITIF} {printf("date et heure evt répétitif %s\n",yytext);}

{DATEH_EVT_UNIQUE} {printf("date et heure evt unique :%s\n" ,yytext);}

{NOMBRE_ENTIER} {printf("nombre entier :%s\n",yytext);}

{POSITION_ALARME} {printf("position alarme :%s\n",yytext);}

{INTROH_DEBUT_EVT_REPETITIF} {printf("intro heure début evt répétitif \n");}

{INTROH_FIN_EVT_REPETITIF} {printf("intro heure fin evt répétitif \n");}

{FREQUENCE} {printf("fréquence:%s\n", yytext);}

{LISTE_JOURS} {printf("liste jours :%s\n",yytext);}

"BEGIN:VCALENDAR" {printf("debut calendrier\n"); BEGIN VCVE;}

<VCVE>.|\n|\t;
"BEGIN:VEVENT" {printf("debut évenement\n"); BEGIN DATE;}
<DATE>"DTSTART:" {printf("intro heure début evt unique\n"); BEGIN EU;}
"DTEND:" {printf("intro heure fin evt unique\n"); BEGIN EUF;}
"UNTIL=" {printf("intro limite\n"); BEGIN EU;}

"DTSTART;TZID="([A-Z][a-z]*("/"([A-Z][a-z]*(":")))) {printf("intro heure debut evt repetitif\n"); BEGIN ER;}
"DTEND;TZID="([A-Z][a-z]*("/"([A-Z][a-z]*(":")))) {printf("intro heure fin evt repetitif\n"); BEGIN ERF;}

"DTSTART;VALUE=DATE:" {printf("intro heure début evt journée\n"); BEGIN EJ;}
"DTEND;VALUE=DATE:" {printf("intro heure fin evt journée\n"); BEGIN EJF;}

<EJ>[0-9]{8} {printf("date evt journée: %s \n", yytext); BEGIN VCVE;}
<ER>[0-9]{8}("T"([0-9]{6})) {printf("date et heure evt repetitif: %s \n", yytext); BEGIN VCVE;}
<EU>[0-9]{8}\T[0-9]{6}\Z {printf("date et heure evt unique: %s \n", yytext); BEGIN VCVE;}
<EUF>[0-9]{8}\T[0-9]{6}\Z {printf("date et heure evt unique: %s \n", yytext); BEGIN VEVENT;}
<ERF>[0-9]{8}("T"([0-9]{6})) {printf("date et heure evt repetitif: %s \n", yytext); BEGIN VEVENT;}
<EJF>[0-9]{8} {printf("date evt journée: %s \n", yytext); BEGIN VEVENT;}
<DESC> {GLOBAL} {printf("Lieu, description ou titre \n"); BEGIN VCVE;}

<VEVENT>"DESCRIPTION:" {printf("intro description\n"); BEGIN DESC;}
<VCVE>"DESCRIPTION:" {BEGIN DESC;}

"LOCATION:" {printf("intro lieu\n");BEGIN DESC;}
"SUMMARY:" {printf("intro titre\n");BEGIN DESC;}

"END:VEVENT" {printf("fin événement\n");}

"BEGIN:VALARM" {printf("début alarme\n");}
"TRIGGER:" {printf("intro position alarme\n"); BEGIN ARM;}
<ARM>"-"([A-Z0-9]*) {printf("position alarme:%s \n", yytext); BEGIN VCVE;}

"END:VALARM" {printf("fin alarme\n");}

.|\n ;
%%
int main(){

yylex();
return 0;
}

int yywrap(){
return 1;
}