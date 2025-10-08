//================================================================================
// Gmsh Script: Dominio Completo Strutturato per Cilindro con Slot
// Risultato Atteso: AR ~ 85 
//==============================================================================

//------------------------------------------------------------------------------
// 1. PARAMETRI GLOBALI E GEOMETRICI
//------------------------------------------------------------------------------
// Questa sezione definisce le dimensioni base della geometria e le
// lunghezze caratteristiche per la densità della mesh nelle varie zone.

// Parametri Base Geometria
D = 1; // Dimensione caratteristica del corpo (larghezza/lunghezza)
r = 0.05*D; // Raggio degli spigoli arrotondati anteriori
G_angle_deg = 2.8; // Ampiezza angolare dello slot di attuazione (gradi)
G_angle_rad = G_angle_deg * Pi / 180.; // Ampiezza angolare slot (radianti)

// Parametri Dimensione Caratteristica Mesh (lunghezze target elementi)
lcBody = D / 80; // Dimensione celle target vicino al corpo
lcSlot = lcBody / 2; // Dimensione celle target vicino agli slot (più fine)
lcIntermediate = lcBody * 8; // Dimensione celle target nella zona intermedia
lcMax = D * 3; // Dimensione celle target nella zona esterna (lontana)

// Calcoli Geometrici Ausiliari per il Corpo (metà superiore)
cx = r; // Coordinata X del centro degli archi anteriori
cy_top = D/2 - r; // Coordinata Y del centro degli archi anteriori
angle_center_sup = 135 * Pi / 180; // Angolo centrale dell'arco sup. rispetto a asse X+
angle_half_slot = G_angle_rad / 2.0; // Metà angolo dello slot
angle_A1 = angle_center_sup - angle_half_slot; // Angolo inizio slot su arco sup.
angle_A = angle_center_sup + angle_half_slot; // Angolo fine slot su arco sup.

// Calcoli Geometria Box Intermedio ("small_sq")
// Usato per creare una zona di transizione della mesh
W_half_domain = 10.5*D; // Semi-altezza totale del dominio
Width_orig = 2 * W_half_domain; // Altezza totale dominio = 21*D
Width_small_sq = Width_orig / 5.0; // Larghezza/Altezza del box intermedio = 4.2*D
Half_Width_small_sq = Width_small_sq / 2.0; // Semi-lato box intermedio = 2.1*D
X_center_body = 0.5*D; // Coordinata X del centro del corpo (per centrare il box)
Y_center_body = 0; // Coordinata Y del centro del corpo
Xmin_small_sq = X_center_body - Half_Width_small_sq; // Coordinata X minima box intermedio
Xmax_small_sq = X_center_body + Half_Width_small_sq; // Coordinata X massima box intermedio
Ymax_small_sq = Half_Width_small_sq; // Coordinata Y massima box intermedio (semi-altezza)

// Calcoli Geometria Box Esterno ("large_rect")
L_upstream = 6*D; // Distanza inlet dal corpo
L_downstream = 25*D; // Distanza outlet dal corpo 
Xmin_large_rect = -L_upstream; // Coordinata X minima dominio (inlet)
Xmax_large_rect = L_downstream; // Coordinata X massima dominio (outlet)
Ymax_large_rect = W_half_domain; // Coordinata Y massima dominio (topWall)

//------------------------------------------------------------------------------
// 2. PUNTI (Metà Dominio Superiore y>=0)
//------------------------------------------------------------------------------
// Definizione dei punti geometrici chiave, specificando la dimensione
// caratteristica della mesh locale desiderata (lc...) vicino a quel punto.

// Punti Corpo Centrale (Prefisso 1xx) - Definiscono il profilo del cilindro + slot
Point(104) = {cx, cy_top, 0, lcBody}; // Centro arco sup
Point(103) = { D, D/2, 0, lcBody}; // Spigolo posteriore sup
Point(114) = { 0, cy_top, 0, lcBody}; // Punto su asse x=0 sul lato sup
Point(113) = { cx, D/2, 0, lcBody}; // Punto su lato sup al termine dell'arco
Point(121) = {cx + r*Cos(angle_A1), cy_top + r*Sin(angle_A1), 0, lcSlot}; // Inizio slot sup
Point(122) = {cx + r*Cos(angle_A),  cy_top + r*Sin(angle_A),  0, lcSlot}; // Fine slot sup

