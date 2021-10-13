### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ f11f0ca8-2bbc-11ec-11bf-9175ed16155b
using Markdown

# ╔═╡ f0bb9793-555a-4878-bcfa-138875020a1a
### A Pluto.jl notebook ###
# v0.14.7


using InteractiveUtils

# ╔═╡ 9b12e757-ebc2-41a4-8a45-858d8d0c84fe
using Plots

# ╔═╡ 7573e657-8866-487b-bd09-42b75a5e3f0b
using GraphRecipes

# ╔═╡ 9462f4e8-61d7-4b25-96f7-6c19f70f1916
# edit the code below to set your name and Cornell ID (i.e. email without @cornell.edu)

student = (name = "Adam Kulaczkowski, Ada Lian, Noah Klausner", cornell_id = "apk73, al894,nmk45")

# ╔═╡ a8f109e4-af02-4f3d-9f16-0cb223320dba
md"""
# Assignment 3

In this group assignment you will create a tutorial notebook to explain the branch and bound solution for the following integer LP. 

```math
\begin{alignat*}{2}
& &\max Z = 4x_1 - x_2 & \\
& & 7x_1 - 2x_2 \leq 14\\
& & x_2 \leq 3 \\
& & 2x_1 - 2x_2 \leq 3\\
& & x_i \in integer, \forall i\\
\end{alignat*}
```
"""

# ╔═╡ 58c63842-f4c4-454f-a191-7fdd6d52ce86
md"""
## Instructions:
1. This is a group assignment. You can form a group with up to 3 members. 
2. The tutorial should show clear contribution from all members of your team.
3. The tutorial should be informative of the branch and bound algorithm. You should use figures, tables or any other method that will help you to improve the accessibility of the tutorial. The grades will be given for correctness, clarity, delivery and engagement.
4. The julia notebook should be submitted to Gradescope as a group assignment. 
"""

# ╔═╡ 1a382ed3-eeb3-49d7-9cdd-c012b0b0604a
md"""
**Understanding the Feasible Space**  \
In order to understand the bounded space of the branch and bound solution, the constraints were rearranged in terms of ``X_2``. This causes the constraints to take the form of a y = mx + b form, which can then be plotted in Julia and filled with their respective inequality boundaries.
"""

# ╔═╡ 77454f6d-6ff6-4903-8da8-2fec4055077e
begin
	f(x) = (7/2)*x-7
	g(x) = 3
	h(x) = x-(3/2)
	X = -1:6
	ffill = max(f(X[end]), g(X[1]))
	gfill = min(f(X[1]), g(X[end]))
	hfill = max(f(X[1]), f(X[end]))
	plot(X,f,fill = (ffill,0.5,:red), label = "x2>=(7/2)x1-7", legend=:outertopright)
	plot!(X,g,fill = (gfill,0.5,:blue), label = "x2<=3")
	plot!(X,h,fill = (hfill,0.5,:green),label = "x2>=x1-(3/2)")
	xlabel!("x1")
	ylabel!("x2")
end

# ╔═╡ b537f629-d88c-472b-b1c5-94900b03a66d
md"""
##### Integer solutions in the feasible space
"""

# ╔═╡ 508661bd-4155-467f-b2b2-dc94070097f0
md"""
From here, knowing we are dealing with only integer solutions for ``X_1`` and ``X_2``, integer solutions within the feasible region can be identified and displayed below.  \
  \
*Important Note*  \
It is important to note that in this graph, it is showing that ``X_1`` cannot be negative. This problem has no non-negativity constraints, therefore ``X_1`` and ``X_2`` could potentially have feasible solutions that extend infinitely in the negative axis. For now, the branch and bound solution will only consider the space shown below, and the solution obtained will illuminate why we did not consider space very far to the left of the ``X_2`` axis.
"""

