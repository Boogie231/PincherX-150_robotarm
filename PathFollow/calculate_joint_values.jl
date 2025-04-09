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
	# measure time
    time1 = time()
	
	# Orientáció meghatározása:
	a_vec1 = [0, 0, -1]
	o_vec1 = [0, 1, 0]
	full_orientation,_,_ = Define_goal_orientation(a_vec1, o_vec1)
	
	
	# Work with data
	data = Read_In("PathFollow\\inputData\\coordinates3.txt"; first_line = true)
	
	# scale data for the robot:
	norm_scale =  maximum(data[:, 1])
	xy_scale = 200
	z_scale = 2
	x_translation = 80 # archive values: 30 - too low
	data[:, 1] = data[:, 1] ./ norm_scale .*xy_scale .+ x_translation
	data[:, 2] = data[:, 2] ./ norm_scale .*xy_scale
	data[:, 2] = data[:, 2] .- maximum(data[:, 2]) ./2
	data[:, 2] = -data[:, 2]
	data[:, 3] = data[:, 3] ./ z_scale

	# save the used data as a pdf
	file_path = "PathFollow\\results\\test5"

	plt = scatter([data[:, 1]], [data[:, 2]], [data[:, 3]], aspect_ratio = 1, ms = 1)
	savefig(plt, file_path*"_dataUsed.pdf")

	short_index = 169
	data_format = [vec(row) for row in eachrow(data[1:short_index, :])]
	path = Define_goal.(data_format, fill(full_orientation, length(data_format)))

	Follow_path(path; filename = file_path, α = 0.01, param = 20000, d_p = 1 ,d_r = 0.05, i_max = 250)
	
	# measure time
	elapsed_time = time()-time1;
    println("Elapsed time: $(elapsed_time) sec ($(elapsed_time/60) min)")
end


# Setting up data scaleing

# plot([data[:, 1]], [data[:, 2]], [data[:, 3]])
plot([data[:, 1]], [data[:, 2]], [data[:, 3]], aspect_ratio = 1)
plt = scatter([data[:, 1]], [data[:, 2]], [data[:, 3]], ms = 1,  aspect_ratio = 1)
savefig(plt, "Date_used.pdf")

plotly()
gr()

path = Define_goal.(data_format, fill(full_orientation, length(data_format)))
path[1:3]
# data[:, 2] = data[:, 2] * 100

# data[:, 1]
# data[:, 2]


