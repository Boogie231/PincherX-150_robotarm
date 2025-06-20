using Plots
using Statistics
using Polynomials

# Adatok
# Ox1 = [77, 75, 72, 64, 65, 62, 58]
# Ox2 = [77, 74, 70, 68, 65, 61, 57]
# Ox3 = [77, 75, 70, 64, 60, 62, 57]
# Ox4 = [77, 74, 71, 64, 61, 62, 56]
# Oy1 = [77, 74, 70, 62, 57, 58, 55]
# Oy2 = [77, 73, 69, 62, 57, 57, 55]

Ox1 = [79, 77, 74, 66, 67, 64, 60]
Ox2 = [79, 76, 72, 70, 67, 63, 59]
Ox3 = [79, 77, 72, 66, 62, 64, 59]
Ox4 = [79, 76, 73, 66, 63, 64, 58]
Oy1 = [79, 76, 72, 64, 59, 60, 57]
Oy2 = [79, 75, 71, 64, 59, 59, 57]

D = [100, 125, 150, 175, 200, 225, 250]

# Átlagos magasságok minden sorra
all_heights = [Ox1 Ox2 Ox3 Ox4 Oy1 Oy2]
# all_heights = [Ox1 Ox2 Ox3 Ox4]
# all_heights = [Oy1 Oy2]
avg_heights = [mean(row) for row in eachrow(all_heights)]


# Illesztés - egyenes (1. fokú polinom)
linear_fit = fit(D[1:5], avg_heights[1:5], 1) # kivettuk a 225 es 250re, mert ott már az adatgenerálásnál nem járt sikerrel az IK
# linear_fit = fit(D, avg_heights, 1)

# Illesztés - polinom (3. fokú)
poly_fit = fit(D, avg_heights, 3)

# Ábrázolás
scatter(D, avg_heights, label="Átlagos magasság", xlabel="D (távolság)", ylabel="Magasság", title="Magasság vs. Távolság", legend=:bottomleft)
plot!(D, linear_fit.(D), label="Lineáris illesztés", lw=2)
# plot!(D, linear_fit.(D), label="Lineáris illesztés - x tengelyen az utolsó két pont elhagyva", lw=2)
plot!(D, poly_fit.(D), label="3. fokú polinom illesztés", lw=2, ls=:dash)

# Egyenletek kiírása
println("Lineáris illesztés: ", linear_fit)
println("Polinomos illesztés (3. fokú): ", poly_fit)

savefig("FerdeSik\\magassag_vs_tavolsag.pdf")


## Results:

# Ennyit esik:
# OX: Lineáris illesztés: 92.3393 - 0.133571*x
# Oy: Lineáris illesztés: 94.125 - 0.157857*x
# FUll: Lineáris illesztés: 92.9345 - 0.141667*x

# Ox 5 adattal: Lineáris illesztés: 96.7667 - 0.17*x