# ╔═╡ b2cf4c45-67d4-465b-a6d4-d3d55d403fe0
begin 
	a = [2,2,2,1,1,1,1,0,0,0,0,0,-1,-1,-1,-1,-1,-1]
	b = [3,2,1,3,2,1,0,3,2,1,0,-1,3,2,1,0,-1,-2,-3]
	opta = Any[2.8]
	optb = Any[3]
	scatter!(a,b, color=:blue,label = "Feasible Integer Solutions")
	scatter!(opta,optb,color=:red,label = "Opt LP Soln") 
end

# ╔═╡ 9e7ece3e-7929-4618-b51d-e0d7a65819e3
md"""
##### First branch 
###### Add additional constraint to ``X_1``
"""

# ╔═╡ 99ffa972-6edc-4475-b5a8-497304ead01c
md"""
Since this is a maximization function, the Opt LP Soln at ``(2.8,3)`` with ``Z = 8.42`` will always be the upper bound to the objective integer problem. Therefore, constraints are added to ``X_1``, that bound it to integers around the previous found solution, in this case that ``X_1`` can be branched to be ``<= 2`` or ``>= 3``.
"""

# ╔═╡ 24da5f7f-844a-4d4a-b8f7-858e564a8558
begin
	A = [0 0 0 0 ;
		 0 0 1 1 ;
		 0 0 0 0 ;
		 0 0 0 0 ]
	
	names = ["(2.8,3) Z=8.42","1","2","3"]
 	xpos = [-.5, 0, -.5, .5]
	ypos = [.5, .5, 0, 0]
	shapes = [:rect,:circle,:circle,:circle]
	node_color = [:lightblue,:lightblue,:lightblue,:lightblue]
	node_size = Any[.5,.5,1,1]
	edgelabel = Dict()
	edgelabel[2,3] = "X1<=2"
	edgelabel[2,4] = "X1>=3"
end;

# ╔═╡ cd711107-41cf-4736-9c59-a9cdf8a8a8a9
graphplot(A, names=names, edge_label = edgelabel, nodeshape=shapes, nodesize=.15,nodecolor=node_color,curves=false, x=xpos, y=ypos)

# ╔═╡ c2e80be6-b90b-418f-a2d7-097bff2cb6b7
begin 
	c(x) = (7/2)*x-7
	d(x) = 3
	e(x) = x-(3/2)
	Y = -1:6
	#plot(Y,c,fill = (cfill,0.5,:red),label = "x2>=(7/2)x1-7", legend = :outertopright )
	plot(Y,c,label = "x2>=(7/2)x1-7", legend = :outertopright)
	#plot!(Y,d,fill = (dfill,0.5,:blue), label = "x2<=3")
	plot!(Y,d,label = "x2<=3")
	#plot!(Y,e,fill = (efill,0.5,:green),label = "x2>=x1-(3/2)")
	plot!(Y,e,label = "x2>=x1-(3/2)")
	xlabel!("x1")
	ylabel!("x2")
	
	plot!(Y,[-1,2],seriestype="vspan",label="x1 <= 2",alpha = 0.25, c=:orange)
	plot!(Y,[3,6],seriestype="vspan",label="x1 >= 3",alpha = 0.25, c=:yellow)
	a1 = [2,2,2,1,1,1,1,0,0,0,0,0,-1,-1,-1,-1,-1,-1]
	b1 = [3,2,1,3,2,1,0,3,2,1,0,-1,3,2,1,0,-1,-2,-3]
	scatter!(a1,b1, color=:blue,label = "Feasible Integer Solutions")
end

# ╔═╡ 3489354f-bc7d-41e0-9745-3a0253e5ea27
md"""
As indicated by the fact that the relaxed LP solution will the the maximum of the objective integer problem, the constraint ``X_1 \geq 3`` is infeasible (node 3). Additionally, all blue dots present indicate feasible integer solutions that have not yet been eliminated with constraints.
"""

# ╔═╡ 353afcd7-3dcf-4472-8ebc-85fe189bb43b
md"""
###### Additional constraints to ``X_2``
"""

