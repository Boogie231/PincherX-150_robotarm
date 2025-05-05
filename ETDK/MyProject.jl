### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 98bc9155-6830-4ad9-b0e0-fc33f004a974
begin
	using Pkg
	Pkg.activate()
	using Images
	using PlutoUI
	import PlutoUI: combine
	using Plots, Colors
	# plotly()
	gr()
	# using LinearAlgebra
	using LaTeXStrings
	import MarkdownLiteral: @mdx # dokumentumon belüli linkelés
	using OrdinaryDiffEq, DynamicalSystems
	using NLsolve
	using LinearAlgebra
	
end

# ╔═╡ 10c96af0-ca9d-4c95-9ce8-51df7393dd14
md"""
### Projekt, 2024. I. félév
#### Dinamikai rendszerek

# Interaktív vizualizációk készítése Pluto notebookban

Fancsali Boglárka, III. tanév

2025.01.13.

---
"""

# ╔═╡ 846f1a25-459d-49e6-8d8c-b49f51aae2b7
md"""
### Célok:

* **logisztikus leképezés** pókhálódiagramja, interaktívan változtatható elemekkel:
	- paraméter
	- kezdeti feltétel
	-iterációszám

* logisztikus leképezés pókhálódiagramja **magasabbrendű leképezések** ábrázolásával 

* **Lorenz attraktor** fázistérbeli trajektóriáinak és idősorainak animációja:
	- interaktívan változtatható paraméterrel
	- kezdeti feltétellel 
	- időkontrollal

* Lorenz-rendszer esetén kezdetben **két közeli trajektória időfejlődésének** interaktív vizualizációja és ezek közötti fázistérbeli távolság ábrázolása

"""

# ╔═╡ 32a75308-ad33-4087-b006-28d5c5d8c507
md"""
### Kulcsfogalmak:

* Logisztikus leképezés
* Pókhálódiagramm
* Lorenz attraktor
* Fázistérbeli trajektória
* Idősor
* Kezdeti feltétel
* Fázistérbeli távolság

"""

# ╔═╡ 8461fb2f-f0c7-4fb4-8d06-f280ee865407
md"""
## Elméleti rész:
"""

# ╔═╡ 4393ec44-7356-47c1-a2e2-3818dfc83c14
html"""
<iframe src="https://drive.google.com/file/d/1Hu_pEbDaL5jJHWnbXqigCS3csK02l83X/preview" width="400" height="300" allow="autoplay"></iframe>
"""


# ╔═╡ fa096dca-83e4-4661-9cd0-27cbc308db69
md"""

### Logisztikus leképezés – Elméleti összefoglaló

A logisztikus leképezés (logistic map) egy egyszerű, de mégis rendkívül gazdag dinamikai rendszermodell, amelyet Robert May népszerűsített az 1970-es években. Az alábbi iterációs képlet írja le:

```math
x_{n+1} = r x_n (1 - x_n),
```

ahol:

- Az $$x_n$$ az $$n$$-edik iteráció populációsűrűségét jelenti, $$0 \leq x_n \leq 1$$,
- Az $$r$$ a növekedési ráta (kontrollparaméter), $$r > 0$$.

---

##### Jelentősége:

A logisztikus leképezés a populációdinamikát modellezi, például egy állatfaj szaporodását egy véges környezetben. Az $$r$$ paraméter beállításától függően a modell különböző dinamikai viselkedéseket mutat.

---

##### Bifurkációs diagram:
A bifurkációs diagram a növekedési ráta $$r$$ függvényében ábrázolja a hosszú távú dinamikai viselkedést. 

---

##### Alkalmazások:
A logisztikus leképezés egyszerűsége ellenére számos tudományterületen használható, például:
- ökológiai populációdinamika,
- gazdasági ciklusok modellezése,
- kaotikus rendszerek elemzése.

##### Pókhálódiagram:

A pókhálódiagram egy grafikus eszköz, amely a logisztikus leképezés iterációinak viselkedését szemlélteti.

A pókhálódiagramot úgy készítjük, hogy a logisztikus leképezés grafikonját és az $$y = x$$ egyenes vonalat (I. szögfelező) egyszerre ábrázoljuk. Az iterációkat egy kiindulási értékből ($$x_0$$) indulva vizuálisan követhetjük, ahol a kezdőpontból először az Oy irányában haladunk, amíg metszük a leképezés grafikonját. Innen párhuzamosan az Ox tengellyel haladunk, amíg metszük az I.szögfelezőt (az $$y = x$$ egyenest), majd innen tovább haladunk függőleges irányban, amíg újra metszük a leképezés grafikonját, ezzel meghatározva a leképezés következő iterációját.

A diagram segítségével jól szemléltethető, hogy különböző $$r$$ értékek beállítása esetén hogyan alakul ki a stabil egyensúly, periodikus ciklusok, vagy a kaotikus viselkedés.


"""

