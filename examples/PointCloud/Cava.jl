using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds

include("../viewfunction.jl")

#
# using Distributed
# addprocs(8)
#
# @everywhere using Pkg
# @everywhere Pkg.activate("./AlphaStructures")
#
# @everywhere using  AlphaStructures
# include("examples/PointCloud/pointCloud/CAVA/VS.jl")
# DT = AlphaStructures.delaunayTriangulation(V);
#
#
#

fname = "examples/PointCloud/pointCloud/CAVA/r.las"
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CAVA"
allfile = PointClouds.filelevel(fname,3)
_,_,_,_,_,spacing = PointClouds.readJSON(fname)

Vtot,VV,rgb = PointClouds.loadlas(allfile...)
_,V = PointClouds.subtractaverage(Vtot)
GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);

# include("./pointCloud/CAVA/VS.jl")
# include("./pointCloud/CAVA/DT.jl")
#DT = AlphaStructures.delaunayTriangulation(V);
#=
#Equivalent to =>
V = AlphaStructures.matrixPerturbation(V);
DT = AlphaStructures.delaunayTriangulation(V);
=#
DT = PointClouds.mat3DT(V)

filtration = AlphaStructures.alphaFilter(V, DT);

α = 0.8
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α)

GL.VIEW(
	[
		colorview(V,EV,rgb);
		#AlphaStructures.colorview(V,TV,rgb)
	]
);
