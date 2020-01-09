using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using ViewerGL
GL= ViewerGL
using PointClouds

include("./viewfunction.jl")
#fname = "examples/PointCloud/pointCloud/CUPOLA/r.las"
fname = "examples/fit/CASALETTO/r.las"
Vtot,VV,rgb = PointClouds.loadlas(fname)
_,V = PointClouds.subtractaverage(Vtot)
GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);

#0.2 0.4 2.
p = 0.4 #spacing cupola 0.4, spacing casaletto 0.27404680848121645,
W,FW,CW = PointClouds.voxel(V,p,0)

GL.VIEW(
	[
		#GL.GLGrid(W,FW,GL.COLORS[2],0.8)
		GL.GLLar2gl(W,CW)
	]
)