# ╔═╡ 9ea90eb4-c12b-4264-92b3-f3d618673116
md"""
### Lorenz rendszer - Elméleti összefoglaló

A Lorenz-rendszer Edward Lorenz által 1963-ban bevezetett háromdimenziós dinamikai rendszer, amely az időjárási minták egyszerűsített modellezésére szolgált. Az egyenletek a konvekciós áramlások matematikai leírására készültek, de hamar kiderült, hogy a rendszer kaotikus viselkedést mutat, ami az időjárás hosszú távú előrejelzésének nehézségére is rávilágít.

A rendszer három differenciálegyenlete a következő:
```math
\begin{align}
\dot{x}&=\sigma(y-x)\\
\dot{y}&=\rho x-y-xz\\
\dot{z}&=xy-bz,
\end{align}
```

Itt $$\sigma$$, $$\rho$$, és $$b$$ valós paraméterek, amelyek tipikus értékei $$\sigma = 10$$, $$\rho = 28$$, és $$\beta = \frac{8}{3}$$. A Lorenz-rendszer legfontosabb jellemzője a kaotikus viselkedés, amely azt jelenti, hogy a rendszer rendkívül érzékeny a kezdeti feltételekre, azaz apró változások a kiindulási állapotban jelentős eltérésekhez vezethetnek a későbbi állapotokban. Ez a tulajdonság tette híressé a „pillangóhatást,” amely szerint egy pillangó szárnycsapása a világ egyik részén képes tornádót okozni egy másik részén.

A Lorenz-rendszer grafikus ábrázolása jellegzetes, bonyolult alakzatot, az úgynevezett Lorenz-attraktort eredményez, amely jól szemlélteti a kaotikus dinamikát.


"""

# ╔═╡ f1e45742-b72a-408e-9c90-eb49271a2221
md"""
## A projekttel felmerülő kérdések:


Megválaszolt kérdések:
* Mit jelent a magasabbrendű leképezés fogalma?
* Fázistérbeli távolság jelentése?
* Interaktivitás?
* Milyen plottok kellenek?

"""

# ╔═╡ f0c90e4d-43fe-4ba0-8162-fcbd29eb57b9
md"""
## Implementációk

### Logisztikus leképezés
"""

# ╔═╡ a0e379fc-d51d-4d0a-8e0a-622bc447ba58
md"""
Változtatható paraméter:
"""

# ╔═╡ 3b87b678-58e6-447d-9dda-bf07b6e300ad
# Parameter = @bind r Slider(0:0.01:4, default=2, show_value = true)

# ╔═╡ 8d432d24-27ed-4aef-908e-378b29a4be4b
md"""
Változtatható kezdeti feltétel:
"""

# ╔═╡ 2c766bbf-0ce6-4e3a-b01c-baddd155bb51
# Kezdeti_felt = @bind x0 Slider(0:0.001:1, default=0.01, show_value = true)

# ╔═╡ fa79f16c-9a7a-42d1-9393-ac58cccda6ab
md"""
Változtatható iterációszám:
"""

# ╔═╡ 192748bb-200a-4022-b7bf-99a35bb3b894
# Iteracio_szam = @bind N Slider(2:1:400, default=2, show_value = true)

# ╔═╡ 44963304-56e8-49cc-ac3b-6d31120d2465
md"""
Változtatható a leképezés rendje:
"""

# ╔═╡ 27ae50e4-9261-4d18-beee-b04c97f0a2c6
# Lekepezes_rendje = @bind rend Slider(1:1:10, default=1, show_value = true)


# ╔═╡ bfa50eca-c679-49f1-ba5b-835192f79f78
function Generate_Sliders_Logistic(text::String, directions::Vector{Tuple{String, Real, Real, Real, Real}})
    return combine() do Child
        inputs = [
            md""" $(name): $(
                Child(name, Slider(min:step:max, default=default, show_value=true))
            )"""
            for (name, min, step, max, default) in directions
        ]
        
        md"""
        ###### $(text)
        $(inputs)
        """
    end
end

# ╔═╡ 6d3813be-5ff8-4dd3-83af-76b9f69b7e6d
function Generate_Sliders_Lorenz(text::String, directions::Vector{Tuple{String, Float64, Float64, Float64, Float64}})
    return combine() do Child
        inputs = [
            md""" $(name): $(
                Child(name, Slider(min:step:max, default=default, show_value=true))
            )"""
            for (name, min, step, max, default) in directions
        ]
        
        md"""
        ###### $(text)
        $(inputs)
        """
    end
end


# ╔═╡ 6411c420-1bbe-4526-8d18-b676bb8fc4d5
begin
	Parameter_logistic = @bind parameter_logistic Generate_Sliders_Logistic("Paraméterek a logistikus leképezéshez",[
		    ("r", 0.0, 0.01, 4.0, 2.),
		    ("Kezdeti_feltétel", 0.0,0.001,1.,0.01),
		    ("Iterációszám", 2, 1, 400, 2),
		    ("Rend", 1, 1, 10, 1)
		])
end

# ╔═╡ 00b7b5d2-8d1a-4b38-a938-00f6bc6e4839
begin
	r = parameter_logistic.r
	x0 = parameter_logistic.Kezdeti_feltétel
	N = parameter_logistic.Iterációszám
	rend = parameter_logistic.Rend
	if true
	end
end

