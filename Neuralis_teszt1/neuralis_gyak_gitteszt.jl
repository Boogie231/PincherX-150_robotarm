# ez egy teszt a commitoláshoz

using Random
using Plots

# Paraméterek
n_samples = 1000  # minták száma
radius = 1.0  # kör sugara
side = 2.0  # négyzet oldala

# Adatok generálása
function generate_data(n_samples, radius, side)
    X = []  # Adatok
    y = []  # Címkék (0 - négyzet, 1 - kör)

    for i in 1:n_samples
        # Véletlen pontok a négyzetből
        if rand() > 0.5
            x = rand() * side - side / 2
            y_val = rand() * side - side / 2
            push!(X, [x, y_val])
            push!(y, 0)  # négyzet
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

x, y = generate_data(n_samples, radius, side)

# Adatok megjelenítése
scatter(X[1, :], X[2, :], c=y, label="Data", xlabel="X", ylabel="Y", title="Generated Data")


# 2. Lepes


using LinearAlgebra

# Aktivációs függvények
function sigmoid(x)
    return 1.0 / (1.0 + exp(-x))
end

function sigmoid_deriv(x)
    return sigmoid(x) * (1 - sigmoid(x))
end

# Neurális háló
struct NeuralNetwork
    input_size::Int
    hidden_size::Int
    output_size::Int
    W1::Matrix{Float64}  # Súlyok az input és rejtett réteg között
    b1::Vector{Float64}  # Eltolás az input és rejtett réteg között
    W2::Matrix{Float64}  # Súlyok a rejtett réteg és a kimenet között
    b2::Vector{Float64}  # Eltolás a kimeneti réteghez
end

# Háló inicializálása, véletlenszerűen
function initialize_network(input_size, hidden_size, output_size)
    W1 = rand(hidden_size, input_size) * 0.01
    b1 = zeros(hidden_size)
    W2 = rand(output_size, hidden_size) * 0.01
    b2 = zeros(output_size)
    return NeuralNetwork(input_size, hidden_size, output_size, W1, b1, W2, b2)
end

# Előrehaladás
function forward(network, X)
    z1 = network.W1 * X .+ network.b1
    a1 = sigmoid.(z1)
    z2 = network.W2 * a1 .+ network.b2
    a2 = sigmoid.(z2)
    return a1, a2
end

# Veszteségfüggvény
function binary_cross_entropy(y_pred, y_true)
    m = length(y_true)
    loss = -1/m * sum(y_true .* log.(y_pred) .+ (1 .- y_true) .* log.(1 .- y_pred))
    return loss
end


# 3. Lepes
# Visszaterjesztés és paraméterfrissítés
function backpropagate!(network, X, y; learning_rate=0.01)
    # Előrehaladás
    a1, a2 = forward(network, X)
    
    m = length(y)
    
    # Kimeneti hiba
    dz2 = a2 .- y
    dW2 = (1/m) * dz2 * a1'
    db2 = (1/m) * sum(dz2, dims=2)
    
    # Rejtett hiba
    dz1 = (network.W2' * dz2) .* sigmoid_deriv.(a1)
    dW1 = (1/m) * dz1 * X'
    db1 = (1/m) * sum(dz1, dims=2)
    
    # Súlyok és eltolások frissítése
    network.W1 .-= learning_rate * dW1
    network.b1 .-= learning_rate * db1
    network.W2 .-= learning_rate * dW2
    network.b2 .-= learning_rate * db2
end

# Háló tanítása
function train_network!(network, X, y; epochs=1000, learning_rate=0.01)
    for epoch in 1:epochs
        backpropagate!(network, X, y, learning_rate)
        if epoch % 100 == 0
            a1, a2 = forward(network, X)
            loss = binary_cross_entropy(a2, y)
            println("Epoch: $epoch, Loss: $loss")
        end
    end
end


# 4. Lepes

# Adatok átalakítása
A = hcat(x...)  # Adatok, 2D mátrix (2, n_samples)
B = reshape(y, 1, n_samples)  # Címkék
A

# Háló inicializálása
network = initialize_network(2, 4, 1)

# Modell tanítása
train_network!(network, A, B, epochs=1000, learning_rate=0.01)

# Eredmények tesztelése
a1, a2 = forward(network, A)
predictions = a2 .> 0.5  # Bináris kimenet

# Pontosság számítása
accuracy = sum(predictions .== B) / length(B)
println("Accuracy: $accuracy")
