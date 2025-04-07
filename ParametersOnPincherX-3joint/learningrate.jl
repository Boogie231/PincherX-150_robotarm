#=
This code aims to study the effect of the learning-rate - parameter on the PincherX150's neural network.

Here it is all about changeing the learning rate.
=#
using  Plots
include("..\\GeneralFunctions\\file_read_write.jl")
include("..\\NeuralNetworks\\basic_mine.jl")
include("..\\NeuralNetworks/activation_functions.jl")

function Study_LearningRate(learning_rates)
    
    data = Read_In("GenerateData\\datasets\\data_Pincher_3joint.txt"; first_line = true)
    x = data[:, 1:3] ./10 # coordinates
    y = data[:, 4:6] # joint values    

    result = []
    for rate in learning_rates

        network = initialize_network(3, 64, 3)
        
        losses = train_network!(network, x, y, epochs=40, learning_rate = rate)
        push!(result, losses)
    end
    return result;
end

function PlotLearningRates(losses, learning_rates)

    plt = plot(title = "A tanulási paraméter hatása a tanulásra")
    for (i, loss) in enumerate(losses)
        plot!(plt, loss, label="tanulási paraméter = $(learning_rates[i])", xlabel="Ciklusok", ylabel="Hiba [Rad]")        
    end

    return plt
end


begin
    time1 = time()
    # rates = [0.01, 0.1]
    # rates = [0.006, 0.008, 0.01, 0.015, 0.02, 0.025]
    # rates = [0.006, 0.008, 0.01]
    rates = [0.1, 0.01, 0.001]

    losses = Study_LearningRate(rates)    
    plt = PlotLearningRates(losses, rates)
    savefig(plt, "losses.pdf")

    elapsed_time = time()-time1;
    println("Elapsed time: $(elapsed_time) sec ($(elapsed_time/60) min)")

    Print_Matrix2(losses, filename = "losses.txt", header = "learning rate = ($(rates))")

    plt
end

losses[1:5]
plt = PlotLearningRates(losses[[2,3,4,5]], rates)
savefig(plt, "losses.pdf")

# data = Read_In("GenerateData\\datasets\\data_Pincher_3joint.txt"; first_line = true)
# x = data[:, 1:3] # coordinates
# y = data[:, 4:6] # joint values 