# ╔═╡ 8435cfec-08b6-44d5-85a1-4dde334e198a
# Logisztikus növekedési függvény
function logistic_growth(r, x_n; rend = 1)
	rend <= 0 && error("i should be >0")
	if  rend== 1
		return r * x_n * (1 - x_n)
	else
		x_n = logistic_growth(r, x_n, rend = rend-1)
		return r * x_n * (1 - x_n)
	end
end

# ╔═╡ 472a27f3-ac3d-43f9-aaea-92c018966883
function Generate_plot_logistic_growth(x0, r, N; rend = 1)
	x = []
	x_full = []
	y = []
	y_full = []
	push!(x_full, x0)
	push!(y_full, 0)
	x2 = x0
	for i in 1:N
		x1 = x2
		x2 = logistic_growth(r, x1, rend = rend)
		# println(x1, " ", x2)
		push!(x, x1)
		push!(y, x2)

		push!(x_full, x1)
		push!(y_full, x2)
		push!(x_full, x2)
		push!(y_full, x2)
	end

	# Plot: a  leképezés pontjai
	plt = scatter(x, y, label = "A leképezés pontjai",  c=colormap("Blues",length(x)), lw = 2)
	
	plot!(plt, x_full, y_full, label = "Vetítések")

	# Plot: az első szögfelező
	szogf = 0:0.1:1
	plot!(plt, szogf, szogf, label= "Első szögfelező", color=:black)

	# Plot: general settings
	plot!(plt, title = "\nLogisztikus leképezés\nRend:$(rend)", xlabel = L"x_n", ylabel=L"x_{n+1}", xlims = (0, 1)) # , aspect_ratio =:equal

	# Plot: kezdőpont ábrázolása
	scatter!(plt, [x0], [0], label = L"x_0")

	# Plot: Fixpontok ábrázolása
	# stabilitásuk: 8.kurzus!
	# scatter!(plt, [0, 1-1/r], [0, 1-1/r], label = L"x_0^*")

	# Plot: Parabolaív ábrázolása - vagy magasabbrendű leképezések esetén más alakzatok
	parab_x = 0:0.001:1
	parab_y = logistic_growth.(r, parab_x, rend = rend)
	plot!(plt, parab_x, parab_y, label = "Leképezés függvénye")
	
end


# ╔═╡ 302c8275-1b26-4985-995b-f9d483bd64e5
Generate_plot_logistic_growth(x0, r, N)

# ╔═╡ 59b25353-e48e-49a8-bd34-0dc29ea77a7b
Parameter_logistic

# ╔═╡ 21ca306f-8484-4b47-9da1-1cbf50b13776
md"""
### Magasabbrendű leképezések:
"""

# ╔═╡ 28e694d5-6a9a-4510-ac48-defe928a342b
# Fixpontok ábrázolása a rendszerben:
function Plot_fixpoints(r; plt = plot())
	# Plot: general settings
	# plot!(plt,title = "\nFixpontok a Logisztikus leképezésben")
	plot!(plt,  xlabel = L"x_n", ylabel=L"x_{n+1}", xlims=(0,1),  ylims=(0,1)) # , aspect_ratio =:equal

	if r<=1 
		scatter!(plt, [0],[0], label = L"x_0^* - stabil fixpont", c =:black)
	else
		if r < 3
			scatter!(plt, [0],[0], label = L"x_0^* -instabil fixpont",  mc =:white, markerstrokecolor =:black)
			scatter!(plt, [1-1/r], [1-1/r], label = L"x_1^* -stabil fixpont", c =:black)
			
		else
			scatter!(plt, [0],[0], label = L"x_0^* -instabil fixpont",  mc =:white, markerstrokecolor =:black)
			scatter!(plt, [1-1/r], [1-1/r], label = L"x_1^* -instabil fixpont",  mc =:white, markerstrokecolor =:black)
			
		end
	end
end

# ╔═╡ 06fb138d-37a7-436a-9e80-73f0fd17da88
begin
	plt_logistic_higher = Generate_plot_logistic_growth(x0, r, N, rend = rend)
	Plot_fixpoints(r, plt =plt_logistic_higher)
end

# ╔═╡ dabee099-a87c-4c34-a548-e0ebd36a49eb
md"""
### Implementció: Lorentz-rendszer
"""

# ╔═╡ abed107d-4ac8-41da-8b42-4255e7c402e1
md"""
A Lorenz-rendszer változtatható paraméterei: RÉGI SETUP
"""

# ╔═╡ 667c7267-df48-47f8-9a7e-2c3477ab5c93
# σ = @bind sigma Slider(0:0.1:11, default=10, show_value = true)

# ╔═╡ 980c7b75-8e64-4acc-8344-e37021a65be5
# ρ = @bind rho Slider(1:0.1:30, default=28, show_value = true)

# ╔═╡ 18caff36-7c30-4c4e-9fc6-73d93f9c14fb
# b = @bind b_value Slider(0:0.1:11, default=8/3, show_value = true)

# ╔═╡ bbeb5576-01c7-4064-be2c-2f4d1df34605
T_max = 200

# ╔═╡ b53eea8a-5395-4977-80bf-cbfd5dfe1008
# Idő = @bind t Slider(0:0.01:T_max, default=T_max/2, show_value = true)

