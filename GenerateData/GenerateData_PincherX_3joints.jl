#=
This code aims to generate training data for the PincherX-150's neural network (3 joint version).
Conclusion: there was not any significant difference in the elapsed time for the two implemented method

2025.03.22
Boogie
=#

# Parameters for the code
begin
    n_samples = 100000  # minták száma
    
end


include("..\\GeneralFunctions\\file_read_write.jl")
include("..\\GeneralFunctions-PincherX\\direct_kinematics.jl")

# Adatok generálása
function generate_data(n_samples)
    x = zeros(n_samples, 3)
    y = zeros(n_samples, 3)
    
    for i in 1:n_samples
        q1 = rand() * π -π/2
        q2 = rand() * π -π/2
        q3 = rand() * π -π/2
        pos = f([q1 q2 q3 0 0])
        

        x[i, :] .= pos[1:3]
        y[i, :] .= [q1, q2, q3]
        println("$(i/n_samples*100)%")
    end
    
    return x, y
end

# function generate_data(n_samples)    
#     q1 = rand(n_samples) * π .-π/2
#     q2 = rand(n_samples) * π .-π/2
#     q3 = rand(n_samples) * π .-π/2
#     z = zeros(n_samples)    

#     inputs = [f([q1[i], q2[i], q3[i], z[i], z[i]]) for i in 1:n_samples]
#     pos = reduce(hcat, inputs)'
    
#     x = pos[:, 1:3]
#     y = hcat(q1, q2, q3)
    
#     return x, y
# end

begin
    time1 = time()
    println("Generating $(n_samples) data...")
    x, y = generate_data(n_samples)
    # println(x)
    # println(y)
    # println(size(x))
    # println(size(y))
    println("Saving data...")
    Print_Matrix(hcat(x, y); filename = "GenerateData\\datasets\\data_Pincher_3joint.txt", header = "x, y, z, q1, q2, q3")
    
    println("Generating $(n_samples) data --> Completed")
    elapsed_time = time()-time1;
    println("Elapsed time: $(elapsed_time) sec")
    
end



