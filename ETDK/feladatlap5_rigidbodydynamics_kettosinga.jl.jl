### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ b6af8e09-01ba-44bc-84cc-39929ac3592e
begin
	using Pkg
	Pkg.activate()
	using StaticArrays
	using RigidBodyDynamics
	using MeshCatMechanisms
	using Plots
	using LinearAlgebra
	using Rotations	
	using Images
end

# ╔═╡ cb46e810-22c9-11eb-1194-af93b64766b5
md"""
# Feladatlap #5

Ennek a feladatlapnak a keretében a `RigidBodyDynamics.jl` csomag segítségével tanulmányozzuk egy hajtás-nélküli kettős-inga mozgását. Majd epítünk egy robotkart.
"""

# ╔═╡ 54e7c1da-24f7-11eb-3651-d9afc46ff928
md"""
### 1. Feladat (10 pont)

Építsünk fel a `RigidBodyDynamics.jl` csomag segítségével egy kettős ingát. Az inga egyes szegmensei legyenek homogén henger alakú merev testek.

!!! hint "Tipp!"

    Lásd a Példák #5 - RigidBodyDynamics testek című notebook-ot.

(a) *(2 pont)* Definiáljunk egy `double_pendulum()` nevezetű függvényt, amely visszatéríti a `Mechanism` típusú teljesen felépített kettős ingát, majd hozzuk létre a kettős-ingát az alábbi paraméterekkel. Legyen a csuklók forgástengelye az $x$ tengely.

```julia
	l_1 = 1 # upper link length
	r_1 = 0.05 # upper link radius
	c_1 = 0.5 # center of mass location with respect to joint axis
	m_1 = 1 # mass
	l_2 = 1. # length of the upper link
	r_2 = 0.05 # link radius
	c_2 = 0.5 # center of mass location with respect to joint axis
	m_2 = 1. # mass
```

!!! hint "Tipp!"

    A tehetetlenségi nyomaték kiszámításához használhatjuk a `cylinder_moment_of_inertia` nevezetű segédfüggvényt.

"""

# ╔═╡ ab49fe64-fab5-40d4-9031-81f4641d2e96
function cylinder_moment_of_inertia(m::Number, h::Number, r::Number)
    I_x_and_y = 1 / 12 * m * (3 * r^2 + h^2)
    I_z = 1/2 * m * r^2
    diagm([I_x_and_y, I_x_and_y, I_z])
end

# ╔═╡ c8ac19a6-2e2b-4500-ab7f-50331357c7c1
function double_pendulum(l_1::Number, r_1::Number, c_1::Number, m_1::Number, l_2::Number, r_2::Number, c_2::Number, m_2::Number)
	g = -9.81 # gravitational acceleration in z-direction
	axis = SVector(1., 0., 0.); # joint axis létrehozása
	world = RigidBody{Float64}("world")
	default_frame(world)
	doublependulum = Mechanism(world, gravity=SVector(0.,0.,g))

	# Felkar
	frame1 = CartesianFrame3D("upper_link")
	I_1 = cylinder_moment_of_inertia(m_1, l_1, r_1)
	intertia1 = SpatialInertia(frame1, moment_about_com=I_1, com=SVector(0,0,-c_1), mass=m_1)
	upperlink = RigidBody(intertia1)

	# Váll
	shoulder = Joint("shoulder", Revolute(axis))
	before_shoulder_to_world = one(Transform3D, frame_before(shoulder), default_frame(world))
	# attach!(doublependulum, world, upperlink, shoulder)
	attach!(doublependulum, world, upperlink, shoulder, joint_pose=before_shoulder_to_world)

	# Alkar
	I_2 = cylinder_moment_of_inertia(m_2, l_2, r_2)
	frame2 = CartesianFrame3D("lower_link")
	intertia2 = SpatialInertia(frame2, moment_about_com=I_2, com=SVector(0,0,-c_2), mass=m_2)
	lowerlink = RigidBody(intertia2)

	# Könyök-csukló
	elbow = Joint("elbow", Revolute(axis))
	before_elbow_to_after_shoulder =  Transform3D(frame_before(elbow),frame_after(shoulder),SVector(0,0,-l_1))
	attach!(doublependulum, upperlink, lowerlink, elbow, joint_pose=before_elbow_to_after_shoulder)

	return doublependulum
	
end

