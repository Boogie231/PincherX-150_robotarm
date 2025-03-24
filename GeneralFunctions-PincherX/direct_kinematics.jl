begin    
    using Symbolics
    # using Random
    # using LinearAlgebra
    # using Statistics
end

# Calculations needed

@variables q1, q2, q3, q4, q5

begin
	# A transzformáció felépítése, homogén transzformációs mátrixokkal:
	
	R0 = [cos(q1) -sin(q1) 0 0; sin(q1) cos(q1) 0 0; 0 0 1 0; 0 0 0 1]
	
	t1 = 103.91
	T1 = [1 0 0 0; 0 1 0 0; 0 0 1 t1; 0 0 0 1] # z irányú eltolás
	R1 = [cos(q2) 0 sin(q2) 0; 0 1 0 0; -sin(q2) 0 cos(q2) 0; 0 0 0 1]
	
	t2 = 150
	T2 = [1 0 0 0; 0 1 0 0; 0 0 1 t2; 0 0 0 1] # z irányú eltolás
	
	t3 = 50 
	T3 = [1 0 0 t3; 0 1 0 0; 0 0 1 0; 0 0 0 1] # x irányú eltolás
	R3 = [cos(q3) 0 sin(q3) 0; 0 1 0 0; -sin(q3) 0 cos(q3) 0; 0 0 0 1]
	
	t4 = 150 
	T4 = [1 0 0 t4; 0 1 0 0; 0 0 1 0; 0 0 0 1] # x irányú eltolás
	R4 = [cos(q4) 0 sin(q4) 0; 0 1 0 0; -sin(q4) 0 cos(q4) 0; 0 0 0 1]
	
	t5 = 65
	T5 = [1 0 0 t5; 0 1 0 0; 0 0 1 0; 0 0 0 1] # x irányú eltolás
	R5 = [1 0 0 0; 0 cos(q5) -sin(q5) 0; 0 sin(q5) cos(q5) 0; 0 0 0 1]
	
	
	t6 = 66 + 43.15
	T6 = [1 0 0 t6; 0 1 0 0; 0 0 1 0; 0 0 0 1] # x irányú eltolás
	
	T = R0*T1*R1*T2*T3*R3*T4*R4*T5*R5*T6
end

pos = simplify(T)[[1,2,3], 4]
rot_Mat = simplify(T)[1:3, 1:3]

function Find_axis_and_angle(R)
	tr_R = R[1,1] + R[2,2] + R[3,3]
	
	# Lázár-képletei:
	theta = acos((tr_R - 1) / 2)
	
	if typeof(theta)!= Num && theta == 0
		error("Error at find axis and angle, R = $(R)")
		return 0, [0, 0, 0]
	end
	
	A = R - transpose(R) # antiszimmetrikus rész
	v = [A[3, 2], A[1, 3], A[2, 1]] / (2 * sin(theta))

	return theta, v
end

general_θ,general_v = Find_axis_and_angle(rot_Mat)
general_pos = vcat(pos, general_θ*general_v)  # Függőleges összefűzés

function Theta_for_parameters(q)
	theta = substitute(general_θ, Dict(q1=>q[1], q2=>q[2], q3=>q[3], q4=>q[4], q5=>q[5]))
	return Symbolics.value.(theta)
end

# Direkt kinematikai egyenlet:
# 	hívatott megadni a pozíciót és a forgatottság mértékét egy tengely és egy szög szorzataként (???)
function f(q)
	position = substitute(general_pos, Dict(q1=>q[1], q2=>q[2], q3=>q[3], q4=>q[4], q5=>q[5]))
	
	θ = Theta_for_parameters(q)
	if θ == 0
		# println("θ = $(θ)")
		position = replace(position, NaN => 0.00)
	end
	
	return Symbolics.value.(position)
	
end