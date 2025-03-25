# Activation functions
sigmoid(x) = 1 / (1 + exp(-x))
relu(x) = max(0, x)
tanh_activation(x) = tanh(x)
softmax(x) = exp.(x .- maximum(x)) ./ sum(exp.(x .- maximum(x)))

# Derivatives
sigmoid_deriv(x) = sigmoid(x) * (1 - sigmoid(x))
relu_deriv(x) = x .> 0  # Derivative is 1 if x > 0, else 0
tanh_deriv(x) = 1 - tanh(x)^2
softmax_deriv(s) = [i == j ? s[i] * (1 - s[i]) : -s[i] * s[j] for i in eachindex(s), j in eachindex(s)]
