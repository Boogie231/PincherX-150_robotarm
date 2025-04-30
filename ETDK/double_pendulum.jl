#= 
This code aims to generate a simulation about the Double Pendulum, as a 2 joint robotic arm in the xOy plane

based on: homework 7 of Robophysiks
=#


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

begin
	urdf = "ETDK/Acrobot_mod.urdf" # modified Acrobot
	mechanism = parse_urdf(urdf)
	mvis1 = MechanismVisualizer(mechanism,URDFVisuals(urdf))
	state = MechanismState(mechanism)
    shoulder, elbow = joints(mechanism)

    velocity(state, shoulder)
    configuration(state, shoulder)
end

# Szimuláció
begin
	final_time = 4
	zero_velocity!(state)
	set_configuration!(state, shoulder, 0.785)
	set_configuration!(state, elbow, 2.785);
	set_velocity!(state, shoulder, 1.)
	set_velocity!(state, elbow, 4.1)
	# ts, qs, vs = simulate(state, final_time; Δt = 1e-5);
	ts, qs, vs = simulate(state, final_time);

	MeshCatMechanisms._render_state!(mvis1,state)
	render(mvis1)
    MeshCatMechanisms.animate(mvis1, ts .*0.5, qs)
end

# Végpont kezelése:

begin
	frame_tip = CartesianFrame3D("tip")
	tip_to_after_elbow = Transform3D(frame_tip, frame_after(elbow), SVector(1.,0.,0.))
	add_body_fixed_frame!(mechanism, tip_to_after_elbow)
	End_Point = Point3D(frame_tip, [0, 0, 0])
end

begin
	# 1. Módszer	
	x1 = []
	y1= []

	# Karok hosszai:
	l1 = 1
	l2 = 1
	
	for q in qs_con
		# Beállítom az adott pozíciót:
		set_configuration!(state, q)

		# 1. Módszer	
		push!(x1, (transform_to_root(state, frame_tip)*End_Point).v[1]) # v-fel férek hozzá a pont paraméteréhez
		push!(y1, (transform_to_root(state, frame_tip)*End_Point).v[2])	
		
	end	
end