# ╔═╡ 4ad501c6-d629-47ab-ad96-f396ce500117
md"""
Z reaches a maximum value of 7.5 from the previous branch at the point ``(2,0.5)`` (node 2). Note this is not a viable integer solution due to the ``X_2`` value. Therefore, ``X_2`` needs to be further branched into constraints that make it ``<= 0`` or ``>= 1``.
"""

# ╔═╡ ff06506b-6729-456e-9c03-5e0e917325bb
begin
	
		C = [0 1 1 0 0 0 0 0;
			 0 0 0 1 1 0 0 0;
			 0 0 1 0 0 0 0 0;
			 0 0 0 1 0 0 0 0;
			 0 0 0 0 0 0 0 0;
			 0 0 0 0 0 1 0 0;
	   	 	 0 0 0 0 0 0 1 0 
			 0 0 0 0 0 0 0 1]
		
		names2 = ["1","2","3","4","5","(2.8,3) Z=8.42","(2,0.5) Z=7.5","Infeasible"]
		shapes2=[:circle,:circle,:circle,:circle,:circle,:rect,:rect,:rect]
		node_color2 = [:lightblue,:lightblue,:lightblue,:lightblue,:lightblue,:lightblue,:lightblue,:lightblue]
	 	xpos2 = [0, -1, 1, -2,-0.25, -1.2,-2, 1.75]
		ypos2 = [1, 0, 0, -1,-1,1,0,0]
		#nsize = [1,1,1,1,1,1,2]
		edgelabel2 = Dict()
		edgelabel2[1,2] = "X1<=2"
		edgelabel2[1,3] = "X1>=3"
		edgelabel2[2,4] = "X2<=0"
		edgelabel2[2,5] = "X2>=1"
end;

# ╔═╡ b6245b7f-646d-4d50-9fef-e84ec80c0b3a
graphplot(C, names=names2, nodeshape=shapes2, nodesize = 0.5, edge_label = edgelabel2,nodecolor=node_color2,curves=false, x=xpos2, y=ypos2)

# ╔═╡ 9bdc0d9a-da89-4e0f-9bb8-77e58b46a2d6
begin
	i(x) = (7/2)*x-7
	j(x) = 3
	k(x) = x-(3/2)
	W = -1:6
	
	plot(W,i,label = "x2>=(7/2)x1-7",xlims=(-1,3),ylims=(-10,10),legend=:outertopright)
	plot!(W,j,label = "x2<=3")
	plot!(W,k,label = "x2>=x1-(3/2)")
	
	xlabel!("x1")
	ylabel!("x2")
	l(x) = 0
	m(x) = 1
	lfill = min(f(W[1]), g(W[end]))
	mfill = max(f(W[1]), f(W[end]))
	plot!(W,l,fill = (lfill,0.25,:yellow), label="x2 <= 0")
	plot!(W,m,fill = (mfill,0.25,:purple), label="x2 >= 1")
	
	a2 = [2,2,1,1,1,1,0,0,0,0,0,-1,-1,-1,-1,-1,-1]
	b2 = [3,2,3,2,1,0,3,2,1,0,-1,3,2,1,0,-1,-2,-3]
	incumba = Any[2]
	incumbb = Any[1]
	scatter!(a2,b2, color=:blue, label = "Feasible Integer Solutions")
	scatter!(incumba,incumbb,color=:red,label = "Incumbant Solution")
end

# ╔═╡ d1e712be-9d2d-4757-a8ed-91f81b3f5189
md"""
From this next branch, we find the incumbant solution of ``Z = 7`` at ``(2,1)`` at node 5. Likewise, node 4 has a maximum of ``Z = 6`` at ``(1.5,0)`` but since it is not an integer solution it needs to be further branched on ``X_1``.
"""

# ╔═╡ b46bb825-0b3c-4562-9a58-f379239c8428
md"""
###### Additional constraints to ``X_1``
"""

