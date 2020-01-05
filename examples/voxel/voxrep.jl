using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using ViewerGL
GL= ViewerGL
using Tesi
using DataStructures
include("./viewfunction.jl")
fname = "examples/PointCloud/pointCloud/CAVA/r.las"
fname = "examples/fit/CASALETTO/r.las"
Vtot,VV,rgb = Tesi.loadlas(fname)
V,VV = Lar.apply(Lar.t(-min(Vtot[1,:]...),-min(Vtot[2,:]...),-min(Vtot[3,:]...)),[Vtot,VV])
GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);


p = 8
W,(FW,CW) = Tesi.voxel(V,p,1)



GL.VIEW(
	[
		 GL.GLLar2gl(W,CW)
	]
);
