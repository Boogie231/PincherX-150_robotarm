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

function PlotLearningRates(losses, learning_rates; plt = plot())

    # plot!(plt, title = "The effect of learning rates")
    plot!(plt, title = "A tanulási paraméter hatása a tanulási folyamatra")

    for (i, loss) in enumerate(losses)

        # index = collect(1:length(loss)) * 10  # olyan esetekhez, ha az 
        # plot!(plt,index, loss, label="tanulási paraméter = $(learning_rates[i])", xlabel="Tanulási ciklusok", ylabel="Hiba [Rad]")
        
        # plot!(plt, loss, label="learning rate = $(learning_rates[i])", xlabel="Epochs", ylabel="Loss")    # angolul
        plot!(plt,index, loss, label="tanulási paraméter = $(learning_rates[i])", xlabel="Tanulási ciklusok", ylabel="Hiba [Rad]")
        println("Done plot: in PlotLearningRates...")
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


# kis beolvasas es adatfeldolgozas, ETDK-hoz
begin
    
    x  = Read_In("ParametersOnDoublePendulum/results/losses.txt"; first_line = true)
    rates = [0.01, 0.05, 0.08, 0.1, 0.3, 0.5]
    plt = PlotLearningRates([x[1,:]], rates)
    for i in 1:6
        plt = PlotLearningRates([x[i, :]], rates[i]; plt = plt)  # Csak az i-edik sort használja
        # Itt lehetőség van a plotok mentésére vagy megjelenítésére
    end
    
    savefig(plt, "losses_ETDK.pdf")
end



