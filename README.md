# PincherX-150_robotarm
Államvizsgához használt PincherX-150-es robotról készült dokumentációk


## TO DO:

Egy reteg eseten: normalizalas, mas transzfer fuggveny, learning rate, optimizacios algoritmus
- fenti pramaterek/fuggvenyek valasztasanak hatasa

- ~~adathalmazok: kettos ingara es 3 csuklos karra, illetve 5 csukós karra~~
  
  Neurális háló:
- 5 csuklos robotkar poziciok
- 5 csuklos robotkar poziciok+ orientaciok


- megoldani a háló kimentését file-ba (weights)
- rátenni a digitalizált koordinátákra a hálót/az inverzkinematikát
- normalizálást megoldani!

### Kettős ingára

1. Learning rate: vizsgalva
2. Activation function: vizsgálva, még le kell írni
3. 

### 3 csuklós robotkarra
Done:
- learning rate
- 

### 5 csuklós robotkarra
Done:
- learning rate
- 

## Progress:

### 2025.03.02:

- Elolvasva a cikk
- Utánaolvasva a neurális hálónak (deep learning kurzus, átlapozva)
- Átnézve a saját munkám implementációja (Euler szögek vs. approach and orientation vektorok)
- GPT-vel implementált és átnézett példafeladat neurális hálóval (sokmindent megértettem, hogy hogyan kellene kinézzen az egész, de még több kérdés merült fel - KÖNYVÉSZET ehhez???)
- Neurális háló architektúrája a cikk alapján?
- Megírva a videófeldolgozó program a kézírás felismeréséhez (tablet - Python - koordináták - feldolgozás és átvitel 3D-be - ábrázolás - adatok exportálása)

#### Kérdések:
- Teljesen a cikk alapján kellene mennünk?
- Mekkora hibahatárral dolgozzunk?
- Milyen architektúrával éri meg nekifogni? (általános megírás vs. specifikus)
- Vegyes módszert fogunk használni? (háló és IK)

#### Teendők: Hétfő, 2025.03.03.
- Harrison Kinsley, Daniel Kukieła - Neural Networks from Scratch in Python (2020)
- Adatgenerálást jó lenne elindítani (méretek?)

#### Teendők: Későbbre
- All joint neuronháló megírása 5 csuklóra
- Vizsgálni a hálót különböző paraméterekre
- Subspaces implementáció a jobb konvergencia és hatékonyság érdekében

### 2025.03.15:
- Írásdigitalizáció version 1.