// Punti Box Intermedio (Prefisso 3xx) - Definiscono gli angoli e punti chiave del box intermedio
Point(303) = {Xmax_small_sq, Ymax_small_sq, 0, lcIntermediate}; // Angolo sup-dx
Point(304) = {Xmin_small_sq, Ymax_small_sq, 0, lcIntermediate}; // Angolo sup-sx
Point(314) = {Xmin_small_sq, 0.9, 0, lcIntermediate};     // Punto manuale su lato sx
Point(351) = {Xmin_small_sq, 1.4136, 0, lcIntermediate};    // Punto manuale su lato sx
Point(352) = {Xmin_small_sq, 1.3316, 0, lcIntermediate};    // Punto manuale su lato sx

// Punti Box Esterno (Prefisso 6xx) - Definiscono gli angoli e punti chiave del box esterno (dominio)
Point(603) = {Xmax_large_rect, Ymax_large_rect, 0, lcMax}; // Angolo sup-dx (outlet-top)
Point(604) = {Xmin_large_rect, Ymax_large_rect, 0, lcMax}; // Angolo sup-sx (inlet-top)
Point(614) = {Xmin_large_rect, 0.9, 0, lcMax};     // Punto su lato sx (inlet)
Point(651) = {Xmin_large_rect, 1.4136, 0, lcMax};    // Punto su lato sx (inlet)
Point(652) = {Xmin_large_rect, 1.3316, 0, lcMax};    // Punto su lato sx (inlet)
Point(655) = {Xmin_large_rect, Ymax_small_sq, 0, lcMax}; // Punto su lato sx (inlet) all'altezza Ymax intermedio
Point(623) = {Xmax_large_rect, Ymax_small_sq, 0, lcMax}; // Punto su lato dx (outlet) all'altezza Ymax intermedio
Point(643) = {Xmax_small_sq, Ymax_large_rect, 0, lcMax}; // Punto su lato sup (topWall) alla Xmax intermedia
Point(600) = {Xmin_small_sq, Ymax_large_rect, 0, lcMax}; // Punto su lato sup (topWall) alla Xmin intermedia

// Punti Asse Simmetria y=0 (Prefisso 901-906) - Definiscono i punti chiave sull'asse y=0
Point(901) = {0, 0, 0, lcBody}; // Origine parte anteriore corpo
Point(902) = {D, 0, 0, lcBody}; // Origine parte posteriore corpo
Point(903) = {Xmin_small_sq, 0, 0, lcIntermediate}; // Intersezione asse Y=0 con Xmin intermedio
Point(904) = {Xmax_small_sq, 0, 0, lcIntermediate}; // Intersezione asse Y=0 con Xmax intermedio
Point(905) = {Xmin_large_rect, 0, 0, lcMax}; // Angolo inf-sx (inlet-bottom)
Point(906) = {Xmax_large_rect, 0, 0, lcMax}; // Angolo inf-dx (outlet-bottom)

