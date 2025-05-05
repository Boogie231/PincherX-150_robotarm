### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ b30e8f09-9d45-4dde-b0b4-8a26f71eefe5
begin
	using Pkg; # Pkg.status()
	Pkg.activate()
	using MeshCat
	using RigidBodyDynamics
	using MeshCatMechanisms
	using StaticArrays
	using LinearAlgebra
	using Rotations
	using Plots
end

# ╔═╡ e87a0b1e-b47f-40bf-afdd-88fdb0a2a038
md"""
# Feladatlap #7

Ennek a feladatlapnak a keretében a `RigidBodyDynamics.jl` csomag segítségével tanulmányozzuk a robotok mozgását illetve irányítását. 
"""

# ╔═╡ 57596a04-79f5-4d97-b45e-7cdf77f86bdb
md"""
### 1. Feladat (6 pont)

Építsünk egy egyszerű fizikai ingát, melynek a felfüggesztési pontját periodikusan, pl. szinuszosan, mozgatjuk az $y$ tengely mentén (lásd a [videót](http://theorphys.elte.hu/fiztan/chaos/Chaos2.html)).
"""

# ╔═╡ 0d914012-0d2a-4b4b-abec-2871a7ca9382
# Másik dokumentumban kidolgozva

# ╔═╡ 6056ebfc-c90a-4624-8fec-652a1351f3c2
md"""
### 2. Feladat (4 pont)

A korábban használt Acrobot.urdf fájl átszerkesztésével hozzunk létre egy $(x,y)$ síkban mozgó, két csuklóval rendelkező robotkart. Irányítsuk a kar mozgását véletlenszerűen változó nyomatékok alkalmazásával (a csuklók esetén bevezethetünk be egy a szögsebességgel arányos disszipációt/súrlódást is).
"""

# ╔═╡ 3b408a5a-fb47-4457-8341-7b1ccab9572f
md"""
!!! hint "Tipp!"

    Az urdf fájlban az `rpy` paraméter-hármas segítségével az adott koordinátarendszer orientációja [adható meg](http://wiki.ros.org/urdf/Tutorials/Building%20a%20Visual%20Robot%20Model%20with%20URDF%20from%20Scratch) a roll-pitch-yaw szögek segítségével.
"""

# ╔═╡ 083e6df9-4174-4d48-a8e0-1261f379e9b0
md"""
(a) *( 2 pont)* Szimuláljuk majd vizualizáljuk a kar mozgását.
"""

# ╔═╡ 25fa7b82-bddf-4958-9fd6-0821660c823e
begin
	urdf = "Acrobot_mod.urdf" # modified Acrobot
	mechanism = parse_urdf(urdf)
	mvis1 = MechanismVisualizer(mechanism,URDFVisuals(urdf))
	state = MechanismState(mechanism)
		
end

# ╔═╡ 43470525-1115-463f-861e-bbef6048ddee
shoulder, elbow = joints(mechanism)

# ╔═╡ e196e975-e5c6-49b1-92d3-1d0718f0fdea
velocity(state, shoulder)

# ╔═╡ bc27cd62-3cc4-459f-a2c2-de3a3316b381
configuration(state, shoulder)

# ╔═╡ 93d728b7-12d1-4dda-ae69-faed2db139f7
begin
	final_time = 4
	zero_velocity!(state)
	set_configuration!(state, shoulder, 0.785)
	set_configuration!(state, elbow, 0.785);
	set_velocity!(state, shoulder, 1.)
	set_velocity!(state, elbow, 0.)
	# ts, qs, vs = simulate(state, final_time; Δt = 1e-3);
	
	
	MeshCatMechanisms._render_state!(mvis1,state)
	ts, qs, vs = simulate(state, final_time);
	# render(mvis1)
end

# ╔═╡ 54840a6d-15e3-4f09-9bf4-62a9733dbad9
state.q

# ╔═╡ f0ef03e6-2063-4080-b1aa-d62b6befc149
state.v

# ╔═╡ adde2da4-77b5-422e-a3ad-9a92e41c9227
render(mvis1)

# ╔═╡ d038f0de-64e7-4551-a901-750f30bf721c
MeshCatMechanisms.animate(mvis1, ts, qs)

# ╔═╡ 86c67af3-6ee0-4531-bc4b-3473f247bd3a
function rand_control!(torques::AbstractVector, t, state::MechanismState)
	# torques = 15 *rand(2)  # varázsparaméter XD
	torques = 15 * rand(2)

	
	# torques[velocity_range(state, elbow)] .= 3*rand() .- 4 .* velocity(state, elbow)	
 #    torques[velocity_range(state, shoulder)] .= 11 * rand() .-2 .* velocity(state, shoulder)

	# shouldernek nagyobb nyomatékot kellett rakjak
end