# ╔═╡ 9a5eabc6-d406-4ce9-b14c-ab659d5f5b04
begin
	l_1 = 1. # upper link length
	r_1 = 0.05 # upper link radius
	c_1 = 0.5 # center of mass location with respect to joint axis
	m_1 = 1. # mass
	l_2 = 1. # length of the upper link
	r_2 = 0.05 # link radius
	c_2 = 0.5 # center of mass location with respect to joint axis
	m_2 = 1. # mass

	
	double_pend_ex = double_pendulum(l_1, r_1, c_1, m_1, l_2, r_2, c_2, m_2)
end

# ╔═╡ 701bce20-24f8-11eb-166f-5fac2a42d9fc
md"""
Majd adjunk hozzá a kettős-inga alsó szegmensének végpontjához egy koordináta-rendszert, majd hozzuk létre ennek origójában egy `Point3D` típusú pontot.

!!! hint "Tipp!"

    Egy merev testhez rögzíthetünk koordináta-rendszert többek között a `add_body_fixed_frame!` függvény segítségével.

"""

# ╔═╡ 645bb473-4004-449b-bed6-f31d0bf673ab
joints(double_pend_ex)

# ╔═╡ 772495aa-a99f-45de-9426-7550d7088867
frame_after(joints(double_pend_ex)[2])

# ╔═╡ 02bea7ba-7507-48c3-8833-b716f2398244
# Pontszám: 2 pont

# ╔═╡ b0cafec0-24fb-11eb-02e4-9dd78f99a5f8
md"""
(b) *(1 pont)* Állítsuk be a kettős inga állapotát úgy, hogy a felső szegmens vízszintesen, míg az alsó szegmens függőlegesen lefele álljon. Vizualizáluk a robotot ugyanebben a notebook-ban. 

!!! hint "Tipp!"

    Vizualizáljuk az inga végén lévő koordináta-rendszert is a `setelement!` függvény segítségével.

"""

# ╔═╡ 4e5907de-24fc-11eb-3bd7-e33e1eea23dd
md"""
(c) *(1 pont)* Határozzuk meg az inga végpontjának a pozícióját a világ-koordinátákban. 
"""

# ╔═╡ 3df3701e-ff6d-46d2-9176-7534561004a2
bodies(double_pend_ex)

# ╔═╡ b0d1b6f4-24fc-11eb-0ad3-ef216be7ca77
md"""
(d) *(2 pont)* Számoljuk ki numerikusan az inga mozgását ebből a kezdeti pozícióból 0 kezdeti sebességgel kiíndítva. Ábrázoljuk az inga végpontjának $x,y,z$ tengelyek szerinti mozgását az idő függvényében, valamint a mozgás $(y, z)$ síkra vett vetületét.
"""

# ╔═╡ a2330bf8-8bd1-48d7-ba78-14dc23b2e93f
function transform_to_array(q)
	q_arr = zeros(length(q),length(q[1]))
	for i in 1:length(q)
		for j in 1:length(q[1])
			q_arr[i,j] = q[i][j]
		end
	end
	return q_arr
end

# ╔═╡ 8ab3c8a8-24fd-11eb-1bb0-7b589f09724e
md"""
(e) *(2 pont)* Határozzuk meg az inga teljes gravitációs potenciális energiáját és ábrázoljuk annak változását az idő függvényében.
"""

# ╔═╡ 06897d88-3991-419b-96bb-26e5b2c34128
md"""
(f) *(2 pont)* Igazoljuk *analtikusan és numerikusan*, hogy egy kvaternió deriváltja megadható a kurzuson levezett formula segítségével. Az analítikus levezetést írjuk be LaTeX-be vagy illesszük be képként (a fotót vagy fel kell tölteni valahová is linket adni hozzá vagy a fájlt is csatolni). A numerikus igazoláshoz hozzunk létre *egy-egy függvényt*, amely:
* visszatéríti az argumentumként megadott kvaternió idő szerinti deriváltját az analítikus képlet alapján,
* visszatéríti a derivált valamely kis $\Delta t$ intervallumhoz tartozó megközelítő értékét, felhasználva a derivált általános értelemezését.
Tekintsünk konkrét értékeket és teszteljük az eredményt, pl.: a $z$ tengely körül $\pi/3$-al elforgatott rendszer $\Delta t=10^{-3}$s alatt, $\Delta\theta=10^{-3}$ radiánnal elfordul.

!!! hint "Tipp!"

    Ha beépített függvényeket használunk a műveletekhez, ellenőrizzük, hogy melyik, mit csinál!

"""

