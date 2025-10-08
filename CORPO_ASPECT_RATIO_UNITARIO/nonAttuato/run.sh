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

echo "### Inizio Script Esecuzione Parallela OpenFOAM (8 Core) ###"

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

# --- Ricostruzione dei Risultati ---
# Esegui solo se la simulazione non è fallita subito
if [ $simExitStatus -eq 0 ]; then
    echo "6. Ricostruisco i risultati dai processori (reconstructPar)..."
    # Ricostruisce tutti i timestep salvati (rimosso -latestTime)
    reconstructPar > "$reconstructLog" 2>&1

    # Controllo errore base su reconstructPar
    if [ $? -ne 0 ]; then
      echo "   ATTENZIONE: reconstructPar fallito. Controlla '$reconstructLog'."
    else
      echo "   Ricostruzione completata. Log in '$reconstructLog'"
    fi
    echo "======================================="

    # --- Pulizia Cartelle Processori (Opzionale) ---
    # Decommenta se vuoi cancellare le cartelle processor* dopo la ricostruzione
    # echo "7. Rimuovo le cartelle temporanee dei processori (processor*)..."
    # rm -r processor*
    # echo "   Pulizia completata."
    # echo "======================================="
else
    echo "### Simulazione fallita, Ricostruzione e Pulizia saltate. Controllare i log e l'output del terminale. ###"
fi

# 8. Apertura automatica di ParaView con paraFoam (in background)
echo "8. Avvio di ParaView (paraFoam) in background..."
paraFoam & # <-- Aggiunto '&' per non bloccare lo script

echo "### Script Terminato ###"

exit 0
