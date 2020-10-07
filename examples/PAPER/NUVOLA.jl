using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds
using NearestNeighbors
NN = NearestNeighbors
include("../viewfunction.jl")

## input data
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\MERGE"
allfile = PointClouds.filelevel(fname,1)
_,_,_,AABB,tightBB,_,_,spacing = PointClouds.readcloudJSON(fname)
V,VV,rgb = PointClouds.loadlas(allfile...)
trasl,Vtrasl = PointClouds.subtractaverage(V)

GL.VIEW(
	[
		viewRGB(Vtrasl, VV, rgb)
		GL.GLAxis(GL.Point3d(0,0,0), GL.Point3d(1,1,1))
	]
);

PLANES = PointClouds.RandomPlanesDetection(Vtrasl, 3, 0.2, spacing,200)
Vplane,FVplane = PointClouds.DrawPlanes(PLANES,nothing,0.5)
GL.VIEW(
	[
		viewRGB(Vtrasl,VV,rgb)
		GL.GLGrid(Vplane,FVplane,GL.COLORS[2])
	]
);
plane = PointClouds.PlaneDetectionFromRandomInitPoint(V,0.02,2*spacing)
