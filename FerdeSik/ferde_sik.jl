#=
This code is for testing how much the robotic arm loses of its hight when aproching a spot, depending on how far is 
the spot from the middle axis.
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



begin

	# measure time
    time1 = time()
	
    file_path = "FerdeSik/results/test5"

	# Orientáció meghatározása:
	a_vec1 = [0, 0, -1]
	o_vec1 = [1, 0, 0] # legyen az x tengely, amire ráfog
	full_orientation,_,_ = Define_goal_orientation(a_vec1, o_vec1)
	
	# data_formeasure = [100 0 87; 125 0 87]
	# data_formeasure = [100 0 87; 125 0 87; 150 0 87; 175 0 87; 200 0 87; 225 0 87; 250 0 87] # x axis
	data_formeasure = [0 110 87; 0 125 87; 0 150 87; 0 175 87; 0 200 87; 0 225 87; 0 250 87] # y axis

    # save the used data as a pdf
    plt = scatter([data_formeasure[:, 1]], [data_formeasure[:, 2]], [data_formeasure[:, 3]], aspect_ratio = 1, ms = 1, xlabel = "x irány (mm)", ylabel = "y irány (mm)", zlabel = "z irány (mm)", 
    title = "Az inverzkinematikától megkért pontok halmaza", label = "index = $(used_index)\nxy_scale = $(xy_scale)\nz_scale = $(z_scale)\nx_translation = $(x_translation)\nz_translation = $(z_translation)")
    # savefig(plt, file_path*"_dataUsed.pdf")

    data_format = [vec(row) for row in eachrow(data_formeasure)]
    path = Define_goal.(data_format, fill(full_orientation, length(data_format)))

	Follow_path(path; filename = file_path, α = 0.01, param = 20000, d_p = 1 ,d_r = 0.05, i_max = 250)

	
	
	
	# measure time
	elapsed_time = time()-time1;
    println("Elapsed time: $(elapsed_time) sec ($(elapsed_time/60) min)")
end

file_path

deg2rad(30)
rad2deg(1.13)