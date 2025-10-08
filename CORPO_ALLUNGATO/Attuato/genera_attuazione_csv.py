#------------------------------------------------------------------------------
# SCRIPT PYTHON PER LA GENERAZIONE DEI FILE CSV DI ATTUAZIONE
#------------------------------------------------------------------------------
# Questo script calcola le componenti della velocità (Ux, Uy, Uz) nel tempo
# per due slot di attuazione (superiore e inferiore) basandosi sui parametri
# ottimali (Best Drag Reduction - BDR) definiti nel paper di Minelli et al. (2020).
# I dati vengono salvati in due file CSV separati, pronti per essere letti
# dalla condizione al contorno 'tableFile' di OpenFOAM.
#------------------------------------------------------------------------------

# 1. IMPORTAZIONE DELLE LIBRERIE NECESSARIE
#------------------------------------------------------------------------------
import numpy as np  # Libreria per calcoli numerici, specialmente per creare array (vettori/matrici) e funzioni matematiche.
import pandas as pd # Libreria per la manipolazione e analisi di dati; qui usata per creare e salvare facilmente i file CSV.
import math         # Libreria matematica standard di Python, usata qui per convertire gradi in radianti e per le funzioni trigonometriche (cos, sin).

#------------------------------------------------------------------------------
# 2. DEFINIZIONE DEI PARAMETRI DELL'ATTUAZIONE E DELLA SIMULAZIONE
#------------------------------------------------------------------------------

# Parametri dimensionali dell'attuazione, derivati dai valori adimensionali BDR
# del paper (F1+=0.42, F2+=0.63, A1+=0.45, A2+=0.04) e scalati usando:
# - Velocità del flusso indisturbato (U_inf): 0.4 m/s
# - Dimensione caratteristica del corpo (D): 1.0 m
# La formula del segnale di attuazione è: U_afc(t) = A1_dim * sin(2*pi*f1_dim*t) + A2_dim * sin(2*pi*f2_dim*t)

A1_dim = 0.18  # Ampiezza (m/s) della prima componente sinusoidale del segnale (A1+ * U_inf)
A2_dim = 0.016 # Ampiezza (m/s) della seconda componente sinusoidale del segnale (A2+ * U_inf)
f1_dim = 0.168 # Frequenza (Hz) della prima componente sinusoidale (F1+ * U_inf / D)
f2_dim = 0.252 # Frequenza (Hz) della seconda componente sinusoidale (F2+ * U_inf / D)

# Parametri per la simulazione e la generazione del file CSV
endTime = 525       # Tempo finale della simulazione (secondi), deve corrispondere a 'endTime' nel controlDict di OpenFOAM.

# Passo temporale per la scrittura dei dati nel file CSV (secondi).
# PER ALTA PRECISIONE:
# Questo valore DEVE essere MINORE del 'deltaT' usato nella simulazione OpenFOAM.
# Esempio: se il deltaT della simulazione è 0.0005 s, un valore buono qui potrebbe essere 0.0001 s.
# Un valore più piccolo produce file CSV più grandi ma fornisce una descrizione più fine del segnale
# per l'interpolazione da parte di OpenFOAM.
time_step_file = 0.00025 # Esempio: 0.25 millisecondi. Modifica questo valore secondo le tue necessità.

# Nomi dei file CSV di output
output_csv_filename_top = "actuation_data_top.csv"      # Per lo slot di attuazione superiore
output_csv_filename_bottom = "actuation_data_bottom.csv" # Per lo slot di attuazione inferiore

# Angoli di direzione del getto di attuazione (NORMALMENTE alla superficie dello slot)
# rispetto all'asse x positivo (direzione del flusso principale).
# Basato sull'interpretazione del paper (slot a 45 gradi, getto normale).
angle_top_deg = 135.0    # Angolo in gradi per il getto dello slot superiore (es. punta in alto a sinistra)
angle_bottom_deg = 225.0 # Angolo in gradi per il getto dello slot inferiore (es. punta in basso a sinistra, per simmetria)

# Conversione degli angoli in radianti, necessari per le funzioni trigonometriche di Python
angle_top_rad = math.radians(angle_top_deg)
angle_bottom_rad = math.radians(angle_bottom_deg)

# Calcolo dei coseni e seni direttori per scomporre la velocità
cos_angle_top = math.cos(angle_top_rad)        # Componente x normalizzata per lo slot superiore (circa -0.7071)
sin_angle_top = math.sin(angle_top_rad)        # Componente y normalizzata per lo slot superiore (circa +0.7071)
cos_angle_bottom = math.cos(angle_bottom_rad)  # Componente x normalizzata per lo slot inferiore (circa -0.7071)
sin_angle_bottom = math.sin(angle_bottom_rad)  # Componente y normalizzata per lo slot inferiore (circa -0.7071)

#------------------------------------------------------------------------------
# 3. GENERAZIONE DEI DATI TEMPORALI
#------------------------------------------------------------------------------

# Creazione di un array (una sequenza) di istanti di tempo da 0 fino a endTime,
# con passi definiti da time_step_file.
# Usiamo np.linspace per garantire che l'ultimo punto (endTime) sia incluso
# e per avere un controllo preciso sul numero di punti.
num_steps = math.ceil(endTime / time_step_file) # Numero di intervalli. Aggiungiamo 1 per il numero di punti.
times = np.linspace(0, endTime, num_steps + 1)  # Array degli istanti di tempo

