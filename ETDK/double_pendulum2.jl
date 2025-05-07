begin

	using Pkg
	Pkg.activate()
	using MeshCat
	using RigidBodyDynamics
	using MeshCatMechanisms
	using StaticArrays
    using Flux

	using LinearAlgebra
	using Rotations
    using GLMakie
    # using Plots

    include("..\\GeneralFunctions\\file_read_write.jl")
    include("..\\NeuralNetworks\\basic_mine.jl")
    include("..\\NeuralNetworks\\activation_functions.jl")
    println("Setup done...")

end

# Start MeshCat simulation:
begin
	urdf = "ETDK/Acrobot_mod.urdf" # modified Acrobot
	mechanism = parse_urdf(urdf)
	mvis1 = MechanismVisualizer(mechanism,URDFVisuals(urdf))
	state = MechanismState(mechanism)
    shoulder, elbow = joints(mechanism)

    # velocity(state, shoulder)
    # configuration(state, shoulder)
end

# Only a plot
begin
    fig = Figure()
       ax = Axis(fig[1, 1]; title = "Effector pályája", xlabel = "X", ylabel = "Y",aspect=DataAspect())
       xs = Observable(Float32[])
       ys = Observable(Float32[])
   
       # Pálya kirajzolása vonallal
       lineplot = lines!(ax, xs, ys, color = :red, linewidth = 2,  label="nyomvonal")
    #    lineplot = scatter!(ax, xs, ys, color = :red, linewidth = 2)
       xlims!(ax, (-2, 2)) 
       ylims!(ax, (-2, 2)) 
   
   # Draw the x-axis (OX)
   lines!(ax, [-2, 2], [0, 0], color=:black, linewidth=2)
   
   # Draw the y-axis (OY)
   lines!(ax, [0, 0], [-2, 2], color=:black, linewidth=2)
   axislegend(ax)
   
    display(fig)  # Makie ablak megnyitása

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

end

goal_x, goal_y = goal_path[:, 1], goal_path[:, 2]

model = deserialize("TestPendulum_Neural\\results\\Flux\\trained_network_Flux0.00166.jls")
predicted_joints = model(goal_path')'  # Use the model directly for predictions

template_state = MechanismState(mechanism)

converted_qs = [
    begin
        qvec = copy(configuration(template_state))  # Get a SegmentedVector copy
        qvec .= Float64.(predicted_joints[i, :])  # Copy values (convert Float32 → Float64)
        qvec
    end
    for i in 1:size(predicted_joints, 1)
]

begin
    # Előkészítjük a mechanikai szimulációt
       zero_velocity!(state)
       set_configuration!(state, shoulder, 1)
       set_configuration!(state, elbow, 1.5)
       set_velocity!(state, shoulder, 1.)
       set_velocity!(state, elbow, 4.1)
   
       final_time = 10.01
       ts, qs, vs = simulate(state, final_time)

    qs = qs[1:100:end]
end

begin
	frame_tip = CartesianFrame3D("tip")
    tip_to_after_elbow = Transform3D(frame_tip, frame_after(elbow), SVector(1.0, 0.0, 0.0))
    add_body_fixed_frame!(mechanism, tip_to_after_elbow)
    End_Point = Point3D(frame_tip, [0, 0, 0])
end

begin
    fig = Figure()
       ax = Axis(fig[1, 1]; title = "Efektor pályája", xlabel = "X", ylabel = "Y",aspect=DataAspect(),
       titlesize = 38,
       xlabelsize = 30,
       ylabelsize = 30,
       xticklabelsize = 20,
       yticklabelsize = 20)
       xs = Observable(Float32[])
       ys = Observable(Float32[])
   
       # Pálya kirajzolása vonallal
       lineplot = lines!(ax, xs, ys, color = :red, linewidth = 2,  label="valós nyomvonal")
       lineplot = scatter!(ax, xs, ys, color = :red, linewidth = 2)

       lineplot = lines!(ax, goal_x, goal_y, color = :blue, linewidth = 2,  label="cél nyomvonal")

       xlims!(ax, (-2, 2)) 
       ylims!(ax, (-2, 2)) 
       
   
   # Draw the x-axis (OX)
   lines!(ax, [-2, 2], [0, 0], color=:black, linewidth=2)
   
   # Draw the y-axis (OY)
   lines!(ax, [0, 0], [-2, 2], color=:black, linewidth=2)
   axislegend(ax, labelsize = 22)

   
    display(fig)  # Makie ablak megnyitása
    sleep(1)
    println("Done Makie...")
    # Animáció futtatása
    for (i, q) in enumerate(converted_qs)
        set_configuration!(state, q)

        # Számoljuk az effektor pozícióját
        ee_pos = transform_to_root(state, frame_tip) * End_Point

        # Adatok hozzáadása és frissítés
        push!(xs[], Float32(ee_pos.v[1]))
        push!(ys[], Float32(ee_pos.v[2]))
		# println(ee_pos.v[1])
        notify(xs)
        notify(ys)  

        # MeshCat render
        MeshCatMechanisms._render_state!(mvis1, state)

        sleep(0.1)
    end

    println("Animáció vége")
end