# ╔═╡ 3fb12893-327e-4abb-a54d-73a12cfc31d2
load("Analitikus.jpg")

# ╔═╡ 406140c2-450e-4daa-b1aa-33535614c53f
function Base.:∘(q1::UnitQuaternion, q2::UnitQuaternion)
	v1 = [q1.x, q1.y, q1.z]
	v2 = [q2.x, q2.y, q2.z]
	scalar = dot(v1, v2)		
	v3 = q1.w * v2 + q2.w * v1 + cross(v1, v2)
	return Rotations.UnitQuaternion(q1.w*q2.w-scalar,v3...)# ... kibontja vectort számokká, külön
end

# ╔═╡ 5a86cb2a-be26-4416-a71a-3bad714fe149
# Javításban:
# Skalárral való szorzás
function Base.:*(s::Number, q1::UnitQuaternion)
	v1 = [q1.x, q1.y, q1.z]	
	return Rotations.UnitQuaternion(s * q1.w,s *v1...)# ... kibontja vectort számokká, külön
end

# ╔═╡ a9b7fbd6-0fa1-4a5b-ac38-09e2c3f26f4f
# 60 fokkal forgatjuk, a z tengely körül elvileg
q_0 = Rotations.UnitQuaternion(cos(pi/6), sin(pi/6)*[0,0,1]...)

# ╔═╡ 9d97dc72-e2b7-4936-98d8-7deba288af45
# Javításban:
# Kivonás implementálása
function Base.:-(q1::UnitQuaternion, q2::UnitQuaternion)
	
	return Rotations.UnitQuaternion(q1.w-q2.w,q1.x-q2.x,q1.y-q2.y,q1.z-q2.z )
end

# ╔═╡ fd4b60b1-02e0-4481-a657-501fefa9dff3
begin
	frame3 = CartesianFrame3D("tip")
	tip_to_after_elbow = Transform3D(frame3, frame_after(joints(double_pend_ex)[2]), SVector(0, 0, -l_2))
	add_body_fixed_frame!(double_pend_ex,tip_to_after_elbow)

	# Pont a kettős inga végére deffiniálva:
	End_Point = Point3D(frame3, [0, 0, 0])
end

# ╔═╡ 0626fee1-82e7-406a-ab33-919e2e26f24c
begin
	elbow = joints(double_pend_ex)[2]
	shoulder = joints(double_pend_ex)[1]
	state = MechanismState(double_pend_ex)
	set_configuration!(state, elbow, -pi/2)
	set_configuration!(state, shoulder, pi/2)
	
	mvis = MechanismVisualizer(double_pend_ex)
	setelement!(mvis, frame_after(elbow))
	setelement!(mvis, frame3)
	
	# Kulcs-parancs a példában:
	MeshCatMechanisms._render_state!(mvis,state)
	render(mvis)
end

# ╔═╡ ced3f66d-f079-4f18-8910-cdc6833092ad
state.q

# ╔═╡ 77dc2447-4154-450a-b668-0cabe48e9290
 transform_tip_to_word = transform_to_root(state, frame3)

# ╔═╡ f5831520-63e2-4870-868f-3383bb8bd4d0
ᵂEndPoint = transform_tip_to_word * End_Point

# ╔═╡ f068ad1c-7f8a-4a7a-a609-756b237206f1
begin
	set_velocity!(state, shoulder, 0.)
	set_velocity!(state, elbow, 0.)
	
	ts, qs, vs = simulate(state, 100, Δt = 1e-3);
	q_arr = transform_to_array(qs)
	plt1 = plot(ts, q_arr[:,1], xlabel = "Time (s)", ylabel = "(rad)", title = "Vállcsuklót jellemző szög", label = "")
end

# ╔═╡ 05e2b064-e1bb-42f5-8ad0-87d84ddd2a5e
plt2 = plot(ts, q_arr[:,2], xlabel = "Time (s)", ylabel = "(rad)", title = "Könyökcsuklót jellemző szög \n(upper_link-hez képest)", label = "")

