# This code aims to animate the data provided by the codes of this folder


begin
	# using Pkg
	# Pkg.activate()
	# using Images
	# using Symbolics
	using LinearAlgebra
	# using Rotations
	# using PlutoUI
	using RigidBodyDynamics
	using MeshCatMechanisms
	# using StaticArrays
	using Plots
end


include("..\\GeneralFunctions\\file_read_write.jl")
include("..\\GeneralFunctions-PincherX\\visualize_pro.jl")


# Adatok visszaolvasása:
data_qs = Read_In("test1_qs.txt"; first_line = true)
data_xs = Read_In("test1_xs.txt"; first_line = true)

Simulate(data_qs,delay = 0.002, i_max = 3020)
println("Done")



plotly() 
plt = plot([data_xs[:, 1]], [data_xs[:, 2]], [data_xs[:, 3]])
savefig(plt, ".pdf")
