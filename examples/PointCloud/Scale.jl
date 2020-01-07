using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
include("./viewfunction.jl")

fname = "examples/PointCloud/pointCloud/SCALE/r.las"
Vtot,VV,rgb = PointClouds.loadlas(fname)
V,VV = Lar.apply(Lar.t(-min(Vtot[1,:]...),-min(Vtot[2,:]...),-min(Vtot[3,:]...)),[Vtot,VV])
#DT = AlphaStructures.delaunayTriangulation(V);

GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);


include("./pointCloud/SCALE/VS.jl")
include("./pointCloud/SCALE/DT.jl")
#=
#Equivalent to =>
V = AlphaStructures.matrixPerturbation(V);
DT = AlphaStructures.delaunayTriangulation(V);
=#

filtration = AlphaStructures.alphaFilter(V, DT);

α = 0.0467882
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α);

GL.VIEW(
	[
		#colorview(V,TV,rgb);
		colorview(V,FV,rgb)
	]
);


#=

open("z.txt", "w") do f
	n=size(V,2)
	write(f, "$n \n")
	for i in 1:n
		x=V[1,i]
		y=V[2,i]
		z=V[3,i]
		write(f, "$z \n")
	end
end
=#


# using Distributed
# addprocs(8)
#
# @everywhere using Pkg
# @everywhere Pkg.activate("./AlphaStructures")
#
# @everywhere using  AlphaStructures
#
# DT = AlphaStructures.delaunayTriangulation(V);
