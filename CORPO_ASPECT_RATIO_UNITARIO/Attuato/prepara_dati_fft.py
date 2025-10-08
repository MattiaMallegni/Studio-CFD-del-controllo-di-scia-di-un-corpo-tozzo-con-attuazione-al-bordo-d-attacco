import pandas as pd

# --- IMPOSTAZIONI ---
force_coeffs_file = 'postProcessing/forceCoeffs1/0/forceCoeffs.dat'
output_cl = 'segnale_Cl.dat'

print("--- Inizio Script di Preparazione Dati per Analisi Cl ---")

try:
    # --- Processa il file forceCoeffs.dat ---
    print(f"Leggo il file dei coefficienti: {force_coeffs_file}")
    df_forces = pd.read_csv(force_coeffs_file, comment='#', sep=r'\s+', header=None)
    df_forces.columns = ['Time', 'Cm', 'Cd', 'Cl', 'Cl(f)', 'Cl(r)']

    # Estrai e salva solo le colonne del Tempo e del Cl
    df_forces[['Time', 'Cl']].to_csv(output_cl, sep=' ', index=False, header=False, float_format='%.6e')
    print(f"-> File creato con successo: {output_cl}")

except FileNotFoundError:
    print(f"\nERRORE: File non trovato -> {force_coeffs_file}")
    print("Controlla che il percorso e il nome del file siano corretti.")
except Exception as e:
    print(f"Si è verificato un errore inaspettato: {e}")

print("\n--- Script completato ---")
