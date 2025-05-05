#= This project aims to examine the Double Pendulum based on neural networks and check if 
    it is capable of solving a Path in 2D
=#

using Pkg; # Pkg.status()
Pkg.activate()

begin  
    using  Plots
    include("..\\GeneralFunctions\\file_read_write.jl")
    include("..\\NeuralNetworks\\basic_mine.jl")
    include("..\\NeuralNetworks\\activation_functions.jl")
    println("Setup done...")
end

# Direct kinematics
function direct_kinematics(theta1, theta2; L1 = 1, L2 = 1)
    x = L1 * cos(theta1) + L2 * cos(theta1 + theta2)
    y = L1 * sin(theta1) + L2 * sin(theta1 + theta2)
    return hcat(x, y)
end

# Read in the training data
data = Read_In("GenerateData\\datasets\\data_DoublePendulum.txt"; first_line = true)
x_teach = data[:, 1:2] .*1 # coordinates
y_teach = data[:, 3:4] # joint values    

# kell egy plot a tanítási adatokról a térben
ind = 4000
scatter(x_teach[1:ind, 1], x_teach[1:ind, 2], 
 xlims=(-4, 4), ylims=(-3, 3), 
framestyle=:origin, aspect_ratio=:equal, 
 )     

# Initialize and train the network
begin
    time1 = time()

    # network = initialize_network(2, 64, 2)
    losses = train_network!(network, x_teach, y_teach, epochs=1500, learning_rate = 0.15)
    save_network(network, "TestPendulum_Neural/results/trained_network_6500.jls")
    # network = load_network("TestPendulum_Neural/results/trained_network_1200.jls")
    
    plt_loss = plotLosses(losses)

    # measure time
	elapsed_time = time()-time1;
    println("Elapsed time: $(elapsed_time) sec ($(elapsed_time/60) min)")
end

network = load_network("TestPendulum_Neural/results/trained_network_1000.jls")
# save_network(network, "TestPendulum_Neural/results/trained_network_vegyes1.jls")


function plot_Circle(radius, plt)
    t = 0:0.01:2π  

    # Parametric equations for the circle
    x = radius * cos.(t)
    y = radius * sin.(t)
    plot!(plt, x, y, label="Kör: r = $(radius)")
    return plt

end

# Set up the goal data:
begin
    # General data:
	# used_index = 87
	used_index = 312
	
	# Read in the actual data:
	goal_path_raw = Read_In("PathFollow\\inputData\\coordinates4.txt"; first_line = true)
	goal_path = goal_path_raw[1:used_index, 1:2] # csak az elso ket oszlopot venni figyelembe, a z-t ignoráljuk az adatokból
	
	# scale data for the robot:


    x_central = minimum(goal_path[:, 1]) # find minimum of x data
	goal_path[:, 1] = goal_path[:, 1] .- x_central

    # norm data
	norm_scale =  maximum(goal_path[:, 1])
	goal_path[:, 1] = goal_path[:, 1] ./ norm_scale
	goal_path[:, 2] = goal_path[:, 2] ./ norm_scale
    
    # scale data
	xy_scale = 1.5
    goal_path[:, 1] = goal_path[:, 1] .* xy_scale
	goal_path[:, 2] = goal_path[:, 2] .* xy_scale
	
    # translate data
	x_translation = 0.3 # mm
	y_translation = (maximum(goal_path[:, 2]) + minimum(goal_path[:, 2])) /2
	goal_path[:, 1] = goal_path[:, 1] .+ x_translation
	goal_path[:, 2] = goal_path[:, 2] .- y_translation
	goal_path[:, 2] = -goal_path[:, 2] # flippeljük az y tengelyt, mert még így maradt a tabletes feldolgozásból az adat

    # plot data
    plt_goal = plot(goal_path[:, 1], goal_path[:, 2], 
    xlims=(-4, 4), ylims=(-3, 3), 
    framestyle=:origin, aspect_ratio=:equal, 
    label = "Cél nyomvonal", 
    legend=:topright,
    title = "Cél a neurális hálónak")
    plt_goal = plot_Circle(2, plt_goal)
    savefig(plt_goal, "TestPendulum_Neural/results/goal_path.pdf")
end


# Using the neural network
    # initialize/load the newtwork
    # set up the goal
    # use this block to test the results
    network = load_network("TestPendulum_Neural/results/trained_network_1200.jls")

begin
    _, _, predicted_joints = forward(network, goal_path)
    direct_data = vcat(direct_kinematics.(predicted_joints[:, 1], predicted_joints[:, 2])...) # use the direct kinematics
    direct_x, direct_y = direct_data[:, 1], direct_data[:, 2] # structurize data

    plt_result = plot(direct_x, direct_y,
    xlims=(-4, 4), ylims=(-2, 2), 
    framestyle=:origin, aspect_ratio=:equal, 
    label = "Eredményezett útvonal, hiba: $(round(losses[end], digits = 4))", 
    legend=:bottomright,
    title = "Neurális háló eredménye\n(koordinátatérben)")
    plt_result = plot_Circle(2, plt_result)
    savefig(plt_result, "TestPendulum_Neural/results/result_path_"*string(round(losses[end], digits = 4))*".pdf")
    
    
end

function plotLosses(losses)
    println("Last loss: $(losses[end])")
    println("Min loss: $(minimum(losses))")
    plt = plot(losses,
    xlabel = "Tanulási ciklusok (vegyes)", ylabel = "Hiba [rad]",
    title = "Hiba a tanulás során",
    label = "hiba"
    )
    return plt
end

plt_loss = plotLosses(losses)

minimum(losses)
losses[end]
rad2deg(losses[end])
losses[end]
round(losses[end], digits = 3)



# meg kellene próbálni és normalizált adatokkal tanítani...