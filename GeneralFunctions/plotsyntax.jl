#=
This file aims to describe functions used generally to create plots!
Boogie
2025.03.23.
=#

using Plots

# Sample data
x = 1:10
y1 = rand(10)
y2 = rand(10)
y3 = rand(10)
y4 = rand(10)
y5 = rand(10)
y6 = rand(10)
y7 = rand(10)
y8 = rand(10)

# Function to create subplots
function create_subplots()
    # 4 Subplots
    p1 = plot(x, y1, title="Plot 1", label="Data 1", legend=:topright)
    p2 = plot(x, y2, title="Plot 2", label="Data 2", legend=:topright)
    p3 = plot(x, y3, title="Plot 3", label="Data 3", legend=:topright)
    p4 = plot(x, y4, title="Plot 4", label="Data 4", legend=:topright)

    # Combine 4 plots in a 2x2 layout
    plot(p1, p2, p3, p4, layout=(2, 2), size=(800, 600))

    # 6 Subplots
    p5 = plot(x, y5, title="Plot 5", label="Data 5", legend=:topright)
    p6 = plot(x, y6, title="Plot 6", label="Data 6", legend=:topright)

    # Combine 6 plots in a 2x3 layout
    plot(p1, p2, p3, p4, p5, p6, layout=(2, 3), size=(800, 600))

    # 8 Subplots
    p7 = plot(x, y7, title="Plot 7", label="Data 7", legend=:topright)
    p8 = plot(x, y8, title="Plot 8", label="Data 8", legend=:topright)

    # Combine 8 plots in a 2x4 layout
    plot(p1, p2, p3, p4, p5, p6, p7, p8, layout=(2, 4), size=(800, 600))
end

# Call the function to create subplots
create_subplots()