# ╔═╡ b263f579-4675-4c7a-8edf-2c4dd2dfa29d
# Kezdeti_x = @bind x0_L Slider(-5:0.1:5, default=1, show_value = true)

# ╔═╡ 5a575ca6-099e-45fa-bda7-a883a6ca9337
# Kezdeti_y = @bind y0_L Slider(-5:0.1:5, default=1, show_value = true)

# ╔═╡ 5ffb9b97-6603-4158-859d-b08c16c9e04b
# Kezdeti_z = @bind z0_L Slider(-5:0.1:5, default=1, show_value = true)

# ╔═╡ 5c0fb4be-567a-46ea-ba78-5f6df74c6ce3
begin
    Parameter_Lorenz = @bind parameter_Lorenz Generate_Sliders_Lorenz("Paraméterek a Lorenz leképezéshez", [
        ("σ", 0.0, 0.1, 11.0, 10.0),
        ("ρ", 1.0, 0.1, 30.0, 28.0),
        ("b", 0.0, 0.1, 11.0, 8/3),
        ("x₀", -5.0, 0.1, 5.0, 1.0),
        ("y₀", -5.0, 0.1, 5.0, 1.0),
        ("z₀", -5.0, 0.1, 5.0, 1.0),
        ("t", 0.0, 0.01, T_max*1., T_max / 2.0)
    ])
end


# ╔═╡ 3b603583-e4d7-4b8a-b8ef-0a3e9c5b4c48
begin
	sigma = parameter_Lorenz.σ
	rho = parameter_Lorenz.ρ
	b_value = parameter_Lorenz.b
	x0_L = parameter_Lorenz.x₀
	y0_L = parameter_Lorenz.y₀
	z0_L = parameter_Lorenz.z₀
	t = parameter_Lorenz.t
end

# ╔═╡ 075c4e44-c835-4030-9714-83549cf37a5b
parameters = [sigma, b_value, rho]

# ╔═╡ a1ed954d-572a-417e-9ee8-f7f8a58fc25b
start_values = [x0_L,y0_L,z0_L]

# ╔═╡ c53f82f0-6c69-45fd-a616-a3e489283b11
function System(u, p, t)	
	x,y,z = u #variables
	σ, b, ρ = p[1], p[2], p[3]
	d_x = σ*(y-x)
    d_y = ρ*x - y - x * z
	d_z = x * y - b * z
    return SVector{3}(d_x, d_y, d_z)
end

# ╔═╡ cbdfa598-8c57-440e-bdb2-66417923af1f
function Calculate_Lorenz(parameters, T_max, start_values; Δt = 0.01)
	# A dinamikai rendszer
	ds = CoupledODEs(System,[0. 0. 0.], parameters)
	traj, time = trajectory(ds, T_max,start_values,Δt=Δt)
end

# ╔═╡ faecd29c-df6b-436d-b49d-c9f3965d85a6
traj, t_Lorenz = Calculate_Lorenz(parameters,T_max, start_values)

# ╔═╡ f0881803-0137-42c0-be6f-314a9fd1c8af
traj2, t_Lorenz2 = Calculate_Lorenz(parameters,T_max, start_values.+10^(-5))

# ╔═╡ ebfbd50a-ceaf-42c3-9185-f068b2f776ba
function Interaktiv_Lorenz_3D!(parameters, t, start_values, traj;plt = plot(), Δt = 0.01)
	x0, y0,z0 = start_values
	σ, b, ρ = parameters
	ind = Int(round(t/0.01))
	
	# Plot: general settings
	plot3d!(plt, title ="Interaktív fázisportré\n ~3D~", xlabel = "x", ylabel = "y", zlabel = "z")
	
	# Plot: System 3D
	plot3d!(plt,traj[1:ind,1], traj[1:ind, 2],traj[1:ind, 3], label = "Lorenz rnedszer", arrow =:arrow)

	
	
		
	scatter3d!(plt, [x0],[y0],[z0], label = "Kezdőpont", markershape=:cross, c =:red)
	plt

end

# ╔═╡ ec6d916f-cac7-40da-9db7-19f84f8ac786
function switch_on_index(x)
	    options = Dict(
	        1 => () -> "x",
	        2 => () -> "y",
	        3 => () -> "z"
	    )
	    
	    get(options, x, () -> error("Error in Switch() function"))()  # Default action for other cases
end

# ╔═╡ d9816d99-519b-4fed-bfe5-5c788a246c63
function Interaktiv_Lorenz_2D!(parameters, t, start_values, traj, ind1, ind2;plt = plot(), Δt = 0.01)
	# ind1, ind2 -> x és y tengelyen levő adatok indexe, [1, 2, 3]
	if(ind1 == ind2)
		error("Please enter two different index!")
	end
	xlabel= switch_on_index(ind1)
	ylabel= switch_on_index(ind2)

	x0, y0,z0 = start_values
	σ, b, ρ = parameters
	ind = Int(round(t/0.01))


	
	# Plot: general settings
	plot!(plt, title ="Interaktív fázisportré\n~$(xlabel)O$(ylabel) sík~", xlabel = xlabel, ylabel = ylabel)
	# Plot: System 2D
	plot!(plt,traj[1:ind,1], traj[1:ind, 2], linecolor =:green, label = "", arrow =:arrow)	

	# Plot: start value
	scatter!(plt, [start_values[ind1]],[start_values[ind2]], label = "Kezdőpont", markershape=:cross, c =:red)
	plt

