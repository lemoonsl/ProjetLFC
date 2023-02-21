%{
	//Compilation
	//lex -v exemple0.lex
	//gcc -Wall lex.yy.c -o analyseur -lfl

#include <stdio.h>

%}
DATEH_EVT_UNIQUE [0-9]{8}"T"[0-9]{6}"Z"
POSITION_ALARME "-P"[0-9]"DT"[0-9]"H"[0-9]"M"[0-9]"S"
INTROH_DEBUT_EVT_REPETITIF "DTSTART;TZID="([a-zA-Z]+|"/")*":"
INTROH_FIN_EVT_REPETITIF "DTEND;TZID="([a-zA-Z]+ |"/")*":"
DATEH_EVT_REPETITIF [0-9] {:} "T"[0-9] {6}
NOMBRE_ENTIER [0-9]+
LISTE_JOURS(("MO" | "TU" | "WE" | "TH" | "FR" | "SA" | "SU"),)*("MO" | "TU" | "WE" | "TH" | "FR" | "SA" | "SU")
DATE_EVT_JOURNEE [0-9] {8}
%%

BEGIN:VCALENDAR { printf("début calendrier \n");
} ;
END:VCALENDAR { printf("fin calendrier \n");
} ;
BEGIN:VEVENT { printf("début événement  \n");
} ;
END:VEVENT { printf("fin événement \n");
} ;
DTSTART: { printf("intro heure début evt unique  \n");
} ;
DTEND: { printf("intro heure fin evt unique   \n");
} ;
SUMMARY: { printf("intro titre    \n");
} ;
LOCATION: { printf("intro lieu   \n");
} ;
DESCRIPTION: { printf("intro description     \n");
} ;
BEGIN:VALARM { printf("début alarme \n");
} ;
END:VALARM { printf("fin alarme \n");
} ;
TRIGGER: { printf("intro position alarme      \n");
} ;
RRULE: { printf("intro règle répétition      \n");
} ;
FREQ= { printf("intro fréquence\n");
} ;
COUNT= { printf("intro compteur\n");
} ;
BYDAY= { printf("intro liste jours \n");
} ;
UNTIL= { printf("intro limite\n");
} ;
WKST=SU { printf("changement de semaine\n");
} ;
; { printf("séparateur d’options \n");
} ;
DTSTART;VALUE=DATE:  { printf("intro heure début evt journée\n");
} ;
DTEND;VALUE=DATE: { printf("intro heure fin evt journée \n");
} ;
.|\n ;



{DATEH_EVT_UNIQUE} {printf("[date et heure evt unique]\n");}

{POSITION_ALARME} {printf("[position alarme]\n");}

{INTROH_DEBUT_EVT_REPETITIF} {printf("[intro heure début evt répétitif]\n");}

{INTROH_FIN_EVT_REPETITIF} {printf("[intro heure fin evt répétitif]\n");}

{DATEH_EVT_REPETITIF} {printf("[date et heure evt répétitif]\n");}

{NOMBRE_ENTIER} {printf("[nombre entier]\n");}

{LISTE_JOURS} {printf("[liste jours]\n");}

{DATE_EVT_JOURNEE} {printf("[date evt journée]\n");}


%%
int main(){

yylex();
return 0;
}

int yywrap(){
return 1;
}
