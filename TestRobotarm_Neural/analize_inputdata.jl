begin
    using Pkg
	Pkg.activate()
    using Flux
    using Flux: params
    using Random
    # using Plots # DO NOT USE PLOTS WHILE WORKIING WITH THIS FILE
    using LinearAlgebra
    using Statistics  # Import Statistics for mean
    # using GLMakie   # nem tamogat pdf-et
    using CairoMakie  # nem tamogat 3D nézetet...

    
    include("..\\GeneralFunctions\\file_read_write.jl")
    # include("..\\NeuralNetworks\\basic_mine.jl")
    # include("..\\NeuralNetworks\\activation_functions.jl")
    println("Setup done...")

end

# Read in and normalize the training data
begin
    # Read in the training data
    data = Read_In("GenerateData\\datasets\\data_Pincher_5joint1.txt"; first_line = true)
    teach_ind = 100000
    x_teach = data[1:teach_ind, 1:6]  # coordinates
    y_teach = data[1:teach_ind, 7:11]   # joint values    
    
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



begin
    ind = 10000
    # GLMakie.activate!()

    fig = Figure(resolution = (800, 900), padding = 40)
    ax3d = Axis3(fig[1, 1];
        title = "Tanítási adatok (3D)",
        xlabel = "X [mm]", ylabel = "Y [mm]", zlabel = "Z [mm]  ",
        titlesize = 38,
        xlabelsize = 30,
        ylabelsize = 30,
        zlabelsize = 30,
        xticklabelsize = 20,
        yticklabelsize = 20,
        zticklabelsize = 20,
        xticks = -400:100:400,
        yticks = -400:100:400,
        zticks = -400:50:400
    )

    scatter!(ax3d, x_teach[1:ind, 1], x_teach[1:ind, 2],  x_teach[1:ind, 3]; color = :red, markersize = 2)    
    display(fig)


end


# Metszetek:

begin
    ind = 500    
    fig2 = Figure(resolution = (1200, 300), padding = 40)

    # XY Plane
    ax_xy = Axis(fig2[1, 1]; title = "XY Plane", xlabel = "X [mm]", ylabel = "Y [mm]", aspect = 1)
    scatter!(ax_xy, x_teach[1:ind, 1], x_teach[1:ind, 2]; color = :red, markersize = 5)

    # XZ Plane
    ax_xz = Axis(fig2[1, 2]; title = "XZ Plane", xlabel = "X [mm]", ylabel = "Z [mm]", aspect = 1)
    scatter!(ax_xz, x_teach[1:ind, 1], x_teach[1:ind, 3]; color = :red, markersize = 5)

    # YZ Plane
    ax_yz = Axis(fig2[1, 3]; title = "YZ Plane", xlabel = "Y [mm]", ylabel = "Z [mm]", aspect = 1)
    scatter!(ax_yz, x_teach[1:ind, 2], x_teach[1:ind, 3]; color = :red, markersize = 5)

    save("TestRobotarm_Neural\\results\\5joint_data_inspace.pdf", fig2)
    # Display the 2D projections
    display(fig2)

end


# SZeletelés: z = 78.as magasság körül??
begin    

    ind = 100000
    x = x_teach[1:ind, 1]
    y = x_teach[1:ind, 2]
    z = x_teach[1:ind, 3]

    # Intervallum a z tengelyen
    zmin, zmax = 77, 94

    # Szűrés: csak azok a pontok, amelyek z értéke zmin és zmax közé esik
    mask = (z .>= zmin) .& (z .<= zmax)

    x_slice = x[mask]
    y_slice = y[mask]

    # 2D ábra: xOY síkban
    fig = Figure()
    ax = Axis(fig[1, 1]; title="Z ∈ [$zmin, $zmax] metszet", xlabel="X", ylabel="Y")
    scatter!(ax, x_slice, y_slice; markersize=10, color=:blue)
    save("TestRobotarm_Neural\\results\\slice_$zmin-$zmax.pdf", fig)

    fig

end

