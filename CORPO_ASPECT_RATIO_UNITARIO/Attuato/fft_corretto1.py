#----------------------------------------------------------------------
# 1. 
#----------------------------------------------------------------------
# Carichiamo le librerie necessarie per far funzionare lo script.

import sys  # Serve per leggere gli argomenti passati da terminale (il nome del file).
import os   # Serve per manipolare i nomi dei file e creare percorsi (es. per salvare i grafici).
import numpy as np  # La libreria fondamentale per i calcoli scientifici e la gestione di array numerici.
import matplotlib.pyplot as plt  # La libreria per creare i grafici.
from scipy.fftpack import fft      # Importiamo solo la funzione specifica "fft" dalla libreria scientifica SciPy.

#----------------------------------------------------------------------
# 2. IMPOSTAZIONI GLOBALI
#----------------------------------------------------------------------

U_inf = 0.4  # La velocità del flusso della simulazione. Serve per calcolare lo Strouhal.
D = 1.0      # La dimensione del corpo. Serve per calcolare lo Strouhal.

# Analizzare solo la parte stabile (escludiamo il transitorio).
t_start_analysis = 160.0 # Stabiliamo che l'analisi inizierà solo dopo t=160 secondi.
t_end_analysis = 525.0
#"Zoomare" il grafico finale.
St_max_plot = 0.5 # Stabiliamo che l'asse X del grafico delle frequenze si fermerà a St=0.5.

#----------------------------------------------------------------------
# 3. FUNZIONE PRINCIPALE
#----------------------------------------------------------------------
# Tutto il codice principale è contenuto in una funzione chiamata "main".

def main():
    # Controlla se l'utente ha fornito un nome di file quando ha lanciato lo script.
    if len(sys.argv) < 2:
        print("Errore: Fornisci il nome del file di dati come argomento.")
        sys.exit(1) # Se non c'è, lo script si ferma.

    # Prende il nome del file (es. "segnale_Cl.dat") dal comando del terminale.
    file_path = sys.argv[1]
    print(f"\n--- Inizio Analisi in Frequenza del file: {file_path} ---")

    # Tenta di caricare i dati dal file di testo.
    try:
        # np.loadtxt è un modo veloce per leggere file di testo a colonne.
        # "unpack=True" mette la prima colonna in 'time' e la seconda in 'signal'.
        time, signal = np.loadtxt(file_path, unpack=True)
        print("Dati caricati con successo.")
    except Exception as e:
        print(f"ERRORE durante la lettura del file '{file_path}': {e}")
        sys.exit(1)

    #------------------------------------------------------------------
    # 4. PREPARAZIONE DEL SEGNALE 
    #------------------------------------------------------------------
    
    # Crea una "maschera" logica per selezionare l'intervallo [160, 525].
    mask = (time >= t_start_analysis) & (time <= t_end_analysis)
    # Usa la maschera per "filtrare" gli array, tenendo solo i dati della parte stabile.
    time_stable = time[mask]
    signal_stable = signal[mask]

    # Controllo di sicurezza per assicurarsi che ci siano abbastanza dati da analizzare.
    if len(signal_stable) < 20:
        print(f"ERRORE: Pochi dati dopo t={t_start_analysis}s. Impossibile analizzare.")
        sys.exit(1)
    
    print(f"Analisi eseguita su {len(signal_stable)} punti dati a partire da t={t_start_analysis:.1f}s.")
    
    # Rimuove il valore medio dal segnale. Questo serve a concentrare l'analisi
    # solo sulle OSCILLAZIONI attorno alla media, che sono quelle che ci interessano.
    signal_detrended = signal_stable - np.mean(signal_stable)
    
    # Calcola l'intervallo di tempo medio (dt) tra un campione e l'altro.
    dt = np.mean(np.diff(time_stable))
    # Calcola la frequenza di campionamento (fs), cioè quanti campioni abbiamo al secondo.
    fs = 1.0 / dt
    # N è il numero totale di punti nel nostro segnale stabile.
    N = len(signal_detrended)

    #------------------------------------------------------------------
    # 5. LA TRASFORMATA DI FOURIER (FFT)
    #------------------------------------------------------------------

    # Applica la Trasformata di Fourier al segnale. Questo lo scompone nelle sue frequenze.
    yf = fft(signal_detrended)
    
    # Calcola l' "Energia" (o Potenza) di ogni frequenza. 
    # Questa formula normalizza il risultato della FFT per renderlo fisicamente interpretabile.
    power_spectrum = (2.0/N * np.abs(yf[0:N//2]))**2
    
    # Crea l'array delle frequenze in Hertz (Hz) che corrisponde ai valori di energia calcolati.
    freqs_hz = np.linspace(0.0, 1.0/(2.0*dt), N//2)

    #------------------------------------------------------------------
    # 6. CONVERSIONE IN STROUHAL 
    #------------------------------------------------------------------

    # Converte l'intero asse delle frequenze da Hertz (Hz) a Numero di Strouhal (adimensionale).
    St_axis = freqs_hz * D / U_inf

    #------------------------------------------------------------------
    # 7. CREAZIONE E SALVATAGGIO DEI GRAFICI
    #------------------------------------------------------------------
    
    # Crea una figura vuota che conterrà i nostri due grafici.
    plt.figure(figsize=(12, 8))

    # --- Grafico 1: Segnale nel Tempo ---
    # Seleziona la parte superiore della figura (il primo di due grafici).
    plt.subplot(2, 1, 1)
    # Disegna il segnale STABILE (dopo t=160s) contro il tempo.
    plt.plot(time_stable, signal_stable, 'b-')
    plt.title('Cl vs Tempo')
    plt.xlabel('Tempo [s]')
    plt.ylabel('Cl')
    plt.grid(True)
    # Imposta l'asse X perché inizi esattamente da dove abbiamo iniziato l'analisi.
    plt.xlim(t_start_analysis, t_end_analysis)


    # --- Grafico 2: Spettro di Frequenza ---
    # Seleziona la parte inferiore della figura (il secondo grafico).
    plt.subplot(2, 1, 2)
    # Disegna l'Energia (Potenza) contro il Numero di Strouhal.
    plt.plot(St_axis, power_spectrum, 'r-')
    plt.title('Spettro di Frequenza (Analisi FFT)')
    plt.xlabel('Numero di Strouhal (St = f*D/U)') # Etichetta aggiornata
    plt.ylabel('Potenza')
    plt.grid(True)
    #"Zooma" l'asse X per vedere solo fino a St=0.5.
    plt.xlim(0, St_max_plot)
    
    # Ottimizza lo spazio tra i due grafici per non farli sovrapporre.
    plt.tight_layout()
    
    # Crea un nome per il file di output e salva il grafico come immagine PNG.
    output_filename = f'analisi_fft_St_{os.path.basename(file_path).replace(".", "_")}.png'
    plt.savefig(output_filename, dpi=300)
    print(f"\nGrafico salvato come: {output_filename}")

# Questa parte standard di Python assicura che la funzione "main" venga eseguita
# solo quando lo script viene lanciato direttamente.
if __name__ == "__main__":
    main()
    
    
#UTILIZZA I COMANDI
# Per analizzare la portanza
#python3 fft_corretto1.py segnale_Cl.dat