# ╔═╡ edc341d0-b784-451a-b852-7df24baaef61
begin
	# 2. Ábrázoljuk a végpont mozgását
	x_vals = Float64[]
	y_vals = Float64[]
	z_vals = Float64[]
	E = Float64[]
	upperlink = bodies(double_pend_ex)[2]
	lowerlink = bodies(double_pend_ex)[3]
	
	# Az időpillanatok végigiterálása és pozíciók rögzítése
	for (t, q) in zip(ts, qs)
	    # Állapot beállítása az aktuális helyzet alapján
	    set_configuration!(state, q)
	    
	    # Transformáció kiszámítása a végponthoz (az EndPoint pozíciója)
	    transform_tip_to_world = transform_to_root(state, frame3)
		end_position = transform_tip_to_world * End_Point		
		
	    # Eltároljuk az x, y, z pozíciókat
	    push!(x_vals, end_position.v[1])
	    push!(y_vals, end_position.v[2])
	    push!(z_vals, end_position.v[3])

		# Energia számolása:
		E_p = gravitational_potential_energy(state,upperlink)+gravitational_potential_energy(state,lowerlink)
		push!(E, E_p)
	end
	
	# Pozíció ábrázolása az idő függvényében
	p1= plot(ts, x_vals, label = "x-tengely")
	plot!(p1, ts, y_vals, label = "y-tengely")
	plot!(p1, ts, z_vals, label = "z-tengely")
	title!(p1, "Kétszeres inga mozgása az idő függvényében")
	xlabel!(p1, "Idő [s]")
	ylabel!(p1,"Pozíció")
	
	# Vetület ábrázolása az y-z síkban
	p2 = scatter(y_vals[1:5:end], z_vals[1:5:end], marker_z = ts[1:5:end], label  ="Színek az idő függvényében", arrow=:arrow, c = :plasma, ms = 2, markerstrokewidth = 0, frame_style =:origin, aspect_ratio =:equal)
	title!(p2, "Kettős-inga mozgásának vetülete az y-z síkban")
	xlabel!(p2, "y pozíció")
	ylabel!(p2, "z pozíció")
	
	print("Koordináták és energiák számolása")
end

# ╔═╡ 7e12ca34-4e88-43f3-9bdd-f9829901c46f
# Pozíció ábrázolása az idő függvényében
	p1

# ╔═╡ 65bd0eb3-cd13-4f90-b0ed-e569e03efee1
p2

# ╔═╡ a8607438-cf8f-47a3-9442-2c342af76cf9
begin
	# Energia ábrázolása (számolva korábban a koordinátákkal)
		p3 = plot(ts, E, label  ="", c = :plasma, ms = 4)
		title!(p3, "Kettős-inga mozgásának vetülete az y-z síkban")
		xlabel!(p3, "Idő")
		ylabel!(p3, "Gravitációs potenciális energia")
end

# ╔═╡ 80da9e63-2fec-4531-9cd3-4c24b687d7a3
function Analitikus_keplet(q::UnitQuaternion{Float64})
	ω = Rotations.UnitQuaternion(0, rotation_axis(q)...)
	return  0.5*(ω ∘ q)
end

# ╔═╡ bea2f915-a32a-4d5b-8f69-4eb9360333ea
function Numerikus_keplet(q::UnitQuaternion{Float64}; Δt::Number = 0.001, Δθ = 0.001 )

	angle = rotation_angle(q) +Δθ
	axis = rotation_axis(q)
	# Javítási próbálkozás: lehetett volna Összeadást-kivon
	s = 1/Δt
	derivalt = s*(q - Rotations.UnitQuaternion(cos(angle/2.), sin(angle/2.)*axis...))
	
	
	return derivalt	
end

# ╔═╡ 424ca005-9c5c-497e-aca9-fe33212694ea
teszt1 = Analitikus_keplet(q_0)

# ╔═╡ 079384be-fb42-429b-adf6-45f12c54d52f
teszt2 = Numerikus_keplet(q_0)

# ╔═╡ f6e89f30-246c-4d2b-acaa-dd632b453098
isapprox(teszt1, teszt2, atol = 0.1)
# :((

