# LET'S DEFINE THE GOAL

function Define_goal_orientation(approach, orientation)
	# Teszünk bele normálást, hogy jobb legyen!
	approach = approach/norm(approach)
	orientation = orientation/norm(orientation)
	#= A cél orientáció megadható vektorokkal: o, a, és n vektorok 
	(ezeket megfeleltettem az x, y, z tengelyeknek a robotra írt transzformációk alapján)
		a: x
		o: z
		n: y
	emiatt más sorrendben fogom beletenni a mátrixba ezeket a vektorokat, mint ahogyan azt a kurzuson tanultuk
	=#
	
	n = cross(orientation, approach)

	# R = hcat(n, orientation, approach) # ez lenne a kurzusos verzio
	R = hcat(approach, n, orientation) # ez a saját kigondolás
	# return R
	# A mátrix alapján meghatározom a cél-elforgatottságot:
	θ,v = Find_axis_and_angle(R)
	# println(R)

	# Visszatérítendő a tengely megszorozva a tengellyel, és esetleg külön-külön is a kettő
	return θ*v, θ, v
end


function Define_goal_orientation(r)
	x, y, z = r
	
	# Az orientációt a v adja meg
	# Speciális esetek tárgyalása: x és y nulla
	if(x == 0 && y == 0)
		error("Hiba az orientáció számolásánál: az (x, y) = (0,0)")
	else 
		v = [-y, x, 0.]
	end

	# Teszünk bele normálást, hogy jobb legyen!
	approach = r/norm(r)
	orientation = v/norm(v)
	#= A cél orientáció megadható vektorokkal: o, a, és n vektorok 
	(ezeket megfeleltettem az x, y, z tengelyeknek a robotra írt transzformációk alapján)
		a: x
		o: z
		n: y
	emiatt más sorrendben fogom beletenni a mátrixba ezeket a vektorokat, mint ahogyan azt a kurzuson tanultuk
	=#
	
	n = cross(orientation, approach)

	# R = hcat(n, orientation, approach) # ez lenne a kurzusos verzio
	R = hcat(approach, n, orientation) # ez a saját kigondolás

	# A mátrix alapján meghatározom a cél-elforgatottságot:
	θ,v = Find_axis_and_angle(R)
	# println(R)

	# Visszatérítendő a tengely megszorozva a tengellyel, és esetleg külön-külön is a kettő
	return θ*v, θ, v
end


function Define_goal(r)
	vec, _, _ = Define_goal_orientation(r)
	return [r..., vec...]
end


function Define_goal(r, approach, orientation)
	vec, _, _ = Define_goal_orientation(approach, orientation)
	return [r..., vec...]
end

function Define_goal(r, full_orientation)
	return [r..., full_orientation...]
end
