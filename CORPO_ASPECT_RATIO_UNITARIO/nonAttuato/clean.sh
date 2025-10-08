#!/bin/bash

# =============================================================================
# Script di Pulizia SICURO per Caso OpenFOAM
# - Rimuove directory processor*
#!/bin/bash

# =============================================================================
# Script di Pulizia AGGRESSIVO per Caso OpenFOAM
# ATTENZIONE! RIMUOVE TUTTI I RISULTATI E FILE INTERMEDI:
# - Directory processor*
# - Directory logs
# - Directory postProcessing (!!! INCLUSI TUTTI I DATI DELLE FUNCTIONS !!!)
# - Directory dei timestep (TUTTE quelle numeriche tranne "0")
# - NON TOCCA constant/polyMesh, system/, o la cartella 0/
# =============================================================================

echo "--- Inizio Pulizia AGGRESSIVA Caso OpenFOAM ---"
echo "ATTENZIONE: Verranno rimossi TUTTI i risultati precedenti,"
echo "inclusa l'intera cartella 'postProcessing'!"


# Rimuovi le directory dei processori paralleli (se esistono)
echo "Rimozione directory processor* ..."
rm -rf processor*

# Rimuovi la directory dei log (se esiste) e ricreala vuota
echo "Rimozione e ricreazione directory logs ..."
rm -rf logs
mkdir logs

# RIMUOVI LA DIRECTORY postProcessing E TUTTO IL SUO CONTENUTO

echo "Rimozione directory postProcessing ..."
rm -rf postProcessing


# Rimuovi le directory dei timestep (tranne la cartella "0")
echo "Rimozione vecchie directory dei timestep (eccetto '0') ..."
rm -rf $(ls -d [1-9]* 2>/dev/null | grep '^[0-9][0-9]*$') # Interi > 0
rm -rf $(ls -d [0-9]*.[0-9]* 2>/dev/null) # Decimali

echo "--- Pulizia Aggressiva Completata ---"
echo "(Directory 'constant/polyMesh', 'system', '0' NON toccate)"

exit 0