# ╔═╡ f77db228-24fd-11eb-3ba1-bfaed3355503
md"""
### 2. Feladat (+4 pont)

Építsünk fel a `RigidBodyDynamics.jl` csomag segítségével a [PincherX150](https://docs.trossenrobotics.com/interbotix_xsarms_docs/specifications/px150.html) robotkart. A kar egyes szegmensei legyenek homogén téglatest/henger alakú merev testek. A méreteket vegyük a specifikációból, a tömegeket becsüljük meg. Állítsuk be a képen látható állapotba, majd vizualizáljuk a robotot.

!!! hint "Tipp!"

    Lásd a Példák #5 - RigidBodyDynamics testek című notebook-ot.

![](https://docs.trossenrobotics.com/interbotix_xsarms_docs/_images/px150.png)

"""

# ╔═╡ 231659cc-24d7-11eb-1378-f33a65208eaa
md"""
### Segédfüggvények
"""

# ╔═╡ 73f608ec-f2a1-4372-a1a2-47b0aa25d88a
#= 		Javítás:

1.a) 2 pont
1.b) 1 pont
1.c) 1 pont
1.d) 2 pont
1.e) 2 pont
1.f) 1.5 pont

Összesen: 9.5 pont
=#

# ╔═╡ Cell order:
# ╟─cb46e810-22c9-11eb-1194-af93b64766b5
# ╠═b6af8e09-01ba-44bc-84cc-39929ac3592e
# ╟─54e7c1da-24f7-11eb-3651-d9afc46ff928
# ╠═ab49fe64-fab5-40d4-9031-81f4641d2e96
# ╠═c8ac19a6-2e2b-4500-ab7f-50331357c7c1
# ╠═9a5eabc6-d406-4ce9-b14c-ab659d5f5b04
# ╟─701bce20-24f8-11eb-166f-5fac2a42d9fc
# ╠═645bb473-4004-449b-bed6-f31d0bf673ab
# ╠═772495aa-a99f-45de-9426-7550d7088867
# ╠═fd4b60b1-02e0-4481-a657-501fefa9dff3
# ╠═02bea7ba-7507-48c3-8833-b716f2398244
# ╟─b0cafec0-24fb-11eb-02e4-9dd78f99a5f8
# ╠═0626fee1-82e7-406a-ab33-919e2e26f24c
# ╠═ced3f66d-f079-4f18-8910-cdc6833092ad
# ╟─4e5907de-24fc-11eb-3bd7-e33e1eea23dd
# ╠═3df3701e-ff6d-46d2-9176-7534561004a2
# ╠═77dc2447-4154-450a-b668-0cabe48e9290
# ╠═f5831520-63e2-4870-868f-3383bb8bd4d0
# ╟─b0d1b6f4-24fc-11eb-0ad3-ef216be7ca77
# ╠═a2330bf8-8bd1-48d7-ba78-14dc23b2e93f
# ╟─f068ad1c-7f8a-4a7a-a609-756b237206f1
# ╠═05e2b064-e1bb-42f5-8ad0-87d84ddd2a5e
# ╟─edc341d0-b784-451a-b852-7df24baaef61
# ╟─7e12ca34-4e88-43f3-9bdd-f9829901c46f
# ╟─65bd0eb3-cd13-4f90-b0ed-e569e03efee1
# ╟─8ab3c8a8-24fd-11eb-1bb0-7b589f09724e
# ╟─a8607438-cf8f-47a3-9442-2c342af76cf9
# ╟─06897d88-3991-419b-96bb-26e5b2c34128
# ╟─3fb12893-327e-4abb-a54d-73a12cfc31d2
# ╠═a9b7fbd6-0fa1-4a5b-ac38-09e2c3f26f4f
# ╠═406140c2-450e-4daa-b1aa-33535614c53f
# ╠═5a86cb2a-be26-4416-a71a-3bad714fe149
# ╠═9d97dc72-e2b7-4936-98d8-7deba288af45
# ╠═80da9e63-2fec-4531-9cd3-4c24b687d7a3
# ╠═bea2f915-a32a-4d5b-8f69-4eb9360333ea
# ╠═424ca005-9c5c-497e-aca9-fe33212694ea
# ╠═079384be-fb42-429b-adf6-45f12c54d52f
# ╠═f6e89f30-246c-4d2b-acaa-dd632b453098
# ╟─f77db228-24fd-11eb-3ba1-bfaed3355503
# ╟─231659cc-24d7-11eb-1378-f33a65208eaa
# ╠═73f608ec-f2a1-4372-a1a2-47b0aa25d88a
