begin

	using Pkg
	Pkg.activate()
	using MeshCat
	using RigidBodyDynamics
	using MeshCatMechanisms
	using StaticArrays
	using LinearAlgebra
	using Rotations
    using GLMakie
    # using Plots

end

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
       ax = Axis(fig[1, 1]; title = "Effector pályája", xlabel = "X", ylabel = "Y",aspect=DataAspect())
       xs = Observable(Float32[])
       ys = Observable(Float32[])
   
       # Pálya kirajzolása vonallal
       lineplot = lines!(ax, xs, ys, color = :red, linewidth = 2,  label="nyomvonal")
       lineplot = scatter!(ax, xs, ys, color = :red, linewidth = 2)
       xlims!(ax, (-2, 2)) 
       ylims!(ax, (-2, 2)) 
   
   # Draw the x-axis (OX)
   lines!(ax, [-2, 2], [0, 0], color=:black, linewidth=2)
   
   # Draw the y-axis (OY)
   lines!(ax, [0, 0], [-2, 2], color=:black, linewidth=2)
   axislegend(ax)
   
    display(fig)  # Makie ablak megnyitása
    # sleep(1)

    # Animáció futtatása
    for (i, q) in enumerate(qs)
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

        sleep(0.001)
    end

    println("Animáció vége")
end