end

# ╔═╡ 17424958-8243-4bd5-94eb-142dbdfb80a9
function Interaktiv_Lorenz_idosor!(parameters, t, start_values, traj, time, ind_cordinate; plt = plot(), Δt = 0.01)
	# ind1, ind2 -> x és y tengelyen levő adatok indexe, [1, 2, 3]
	
	ylabel= switch_on_index(ind_cordinate)

	x0, y0,z0 = start_values
	σ, b, ρ = parameters
	ind = Int(round(t/0.01))

	# Plot: general settings
	plot!(plt, title ="Interaktív idősor\n~$(ylabel)(t) ~", xlabel = "t", ylabel = ylabel*"(t)")
	# Plot: Idősor
	plot!(plt,collect(time)[1:ind], traj[1:ind, ind_cordinate], label = "$(ylabel)(t)", arrow =:arrow)

	# Plot: start value
	scatter!(plt, [collect(time)[1]],[traj[1,ind_cordinate]], label = "Kezdőpont", markershape=:cross, c =:red)
	plt
end

# ╔═╡ 543c7f0a-26c0-47f2-bceb-c919158c36b7
function Fazisterbeli_tavolsag(traj1, traj2)
    # Ellenőrizzük, hogy az inputok ugyanolyan hosszúak-e
    if size(traj1, 1) != size(traj2, 1)
        error("The trajectories must have the same number of time steps.")
    end

    # Számoljuk ki az Euklideszi távolságot minden időpillanatra
    distances = [norm(traj1[i, :] - traj2[i, :]) for i in 1:size(traj1, 1)]
    
    return distances
end


# ╔═╡ 4ed85e35-c638-4cce-aad4-691369f49155
# Fázistérbeli távolság
δ = Fazisterbeli_tavolsag(traj, traj2)

# ╔═╡ 9e5a94d1-8292-4de6-8ac8-cd4c1d7c2e69
function Interaktiv_Fazisterbeli_tavolsag!(t, δ, time; plt = plot(), Δt = 0.01)

	# Plot: calculate index
	ind = Int(round(t/0.01))

	# Plot: general settings
	plot!(plt, title ="Interaktív fázistérbeli távolság\n~δ(t)~", xlabel = "t", ylabel = "δ(t)")
	
	# Plot: Fázistérbeli távolság
	plot!(plt,collect(time)[1:ind], δ[1:ind], label = "δ(t)", arrow =:arrow)

	plt
end

# ╔═╡ c32e218b-a8c7-4d13-946f-ddbfb1e091e1
md"""
###### Fixpontok megkeresése:
"""

# ╔═╡ 3bcb488b-889e-465b-bbe7-7de0e28109ce
# Numerikus fixpoint-keresés
	# csak úgy vagányságnak, de nem ezt használtam
function Find_fixpoints_numerical(p; initial_guesses = [
    [0.5, .5, .5],                # Triviális fixpont
    [5.0, 5.0, 5.0],               # Egyik nemtriviális fixpont
    [-3.0, -3.0, 5.0]              # Másik nemtriviális fixpont
	])
	σ, b, ρ = p
	function lorenz_fixpoint!(F, x)
	    F[1] = σ * (x[2] - x[1])              # dx/dt = 0
	    F[2] = x[1] * (ρ - x[3]) - x[2]       # dy/dt = 0
	    F[3] = x[1] * x[2] - b * x[3]         # dz/dt = 0
	end
	
	fixpoints = [nlsolve(lorenz_fixpoint!, guess).zero for guess in initial_guesses]
	# println("Fixpontok: \n", fixpoints)
	return fixpoints
end

# Usage:
# fp1, fp2, fp3 = Find_fixpoints_numerical([sigma b_value rho])

# ╔═╡ 0f0d7230-48cc-4e2c-b40b-31a1c9aebd39
# Analitikus fixpoint-keresés
function Find_fixpoints_analitic(parameters)
	σ, b, ρ = parameters
	fp1 = [0, 0, 0]
	fp2 = [sqrt(b*(ρ-1)), sqrt(b*(ρ-1)), ρ-1]
	fp3 = [-sqrt(b*(ρ-1)), -sqrt(b*(ρ-1)), ρ-1]
	
	fixpoints = [fp1, fp2, fp3]
	return fixpoints
end
# Usage:
# fp1, fp2, fp3 = Find_fixpoints_analitic(parameters)

# ╔═╡ 4e4bc229-e07b-4bc2-a7df-5ac2505e9ee3
function Jacobi_Lorenz(parameters, coordinates)
	x, y,z = coordinates
	σ, b, ρ = parameters
	return [-σ σ 0; ρ-z -1 -x;y x -b]
end

