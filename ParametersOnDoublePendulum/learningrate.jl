#=
This code aims to study the effect of the learning-rate - parameter on the double pendulum's neural network.


Here it is all about changeing the learning rate.
=#
using  Plots
include("..\\GeneralFunctions\\file_read_write.jl")
include("..\\NeuralNetworks\\basic_mine.jl")
include("..\\NeuralNetworks\\activation_functions.jl")

function Study_LearningRate(learning_rates)
    
    data = Read_In("GenerateData\\datasets\\data_DoublePendulum.txt"; first_line = true)
    x = data[:, 1:2] .*100 # coordinates
    y = data[:, 3:4] # joint values    

    result = []
    for rate in learning_rates

        network = initialize_network(2, 64, 2)
        
        losses = train_network!(network, x, y, epochs=700, learning_rate = rate)
        push!(result, losses)
    end
    return result;
end

function PlotLearningRates(losses, learning_rates)

    plt = plot(title = "The effect of learning rates")
    for (i, loss) in enumerate(losses)
        plot!(plt, loss, label="learning rate = $(learning_rates[i])", xlabel="Epochs", ylabel="Loss")
        println("Hejj")
    end

    return plt
end


begin
    time1 = time()
    # rates = [0.01, 0.1]
    # rates = [0.01, 0.05, 0.08, 0.1, 0.3, 0.5]
    rates = [0.01]

    losses = Study_LearningRate(rates)    
    plt = PlotLearningRates(losses, rates)
    savefig(plt, "losses_withscale.pdf")

    elapsed_time = time()-time1;
    println("Elapsed time: $(elapsed_time) sec")

    Print_Matrix2(losses, filename = "losses_withscale.txt", header = "learning rate = ($(rates))")

    plt
end

losses

plt = PlotLearningRates(losses[[1,2]], rates)
savefig(plt, "losses_withscale.pdf")