// Punti Aggiunti Manualmente (Prefisso 907-915) - Usati per strutturare meglio la mesh
Point(907) = {Xmin_small_sq, 1.3755, 0, lcIntermediate}; // Punto intermedio sx
Point(908) = {Xmin_large_rect, 1.3755, 0, lcMax}; // Punto su inlet
P121x = cx + r*Cos(angle_A1); P121y = cy_top + r*Sin(angle_A1);
P122x = cx + r*Cos(angle_A);  P122y = cy_top + r*Sin(angle_A);
Point(909) = {(P121x+P122x)/2, (P121y+P122y)/2, 0, lcSlot}; // Punto centrale slot sup
Point(910) = {X_center_body, D/2, 0, lcBody}; // Punto centrale lato superiore corpo
Point(911) = {X_center_body, Ymax_small_sq, 0, lcIntermediate}; // Punto centrale lato superiore box intermedio
Point(912) = {X_center_body, Ymax_large_rect, 0, lcMax}; // Punto centrale lato superiore box esterno (topWall)
Point(913) = {13.8, 0, 0, lcIntermediate}; // Punto su asse Y=0 nella scia
Point(914) = {13.8, Ymax_small_sq, 0, lcIntermediate}; // Punto alla X di 913, su Ymax intermedio
Point(915) = {13.8, Ymax_large_rect, 0, lcMax}; // Punto alla X di 913, su Ymax esterno (topWall)


//------------------------------------------------------------------------------
// 3. CURVE (Metà Dominio Superiore y>=0)
//------------------------------------------------------------------------------
// Definizione delle linee e degli archi che collegano i punti definiti sopra.
// Line = linea retta tra due punti. Circle = arco tra due punti passante per un centro.

// --- Curve del Corpo (2xx) e Slot (210, 1001) ---
Line(206) = {114, 901}; // Lato anteriore su asse x=0
Circle(205) = {122, 104, 114}; // Arco anteriore (dopo slot)
Circle(204) = {121, 104, 113}; // Arco anteriore (prima slot)
Line(202) = {103, 902}; // Lato posteriore (base)
Line(210) = {909, 121}; // Metà sinistra slot superiore
Line(1001) = {909, 122}; // Metà destra slot superiore

// --- Linee radiali: Corpo -> Box Intermedio (4xx) ---
Line(404) = {114, 314}; // Da lato ant a box interm
Line(413) = {113, 304}; // Da fine arco a box interm
Line(406) = {103, 303}; // Da lato post a box interm
Line(451) = {121, 351}; // Da inizio slot a box interm
Line(452) = {122, 352}; // Da fine slot a box interm
Line(491) = {901, 903}; // Da origine ant a asse y=0 interm
Line(492) = {902, 904}; // Da origine post a asse y=0 interm

// --- Linee Box Intermedio (5xx) ---
Line(503) = {904, 303}; // Lato dx
Line(506) = {351, 304}; // Parte lato sup sx
Line(508) = {352, 314}; // Parte lato sup sx
Line(509) = {314, 903}; // Lato sx inf
Line(599) = {903, 901}; // Asse y=0 tra corpo e box interm
Line(598) = {902, 904}; // Asse y=0 tra corpo e box interm
Line(507) = {907, 351}; // Collegamento punti manuali
Line(504) = {304, 911}; // Metà lato superiore
Line(1005) = {303, 911}; // Metà lato superiore

// --- Linee radiali: Box Intermedio -> Box Esterno (7xx) ---
Line(704) = {314, 614}; Line(711) = {351, 651}; Line(712) = {352, 652}; Line(734) = {304, 655}; Line(743) = {303, 643}; Line(700) = {304, 600}; Line(791) = {903, 905}; // Asse y=0
Line(792) = {904, 913}; // Asse y=0 (fino a x=13.8)
Line(723) = {303, 914}; // Fino a x=13.8

// --- Linee Box Esterno (8xx) ---
Line(805) = {906, 623}; // Lato dx (outlet) inf
Line(807) = {623, 603}; // Lato dx (outlet) sup
Line(810) = {600, 604}; // Lato sup (topWall) sx
Line(811) = {655, 604}; // Lato sx (inlet) sup 
Line(812) = {604, 655}; // Lato sx (inlet) sup
Line(813) = {651, 655}; // Lato sx (inlet)
Line(815) = {652, 614}; // Lato sx (inlet)
Line(816) = {614, 905}; // Lato sx (inlet) inf
Line(899) = {905, 903}; // Asse y=0 (inlet -> interm)
Line(898) = {913, 906}; // Asse y=0 (x=13.8 -> outlet)
Line(814) = {908, 651}; // Collegamento punti manuali
Line(809) = {643, 912}; // Metà lato sup (topWall)
Line(808) = {643, 915}; // Linea a x=13.8 verso topWall

