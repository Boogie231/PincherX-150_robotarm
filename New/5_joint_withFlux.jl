# This code aims to implemet a Neural Network for the PicherX robotic arms 5 joint and 6 position data

using Flux
using Flux: params

using Random
using Plots
using LinearAlgebra

include("..\\GeneralFunctions\\file_read_write.jl")

begin
    # Work with data
	data = Read_In("GenerateData\\datasets\\data_Pincher_5joint1.txt"; first_line = true)

    # Neural Network:
    model = Chain(
    Dense(3, 64, relu),
    Dense(64, 64, relu),
    Dense(64, 64, relu),
    Dense(64, 5)  # Output: 5 joint angles
)
    loss(x, y) = Flux.Losses.mse(model(x), y) # hibafüggvény
    opt = ADAM(0.001) # optimizer

end