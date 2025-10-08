#!/bin/bash

# =============================================================================
# Script per Esecuzione Parallela Completa OpenFOAM 
# 1. Pulisce le run parallele precedenti
# 2. Decompone il dominio
# 3. Esegue la simulazione in parallelo
# 4. Ricostruisce i risultati
# 5. Apre ParaView in background
# =============================================================================

# --- Impostazioni Modificabili ---
numberOfProcessors=8 # 
# Usa il comando foamRun per OF12+
solverToRun="foamRun -solver incompressibleFluid" 
logDir="logs" # Nome directory per i log
# ------------------------------

# Crea nomi file di log 
runLog="$logDir/log.foamRun"
decomposeLog="$logDir/log.decomposePar"
reconstructLog="$logDir/log.reconstructPar"
checkMeshLog="$logDir/log.checkMesh" # Log separato per checkMesh

echo "### Inizio Script Esecuzione Parallela OpenFOAM (12 Core) ###"

# 1. Crea directory per i log (ignora errore se esiste già)
echo "1. Creazione directory $logDir ..."
mkdir -p "$logDir"
echo "   Directory logs pronta."

# 2. Pulisci esecuzioni parallele precedenti e log vecchi
echo "2. Pulizia esecuzioni parallele precedenti (processor* e log vecchi)..."
# Se vuoi ripartire da una run interrotta, commenta la riga seguente:
rm -rf processor*
rm -f "$runLog" "$decomposeLog" "$reconstructLog" "$checkMeshLog"
echo "   Pulizia completata."

# --- Controllo Mesh (Importata) ---
# Si assume che la mesh sia già presente in constant/polyMesh
echo "3. Controllo la mesh esistente (checkMesh)..."
checkMesh > "$checkMeshLog" 2>&1
# Controlla lo stato di uscita di checkMesh
if [ $? -ne 0 ]; then
    echo "   ATTENZIONE: checkMesh ha riportato errori. Controlla '$checkMeshLog'."
    # Potresti voler uscire qui se la mesh non è valida:
    # read -p "Mesh non valida. Premi Ctrl+C per uscire o Invio per tentare comunque..."
fi
echo "   CheckMesh completato. Controlla l'output in '$checkMeshLog'"
# Ho rimosso la pausa interattiva 'read -p', se la rivuoi decommentala:
# read -p "Premi Invio per continuare se la mesh è OK, altrimenti Ctrl+C per uscire..."
echo "======================================="

# --- Decomposizione del Dominio ---
echo "4. Decompongo il dominio per $numberOfProcessors processori (decomposePar)..."
# '-force' sovrascrive eventuali directory processor* rimaste
decomposePar -force > "$decomposeLog" 2>&1

# Controllo errore base su decomposePar
if [ $? -ne 0 ]; then
  echo "   ERRORE: decomposePar fallito. Controlla il file '$decomposeLog'. Script interrotto."
  exit 1
fi
echo "   Decomposizione completata. Log in '$decomposeLog'"
echo "======================================="

# --- Esecuzione Simulazione Parallela ---
echo "5. Eseguo la simulazione con $solverToRun su $numberOfProcessors core..."
echo "   L'output e gli errori verranno mostrati qui sotto E salvati in '$runLog'"
echo "   ======================================================================"
echo "   ===> NOTA: Per monitorare l'avanzamento in tempo reale, apri      <==="
echo "   ===> un ALTRO terminale e digita: tail -f $runLog              <==="
echo "   ======================================================================"

# Esegui mpirun, usa la variabile solverToRun e tee per vedere l'output e salvarlo
mpirun -np $numberOfProcessors $solverToRun -parallel 2>&1 | tee "$runLog"

# Controlla l'exit status del comando mpirun/foamRun
simExitStatus=${PIPESTATUS[0]}

# Verifica se la simulazione è fallita
if [ $simExitStatus -ne 0 ]; then
    echo "!!! ERRORE: Il comando mpirun/$solverToRun è terminato con stato $simExitStatus. Controlla l'output sopra e il log '$runLog'. !!!"
fi
echo "Simulazione (o tentativo) completata. Controlla l'output sopra e in '$runLog'"
echo "======================================="

#-----------------------------------------------------------------------
# SCRIPT PER LA RICOSTRUZIONE SELETTIVA E OTTIMIZZATA DEI DATI OpenFOAM
# Esegue reconstructPar in 3 passaggi per accelerare il processo.
# Creato il: 08/09/2025
#-----------------------------------------------------------------------

echo "### Inizio Script di Ricostruzione Selettiva ###"
echo "============================================================"

# Passaggio 1: Ricostruzione dei campi medi finali (UMean, pMean).
# Questa operazione è molto veloce.
echo "--- Passaggio 1/3: Ricostruzione dei campi medi finali (UMean, pMean)... ---"
reconstructPar -latestTime -fields '(UMean pMean)'
echo "Completato."
echo "============================================================"

# Passaggio 2: Ricostruzione del campo di pressione istantaneo (p) per tutti i tempi.
# Anche questa operazione è relativamente veloce.
echo "--- Passaggio 2/3: Ricostruzione del campo di pressione istantaneo (p)... ---"
reconstructPar -fields '(p)'
echo "Completato."
echo "============================================================"

# Passaggio 3: Ricostruzione del campo di velocità istantaneo (U) solo per la fase attuata.
# Questo è il passaggio che prima era lento, ora è mirato solo all'intervallo t > 340s.
echo "--- Passaggio 3/3: Ricostruzione della velocità (U) per la fase attuata (t > 340s)... ---"
reconstructPar -fields '(U)' -time '340:'
echo "Completato."
echo "============================================================"

echo "### Ricostruzione selettiva completata con successo! ###"
