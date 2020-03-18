using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL=ViewerGL
include("../viewfunction.jl")

# from this repository
fname = "examples/AlphaShapes/pointCloud/CAVA/r.las"
# fname = "examples/AlphaShapes/pointCloud/CUPOLA/r.las"
# fname = "examples/AlphaShapes/pointCloud/SCALE/r.las"

Voriginal,VV,rgb = PointClouds.loadlas(fname)
_,V = PointClouds.subtractaverage(Voriginal)


GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);

DT = PointClouds.delaunayMATLAB(V)
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
