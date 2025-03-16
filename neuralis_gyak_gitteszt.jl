using Flux
using Flux: params

using Random
using Plots
using LinearAlgebra

# Paraméterek
n_samples = 1000  # minták száma
radius = 1.0  # kör sugara
side = 2.0  # négyzet oldala

# Adatok generálása
function generate_data(n_samples, radius, side)
    X = []  # Adatok
    y = []  # Címkék (0 - négyzet, 1 - kör)

    origo = [0, 4]
    for _ in 1:n_samples
        if rand() > 0.5
            x = rand() * side - side / 2 + origo[1]
            y_val = rand() * side - side / 2 + origo[2]
            push!(X, [x, y_val])
            push!(y, 0)
        else
            # Véletlen pontok a körből
            angle = rand() * 2 * π
            r = rand() * radius
            x = r * cos(angle)
            y_val = r * sin(angle)
            push!(X, [x, y_val])
            push!(y, 1)  # kör
        end
    end
    return hcat(X...), y
end

# Adatok generálása
x, y = generate_data(n_samples, radius, side)
println(size(x'))  # pl. (1, 2000) lehet



# Adatok megjelenítése
scatter(x[1, :], x[2, :], c=y, label="Data", xlabel="X", ylabel="Y", title="Generated Data", aspect_ratio =:equal)

# Modell
model = Chain(
    Dense(2, 4, relu),  # 2 input, 4 rejtett neuron
    Dense(4, 1, sigmoid)  # 4 rejtett, 1 kimeneti neuron
)

# Veszteségfüggvény
loss(x, y) = Flux.Losses.binarycrossentropy(model(x), y)

# Optimizáló
opt = ADAM(0.01)

# Adatok átalakítása (a címkék oszlopmátrix)
x_data = vcat(x...)'
y_data = reshape(y, 1, n_samples)


println(size(x_data))  # pl. (1, 2000) lehet
println(size(y_data))  # Ellenőrizd, hogy a kimenet is megfelel-e az elvárásnak
x

# Tanítás
for epoch in 1:1000
    # Képzés
    Flux.train!(loss, params(model), [(x, y_data)], opt)



    
    # Minden 100. epoch után kiírjuk a veszteséget
    if epoch % 100 == 0
        current_loss = loss(x, y_data)
        println("Epoch: $epoch, Loss: $current_loss")
    end
end

# Eredmények tesztelése
predictions = model(x) .> 0.5  # Bináris kimenet
print(predictions)
# Pontosság számítása
accuracy = sum(predictions .== y_data) / length(y_data)
println("Accuracy: $accuracy")


model([1, 5])
model([-0.5, 0])
model([1, 1])
model([0, 2])
model([0, 3])
model([-1, 3])