# ╔═╡ af41a43a-7fa0-453e-b510-924855d4744f
begin
	
		D = [0 1 1 0 0 0 0 0 0 0 0 0;
			 0 0 0 1 1 0 0 0 0 0 0 0;
			 0 0 0 0 0 0 0 0 0 0 0 0;
			 0 0 0 0 0 1 1 0 0 0 0 0;
			 0 0 0 0 0 0 0 0 0 0 0 0;
			 0 0 0 0 0 0 0 0 0 0 0 0;
	   	 	 0 0 0 0 0 0 0 0 0 0 0 0;
		     0 0 0 0 0 0 0 0 0 0 0 0;
			 0 0 0 0 0 0 0 0 0 0 0 0;
	         0 0 0 0 0 0 0 0 0 0 0 0;
			 0 0 0 0 0 0 0 0 0 0 0 0;
			 0 0 0 0 0 0 0 0 0 0 0 1]
		
		names3 = ["1","2","3","4","5","6","7","(2.8,3) Z=8.42","(2,0.5) Z=7.5","Infeasible","(1.5,0) Z=6","(2,1) Z=7"]
		shapes3=[:circle,:circle,:circle,:circle,:circle,:circle,:circle,:rect,:rect,:rect,:rect,:rect]
		node_color3 = [:lightblue,:lightblue,:lightblue,:lightblue,:lightblue,:lightblue,:lightblue,:lightblue,:lightblue,:lightblue,:lightblue,:lightblue]
	 	xpos3 = [0, -1, 1, -2,-0.25,-2.75,-1.25,-1.2,-2, 1.75,-2.75, 0.75]
		ypos3 = [1, 0, 0, -1,-1,-2,-2,1,0,0,-1,-1]
		#nsize = [1,1,1,1,1,1,2]
	    edgelabel3 = Dict()
	    edgelabel3[1,2] = "X1<=2"
		edgelabel3[1,3] = "X1>=3"
		edgelabel3[2,4] = "X2<=0"
		edgelabel3[2,5] = "X2>=1"
	    edgelabel3[4,6] = "X1<=1"
	    edgelabel3[4,7] = "X1>=2"
	    
end;

# ╔═╡ a5652d73-2f82-4def-8ce2-4477e2f4866f
graphplot(D, names=names3, nodeshape=shapes3, nodesize = 0.5, edge_label = edgelabel3,nodecolor=node_color3,curves=false, x=xpos3, y=ypos3)

# ╔═╡ 3fa64b44-8da9-4ee3-9257-9eca039331ec
begin
	n(x) = (7/2)*x-7
	o(x) = 3
	p(x) = x-(3/2)
	Z = -1:6
	
	plot(Z,n,label = "x2>=(7/2)x1-7",xlims=(-1,3),ylims=(-10,10),legend=:outertopright)
	plot!(Z,o,label = "x2<=3")
	plot!(Z,p,label = "x2>=x1-(3/2)")
	plot!(Z,[-1,1],seriestype="vspan",label="x1 <= 1",alpha = 0.25, c=:teal)
	plot!(Z,[2,6],seriestype="vspan",label="x1 >= 2",alpha = 0.25, c=:orchid)
	
	q(x) = 0 
	qfill = min(f(Z[1]), g(Z[end]))
	plot!(Z,q,fill = (qfill,0.25,:yellow),label="x2 <= 0")
	
	a3 = [-1,0,1,-1,0,-1]
	b3 = [0,0,0,-1,-1,-2]
	scatter!(a3,b3, color=:blue, label = "Feasible Integer Solutions")
	scatter!(incumba,incumbb,color=:red,label = "Incumbant Solution")
end

# ╔═╡ 9c2a9f24-acea-407b-9154-4723942bd4f3
md"""
``X_1 \geq 2`` has no feasible solutions. 

The largest solution for the ``x_1 \leq 1`` is at ``(0,-3/2)`` with the Z value of ``3/2``. Since this value is less than the incumbant solution, it is dominated and we keep the previously found solution of ``Z = 7`` at ``(2,1)`` as the Optimal Solution to the Integer LP using the branch and bound method.
"""

# ╔═╡ 11122d74-dd1d-445d-b248-d088b81002a1
md"""
## Contribution
Please use this space to document the contribution of each group member.
"""

