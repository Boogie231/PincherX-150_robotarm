import numpy as np

# Fájl megnyitása és sorok beolvasása, kihagyva az első üres sort
with open("PathFollow\\results\\test2_qs.txt") as f:
    lines = f.readlines()[1:]  # első sor kihagyása

# Sorok feldolgozása lebegőpontos számokká
data = np.array([[float(szám) for szám in sor.strip().split()] for sor in lines])

# Ellenőrzésül kiírjuk a tömböt
print(data)

for sor in data:
    utolso = sor[0]  # az utolsó oszlop
    abszolut = abs(utolso)
    # print(f"Utolsó oszlop abszolút értéke: {abszolut}")
    print(sor)