# ╔═╡ 8e327d15-8173-4b21-a46b-b458def05210
# Mozgatáshoz:
begin
	mvis_con = MechanismVisualizer(mechanism, URDFVisuals(urdf))	
	zero_velocity!(state)
	set_configuration!(state, shoulder, 1.0)
	set_configuration!(state, elbow, 0.0);
	MeshCatMechanisms._render_state!(mvis_con,state)
	ts_con, qs_con, vs_con = simulate(state, final_time, rand_control!);
end

# ╔═╡ 6c18be9f-8ccb-4deb-8ae9-1d0d00d6ba00
MeshCatMechanisms.render(mvis_con)

# ╔═╡ 9d746aeb-56ce-42dc-8022-eb7c7e90d5e5
# MeshCatMechanisms.animate(mvis_con, ts_con, qs_con; realtimerate = 1)

# ╔═╡ f6d25662-a635-4bb5-ad1c-c1f03a703ba0
md"""
(b) *(2 pont)* Határozzuk meg kétféleképpen a kar effektorjának pozícióját a világ koordináta-rendszerében majd ábrázoljuk őket ugyanabban az $(x,y)$ síkban.
"""

# ╔═╡ 6e26054e-30ca-48b3-95df-9ec8cd5da95c
md"""
!!! hint "Tipp!"

    Például: a kurzuson levezetett összefüggés vs. beépített függvények használata. 
"""

# ╔═╡ 350570e5-8478-444a-9e2e-610a70ebb2fa
begin
	frame_tip = CartesianFrame3D("tip")
	tip_to_after_elbow = Transform3D(frame_tip, frame_after(elbow), SVector(1.,0.,0.))
	add_body_fixed_frame!(mechanism, tip_to_after_elbow)
	End_Point = Point3D(frame_tip, [0, 0, 0])
end

# ╔═╡ 6c49e8c4-4851-4ed6-902b-d9523bc0a085
begin
	# 1. Módszer	
	x1 = []
	y1= []

	# 2. Módszer
	x2 = []
	y2 = []

	# Karok hosszai:
	l1 = 1
	l2 = 1
	
	for q in qs_con
		# Beállítom az adott pozíciót:
		set_configuration!(state, q)

		# 1. Módszer	
		push!(x1, (transform_to_root(state, frame_tip)*End_Point).v[1]) # v-fel férek hozzá a pont paraméteréhez
		push!(y1, (transform_to_root(state, frame_tip)*End_Point).v[2])	

		# 2. Módszer
		push!(y2,l1*sin(q[1])+l2*sin(q[1]+q[2]))
		push!(x2,l1*cos(q[1])+l2*cos(q[1]+q[2]))
		
	end	
end

# ╔═╡ a9e8aa51-c2a1-44c7-89ee-60c4745590a9
begin
	plt = plot(title = "Random vezérlés", legend=:bottomleft)
	plot!(plt, x1, y1, label = "Beépített függvénnyel", xlabel = "x", ylabel = "y", lw = 2, framestyle=:origin, aspect_ratio=:equal, lc=:black)

	δ = 0.02
	plot!(plt, x2.+δ, y2.+δ, label = "Trigonometrikusan", lc =:green)
end

# ╔═╡ Cell order:
# ╟─e87a0b1e-b47f-40bf-afdd-88fdb0a2a038
# ╟─57596a04-79f5-4d97-b45e-7cdf77f86bdb
# ╠═0d914012-0d2a-4b4b-abec-2871a7ca9382
# ╠═b30e8f09-9d45-4dde-b0b4-8a26f71eefe5
# ╟─6056ebfc-c90a-4624-8fec-652a1351f3c2
# ╟─3b408a5a-fb47-4457-8341-7b1ccab9572f
# ╟─083e6df9-4174-4d48-a8e0-1261f379e9b0
# ╠═25fa7b82-bddf-4958-9fd6-0821660c823e
# ╠═43470525-1115-463f-861e-bbef6048ddee
# ╠═e196e975-e5c6-49b1-92d3-1d0718f0fdea
# ╠═bc27cd62-3cc4-459f-a2c2-de3a3316b381
# ╠═93d728b7-12d1-4dda-ae69-faed2db139f7
# ╠═54840a6d-15e3-4f09-9bf4-62a9733dbad9
# ╠═f0ef03e6-2063-4080-b1aa-d62b6befc149
# ╠═adde2da4-77b5-422e-a3ad-9a92e41c9227
# ╠═d038f0de-64e7-4551-a901-750f30bf721c
# ╠═86c67af3-6ee0-4531-bc4b-3473f247bd3a
# ╠═8e327d15-8173-4b21-a46b-b458def05210
# ╠═6c18be9f-8ccb-4deb-8ae9-1d0d00d6ba00
# ╠═9d746aeb-56ce-42dc-8022-eb7c7e90d5e5
# ╟─f6d25662-a635-4bb5-ad1c-c1f03a703ba0
# ╟─6e26054e-30ca-48b3-95df-9ec8cd5da95c
# ╠═350570e5-8478-444a-9e2e-610a70ebb2fa
# ╠═6c49e8c4-4851-4ed6-902b-d9523bc0a085
# ╠═a9e8aa51-c2a1-44c7-89ee-60c4745590a9