# ╔═╡ a9181f6e-7b7f-4ab0-a5be-72e3fd528eca
struct FixPoint
    coordinates::Vector{Float64}
    stability::String  # Stabilitás típusa: "stabil" vagy "instabil"
end

# ╔═╡ 90e05b4f-44fc-4f3b-9e46-efa0f50c56a7
# Stabilitás vizsgálata
function stability_of_fixpoint(parameters, coordinates) 
	
	J = Jacobi_Lorenz(parameters,coordinates)
	eigenvalues = eigen(J).values
	
	# Ellenőrzöm, hogy a sajátértékek valós része pozitív-e
	all_negative_real = all(real(eigenvalues) .< 0)
	has_imaginary = any(imag.(eigenvalues) .!= 0)
	if has_imaginary
		println("stability_of_fixpoint: fixpoints eigenvalues have imaginary parts,oscillations might appear?")
		println(eigenvalues)
	end
    return all_negative_real ? "stabil" : "instabil", eigenvalues
end

# ╔═╡ 88cbd45a-29a9-4415-bca2-31d98f8168d0
function Create_fixpoint_structure(parameters)
	fixpoints = Find_fixpoints_analitic(parameters)
	struct_fixpoints = []  # Üres tömb a fixpontok tárolására
	for fixpoint in fixpoints
	 	stability,_ = stability_of_fixpoint(parameters,fixpoint)  # Stabilitás meghatározása
		push!(struct_fixpoints, FixPoint(fixpoint, stability))  # Fixpont tárolása
	end
	return struct_fixpoints
	
end

# ╔═╡ d7287b1b-2641-489e-a59b-095c196b9cb8
fixpoints = Create_fixpoint_structure(parameters)

# ╔═╡ 289a57a7-9662-4b9b-84dc-0afe5f42211c
function Plot_Fixpoints_3D(fixpoints; plt = plot())
	# Fixpontok válogatása stabilitás szerint
	stable_points = [fp.coordinates for fp in fixpoints if fp.stability == "stabil"]
    unstable_points = [fp.coordinates for fp in fixpoints if fp.stability == "instabil"]

	# Adatok újra strukturálása
    function separate_coords(points)
        x = [p[1] for p in points]
        y = [p[2] for p in points]
        z = [p[3] for p in points]
        return x, y, z
    end

	 # Plot: stabil fixpontok, ha vannak
    if length(stable_points) > 0
        x, y, z = separate_coords(stable_points)
        scatter!(plt, x, y, z, label="Stabil fixpontok",mc=:black, ms=4)
    end

	 # Plot: instabil fixpontok, ha vannak
    if length(unstable_points) > 0
        x, y, z = separate_coords(unstable_points)
        scatter!(plt, x, y, z, label="Instabil fixpontok", mc =:white, markerstrokecolor =:black)
    end
    return plt
end

# ╔═╡ 5cf5fc51-6fff-496c-a0a1-87cd09cfb513
begin
	plt_Lorenz_3D =Interaktiv_Lorenz_3D!(parameters,t, start_values, traj)
	plt_Lorenz_3D = Plot_Fixpoints_3D(fixpoints, plt = plt_Lorenz_3D)
	
	plt_Lorenz_2D_XY = Interaktiv_Lorenz_2D!(parameters,t, start_values, traj, 1, 2)
	plt_Lorenz_idosorY = Interaktiv_Lorenz_idosor!(parameters,t, start_values, traj, t_Lorenz, 2)
	
	# plt_Lorenz_2D_XZ = Interaktiv_Lorenz_2D!(parameters,t, start_values, traj, 1, 3)
	# plt_Lorenz_2D_YZ = Interaktiv_Lorenz_2D!(parameters,t, start_values, traj, 2, 3)
	# plt_2D_full = plot(plt_Lorenz_2D_XY,plt_Lorenz_2D_XZ,plt_Lorenz_2D_YZ,layout=(3,1),size=(1500,1400))
	
	# plt_Lorenz_idosorX = Interaktiv_Lorenz_idosor!(parameters,t, start_values, traj, t_Lorenz, 1)
	# plt_Lorenz_idosorZ = Interaktiv_Lorenz_idosor!(parameters,t, start_values, traj, t_Lorenz, 3)
	# plt_Lorenz_idosor_full = plot(plt_Lorenz_idosorX,plt_Lorenz_idosorY,plt_Lorenz_idosorZ,layout=(3,1),size=(1500,1400))


	# ALL_PLOTS = [plt_Lorenz_3D, plt_Lorenz_2D_XY, plt_Lorenz_2D_XZ, plt_Lorenz_2D_YZ, plt_2D_full,plt_Lorenz_idosorX, plt_Lorenz_idosorY, plt_Lorenz_idosorZ, plt_Lorenz_idosor_full]
	MAIN_PLOTS = [plt_Lorenz_3D, plt_Lorenz_2D_XY, plt_Lorenz_idosorY]
end

# ╔═╡ 2bc6efd6-bb7a-4d8f-ba97-cbf2d212a14b
md"""
## Teszteld  itt!

### Logisztikus leképezés
"""

# ╔═╡ eb2fb779-a281-4d1d-b2ba-b8a252e4c830
md"""
Elsőrendű leképezés ábrája:
"""

