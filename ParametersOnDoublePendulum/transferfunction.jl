#=
This code aims to study the effect of the transfer function on the double pendulums neural network. Still in progress.

Here it is all about changeing the learning rate.
=#
using  Plots
using  LinearAlgebra
include("..\\GeneralFunctions\\file_read_write.jl")
include("..\\NeuralNetworks\\basic_mine.jl")


# =================================================================================
#        Activation functions:

include("..\\NeuralNetworks/activation_functions.jl")

# =================================================================================

function Study_ActFunctions(functions, func_derivatives, func_names)
    
    data = Read_In("GenerateData\\datasets\\data_DoublePendulum.txt"; first_line = true)
    x = data[:, 1:2] # coordinates
    y = data[:, 3:4] # joint values    

    result = []
    for (func, deriv, func_name) in zip(functions, func_derivatives, func_names)
        println("Working on: $(func_name)...")
        network = initialize_network(2, 64, 2)
        
        losses = train_network!(network, x, y; epochs=300, learning_rate = 0.3, act_func = func, act_func_deriv = deriv)
        push!(result, losses)
        println("Done...")
    end
    return result;
end

function PlotLearningRates(losses, learning_rates)

    plt = plot(title = "The effect of activation functions on learning")
    for (i, loss) in enumerate(losses)
        plot!(plt, loss, label="activation function: $(learning_rates[i])", xlabel="Epochs []", ylabel="Loss [rad]")
        # println("Hejj")
    end

    return plt
end


begin
    time1 = time()

    # functions = [relu, sigmoid, tanh_activation, softmax]
    functions = [relu, sigmoid, tanh_activation]
    function_derivatives = [relu_deriv, sigmoid_deriv, tanh_deriv]
    # function_derivatives = [relu_deriv, sigmoid_deriv, tanh_deriv, softmax_deriv]
    func_names = ["relu", "sigmoid", "tanh", "softmax"]

    losses = Study_ActFunctions([tanh_activation], [tanh_deriv], [func_names[3]])    
    # losses = Study_ActFunctions([softmax], [softmax_deriv], func_names)    
    # losses = Study_ActFunctions(functions, function_derivatives, func_names)    
    plt = PlotLearningRates(losses, func_names)
    savefig(plt, "act_funcs_effect.png")

    elapsed_time = time()-time1;
    println("Elapsed time: $(elapsed_time) sec")

    Print_Matrix2(losses, filename = "act_funcs_effect.txt", header = "fucntions: $(func_names)")

    plt
end


plt = PlotLearningRates([losses[1][1:188]], [func_names[3]])
savefig(plt, "act_funcs_effect.png")

# work with data: after
losses
[losses[1][1:192]]

a = Read_In("act_funcs_effect.txt", first_line = true)'
list_of_lists = [collect(row) for row in eachcol(a[1:193, 1:3])]
# list_of_lists = [collect(row) for row in eachcol(a[:, 1])]
plt2 = PlotLearningRates(list_of_lists,  func_names)
savefig(plt2, "act_funcs_effect.png")

