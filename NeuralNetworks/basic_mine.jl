#=
This code aims to implement a basic neural network with 1 single hidden layer.

=#

# Aktivációs függvények
relu(x) = max.(0, x)
relu_deriv(x) = x .> 0

# Neurális hálózat struktúrája
mutable struct NeuralNetwork
    W1::Matrix{Float64}
    b1::Vector{Float64}
    W2::Matrix{Float64}
    b2::Vector{Float64}
    W3::Matrix{Float64}
    b3::Vector{Float64}
end

# Háló inicializálása
function initialize_network(input_size, hidden_size, output_size)
    W1 = randn(hidden_size, input_size) * 0.01
    b1 = zeros(hidden_size)
    W2 = randn(hidden_size, hidden_size) * 0.01
    b2 = zeros(hidden_size)
    W3 = randn(output_size, hidden_size) * 0.01
    b3 = zeros(output_size)
    return NeuralNetwork(W1, b1, W2, b2, W3, b3)
end

# Előrehaladás
function forward(network::NeuralNetwork, X)
    z1 = network.W1 * X' .+ network.b1
    a1 = relu.(z1)
    z2 = network.W2 * a1 .+ network.b2
    a2 = relu.(z2)
    z3 = network.W3 * a2 .+ network.b3
    return a1, a2, z3'
end

# Veszteségfüggvény (MSE)
function mean_squared_error(y_pred, y_true)
    return sum((y_pred - y_true) .^ 2) / size(y_true, 1)
end

# Visszaterjesztés és frissítés
function backpropagate!(network::NeuralNetwork, X, y, learning_rate=0.01)
    a1, a2, y_pred = forward(network, X)
    m = size(y, 1)
    
    dL = (y_pred - y) / m
    
    dW3 = dL' * a2'
    db3 = vec(sum(dL, dims=1))
    
    dz2 = (network.W3' * dL') .* relu_deriv(a2)
    dW2 = dz2 * a1'
    db2 = vec(sum(dz2, dims=2))
    
    dz1 = (network.W2' * dz2) .* relu_deriv(a1)
    dW1 = dz1 * X
    db1 = vec(sum(dz1, dims=2))
    
    network.W1 .-= learning_rate * dW1
    network.b1 .-= learning_rate * db1
    network.W2 .-= learning_rate * dW2
    network.b2 .-= learning_rate * db2
    network.W3 .-= learning_rate * dW3
    network.b3 .-= learning_rate * db3
end

# Háló tanítása
function train_network!(network::NeuralNetwork, X, y; epochs=1000, learning_rate=0.01)
    losses = Float64[]
    for epoch in 1:epochs
        backpropagate!(network, X, y, learning_rate)
        if epoch % 10 == 0
            _, _, y_pred = forward(network, X)
            loss = mean_squared_error(y_pred, y)
            push!(losses, loss)
            println("Epoch: $epoch, Loss: $loss")
        end
    end
    return losses
end