# ╔═╡ 3f7cd094-4557-49b1-b93b-e1e28145249d
Generate_plot_logistic_growth(x0, r, N)

# ╔═╡ 5df41852-84c3-408b-bed5-ba9e2a73bb64
Parameter_logistic

# ╔═╡ 1d417797-e070-4d49-ad02-24580bd5ee6c
md"""
Magasabbrendű leképezések:
"""

# ╔═╡ b2b76147-9315-4806-b277-243a9006a62c
plt_logistic_higher

# ╔═╡ 7b30e6c3-ea67-4b0f-9e49-a0987354424f
md"""
### Lorenz-rendszer

"""

# ╔═╡ a6dde11c-0810-4802-bcf9-5ef72dc8675e
MAIN_PLOTS[1]

# ╔═╡ 4058c2fd-a091-4bd2-866b-6e0a0acc88b4
Parameter_Lorenz

# ╔═╡ b65f41d6-3ea0-4309-9d4f-78830650623f
MAIN_PLOTS[2]

# ╔═╡ 8e9e2133-ee7f-4019-b46c-487289640a3b
MAIN_PLOTS[3]

# ╔═╡ e4785c91-f023-42e7-81fe-4b48c32f8449
Parameter_Lorenz

# ╔═╡ c2987ef9-980b-494c-9037-654e583eaccd
md"""
#### Két közeli trajektória időfejlődése:

A második trajektória, $$10^{-5}$$ eltéréssel a kezdőfeltételekben:
"""

# ╔═╡ 7b6c38ba-188f-4a97-bfe0-22ebe8e8ecb2
Interaktiv_Lorenz_3D!(parameters,t, start_values, traj2, plt = plt_Lorenz_3D)

# ╔═╡ b208996a-379f-43d3-bf12-ed5081e53a23
Interaktiv_Fazisterbeli_tavolsag!(t, δ, t_Lorenz)

# ╔═╡ f5192570-f8ca-4a60-9985-cfc894c2a26f
Parameter_Lorenz

# ╔═╡ 8b6d0755-ceee-4bb1-899c-5c29a2c42625
begin
	# Idősor kimutatás 2 közeli trajektóriára
	# plt_Lorenz_idosorY = Interaktiv_Lorenz_idosor!(parameters,t, start_values, traj, t_Lorenz, 2)
	
	Interaktiv_Lorenz_idosor!(parameters,t, start_values, traj2, t_Lorenz2, 2, plt = plt_Lorenz_idosorY)
end

# ╔═╡ 06e974f4-5187-428c-a8d0-1986f9def620
# ALL_PLOTS[1]

# ╔═╡ 4eed41dd-3d8c-402b-aacb-f2b3b9ed0911
md"""
## **Források:**

* [Példák interaktív vizualizációra](https://juliadynamics.github.io/DynamicalSystemsDocs.jl/dynamicalsystems/dev/visualizations/)
* [További példák](https://en.wikipedia.org/wiki/Logistic_map#)
* [További példák](https://en.wikipedia.org/wiki/Logistic_map#/media/File:Iterated_logistic_functions.svg)
* A félév során kapott és megoldott házi feladatok
* [Fixpontok stabilitása](https://adipandas.github.io/posts/2021/03/fixed-point-high-dim/)

"""

# ╔═╡ a0086ae9-da2a-4099-9ff0-c5c4fe647d6a
PlutoUI.TableOfContents()

