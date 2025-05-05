using Flux

# Number of training samples
N = 1000

# Input: 2 features per sample
x_teach = rand(Float32, 2, N)  # (2, 1000)

# Output: 2 target values per sample
y_teach = x_teach .+ 0.1f0 * randn(Float32, 2, N)  # Just an example mapping

# Model
model = Chain(
    Dense(2, 128, relu),
    Dense(128, 128, relu),
    Dense(128, 64, relu),
    Dense(64, 2)  # 2 output values per input
)

# Loss function
loss(x, y) = Flux.Losses.mse(model(x), y)

# Optimizer
opt = Adam()

# Train for 1 epoch
Flux.train!(loss, params(model), [(x_teach, y_teach)], opt)