# ╔═╡ c28bc156-f001-4c3d-b28f-0e67822c7bb6
md"""
Adam Kulaczkowski: Made graph depicting the feasible space and dots depicting feasible integer solutions with appropriate labeling. Added all comments elaborating on steps to achieve the solution to the Integer LP.  \
Ada Lian: Created all tree diagrams with labels, correct arrows, and boxes with Z values at given points. Created graphs showing feasible space with shaded constraint regions.  \
Noah Klausner: Laid out framework for solving the integer LP, including working out the branch and bound steps on paper with the Z values obtained. Added lines in notebook where infeasible regions were located along with the optimal integer LP value.
"""

# ╔═╡ 1cf569b4-6419-49f3-b2c6-107e21943a4e
md"""
## Citations

If you used any external resource in the process of solving this problem, provide a reference below. These could be other people, websites, datasets, or code examples.
"""

# ╔═╡ 9bb9dc3c-5b99-4a40-8d1b-b1e4768c0eb7
md"""
BEE 4750 Lecture 10 Slides  \
GitHub - JuliaPlots: https://github.com/JuliaPlots/GraphRecipes.jl  \
JuliaPlots - Examples-Plots: http://docs.juliaplots.org/latest/graphrecipes/examples/#graph_examples
"""

# ╔═╡ Cell order:
# ╠═f11f0ca8-2bbc-11ec-11bf-9175ed16155b
# ╠═f0bb9793-555a-4878-bcfa-138875020a1a
# ╠═9b12e757-ebc2-41a4-8a45-858d8d0c84fe
# ╠═7573e657-8866-487b-bd09-42b75a5e3f0b
# ╟─9462f4e8-61d7-4b25-96f7-6c19f70f1916
# ╟─a8f109e4-af02-4f3d-9f16-0cb223320dba
# ╟─58c63842-f4c4-454f-a191-7fdd6d52ce86
# ╟─1a382ed3-eeb3-49d7-9cdd-c012b0b0604a
# ╟─77454f6d-6ff6-4903-8da8-2fec4055077e
# ╟─b537f629-d88c-472b-b1c5-94900b03a66d
# ╟─508661bd-4155-467f-b2b2-dc94070097f0
# ╟─b2cf4c45-67d4-465b-a6d4-d3d55d403fe0
# ╟─9e7ece3e-7929-4618-b51d-e0d7a65819e3
# ╟─99ffa972-6edc-4475-b5a8-497304ead01c
# ╟─24da5f7f-844a-4d4a-b8f7-858e564a8558
# ╟─cd711107-41cf-4736-9c59-a9cdf8a8a8a9
# ╟─c2e80be6-b90b-418f-a2d7-097bff2cb6b7
# ╟─3489354f-bc7d-41e0-9745-3a0253e5ea27
# ╟─353afcd7-3dcf-4472-8ebc-85fe189bb43b
# ╟─4ad501c6-d629-47ab-ad96-f396ce500117
# ╟─ff06506b-6729-456e-9c03-5e0e917325bb
# ╟─b6245b7f-646d-4d50-9fef-e84ec80c0b3a
# ╟─9bdc0d9a-da89-4e0f-9bb8-77e58b46a2d6
# ╟─d1e712be-9d2d-4757-a8ed-91f81b3f5189
# ╟─b46bb825-0b3c-4562-9a58-f379239c8428
# ╟─af41a43a-7fa0-453e-b510-924855d4744f
# ╟─a5652d73-2f82-4def-8ce2-4477e2f4866f
# ╟─3fa64b44-8da9-4ee3-9257-9eca039331ec
# ╟─9c2a9f24-acea-407b-9154-4723942bd4f3
# ╟─11122d74-dd1d-445d-b248-d088b81002a1
# ╟─c28bc156-f001-4c3d-b28f-0e67822c7bb6
# ╟─1cf569b4-6419-49f3-b2c6-107e21943a4e
# ╟─9bb9dc3c-5b99-4a40-8d1b-b1e4768c0eb7
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
