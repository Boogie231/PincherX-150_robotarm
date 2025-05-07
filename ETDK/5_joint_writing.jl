begin

	using Pkg
	Pkg.activate()
	using MeshCat
	using RigidBodyDynamics
	using MeshCatMechanisms
	using StaticArrays
    # using Flux

	using LinearAlgebra
	using Rotations
    using GLMakie
    using CairoMakie

    # using Plots

    include("..\\GeneralFunctions\\file_read_write.jl")
    include("..\\NeuralNetworks\\basic_mine.jl")
    include("..\\NeuralNetworks\\activation_functions.jl")
    include("..\\GeneralFunctions-PincherX\\visualize_pro.jl")

    println("Setup done...")

end



begin
	
	# Adatok visszaolvasása:
	path = "FerdeSik\\results\\test3"
	data_qs = Read_In(path*"_qs.txt"; first_line = true)
	data_xs = Read_In(path*"_xs.txt"; first_line = true)

end



begin
    GLMakie.activate!() 
    # 3D ábra készítése
    fig = Figure(resolution = (800, 900), padding = 40)
    ax3d = Axis3(fig[1, 1];
        title = "Efektor pályája (3D)",
        xlabel = "X [mm]", ylabel = "Y [mm]", zlabel = "Z [mm]",
        titlesize = 38,
        xlabelsize = 30,
        ylabelsize = 30,
        zlabelsize = 30,
        xticklabelsize = 20,
        yticklabelsize = 20,
        zticklabelsize = 20
    )

    # Observables a 3D pályához
    xs = Observable(Float32[])
    ys = Observable(Float32[])
    zs = Observable(Float32[])

    # Vonallal való kirajzolás
    lineplot = scatter!(ax3d, xs, ys, zs; color = :red, linewidth = 2, label = "valós nyomvonal")

    area_size = 250
    # Koordináta tengelyek ábrázolása
    lines!(ax3d, [-area_size, area_size], [0, 0], [0, 0], color = :red, linewidth = 2) # X tengely
    lines!(ax3d, [0, 0], [-area_size, area_size], [0, 0], color = :green, linewidth = 2) # Y tengely
    lines!(ax3d, [0, 0], [0, 0], [-area_size, area_size], color = :blue, linewidth = 2) # Z tengely

    autolimits!(ax3d)
    # xlims!(ax3d, (0, 250)) 
    # ylims!(ax3d, (-100, 100)) 
    # zlims!(ax3d, (0, 100)) 

    axislegend(ax3d, labelsize = 22)
    cam_pos = Vec3(5, 5, 5)  # Position of the camera
    cam_lookat = Vec3(0, 0, 0)  # Point the camera is looking at
    cam_up = Vec3(0, 1, 0)  # Up direction
    
    


    display(fig)
    sleep(1)
    println("Done Makie...")

    # Animáció futtatása
    for i in 1:length(data_xs[:, 1])
        println(data_qs[i, :])
        Teszt(data_qs[i, :])

        # Új pont hozzáadása
        push!(xs[], data_xs[i, 1])
        push!(ys[], data_xs[i, 2])
        push!(zs[], data_xs[i, 3])

        notify(xs)
        notify(ys)
        notify(zs)

        # MeshCat render például:
        # MeshCatMechanisms._render_state!(mvis1, state)

        sleep(1)
    end

    println("Animáció vége")
end

# Save figure:
begin
    CairoMakie.activate!()  
    save("final_figure2.pdf", fig)  # same fig reused
    
end

begin
    
    fig = Figure(resolution = (1200, 600))

    # === Left side: 3D plot ===
    lscene = LScene(fig[1, 1], scenekw = (show_axis = true,))

    # Some sample surface data — replace with your own
    x = LinRange(0, 10, 100)
    y = LinRange(0, 10, 100)
    z = [sin(xi) + cos(yi) for xi in x, yi in y]
    surface!(lscene, x, y, z)

    # Optional: add more padding to reveal labels
    # fig.layout[1, 1].padding = (30, 60, 30, 40)

    # === Right side: 3 stacked 2D plots ===
    for i in 1:3
        ax = Axis(fig[i, 2])
        lines!(ax, data_xs[:, i + 3], color = :blue, label = "data_xs[$(i + 3)]")
        axislegend(ax)
    end

    fig
end