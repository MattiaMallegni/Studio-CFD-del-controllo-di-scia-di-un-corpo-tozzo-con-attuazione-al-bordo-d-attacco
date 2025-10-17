# Studio-CFD-del-controllo-di-scia-di-un-corpo-tozzo-con-attuazione-al-bordo-d-attacco

Questo repository contiene tutti i casi di simulazione OpenFOAM e gli script di post-processing utilizzati per il lavoro di tesi 
Simulazione LES Re=40000: U=0.4 m/s, ni=1e-5 m²/s, D=1 m, deltaT=0.0005s, durata=525s

## Prerequisiti Software

Per eseguire le simulazioni e le analisi sono necessari i seguenti software:
* **OpenFOAM v12**
* **ParaView 5.x**
* **Python 3.x** con le librerie `pandas`, `matplotlib` e `numpy`.

## Struttura del Repository

Il repository è organizzato come segue:
* **`CORPO_ASPECT_RATIO_UNITARIO`**: Contiene i casi di simulazione per il corpo con aspect-ratio unitario.
* **`CORPO_ALLUNGATO`**: Contiene i casi di simulazione per il corpo allungato.
* **`mesh/`**: Contiene i file `.geo` per la generazione delle mesh.
Le cartelle `CORPO_ASPECT_RATIO_UNITARIO`/`CORPO_ALLUNGATO` contengono due sottocartelle: **nonAttuato** (per simulare il caso non attuato) e **Attuato** (per simulare il caso attuato)

## Guida all'Esecuzione della simulazione

Per avviare la simulazione, è necessario posizionarsi nella cartella del caso di interesse ed eseguire
lo script run.sh. Sono tuttavia necessarie delle note preliminari:
* **Impostazione dei Processori**: Prima di avviare la simulazione, è necessario modificare il file run.sh, sostituendo il valore della variabile 'numberOfProcessors' con il numero di core
disponibili sul proprio computer. Lo stesso numero deve essere inserito anche nel parametro 'numberOfSubdomains', che si trova nel file system/decomposeParDict.
* **Variazione script di esecuzione**: Per il caso attuato il file run.sh è stato modificato in run1.sh, le struttura dei due file è sostanzialmente identica ma il secondo garantisce una
ricostruzione selettiva e più ottimizzata. In particolare run1.sh ricostruisce il campo di velocità (che è il più pesante) solamente da time step 340, questo perché l’attuazione rende
la simulazione molto pesante a causa delle condizioni al contorno presenti negli slot di attuazione, in cui vengono letti i valori di velocità da tabelle con dimensioni molto elevate.
* **Pulizia della Cartella**: Per eliminare i risultati di una simulazione e ripulire la cartella, è disponibile lo script clean.sh.

## Post-Processing

L'analisi dei dati è stata condotta tramite notebook Jupyter e script Python.
Grafici dei Coefficienti di Forza: Per la creazione dei grafici temporali di Cl e Cd, è stato utilizzato il file Jupyter Notebook CdeCl.ipynb. Analisi in Frequenza (FFT): per ottenere invece i grafici dell’analisi in frequenza sono presenti due file: ‘prepara_dati_fft.py’ e ‘fft_corretto1.py’.
‘prepara_dati_fft.py’ ha il compito di organizzare i dati forniti in output dalla funzione forceCoeffs, in particolare va a cercare il file postProcessing/forceCoeffs1/0/forceCoeffs.dat ed estrae la solo la colonna del tempo e del Cl, salvandola in un file ‘segnale_Cl.dat’.
Successivamente il file ‘fft_corretto1.py’ legge il file’ segnale_Cl.dat’ e lo filtra escludendo il transitorio iniziale (considera l’intervallo temporale da 160 a 525s), su questo segnale preparato, viene applicata la Trasformata Veloce di Fourier (FFT) per calcolarne lo spettro di potenza. Per praticità l'asse delle frequenze viene convertito da Hertz (Hz) al Numero di Strouhal adimensionale (St), utilizzando la velocità indisturbata (Uinf=0.4m/s) e la dimensione caratteristica del corpo (D=1.0m) definite nello script. Infine, lo script genera e salva automaticamente un'immagine in formato PNG contenente due grafici sovrapposti: in alto, l'andamento del Cl nel tempo (da 160s a 525s), e in basso, il corrispondente spettro di potenza in funzione del Numero di Strouhal.
