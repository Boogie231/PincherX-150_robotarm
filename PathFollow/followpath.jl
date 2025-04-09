function Follow_path(Big_goal; filename = "Challange", α = 0.01, param = 20000, d_p = 2 ,d_r = 0.04, i_max = 200)
	# Inicializálás
	Big_big_qs = []  # Üres tömb a q-k tárolására
	Big_big_xs = []  # Üres tömb az x-ek tárolására

	println("Finding the first route for the first goal...")
	Big_qs, Big_xs = Numerikus_inverz_kin(Big_goal[1], α =α, param = param, d_p = d_p ,d_r = d_r, i_max = 300)  # Kiszámítjuk a qs és xs értékeket
	start_q = Big_qs[end]
	# println(start_q)
	
	# start_q = [-2.6262544677431627e-5, 0.6148409411079253, 0.5858182751350163, -1.457518070119294, -1.5698622540925415]
	# start_q = [0.0003019433768769848, 0.10321577346969718, 0.4179011174464297, 1.032950755757129, -1.5681388332121287]
	
	append!(Big_big_qs, Big_qs)  # Hozzáfűzzük a Big_qs-t a Big_big_qs-hez
	
	println("** Rout found! **")
	
	unfinished_goals = []

	full_length = length(Big_goal)
	# Iterálás a Big_goal-on
	for (index, goal) in enumerate(Big_goal)
		println("\nIndex: ", index, "/$(full_length)\nGoal: ", goal, "")
		# println(Big_qs)
		Big_qs, Big_xs, res = Numerikus_inverz_kin(goal, q = start_q, α =α, param = param, d_p = d_p ,d_r = d_r, i_max = i_max)  # Kiszámítjuk a qs és xs értékeket
		start_q = Big_qs[end]
		append!(Big_big_qs, Big_qs)  # Hozzáfűzzük a Big_qs-t a Big_big_qs-hez
		append!(Big_big_xs, Big_xs)  # Hozzáfűzzük a Big_xs-t a Big_big_xs-hez
		# append!(Big_big_qs, [Big_qs[end]])  # Hozzáfűzzük a Big_qs-t a Big_big_qs-hez
		# append!(Big_big_xs, [Big_xs[end]])  # Hozzáfűzzük a Big_xs-t a Big_big_xs-hez

		if(res == -1)
			push!(unfinished_goals, goal)
		end
			
	end

	# Kiírás fájlba
	Print_Matrix2(Big_big_qs; filename = filename*"_qs.txt")
	Print_Matrix2(Big_big_xs; filename = filename*"_xs.txt")
	Print_Matrix2(unfinished_goals; filename = filename*"_unfinished_goals.txt")


	println("** Program finished finding the q values for the given path! **")
end
