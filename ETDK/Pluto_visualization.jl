### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ 642990ad-e21c-432f-9dc6-933305559982
begin

	using Pkg
	Pkg.activate()
	using MeshCat
	using RigidBodyDynamics
	using MeshCatMechanisms
	using StaticArrays
	using LinearAlgebra
	using Rotations
	# using Plots
	using GLMakie

end


# ╔═╡ f4d1da40-29ad-11f0-1df3-9375c985a959
md"""
# Szinkron-plot
"""

# ╔═╡ b5451724-e92e-49e1-9f3e-327a5ab41266
begin
	urdf = "Acrobot_mod.urdf" # modified Acrobot
	mechanism = parse_urdf(urdf)
	mvis1 = MechanismVisualizer(mechanism,URDFVisuals(urdf))
	state = MechanismState(mechanism)
    shoulder, elbow = joints(mechanism)

    velocity(state, shoulder)
    configuration(state, shoulder)
end

# ╔═╡ b50a85a9-c140-4b05-97cc-a9640de38455
# render(mvis1)	

# ╔═╡ fb910ac4-7f3b-46c9-9aaf-e5884561f380
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
	
end

# ╔═╡ a6747844-ff35-4f57-9323-25d3cd2e5c70
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

# ╔═╡ cfb11c46-f595-4ebf-93d5-c636e7af1acb
begin
	frame_tip = CartesianFrame3D("tip")
		    tip_to_after_elbow = Transform3D(frame_tip, frame_after(elbow), SVector(1.0, 0.0, 0.0))
		    add_body_fixed_frame!(mechanism, tip_to_after_elbow)
		    End_Point = Point3D(frame_tip, [0, 0, 0])
end

# ╔═╡ 117973f9-45c6-4f93-b819-ed7facf599a5
begin
   
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

        # sleep(0.01)
    end

    println("Animáció vége")
end


# ╔═╡ 99313c4c-6ccc-42bf-8546-1bcac320897e


# ╔═╡ 52c78074-a967-44fe-89a2-3966f9b845c2
# Direct kinematics
function direct_kinematics(theta1, theta2; L1 = 1, L2 = 1)
    x = L1 * cos(theta1) + L2 * cos(theta1 + theta2)
    y = L1 * sin(theta1) + L2 * sin(theta1 + theta2)
    return hcat(x, y)
end

# ╔═╡ d403763c-a1c5-4137-97e1-d37227104472
# ╠═╡ disabled = true
#=╠═╡
# begin
# 	# Előkészítjük a mechanikai szimulációt
#     zero_velocity!(state)
#     set_configuration!(state, shoulder, 1)
#     set_configuration!(state, elbow, 1.5)
#     set_velocity!(state, shoulder, 1.)
#     set_velocity!(state, elbow, 4.1)
# 	final_time = 10
#     ts, qs, vs = simulate(state, final_time)

# 	# Convert to a matrix
# 	matrix = hcat([collect(vec) for vec in qs]...)'
	
# 	# Display the resulting matrix
# 	using Plots
# 	direct_data = vcat(direct_kinematics.(matrix[:, 1], matrix[:, 2])...) # structurize data
# 	direct_x, direct_y = direct_data[:,1], direct_data[:,2] # structurize data	

# 	plot(direct_x, direct_y)
	
	
# end
  ╠═╡ =#

# ╔═╡ Cell order:
# ╟─f4d1da40-29ad-11f0-1df3-9375c985a959
# ╠═642990ad-e21c-432f-9dc6-933305559982
# ╠═b5451724-e92e-49e1-9f3e-327a5ab41266
# ╠═b50a85a9-c140-4b05-97cc-a9640de38455
# ╠═fb910ac4-7f3b-46c9-9aaf-e5884561f380
# ╠═a6747844-ff35-4f57-9323-25d3cd2e5c70
# ╠═cfb11c46-f595-4ebf-93d5-c636e7af1acb
# ╠═117973f9-45c6-4f93-b819-ed7facf599a5
# ╠═99313c4c-6ccc-42bf-8546-1bcac320897e
# ╠═52c78074-a967-44fe-89a2-3966f9b845c2
# ╠═d403763c-a1c5-4137-97e1-d37227104472