# ╔═╡ Cell order:
# ╠═98bc9155-6830-4ad9-b0e0-fc33f004a974
# ╟─10c96af0-ca9d-4c95-9ce8-51df7393dd14
# ╟─846f1a25-459d-49e6-8d8c-b49f51aae2b7
# ╟─32a75308-ad33-4087-b006-28d5c5d8c507
# ╟─8461fb2f-f0c7-4fb4-8d06-f280ee865407
# ╟─4393ec44-7356-47c1-a2e2-3818dfc83c14
# ╟─fa096dca-83e4-4661-9cd0-27cbc308db69
# ╟─9ea90eb4-c12b-4264-92b3-f3d618673116
# ╟─f1e45742-b72a-408e-9c90-eb49271a2221
# ╟─f0c90e4d-43fe-4ba0-8162-fcbd29eb57b9
# ╟─a0e379fc-d51d-4d0a-8e0a-622bc447ba58
# ╠═3b87b678-58e6-447d-9dda-bf07b6e300ad
# ╟─8d432d24-27ed-4aef-908e-378b29a4be4b
# ╠═2c766bbf-0ce6-4e3a-b01c-baddd155bb51
# ╟─fa79f16c-9a7a-42d1-9393-ac58cccda6ab
# ╠═192748bb-200a-4022-b7bf-99a35bb3b894
# ╟─44963304-56e8-49cc-ac3b-6d31120d2465
# ╠═27ae50e4-9261-4d18-beee-b04c97f0a2c6
# ╠═bfa50eca-c679-49f1-ba5b-835192f79f78
# ╟─6d3813be-5ff8-4dd3-83af-76b9f69b7e6d
# ╟─6411c420-1bbe-4526-8d18-b676bb8fc4d5
# ╟─00b7b5d2-8d1a-4b38-a938-00f6bc6e4839
# ╠═8435cfec-08b6-44d5-85a1-4dde334e198a
# ╟─472a27f3-ac3d-43f9-aaea-92c018966883
# ╠═302c8275-1b26-4985-995b-f9d483bd64e5
# ╠═59b25353-e48e-49a8-bd34-0dc29ea77a7b
# ╟─21ca306f-8484-4b47-9da1-1cbf50b13776
# ╠═06fb138d-37a7-436a-9e80-73f0fd17da88
# ╟─28e694d5-6a9a-4510-ac48-defe928a342b
# ╟─dabee099-a87c-4c34-a548-e0ebd36a49eb
# ╟─abed107d-4ac8-41da-8b42-4255e7c402e1
# ╠═667c7267-df48-47f8-9a7e-2c3477ab5c93
# ╠═980c7b75-8e64-4acc-8344-e37021a65be5
# ╠═18caff36-7c30-4c4e-9fc6-73d93f9c14fb
# ╠═bbeb5576-01c7-4064-be2c-2f4d1df34605
# ╠═b53eea8a-5395-4977-80bf-cbfd5dfe1008
# ╠═b263f579-4675-4c7a-8edf-2c4dd2dfa29d
# ╠═5a575ca6-099e-45fa-bda7-a883a6ca9337
# ╠═5ffb9b97-6603-4158-859d-b08c16c9e04b
# ╟─5c0fb4be-567a-46ea-ba78-5f6df74c6ce3
# ╟─3b603583-e4d7-4b8a-b8ef-0a3e9c5b4c48
# ╠═075c4e44-c835-4030-9714-83549cf37a5b
# ╠═a1ed954d-572a-417e-9ee8-f7f8a58fc25b
# ╠═faecd29c-df6b-436d-b49d-c9f3965d85a6
# ╠═f0881803-0137-42c0-be6f-314a9fd1c8af
# ╠═4ed85e35-c638-4cce-aad4-691369f49155
# ╟─c53f82f0-6c69-45fd-a616-a3e489283b11
# ╟─cbdfa598-8c57-440e-bdb2-66417923af1f
# ╟─ebfbd50a-ceaf-42c3-9185-f068b2f776ba
# ╟─ec6d916f-cac7-40da-9db7-19f84f8ac786
# ╟─d9816d99-519b-4fed-bfe5-5c788a246c63
# ╠═17424958-8243-4bd5-94eb-142dbdfb80a9
# ╟─543c7f0a-26c0-47f2-bceb-c919158c36b7
# ╟─9e5a94d1-8292-4de6-8ac8-cd4c1d7c2e69
# ╟─c32e218b-a8c7-4d13-946f-ddbfb1e091e1
# ╟─3bcb488b-889e-465b-bbe7-7de0e28109ce
# ╟─0f0d7230-48cc-4e2c-b40b-31a1c9aebd39
# ╟─4e4bc229-e07b-4bc2-a7df-5ac2505e9ee3
# ╟─a9181f6e-7b7f-4ab0-a5be-72e3fd528eca
# ╟─90e05b4f-44fc-4f3b-9e46-efa0f50c56a7
# ╟─88cbd45a-29a9-4415-bca2-31d98f8168d0
# ╠═d7287b1b-2641-489e-a59b-095c196b9cb8
# ╟─289a57a7-9662-4b9b-84dc-0afe5f42211c
# ╠═5cf5fc51-6fff-496c-a0a1-87cd09cfb513
# ╟─2bc6efd6-bb7a-4d8f-ba97-cbf2d212a14b
# ╟─eb2fb779-a281-4d1d-b2ba-b8a252e4c830
# ╠═3f7cd094-4557-49b1-b93b-e1e28145249d
# ╟─5df41852-84c3-408b-bed5-ba9e2a73bb64
# ╟─1d417797-e070-4d49-ad02-24580bd5ee6c
# ╠═b2b76147-9315-4806-b277-243a9006a62c
# ╟─7b30e6c3-ea67-4b0f-9e49-a0987354424f
# ╠═a6dde11c-0810-4802-bcf9-5ef72dc8675e
# ╠═4058c2fd-a091-4bd2-866b-6e0a0acc88b4
# ╠═b65f41d6-3ea0-4309-9d4f-78830650623f
# ╠═8e9e2133-ee7f-4019-b46c-487289640a3b
# ╠═e4785c91-f023-42e7-81fe-4b48c32f8449
# ╟─c2987ef9-980b-494c-9037-654e583eaccd
# ╠═7b6c38ba-188f-4a97-bfe0-22ebe8e8ecb2
# ╟─b208996a-379f-43d3-bf12-ed5081e53a23
# ╟─f5192570-f8ca-4a60-9985-cfc894c2a26f
# ╠═8b6d0755-ceee-4bb1-899c-5c29a2c42625
# ╠═06e974f4-5187-428c-a8d0-1986f9def620
# ╟─4eed41dd-3d8c-402b-aacb-f2b3b9ed0911
# ╟─a0086ae9-da2a-4099-9ff0-c5c4fe647d6a