// --- Linee Aggiuntive per Struttura (9xx, 10xx) ---
Line(299) = {901, 902}; // Base corpo (su asse y=0)
Line(900) = {909, 907}; Line(901) = {907, 908}; Line(1003) = {908,652}; Line(1002) = {907, 352}; Line(1004) = {911, 912}; Line(1009) = {913, 914}; Line(1010) = {914, 915}; Line(1006) = {912, 600}; Line(1007) = {910, 911}; Line(203) = {113, 910}; Line(1008) = {103, 910}; Line(1013) = {913, 906}; // Asse y=0 (x=13.8 -> outlet) -
Line(1011) = {914, 623}; Line(1012) = {915, 603};


//------------------------------------------------------------------------------
// 4. SURFACES (Metà Dominio Superiore y>=0)
//------------------------------------------------------------------------------
// Definizione delle superfici piane 2D usando i 'Curve Loop'.
// Un Curve Loop è un elenco ordinato di ID di Curve (Line o Circle).
// Il segno '-' prima di un ID indica che la curva va percorsa in direzione opposta.
// Ogni Plane Surface(ID) = {Loop_ID}; definisce una superficie delimitata da quel loop.
// I commenti indicano approssimativamente la posizione della superficie.

// --- Anello Esterno (Tra Box Esterno e Intermedio) ---
Curve Loop(1) = {816, -791, -509, 704};       Plane Surface(1) = {1}; // Anteriore Sinistro Inferiore
Curve Loop(2) = {815, -704, -508, 712};       Plane Surface(2) = {2}; // Anteriore Sinistro Mediano 1
Curve Loop(15) = {1003, -712, -1002, 901};    Plane Surface(15) = {15}; // Anteriore Sinistro Mediano 2 (vicino slot)
Curve Loop(16) = {-814, -901, 507, 711};      Plane Surface(16) = {16}; // Anteriore Sinistro Mediano 3 (vicino slot)
Curve Loop(4) = {-813, -711, 506, 734};       Plane Surface(4) = {4}; // Anteriore Sinistro Superiore
Curve Loop(23) = {811, -810, -700, 734};      Plane Surface(23) = {23}; // Superiore Sinistro
Curve Loop(21) = {700, -1006, -1004, -504};   Plane Surface(21) = {21}; // Superiore Centrale Sinistro
Curve Loop(22) = {1004, -809, -743, 1005};    Plane Surface(22) = {22}; // Superiore Centrale Destro
Curve Loop(25) = {743, 808, -1010, -723};     Plane Surface(25) = {25}; // Superiore Destro (fino a x=13.8)
Curve Loop(26) = {1010, 1012, -807, -1011};   Plane Surface(26) = {26}; // Posteriore Destro Superiore (da x=13.8)
Curve Loop(27) = {1009, 1011, -805, -898};    Plane Surface(27) = {27}; // Posteriore Destro Inferiore (da x=13.8)
Curve Loop(24) = {503, 723, -1009, -792};     Plane Surface(24) = {24}; // Inferiore Destro (fino a x=13.8)

// --- Anello Interno (Tra Box Intermedio e Corpo) ---
Curve Loop(7) = {509, -491, -206, 404};       Plane Surface(7) = {7}; // Anteriore Sinistro Inferiore (vicino corpo)
Curve Loop(8) = {508, -404, -205, 452};       Plane Surface(8) = {8}; // Anteriore Sinistro Mediano 1 (vicino corpo)
Curve Loop(17) = {1002, -452, -1001, 900};    Plane Surface(17) = {17}; // Attorno allo Slot Superiore (dx)
Curve Loop(18) = {-507, -900, 210, 451};      Plane Surface(18) = {18}; // Attorno allo Slot Superiore (sx)
Curve Loop(10) = {-506, -451, 204, 413};      Plane Surface(10) = {10}; // Anteriore Sinistro Superiore (vicino corpo)
Curve Loop(19) = {413, 504, -1007, -203};     Plane Surface(19) = {19}; // Superiore Sinistro (vicino corpo)
Curve Loop(20) = {1007, -1005, -406, 1008};   Plane Surface(20) = {20}; // Superiore Destro (vicino corpo)
Curve Loop(13) = {406, -503, -492, -202};     Plane Surface(13) = {13}; // Posteriore (vicino corpo)

