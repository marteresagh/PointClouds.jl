using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using ViewerGL
GL= ViewerGL
using PointClouds

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


p = 1.2  #spacing cupola 0.4
W,FW,CW = PointClouds.voxel(V,p,2)

GL.VIEW(
	[
		# GL.GLGrid(W,FW,GL.COLORS[1],0.8)
		GL.GLLar2gl(W,CW)
	]
)