# Inizializzazione di liste vuote per contenere i dati [tempo, Ux, Uy, Uz]
# che verranno poi usate per creare i file CSV.
data_for_csv_top = []
data_for_csv_bottom = []

# Stampa a schermo dei parametri usati, per verifica da parte dell'utente
print(f"Generazione dei file CSV per l'attuazione BDR in corso...")
print(f"Parametri del segnale:")
print(f"  A1 = {A1_dim} m/s, f1 = {f1_dim} Hz")
print(f"  A2 = {A2_dim} m/s, f2 = {f2_dim} Hz")
print(f"Parametri del file CSV:")
print(f"  Tempo finale: {endTime} s")
print(f"  Passo temporale nel CSV: {time_step_file} s (Numero di righe dati: {len(times)})")
print(f"Direzione getto slot superiore: {angle_top_deg} gradi (cos: {cos_angle_top:.4f}, sin: {sin_angle_top:.4f})")
print(f"Direzione getto slot inferiore: {angle_bottom_deg} gradi (cos: {cos_angle_bottom:.4f}, sin: {sin_angle_bottom:.4f})")

#------------------------------------------------------------------------------
# 4. CICLO PRINCIPALE: CALCOLO DELLE VELOCITÀ E POPOLAMENTO DELLE LISTE
#------------------------------------------------------------------------------
# Itera su ogni istante di tempo 't' nell'array 'times'.
for t in times:
    # Calcola la magnitudine istantanea del segnale di attuazione U_afc(t)
    # usando la formula del paper (Eq. 2.1).
    u_afc_magnitude = (A1_dim * np.sin(2.0 * np.pi * f1_dim * t) +
                       A2_dim * np.sin(2.0 * np.pi * f2_dim * t))

    # --- Dati per lo SLOTT SUPERIORE ---
    # Scompone la magnitudine u_afc_magnitude nelle componenti Ux, Uy, Uz
    # usando i coseni e seni direttori calcolati per lo slot superiore.
    vx_top = u_afc_magnitude * cos_angle_top  # Componente x della velocità
    vy_top = u_afc_magnitude * sin_angle_top  # Componente y della velocità
    vz_top = 0.0                              # Componente z è zero (simulazione 2D/2.5D)
    # Aggiunge la riga [tempo, Ux, Uy, Uz] alla lista per lo slot superiore
    data_for_csv_top.append([t, vx_top, vy_top, vz_top])

    # --- Dati per lo SLOT INFERIORE ---
    # Scompone la magnitudine u_afc_magnitude nelle componenti Ux, Uy, Uz
    # usando i coseni e seni direttori calcolati per lo slot inferiore.
    vx_bottom = u_afc_magnitude * cos_angle_bottom # Stessa componente x dello slot superiore se gli angoli sono simmetrici rispetto all'asse x del getto
    vy_bottom = u_afc_magnitude * sin_angle_bottom # Componente y opposta rispetto allo slot superiore (se gli angoli sono simmetrici)
    vz_bottom = 0.0                                # Componente z è zero
    # Aggiunge la riga [tempo, Ux, Uy, Uz] alla lista per lo slot inferiore
    data_for_csv_bottom.append([t, vx_bottom, vy_bottom, vz_bottom])

#------------------------------------------------------------------------------
# 5. SCRITTURA DEI FILE CSV
#------------------------------------------------------------------------------
# Definisce l'intestazione (nomi delle colonne) per i file CSV.
header_columns = ['time', 'Ux', 'Uy', 'Uz']

# Blocco try-except per gestire eventuali errori durante la scrittura dei file.
try:
    # --- Scrittura file per lo SLOT SUPERIORE ---
    # Crea un DataFrame (struttura dati tabellare) di Pandas usando i dati raccolti.
    df_actuation_top = pd.DataFrame(data_for_csv_top, columns=header_columns)
    # Salva il DataFrame in un file CSV.
    # - index=False: non scrive l'indice del DataFrame nel file CSV.
    # - float_format='%.8g': formatta i numeri in virgola mobile con 8 cifre significative
    #   in modo compatto (notazione scientifica se necessario, o decimale).
    df_actuation_top.to_csv(output_csv_filename_top, index=False, float_format='%.8g')
    print(f"\nOK: File CSV '{output_csv_filename_top}' generato con successo.")

    # --- Scrittura file per lo SLOT INFERIORE ---
    df_actuation_bottom = pd.DataFrame(data_for_csv_bottom, columns=header_columns)
    df_actuation_bottom.to_csv(output_csv_filename_bottom, index=False, float_format='%.8g')
    print(f"OK: File CSV '{output_csv_filename_bottom}' generato con successo.")

    print(f"\nISTRUZIONI IMPORTANTI:")
    print(f"1. Copia i file '{output_csv_filename_top}' e '{output_csv_filename_bottom}'")
    print(f"   nella directory principale del tuo caso OpenFOAM.")
    print(f"2. Assicurati che le patch 'actuatorSlot_top' e 'actuatorSlot_bottom'")
    print(f"   siano configurate correttamente nel file '0/U' per leggere questi CSV.")

except Exception as e:
    # Se si verifica un errore durante la creazione o scrittura dei file,
    # stampa un messaggio di errore.
    print(f"ERRORE durante la scrittura dei file CSV: {e}")

#------------------------------------------------------------------------------
# FINE DELLO SCRIPT
#------------------------------------------------------------------------------
