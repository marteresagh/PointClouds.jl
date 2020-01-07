using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using ViewerGL
GL= ViewerGL
using PointClouds
using DataStructures
include("./viewfunction.jl")
fname = "examples/PointCloud/pointCloud/CUPOLA/r.las"
fname = "examples/fit/CASALETTO/r.las"
Vtot,VV,rgb = PointClouds.loadlas(fname)
V,VV = Lar.apply(Lar.t(-min(Vtot[1,:]...),-min(Vtot[2,:]...),-min(Vtot[3,:]...)),[Vtot,VV])
GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);


p = 1
W,(FW,CW) = PointClouds.voxel(V,p,1)



GL.VIEW(
	[
		 GL.GLLar2gl(W,CW)
	]
);