// Lista superfici originali (da duplicare) - Mantenuta dall'originale
original_surfaces[] = {1, 2, 4, 7, 8, 10, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27};

//------------------------------------------------------------------------------
// 5. MIRRORING DELLA GEOMETRIA ACROSS Y=0 (XZ PLANE)
//------------------------------------------------------------------------------
// Specchia tutte le superfici definite sopra rispetto al piano XZ (y=0)
// per creare la metà inferiore del dominio.
Symmetry {0, 1, 0, 0} {
  Duplicata{ Surface{original_surfaces[]}; }
}

//------------------------------------------------------------------------------
// 6. RECUPERA LISTA SUPERFICI TOTALI (POST MIRRORING)
//------------------------------------------------------------------------------
// Recupera gli ID di TUTTE le superfici definite (originali + specchiate)
// Utile per applicare Transfinite/Recombine a tutte.
all_surfaces_list[] = Surface{:};
Printf("INFO: Total number of surfaces (original + mirrored) = %g", #all_surfaces_list[]);


//------------------------------------------------------------------------------
// 7. DEFINIZIONE GRUPPI FISICI 2D (CURVE DI CONTORNO)
//------------------------------------------------------------------------------
// Assegna nomi e tag numerici ai gruppi di CURVE che definiranno i bordi 3D.
// Questi nomi verranno usati da gmshToFoam/gambitToFoam per creare le patch nel file 'boundary'.
// IMPORTANTE: Definiti PRIMA della Sezione 9/10 perché la logica Transfinite
// può dipendere da queste definizioni (anche se qui non sembra usata).

Physical Curve("inlet", 1) = {811, 813, 814, 1003, 815, 816, 1015, 1020, 1050, 1055, 1025, 1090}; // Patch di ingresso
Physical Curve("outlet", 2) = {807, 805, 1112, 1107}; // Patch di uscita
Physical Curve("topWall", 3) = {810, 1006, 809, 808, 1012}; // Patch superiore (simmetria o slip)
Physical Curve("bottomWall", 4) = {1091, 1081, 1086, 1101, 1106}; // Patch inferiore (simmetria o slip)
Physical Curve("bodyWall", 5) = {203, 1008, 202, 1048, 1078, 1073, 1032, 206, 1037, 1042, 204, 205}; // Pareti del corpo solido
Physical Curve("actuatorSlots", 6) = {210, 1001, 1062, 1067}; // Zone degli slot per attuazione

//------------------------------------------------------------------------------
// 8. DEFINIZIONE BOUNDARY LAYER FIELD
//------------------------------------------------------------------------------
// *** SEZIONE RIMOSSA ***

//------------------------------------------------------------------------------
// 9. DISCRETIZZAZIONE BORDI (TRANSFINITE CURVE)
//------------------------------------------------------------------------------
// Imposta il numero di nodi (N) e la progressione (p) per ciascuna curva.
// 'Transfinite Curve {ID} = N Using Progression p;'
// N = numero di nodi lungo la curva (crea N-1 segmenti/celle)
// p = fattore di crescita geometrica. p > 1 -> celle piccole all'inizio, grandi alla fine.
//     p = 1 -> celle di dimensione uniforme. p < 1 -> celle grandi all'inizio, piccole alla fine.
// Le impostazioni qui definiscono la densità della mesh lungo i bordi dei blocchi.

// 9.1 Definizioni per Curve Originali (y>=0)
Transfinite Curve {205} = 20 Using Progression 1.18;
Transfinite Curve {508} = 20 Using Progression 1.08;
Transfinite Curve {815} = 20 Using Progression 1.08;
Transfinite Curve {204} = 20 Using Progression 1.18;
Transfinite Curve {506} = 20 Using Progression 1.13;
Transfinite Curve {813} = 20 Using Progression 1.13;
Transfinite Curve {210} = 6 Using Progression 1;
Transfinite Curve {1001} = 6 Using Progression 1;
Transfinite Curve {507} = 6 Using Progression 1;
Transfinite Curve {1002} = 6 Using Progression 1;
Transfinite Curve {814} = 6 Using Progression 1;
Transfinite Curve {1003} = 6 Using Progression 1;
Transfinite Curve {451} = 35 Using Progression 1.18;
Transfinite Curve {413} = 35 Using Progression 1.18;
Transfinite Curve {452} = 35 Using Progression 1.18;
Transfinite Curve {404} = 35 Using Progression 1.18;
Transfinite Curve {491} = 35 Using Progression 1.18; // Su asse y=0
Transfinite Curve {900} = 35 Using Progression 1.18;
Transfinite Curve {406} = 35 Using Progression 1.18;
Transfinite Curve {206} = 40 Using Progression 1.03;
Transfinite Curve {509} = 40 Using Progression 0.97;
Transfinite Curve {816} = 40 Using Progression 0.97;
Transfinite Curve {711} = 11 Using Progression 1.1;
Transfinite Curve {734} = 11 Using Progression 1.1;
Transfinite Curve {712} = 11 Using Progression 1.1;
Transfinite Curve {901} = 11 Using Progression 1.1;
Transfinite Curve {704} = 11 Using Progression 1.1;
Transfinite Curve {791} = 11 Using Progression 1.1; // Su asse y=0
Transfinite Curve {202} = 30 Using Progression 1.06;
Transfinite Curve {503} = 30;
Transfinite Curve {1009} = 30;
Transfinite Curve {492} = 35 Using Progression 1.18; // Su asse y=0
Transfinite Curve {811} = 25 Using Progression 1.1;
Transfinite Curve {203} = 25 Using Progression 1.08;
Transfinite Curve {504} = 25 Using Progression 1;
Transfinite Curve {743} = 25 Using Progression 1.1;
Transfinite Curve {1007} = 35 Using Progression 1.18;
Transfinite Curve {1010} = 25 Using Progression 1.1;
Transfinite Curve {807} = 25 Using Progression 1.1;
Transfinite Curve {810} = 11 Using Progression 1.1;
Transfinite Curve {700} = 25 Using Progression 1.1;
Transfinite Curve {1008} = 25 Using Progression 1.08;
Transfinite Curve {1005} = 25 Using Progression 1;
Transfinite Curve {1004} = 25 Using Progression 1.1;
Transfinite Curve {1006} = 25 Using Progression 1;
Transfinite Curve {809} = 25 Using Progression 1;
Transfinite Curve {805} = 30;
Transfinite Curve {723} = 20 Using Progression 1.05;
Transfinite Curve {792} = 20 Using Progression 1.05; // Su asse y=0
Transfinite Curve {808} = 20 Using Progression 1.05;
Transfinite Curve {898} = 8 Using Progression 1.13;  // Su asse y=0
Transfinite Curve {1011} = 8 Using Progression 1.13;
Transfinite Curve {1012} = 8 Using Progression 1.13;

// 9.2 Definizioni per Curve Specchiate (y<0) - Da IDs GUI
Transfinite Curve {1037} = 20 Using Progression 1/1.18; // Mirror di 205
Transfinite Curve {1022} = 20 Using Progression 1/1.08; // Mirror di 508
Transfinite Curve {1020} = 20 Using Progression 1.08; // Mirror di 815
Transfinite Curve {1042} = 20 Using Progression 1.18; // Mirror di 204
Transfinite Curve {1027} = 20 Using Progression 1.13; // Mirror di 506
Transfinite Curve {1025} = 20 Using Progression 1/1.13; // Mirror di 813 
Transfinite Curve {1067} = 6 Using Progression 1; // Mirror di 210
Transfinite Curve {1062} = 6 Using Progression 1/1; // Mirror di 1001
Transfinite Curve {1057} = 6 Using Progression 1; // Mirror di 507
Transfinite Curve {1052} = 6 Using Progression 1/1; // Mirror di 1002
Transfinite Curve {1055} = 6 Using Progression 1/1; // Mirror di 814
Transfinite Curve {1050} = 6 Using Progression 1; // Mirror di 1003
Transfinite Curve {1041} = 35 Using Progression 1/1.18; // Mirror di 451
Transfinite Curve {1043} = 35 Using Progression 1.18; // Mirror di 413
Transfinite Curve {1038} = 35 Using Progression 1.18; // Mirror di 452
Transfinite Curve {1033} = 35 Using Progression 1.18; // Mirror di 404
// Transfinite Curve {491} = 31 Using Progression 1.18; // Su asse - NON DUPLICARE
Transfinite Curve {1063} = 35 Using Progression 1.18; // Mirror di 900
Transfinite Curve {1045} = 35 Using Progression 1.18; // Mirror di 406
Transfinite Curve {1032} = 40 Using Progression 1/1.03; // Mirror di 206
Transfinite Curve {1017} = 40 Using Progression 1/0.97; // Mirror di 509
Transfinite Curve {1015} = 40 Using Progression 0.97; // Mirror di 816
Transfinite Curve {1026} = 11 Using Progression 1/1.1; // Mirror di 711 
Transfinite Curve {1028} = 11 Using Progression 1.1; // Mirror di 734
Transfinite Curve {1023} = 11 Using Progression 1.1; // Mirror di 712
Transfinite Curve {1053} = 11 Using Progression 1.1; // Mirror di 901
Transfinite Curve {1018} = 11 Using Progression 1.1; // Mirror di 704
// Transfinite Curve {791} = 11 Using Progression 1.1; // Su asse - NON DUPLICARE
Transfinite Curve {1048} = 30 Using Progression 1/1.06; // Mirror di 202
Transfinite Curve {1046} = 30;                       // Mirror di 503
Transfinite Curve {1097} = 30;                       // Mirror di 1009
// Transfinite Curve {492} = 31 Using Progression 1.18; // Su asse - NON DUPLICARE
Transfinite Curve {1090} = 25 Using Progression 1.1; // Mirror di 811
Transfinite Curve {1073} = 25 Using Progression 1/1.08; // Mirror di 203
Transfinite Curve {1071} = 25 Using Progression 1;  // Mirror di 504
Transfinite Curve {1087} = 25 Using Progression 1/1.1; // Mirror di 743
Transfinite Curve {1072} = 35 Using Progression 1/1.18; // Mirror di 1007
Transfinite Curve {1102} = 25 Using Progression 1/1.1; // Mirror di 1010
Transfinite Curve {1107} = 25 Using Progression 1/1.1; // Mirror di 807
Transfinite Curve {1091} = 11 Using Progression 1/1.1; // Mirror di 810
Transfinite Curve {1080} = 25 Using Progression 1.1; // Mirror di 700
Transfinite Curve {1078} = 25 Using Progression 1.08; // Mirror di 1008
Transfinite Curve {1076} = 25 Using Progression 1;  // Mirror di 1005
Transfinite Curve {1082} = 25 Using Progression 1/1.1; // Mirror di 1004
Transfinite Curve {1081} = 25 Using Progression 1;  // Mirror di 1006
Transfinite Curve {1086} = 25 Using Progression 1;  // Mirror di 809
Transfinite Curve {1112} = 30;                       // Mirror di 805
Transfinite Curve {1096} = 20 Using Progression 1.05; // Mirror di 723
// Transfinite Curve {792} = 20 Using Progression 1.05; // Su asse - NON DUPLICARE
Transfinite Curve {1101} = 20 Using Progression 1.05; // Mirror di 808
// Transfinite Curve {898} = 8 Using Progression 1.13;  // Su asse - NON DUPLICARE
Transfinite Curve {1108} = 8 Using Progression 1/1.13; // Mirror di 1011
Transfinite Curve {1106} = 8 Using Progression 1.13; // Mirror di 1012



//------------------------------------------------------------------------------
// 10. APPLICA TRANSFINITE E RECOMBINE ALLE SUPERFICI 2D
//------------------------------------------------------------------------------
// Applica l'algoritmo Transfinite per mappare la griglia dai bordi all'interno
// e Recombine per forzare la creazione di quadrilateri invece che triangoli.
// Questo crea la mesh 2D strutturata.
For i In {0:#all_surfaces_list[]-1}
  Transfinite Surface{ all_surfaces_list[i] };
  Recombine Surface{ all_surfaces_list[i] };
EndFor

//-------------------------------------
// 11. ESTRUSIONE A SINGOLO LAYER (2.5D)
//-------------------------------------
// Estrude la mesh 2D lungo l'asse Z per creare un volume 3D
// spesso una sola cella (Layers{1}). Recombine tenta di mantenere esaedri.
Z_thickness = D * 0.1;
out[] = Extrude {0, 0, Z_thickness} {
  Surface{all_surfaces_list[]};
  Layers{1};
  Recombine;
};

//-------------------------------------
// 12. GRUPPI FISICI 3D (Mantenendo gli ID forniti dall'utente)
//-------------------------------------
// Assegna nomi e tag numerici ai gruppi di SUPERFICI 3D create dall'estrusione.
// Questi nomi verranno usati da gmshToFoam per creare le patch nel file 'boundary'.
// !!! ATTENZIONE: GLI ID NUMERICI QUI DEVONO CORRISPONDERE A QUELLI REALI POST-ESTRUSIONE !!!
// !!!           Verificarli con la GUI di Gmsh aprendo il file .msh generato !!!
// Assegna anche un nome e un tag al volume creato.

// Volume
all_volumes_created[] = Volume{:};
Physical Volume("Volume", 100) = {all_volumes_created[]}; // Zona cellulare

// Superfici di Contorno
Physical Surface("inlet", 1) = {1451, 1165, 1297, 1275, 1143, 1121, 1561, 1583, 1715, 1737, 1605, 1891};
Physical Surface("outlet", 2) = {1525, 1547, 1987, 1965};
Physical Surface("topWall", 3) = {1455, 1411, 1433, 1499, 1521};
Physical Surface("bottomWall", 4) = {1895, 1851, 1873, 1939, 1961};
Physical Surface("bodyWall", 5) = {1397, 1375, 1265, 1705, 1837, 1815, 1635, 1195, 1679, 1657, 1239, 1217};
Physical Surface("actuatorSlots", 6) = {1789, 1767, 1349, 1327};
Physical Surface("frontAndBack", 7) = {1464, 1420, 1442, 1508, 1530, 1552, 1486, 1376, 1398, 1266, 1178, 1156, 1134, 1574, 1596, 1618, 1904, 1860, 1882, 1926, 1948, 1706, 1838, 1816, 1970, 1992, 1200, 1640, 1662, 1684, 1244, 1222, 1728, 1750, 1310, 1288, 17, 1354, 18, 1332, 1772, 1794, 1064, 1059, 1089, 1079, 1084, 1099, 1094, 1109, 1104, 26, 27, 24, 25, 22, 21, 23, 4, 1, 2, 1014, 1024, 1019, 1044, 13, 20, 19, 1074, 1069, 1039, 1034, 1029, 7, 10, 8, 15, 16, 1049, 1054}; // Include le facce 2D originali e le facce laterali estruse? Controllare!

//-------------------------------------
// 13. GENERAZIONE MESH 3D
//-------------------------------------
// Comando finale per generare la mesh volumetrica
Mesh 3;
//+
Show "*";
//+
Show "*";
