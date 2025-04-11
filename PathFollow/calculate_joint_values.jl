#=
This code aims to generate joint values for the robotic arm, with multiple use of 
inverse kinematics, using an orientation of pointing vertically downward thw whole time.


=#

begin
	using Pkg
	Pkg.activate()
	# using Images
	# using Symbolics
	using LinearAlgebra
	# using Rotations
	# using PlutoUI
	# using RigidBodyDynamics
	# using MeshCatMechanisms
	# using StaticArrays
	using Plots
end

include("..\\GeneralFunctions\\file_read_write.jl")
include("..\\GeneralFunctions-PincherX\\goal_and_orientation.jl")
include("..\\GeneralFunctions-PincherX\\direct_kinematics.jl")
include("followpath.jl")


begin
	file_path = "PathFollow\\results\\test16"


	# measure time
    time1 = time()
	
	# Orientáció meghatározása:
	a_vec1 = [0, 0, -1]
	o_vec1 = [1, 0, 0] # legyen az x tengely, amire ráfog
	full_orientation,_,_ = Define_goal_orientation(a_vec1, o_vec1)
	
	# General data:
	used_index = 40
	
	# Work with data
	data = Read_In("PathFollow\\inputData\\coordinates3.txt"; first_line = true)
	data = data[1:used_index, :]
	
	# scale data for the robot:
	norm_scale =  minimum(data[:, 1])
	xy_scale = 110 # kiserleti adat
	z_scale = 4
	data[:, 1] = data[:, 1] ./ norm_scale .*xy_scale 
	data[:, 2] = data[:, 2] ./ norm_scale .*xy_scale
	data[:, 3] = data[:, 3] ./ z_scale

	
	x_translation = 0 # mm
	y_translation = (maximum(data[:, 2]) + minimum(data[:, 2])) /2
	z_translation = 86 # mm, 

	data[:, 1] = data[:, 1] .+ x_translation
	data[:, 2] = data[:, 2] .- y_translation
	data[:, 2] = -data[:, 2]
	data[:, 3] = data[:, 3] .+ z_translation

	
	# save the used data as a pdf
	plt = scatter([data[:, 1]], [data[:, 2]], [data[:, 3]], aspect_ratio = 1, ms = 1, xlabel = "x irány (mm)", ylabel = "y irány (mm)", zlabel = "z irány (mm)", 
	title = "Az inverzkinematikától megkért pontok halmaza", label = "index = $(used_index)\nxy_scale = $(xy_scale)\nz_scale = $(z_scale)\nx_translation = $(x_translation)\nz_translation = $(z_translation)")
	savefig(plt, file_path*"_dataUsed.pdf")

	data_format = [vec(row) for row in eachrow(data[1:used_index, :])]
	path = Define_goal.(data_format, fill(full_orientation, length(data_format)))

	Follow_path(path; filename = file_path, α = 0.01, param = 20000, d_p = 1 ,d_r = 0.05, i_max = 250)
	
	# measure time
	elapsed_time = time()-time1;
    println("Elapsed time: $(elapsed_time) sec ($(elapsed_time/60) min)")
end




plotly()
gr()

plt