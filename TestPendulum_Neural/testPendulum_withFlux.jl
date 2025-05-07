using Flux
using Flux: params
using Random
using Plots
using LinearAlgebra
using Statistics  # Import Statistics for mean

# Direct kinematics function
function direct_kinematics(theta1, theta2; L1 = 1, L2 = 1)
    x = L1 * cos(theta1) + L2 * cos(theta1 + theta2)
    y = L1 * sin(theta1) + L2 * sin(theta1 + theta2)
    return hcat(x, y)
end

# Read in and normalize the training data
begin
    # Read in the training data
    data = Read_In("GenerateData\\datasets\\data_DoublePendulum.txt"; first_line = true)
    x_teach = data[1:100000, 1:2]  # coordinates
    y_teach = data[1:100000, 3:4]   # joint values    
    
    # Normalize data
    # x_teach = x_teach ./2
    # y_teach = y_teach ./(2pi)

    # x_teach = (x_teach .- mean(x_teach, dims=1)) ./ std(x_teach, dims=1)
    # y_teach = (y_teach .- mean(y_teach, dims=1)) ./ std(y_teach, dims=1)
    
    # x_teach = permutedims(x_teach)  # Now y_train is (2, 500000)
    # y_teach = permutedims(y_teach)  # Now y_train is (2, 500000)

    x_teach = Float32.(x_teach)
    y_teach = Float32.(y_teach)

end

x_teach
y_teach

# kell egy plot a tanítási adatokról a térben
ind = 8000
scatter(x_teach[1:ind, 1], x_teach[1:ind, 2], 
 xlims=(-4, 4), ylims=(-3, 3), 
framestyle=:origin, aspect_ratio=:equal, 
 )     


 # Set up the neural network
begin
    # Initialize the neural network
    model = Chain(
        Dense(2, 128, relu),
        Dense(128, 128, relu),
        Dense(128, 64, relu),
        Dense(64, 2)  # Output: 5 joint angles
    )
    
    # Loss function
    loss(x, y) = Flux.Losses.mse(model(x), y)
    
    # Optimizer
    opt = ADAM(0.001)  # Experiment with learning rates
    
end


# Training function
function train_network!(model, x, y; epochs=1500, batch_size=32)
    losses = Float64[]

    x = Float32.(x)'
    y = Float32.(y)'

    for epoch in 1:epochs
        for i in 1:batch_size:size(x, 1)
            # Create batches
            x_batch = x[i:min(i + batch_size - 1, end), :]  # Shape: (batch_size, 2)
            y_batch = y[i:min(i + batch_size - 1, end), :]  # Shape: (batch_size, 2)

            # Transpose the batches to match the expected input shape
            # az adatok szerkezetéből adódóan kell ezt tennünk:
            # x_batch = transpose(x_batch)  # Shape: (2, batch_size)
            # y_batch = transpose(y_batch)  # Shape: (2, batch_size)
            # println(size(x_batch))

            # Train the model on the batch
            Flux.train!(loss, params(model), [(x_batch, y_batch)], opt)
        end
        push!(losses, loss(x, y))
        if epoch % 10 == 0
            println("Epoch: $epoch, Loss: $(losses[end])")
        end
    end
    println("Done training...")
    return losses
end

begin
    time0 = time()
    # losses = Float64[] # uncomment this for the first line

    for i in 1:10
        
        # Train the network
        time1 = time()
        loss_small = train_network!(model, x_teach, y_teach, epochs=30, batch_size=100)
        push!(losses, loss_small...)

        # measure time
        elapsed_time = time()-time1;
        println("$(i). cycle:\nElapsed time: $(elapsed_time) sec ($(elapsed_time/60) min)")
        println("Loss: $(losses[end])")
    end
    elapsed_time = time()-time0;        
    println("Elapsed time: $(elapsed_time) sec ($(elapsed_time/60) min)")
    

end

losses[end]

# Save the trained model
serialize("TestPendulum_Neural/results/Flux/trained_network_Flux" * string(round(losses[end], digits = 5)) * ".jls", model)
# model = deserialize("trained_network_Flux.jls")
# loaded_model = deserialize("trained_network_Flux.jls")


# Plot losses
plot(losses, title="Hiba a tanulás során", 
xlabel="Ciklusok", ylabel="Hiba [rad]",
label = "",
xlims = (0, 4.1*10^4),ylims=(0, 0.06), 
)


# Using the neural network
    # initialize/load the newtwork
    # set up the goal
    # use this block to test the results
begin
    # Assuming 'network' is your trained model and 'goal_path' is your input data
    
    
    # predicted_joints = model(goal_path')' .*(2pi) # Use the model directly for predictions
    predicted_joints = model(goal_path')'  # Use the model directly for predictions
    
    # Use the direct kinematics to calculate the positions based on predicted joint angles
    direct_data = vcat(direct_kinematics.(predicted_joints[:, 1], predicted_joints[:, 2])...)  # Use the direct kinematics
    direct_x, direct_y = direct_data[:, 1], direct_data[:, 2]  # Structurize data
    
    # Plot the results
    plt_result = plot(direct_x, direct_y,
        xlims=(-4, 4), ylims=(-2, 2), 
        framestyle=:origin, aspect_ratio=:equal, 
        # label = "Eredményezett útvonal, hiba: $(round(losses[end], digits = 4))", 
        legend=:bottomright,
        label = "Eredményezett útvonal, hiba: $(round(losses[end], digits = 4)) rad", 

        title = "Neurális háló eredménye\n(koordinátatérben)")
    
    plt_result = plot_Circle(2, plt_result)
    # savefig(plt_result, "TestPendulum_Neural/results/Flux/Flux_result_path_" * string(round(losses[end], digits = 4)) * ".pdf")
    
end

goal_path .*= 2
goal_path = goal_path ./2
predicted_joints = model(goal_path')' .*(2pi)  # Use the model directly for predictions

begin
    # Create a figure with two subplots
    plt_joints = plot(layout = (2, 1))  # 2 rows, 1 column
    

    # Plot the first array
    plot!(plt_joints[1], predicted_joints[:, 1], label="Array 1", title="Plot of Array 1", xlabel="Index", ylabel="Value", legend=:topright)

    # Plot the second array
    plot!(plt_joints[2], predicted_joints[:, 2], label="Array 2", title="Plot of Array 2", xlabel="Index", ylabel="Value", legend=:topright)

    
end

plt_goal = plot(goal_path[:, 1], goal_path[:, 2], 
xlims=(-4, 4), ylims=(-3, 3), 
framestyle=:origin, aspect_ratio=:equal, 
label = "Cél nyomvonal", 
legend=:topright,
title = "Cél a neurális hálónak")




loss(model(x_teach'), y_teach')

mean_squared_error(model(x_teach'), y_teach')


# Archive:

loss(model(x_teach'), y_teach')

mean_squared_error(model(x_teach'), y_teach')
